use crate::interpreter::deployer::{deploy_expression, get_sip_addresses};
use crate::interpreter::registry::IInterpreterV2;
use crate::interpreter::rust_evm::{commit_transaction, write_account_info};
use ethers::{
    abi::{ParamType, Token},
    providers::{Http, Provider},
    types::H160,
};
use revm::primitives::Address;
use revm::{
    db::{CacheDB, EmptyDB},
    primitives::{ExecutionResult, Output},
    EVM,
};
use std::str::FromStr;
use std::sync::Arc;

pub mod deployer;
pub mod registry;
pub mod rust_evm;

pub async fn compute_eval2(
    raininterpreter_deployer_npe2_address: Address,
    rainlang_expression: String,
    client: Provider<Http>,
) -> anyhow::Result<()> {
    let arc_client: Arc<Provider<Http>> = Arc::new(client.clone());
    let (store, interpreter, parser) =
        get_sip_addresses(raininterpreter_deployer_npe2_address, client.clone()).await?;

    // initialise empty in-memory-db
    let mut cache_db: CacheDB<revm::db::EmptyDBTyped<std::convert::Infallible>> =
        CacheDB::new(EmptyDB::default());

    let _ = write_account_info(
        &mut cache_db,
        raininterpreter_deployer_npe2_address,
        arc_client.clone(),
    )
    .await;
    let _ = write_account_info(&mut cache_db, store, arc_client.clone()).await;
    let _ = write_account_info(&mut cache_db, interpreter, arc_client.clone()).await;
    let _ = write_account_info(&mut cache_db, parser, arc_client.clone()).await;

    // initialise an empty (default) EVM
    let mut evm: EVM<CacheDB<revm::db::EmptyDBTyped<std::convert::Infallible>>> = EVM::new();

    // insert pre-built database from above
    evm.database(cache_db);

    let expression_address = deploy_expression(
        raininterpreter_deployer_npe2_address,
        parser,
        rainlang_expression,
        &mut evm,
        arc_client.clone(),
    )
    .await?;

    println!("expression_address : {:#?}", expression_address);

    let encode_dispatch = ethers::types::U256::from_dec_str(
        "4501898752799015415754650127604722314397366187185745756159",
    )
    .unwrap();
    let statenamespace = ethers::types::U256::from_dec_str("0").unwrap();

    let context: Vec<Vec<ethers::types::U256>> = vec![];

    let inputs: Vec<ethers::types::U256> =
        vec![ethers::types::U256::from_dec_str("123456").unwrap()];

    let (stack, kvs) = eval_expression(
        store,
        encode_dispatch,
        statenamespace,
        context,
        inputs,
        interpreter,
        &mut evm,
        arc_client.clone(),
    )
    .await?;

    println!("stack : {:#?}", stack);
    println!("kvs : {:#?}", kvs);

    Ok(())
}

pub async fn eval_expression(
    store: Address,
    encode_dispatch: ethers::types::U256,
    statenamespace: ethers::types::U256,
    context: Vec<Vec<ethers::types::U256>>,
    inputs: Vec<ethers::types::U256>,
    interpreter: Address,
    evm: &mut EVM<CacheDB<revm::db::EmptyDBTyped<std::convert::Infallible>>>,
    client: Arc<Provider<Http>>,
) -> anyhow::Result<(Vec<ethers::types::U256>, Vec<ethers::types::U256>)> {
    let rain_interpreter =
        IInterpreterV2::new(H160::from_str(&interpreter.to_string())?, client.clone());

    let eval_tx = rain_interpreter.eval_2(
        H160::from_str(&store.to_string())?,
        statenamespace,
        encode_dispatch,
        context,
        inputs,
    );
    let eval_tx_bytes = eval_tx.calldata().unwrap();

    let result = commit_transaction(interpreter, eval_tx_bytes, evm).await?;

    // unpack output call enum into raw bytes
    let value = match result {
        ExecutionResult::Success {
            output: Output::Call(value),
            ..
        } => value,
        result => panic!("Execution failed: {result:?}"),
    };

    let decoded_data = ethers::abi::decode(
        &[
            ParamType::Array(Box::new(ParamType::Uint(256))),
            ParamType::Array(Box::new(ParamType::Uint(256))),
        ],
        &value,
    )
    .unwrap();

    let mut resolved_stack: Vec<ethers::types::U256> = vec![];
    let mut resolved_kvs: Vec<ethers::types::U256> = vec![];

    match &decoded_data[0] {
        Token::Array(stack) => {
            for e in stack {
                match e {
                    Token::Uint(value) => {
                        resolved_stack.push(*value);
                    }
                    _ => {}
                }
            }
        }
        _ => panic!("EVAL FAILED"),
    };

    match &decoded_data[1] {
        Token::Array(kvs) => {
            for e in kvs {
                match e {
                    Token::Uint(value) => {
                        resolved_kvs.push(*value);
                    }
                    _ => {}
                }
            }
        }
        _ => panic!("EVAL FAILED"),
    };

    Ok((resolved_stack, resolved_kvs))
}
