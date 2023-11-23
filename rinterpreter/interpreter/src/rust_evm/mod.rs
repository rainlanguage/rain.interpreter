use ethers::providers::{Http, Provider};
use revm::{
    db::{CacheDB, EthersDB},
    primitives::{address, Address, ExecutionResult, TransactTo, U256, Bytecode, Bytes, AccountInfo},
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