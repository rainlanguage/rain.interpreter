
use ethers::providers::{Http, Provider};

use revm::primitives::address;

use crate::interpreter::deploy_and_eval2;

#[tokio::main]
pub async fn main() -> anyhow::Result<()> {  

    let rpc_url = String::from("https://polygon.llamarpc.com");

    let client = Provider::<Http>::try_from(rpc_url)?; 

    let deployer_npe2 = address!("1b21dfA0107920F23D27a5891dEd65101302314D");

    let rainlang_expression = String::from("val1: ,val2: ,sum: int-add(val1 val2);");
    let source_index = ethers::types::U256::from(0);
    let inputs:Vec<ethers::types::U256> = vec![
        ethers::types::U256::from(3),
        ethers::types::U256::from(6)
    ]; 

    let (stack,kvs) = deploy_and_eval2(
        deployer_npe2,
        rainlang_expression,
        source_index,
        inputs,
        client
    ).await?; 


    println!("stack: {:#?}",stack);
    println!("kvs: {:#?}",kvs);

    Ok(())
} 

