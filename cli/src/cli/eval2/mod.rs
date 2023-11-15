use anyhow::anyhow;
use clap::Parser;
use ethers::{
    providers::{Http, Provider},
    types::U256,
};
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

    /// index of source
    #[arg(short, long)]
    pub source_index: u8,

    /// inputs to the eval2 call
    #[arg(short,long,num_args = 0.. )]
    pub inputs: Vec<String>,

    /// mumbai rpc url, default read from env varibales
    #[arg(long, env)]
    pub rpc_url: Option<String>,
}

pub async fn handle_eval2(eval2: Eval2) -> anyhow::Result<()> {
    let rpc_url = match eval2.rpc_url {
        Some(url) => url,
        None => {
            error!("RPC URL NOT PROVIDED");
            return Err(anyhow!("RPC URL not provided."));
        }
    };
    let client: Provider<Http> = match Provider::<Http>::try_from(rpc_url) {
        Ok(rpc_url) => rpc_url,
        Err(err) => {
            error!("{}", err);
            return Err(anyhow!(err));
        }
    };
    let deployer = match Address::parse_checksummed(eval2.deployer, None) {
        Ok(address) => address,
        Err(err) => {
            error!("{}", err);
            return Err(anyhow!(err));
        }
    };

    let inputs = eval2
        .inputs
        .iter()
        .map(|t| U256::from_dec_str(t).unwrap())
        .collect::<Vec<U256>>();

    let source_index = U256::from(eval2.source_index);

    let _ = compute_eval2(deployer, eval2.expression, source_index, inputs, client).await;

    // println!("{:#?}",eval2);
    Ok(())
}
