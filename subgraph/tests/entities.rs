use ethers::{types::Bytes, utils::keccak256};
use generated::RAINTERPRETEREXPRESSIONDEPLOYER_BYTECODE;
use utils::deploy::get_deployer_construction_meta;
use utils::setup::{get_deployer, get_extrospection};
use utils::subgraph;

mod generated;
mod utils;

#[tokio::main]
#[test]
async fn test_deployer() -> anyhow::Result<()> {
    let deployer = get_deployer().await?;
    subgraph::wait().await?;
    let response = subgraph::Query::expression_deployer(&deployer.address()).await?;

    let constructor_meta = get_deployer_construction_meta()?;
    let extrospection = get_extrospection().await?;

    assert_eq!(response.id, deployer.address());
    assert_eq!(response.interpreter, deployer.i_interpreter().call().await?);
    assert_eq!(response.store, deployer.i_store().call().await?);
    assert_eq!(response.parser, deployer.i_parser().call().await?);
    assert_eq!(response.constructor_meta, constructor_meta);
    assert_eq!(
        response.constructor_meta_hash,
        Bytes::from(keccak256(constructor_meta))
    );
    assert_eq!(response.bytecode, RAINTERPRETEREXPRESSIONDEPLOYER_BYTECODE);
    assert_eq!(
        response.bytecode_hash,
        Bytes::from(keccak256(&RAINTERPRETEREXPRESSIONDEPLOYER_BYTECODE))
    );
    assert_eq!(
        response.deployed_bytecode,
        extrospection.bytecode(deployer.address()).call().await?
    );
    assert_eq!(
        response.deployed_bytecode_hash,
        Bytes::from(
            extrospection
                .bytecode_hash(deployer.address())
                .call()
                .await?
        )
    );

    Ok(())
}
