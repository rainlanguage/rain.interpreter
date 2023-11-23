
use ethers::providers::{Http, Provider};
use rain_interpreter::interpreter::deploy_and_eval2;
use revm::primitives::address;

#[tokio::main]
pub async fn main() -> anyhow::Result<()> {  

    // RPC URL of the network
    let rpc_url = String::from("https://polygon.llamarpc.com");

    let client = Provider::<Http>::try_from(rpc_url)?; 

    // Address of RainterpreterExpressionDeployerNPE2
    let deployer_npe2 = address!("1b21dfA0107920F23D27a5891dEd65101302314D");
    // Expression to eval2
    let rainlang_expression = String::from("val1: ,val2: ,sum: int-add(val1 val2);"); 
    // Index of source
    let source_index = ethers::types::U256::from(0);
    // Inputs to eval2
    let inputs:Vec<ethers::types::U256> = vec![
        ethers::types::U256::from(3),
        ethers::types::U256::from(6)
    ]; 
    // Deploy and Eval Expression
    let (stack,kvs) = deploy_and_eval2(
        deployer_npe2,
        rainlang_expression,
        source_index,
        inputs,
        client
    ).await?; 
    // Log stack and kvs
    println!("stack: {:#?}",stack);
    println!("kvs: {:#?}",kvs);

    Ok(())
} 

