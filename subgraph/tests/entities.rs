use utils::setup::get_deployer;
use utils::subgraph;

mod generated;
mod utils;

#[tokio::main]
#[test]
async fn test_deployer() -> anyhow::Result<()> {
    let deployer = get_deployer().await?;

    subgraph::wait().await?;

    let response = subgraph::Query::expression_deployer(&deployer.address()).await?;

    assert_eq!(response.id, deployer.address());

    Ok(())
}
