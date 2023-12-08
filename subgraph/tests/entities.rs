use utils::setup::get_deployer;
use utils::subgraph;

mod generated;
mod utils;

#[tokio::main]
#[test]
async fn test_deployer() -> anyhow::Result<()> {
    let deployer = get_deployer().await?;
    println!("deployer: {:?}", deployer.address());

    subgraph::wait().await?;

    Ok(())
}
