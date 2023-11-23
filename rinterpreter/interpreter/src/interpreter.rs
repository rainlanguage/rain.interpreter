use ethers::{
    abi::{ParamType, Token},
    providers::{Http, Provider, Middleware},
    types::H160,
};
use revm::primitives::{Address, U256};
use revm::{
    db::{CacheDB, EmptyDB},
    primitives::{ExecutionResult, Output},
    EVM,
};
use std::str::FromStr;
use std::sync::Arc;

use crate::{deployer::{get_sip_addresses, deploy_expression}, rust_evm::{write_account_info, exec_transaction}, registry::IInterpreterV2};

/// # Deploy Expression and Eval2
/// 
/// Function to deploy and eval2 rainlang expression.
/// The function fetchs the current on chain state of the `RainterpreterExpressionDeployerNPE2` contract passed as an argument  
/// and saves the contract account info to the in-memory db, along with `RainterpreterNPE2`, `RainterpreterParserNPE2` and `RainterpreterStoreNPE2`
/// contracts associated with it. This is a crucial step which needs to happen before any expression is evaluated. The function then parses and deploys
/// the expression and the result is committed to the db. Finally eval2 is called on the expression and resultant stack and key-values are returned.
/// Optionally one can save the key-value pairs generated to the in memory db.
/// 
/// # Arguments
/// * `raininterpreter_deployer_npe2_address` - `RainterpreterExpressionDeployerNPE2` contract address.
/// * `rainlang_expression` - Rainlang Expression to eval2.
/// * `source_index` - Index of source.
/// * `inputs` - Inputs to expression.
/// * `client` - Provider Instance.
/// 
/// # Example 
/// 
/// ```
/// use ethers::providers::{Http, Provider};
/// use rain_interpreter::interpreter::deploy_and_eval2;
/// use revm::primitives::address;
/// 
/// async fn deploy_eval2() { 
/// 
///     // RPC URL of the network
///     let rpc_url = String::from("https://polygon.llamarpc.com");
///     let client = Provider::<Http>::try_from(rpc_url)?; 
///  
///     // Address of RainterpreterExpressionDeployerNPE2
///     let deployer_npe2 = address!("1b21dfA0107920F23D27a5891dEd65101302314D");
/// 
///     // Expression to eval2
///     let rainlang_expression = String::from("val1: ,val2: ,sum: int-add(val1 val2);");
///  
///     // Index of source
///     let source_index = ethers::types::U256::from(0);
///     // Inputs to eval2
///     let inputs:Vec<ethers::types::U256> = vec![
///         ethers::types::U256::from(3),
///         ethers::types::U256::from(6)
///     ]; 
///     // Deploy and Eval Expression
///     let (stack,kvs) = deploy_and_eval2(
///         deployer_npe2,
///         rainlang_expression,
///         source_index,
///         inputs,
///         client
///     ).await?; 
/// 
///     // Log stack and kvs
///     println!("stack: {:#?}",stack);
///     println!("kvs: {:#?}",kvs);
/// }
///
pub async fn deploy_and_eval2(
    raininterpreter_deployer_npe2_address: Address,
    rainlang_expression: String,
    source_index: ethers::types::U256,
    inputs: Vec<ethers::types::U256>,
    client: Provider<Http>,
) -> anyhow::Result<(Vec<ethers::types::U256>, Vec<ethers::types::U256>)> {

    let arc_client: Arc<Provider<Http>> = Arc::new(client.clone());
 
    let recent_block = client.get_block_number().await?;
    let block_timestamp = client.get_block(recent_block).await?.unwrap().timestamp.as_u128() ; 

    let (store, interpreter, parser) =
        get_sip_addresses(raininterpreter_deployer_npe2_address, arc_client.clone()).await?;

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

    let expression_uint = ethers::types::U256::from(expression_address.as_slice()) << 32;
    let max_output = ethers::types::U256::from(65535);
    let encode_dispatch = expression_uint | (source_index << 10) | max_output;

    let statenamespace = ethers::types::U256::from_dec_str("0").unwrap();

    let context: Vec<Vec<ethers::types::U256>> = vec![]; 

    evm.env.block.timestamp = U256::from(block_timestamp);

    let (stack, kvs) = eval2_expression(
        store,
        encode_dispatch,
        statenamespace,
        context.clone(),
        inputs.clone(),
        interpreter,
        &mut evm,
        arc_client.clone(),
    )
    .await?;
    
    Ok((stack,kvs))
}

/// # Eval2 Expression
/// 
/// Function to eval2 rainlang expression.
/// The function executes eval2 on the rainlang expression that is already parsed, deployed and committed to the in-memory db and
/// returns the generated stack and key-value pairs, which are NOT committed to the db. 
/// 
/// # Arguments
/// * `raininterpreter_store_npe2_address` - `RainterpreterStoreNPE2` contract address.
/// * `encode_dispatch` - Encoded Dispatch for expression.
/// * `statenamespace` - Expression namespace.
/// * `context` - Expression context.
/// * `inputs` - Expression inputs.
/// * `raininterpreter_npe2_address` - `RainterpreterNPE2` contract address.
/// * `evm` - EVM instance with inserted contract info and deployed expression result.
/// * `client` - Provider Instance.
/// 
pub async fn eval2_expression(
    raininterpreter_store_npe2_address: Address,
    encode_dispatch: ethers::types::U256,
    statenamespace: ethers::types::U256,
    context: Vec<Vec<ethers::types::U256>>,
    inputs: Vec<ethers::types::U256>,
    raininterpreter_npe2_address: Address,
    evm: &mut EVM<CacheDB<revm::db::EmptyDBTyped<std::convert::Infallible>>>,
    client: Arc<Provider<Http>>,
) -> anyhow::Result<(Vec<ethers::types::U256>, Vec<ethers::types::U256>)> { 

    let rain_interpreter =
        IInterpreterV2::new(H160::from_str(&raininterpreter_npe2_address.to_string())?, client.clone());

    let eval_tx = rain_interpreter.eval_2(
        H160::from_str(&raininterpreter_store_npe2_address.to_string())?,
        statenamespace,
        encode_dispatch,
        context,
        inputs,
    );
    let eval_tx_bytes = eval_tx.calldata().unwrap();

    let result = exec_transaction(raininterpreter_npe2_address, eval_tx_bytes, evm).await?;

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
