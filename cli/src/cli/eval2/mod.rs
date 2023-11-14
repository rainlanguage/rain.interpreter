use anyhow::anyhow;
use clap::Parser;
use ethers::providers::{Http, Provider};
use revm::primitives::Address;
use std::convert::TryFrom;
use tracing::error;

use crate::interpreter::compute_eval2;

#[derive(Parser, Debug, Clone)]
pub struct Eval2 {
    /// address of the expression deployer
    #[arg(long, short)]
    pub deployer: String,

    /// rainlang expression string
    #[arg(short, long)]
    pub expression: String, 

    /// mumbai rpc url, default read from env varibales
    #[arg(long, env)]
    pub rpc_url: Option<String>
} 

pub async fn handle_eval2(eval2: Eval2) -> anyhow::Result<()> { 
    let rpc_url = match eval2.rpc_url {
        Some(url) => url,
        None => {
            error!("RPC URL NOT PROVIDED");
            return Err(anyhow!("RPC URL not provided."));
        }
    };
    let client: Provider<Http> = match Provider::<Http>::try_from(rpc_url){
        Ok(rpc_url) => rpc_url,
        Err(err) => {
            error!("{}",err);
            return Err(anyhow!(err));
        }
    }; 
    let deployer = match Address::parse_checksummed(eval2.deployer,None){
        Ok(address) => address,
        Err(err) => {
            error!("{}",err);
            return Err(anyhow!(err));
        }
    };
    let _ = compute_eval2(deployer, eval2.expression, client).await ; 

    // println!("{:#?}",eval2);
    Ok(())
}