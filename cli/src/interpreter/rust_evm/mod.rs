use ethers::providers::{Http, Provider};
use revm::{
    db::{CacheDB, EthersDB},
    primitives::{address, Address, ExecutionResult, TransactTo, U256},
    Database, EVM,
};
use std::sync::Arc;

pub async fn commit_transaction(
    to: Address,
    data: ethers::types::Bytes,
    evm: &mut EVM<CacheDB<revm::db::EmptyDBTyped<std::convert::Infallible>>>,
) -> anyhow::Result<ExecutionResult> {
    // Fill in missing bits of env struct
    // change that to whatever caller you want to be
    evm.env.tx.caller = address!("0000000000000000000000000000000000000000");
    // account you want to transact with
    evm.env.tx.transact_to = TransactTo::Call(to);
    // calldata formed via abigen
    evm.env.tx.data = data.0.into();
    // transaction value in wei
    evm.env.tx.value = U256::from(0);

    // execute transaction and write it to the DB
    let ref_tx = evm.transact_commit().unwrap();
    // select ExecutionResult struct
    let result: ExecutionResult = ref_tx;
    Ok(result)
}

pub async fn write_account_info(
    cache_db: &mut CacheDB<revm::db::EmptyDBTyped<std::convert::Infallible>>,
    account: Address,
    client: Arc<Provider<Http>>,
) -> anyhow::Result<()> {
    // initialize new EthersDB
    let mut ethersdb = EthersDB::new(client, None).unwrap();

    // query basic properties of an account incl bytecode
    let account_info = ethersdb.basic(account).unwrap().unwrap();

    // insert basic account info which was generated via Web3DB with the corresponding address
    cache_db.insert_account_info(account, account_info);

    Ok(())
}