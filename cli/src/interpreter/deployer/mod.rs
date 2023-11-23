use ethers::abi::{ParamType, Token};
use ethers::contract::Contract;
use ethers::core::abi::Abi;
use ethers::core::types::H160;
use ethers::providers::{Http, Provider};
use revm::primitives::{Address, ExecutionResult, Output};
use revm::{db::CacheDB, EVM};
use std::str::FromStr;
use std::sync::Arc;

use super::registry::{IExpressionDeployerV3, IParserV1};
use super::rust_evm::commit_transaction;

pub async fn deploy_expression(
    deployer: Address,
    parser: Address,
    rainlang_expression: String,
    evm: &mut EVM<CacheDB<revm::db::EmptyDBTyped<std::convert::Infallible>>>,
    client: Arc<Provider<Http>>,
) -> anyhow::Result<Address> {

    let rain_expression_deployer =
        IExpressionDeployerV3::new(H160::from_str(&deployer.to_string())?, client.clone());
    let rain_parser = IParserV1::new(H160::from_str(&parser.to_string())?, client.clone()); 
  

    let (sources, constants) = rain_parser
        .parse(ethers::types::Bytes::from(
            rainlang_expression.as_bytes().to_vec(),
        ))
        .call()
        .await
        .unwrap();

    let deploy_expression = rain_expression_deployer.deploy_expression_2(sources, constants);
    let deploy_expression_bytes = deploy_expression.calldata().unwrap();

    let result = commit_transaction(deployer, deploy_expression_bytes, evm).await?;

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
            ParamType::Address,
            ParamType::Address,
            ParamType::Address,
            ParamType::Bytes,
        ],
        &value,
    )
    .unwrap();

    let expression_address = match &decoded_data[2] {
        Token::Address(address) => *address,
        _ => panic!("UNABLE TO DEPLOY EXPRESSION"),
    };

    Ok(Address::new(expression_address.to_fixed_bytes()))
} 


pub async fn get_sip_addresses(
    deployer_address: Address,
    client: Arc<Provider<Http>>,
) -> anyhow::Result<(Address, Address, Address)> { 

    let abi: Abi = serde_json::from_str(
        r#"[{
        "inputs": [],
        "name": "iInterpreter",
        "outputs": [
          {
            "internalType": "contract IInterpreterV2",
            "name": "",
            "type": "address"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "iParser",
        "outputs": [
          {
            "internalType": "contract IParserV1",
            "name": "",
            "type": "address"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "iStore",
        "outputs": [
          {
            "internalType": "contract IInterpreterStoreV1",
            "name": "",
            "type": "address"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      }]"#,
    )?;

    let deployer = H160::from_str(&deployer_address.to_string()).unwrap();
    // create the contract object at the address
    let contract = Contract::new(deployer, abi, Arc::new(client)); 

    let store: H160 = contract.method::<_, H160>("iStore", ())?.call().await?; 
   
    let intepreter: H160 = contract
        .method::<_, H160>("iInterpreter", ())?
        .call()
        .await?;
    let parser: H160 = contract.method::<_, H160>("iParser", ())?.call().await?;

    let store = Address::new(store.to_fixed_bytes());
    let intepreter = Address::new(intepreter.to_fixed_bytes());
    let parser = Address::new(parser.to_fixed_bytes());

    Ok((store, intepreter, parser))
}
