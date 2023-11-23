use revm::primitives::Address;
use ethers::{providers::{Http, Provider}, types::H160};
use revm::{db::CacheDB,EVM}; 
use std::str::FromStr;
use std::sync::Arc;

use super::{registry::IInterpreterStoreV1, rust_evm::commit_transaction}; 

/// # Set Keys
/// 
/// Commit `RainterpreterStoreNPE2` keys-value pairs to in-memory db.
/// The contract info should already by present in the in-memory db.
/// 
/// # Arguments
/// * `rainterpreter_store_npe2_address` - `RainterpreterStoreNPE2` contract address.
/// * `kvs` - Array of key-values.
/// * `evm` - EVM instance with contract data inserted.
/// * `client` - Provider Instance.
///
pub async fn set_keys(
    rainterpreter_store_npe2_address: Address,
    kvs: Vec<ethers::types::U256>,
    evm: &mut EVM<CacheDB<revm::db::EmptyDBTyped<std::convert::Infallible>>>,
    client: Arc<Provider<Http>>,
)->anyhow::Result<()> { 
  
    let rain_store =
    IInterpreterStoreV1::new(H160::from_str(&rainterpreter_store_npe2_address.to_string())?, client.clone()); 

    let set_tx = rain_store.set(ethers::types::U256::from(0), kvs).calldata().unwrap(); 

    let _ = commit_transaction(rainterpreter_store_npe2_address, set_tx, evm).await?;

    Ok(())
}