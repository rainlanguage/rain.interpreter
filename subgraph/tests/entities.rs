use utils::setup::get_deployer;

mod generated;
mod utils;

#[tokio::main]
#[test]
async fn test_deployer() -> anyhow::Result<()> {
    let deployer = get_deployer().await?;
    println!("deployer: {:?}", deployer.address());

    Ok(())
}
