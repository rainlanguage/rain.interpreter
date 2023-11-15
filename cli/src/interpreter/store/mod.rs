use revm::primitives::Address;
use ethers::{providers::{Http, Provider}, types::H160};
use revm::{db::CacheDB,EVM}; 
use std::str::FromStr;
use std::sync::Arc;

use super::{registry::IInterpreterStoreV1, rust_evm::commit_transaction}; 

pub async fn setKeys(
    store: Address,
    kvs: Vec<ethers::types::U256>,
    evm: &mut EVM<CacheDB<revm::db::EmptyDBTyped<std::convert::Infallible>>>,
    client: Arc<Provider<Http>>,
)->anyhow::Result<()> { 
    let rain_store =
    IInterpreterStoreV1::new(H160::from_str(&store.to_string())?, client.clone()); 

    let set_tx = rain_store.set(ethers::types::U256::from(0), kvs).calldata().unwrap(); 

    let _ = commit_transaction(store, set_tx, evm).await?;

    Ok(())
}