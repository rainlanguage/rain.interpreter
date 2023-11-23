use ethers::providers::{Http, Provider};
use revm::{
    db::{CacheDB, EthersDB},
    primitives::{address, Address, ExecutionResult, TransactTo, U256, Bytecode, Bytes, AccountInfo},
    Database, EVM,
};
use std::sync::Arc;

/// # Execute and Commit Transaction
/// 
/// Executes and commits the state transition to the in-memory db.
/// The caller for the transaction is set as zero address, and if `tx.transact_to` feild is a contract,
/// then the contract account info should already be present in the db.
/// 
/// # Arguments
/// * `to` - Address to trasact to.
/// * `data` - Bytes representing the transaction data.
/// * `evm` - EVM instance with contract data inserted.
///
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

/// # Execute Transaction
/// 
/// Executes transaction with the current state of in memory db, result is not committed
/// The caller for the transaction is set as zero address, and if `tx.transact_to` feild is a contract,
/// then the contract account info should already be present in the db.
/// 
/// # Arguments
/// * `to` - Address to trasact to.
/// * `data` - Bytes representing the transaction data.
/// * `evm` - EVM instance with contract data inserted.
///
pub async fn exec_transaction(
    to: Address,
    data: ethers::types::Bytes,
    evm: &mut EVM<CacheDB<revm::db::EmptyDBTyped<std::convert::Infallible>>>,
) -> anyhow::Result<ExecutionResult> { 

    evm.env.tx.caller = address!("0000000000000000000000000000000000000000");
    evm.env.tx.transact_to = TransactTo::Call(to);
    evm.env.tx.data = data.0.into();
    evm.env.tx.value = U256::from(0);

    // execute transaction and without writting to db
    let ref_tx = evm.transact_ref().unwrap();
    // select ExecutionResult struct
    let result: ExecutionResult = ref_tx.result;
    Ok(result)
}

/// # Write Account Info
/// 
/// Save an account's info to in-memory db.
/// This function is used to save contract state from on chain to the in memory.
/// Revm saves contract runtime bytecode to in-memory db, so any contract variables associated are also accessible.
/// 
/// # Arguments
/// * `cache_db` - CacheDB instance to write data to.
/// * `account` - Address of account to save.
/// * `client` - Provider Instance.
///
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

/// # Write Account Info from bytecode
/// 
/// Save an account info to in-memory db.
/// This function is used to save contract state from the deployed bytecode passed as an argument to in memory db.
/// Revm saves contract runtime bytecode to in-memory db, so any contract variables associated are also accessible.
/// 
/// # Arguments
/// * `cache_db` - CacheDB instance to write data to.
/// * `account` - Address of account to save info to the db.
/// * `deployed_bytecode` - String representing the deployed bytecode of the contract.
///
pub async fn write_account_info_from_bytecode(
    cache_db: &mut CacheDB<revm::db::EmptyDBTyped<std::convert::Infallible>>,
    address: Address,
    deployed_bytecode: String
) -> anyhow::Result<()> {

    let contract_bytecode = Bytecode::new_raw(Bytes::from(hex::decode(deployed_bytecode).unwrap())); 

    let contrac_account_info = AccountInfo::new(
        U256::from(0),
        0,
        contract_bytecode.hash_slow(),
        contract_bytecode
    ); 

    cache_db.insert_account_info(address, contrac_account_info); 

    Ok(())  
}