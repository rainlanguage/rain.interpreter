use crate::{
    generated::{Extrospection, EXTROSPECTION_BYTECODE},
    utils::setup::{get_rpc_provider, get_wallets_handler},
};
use ethers::{
    core::k256::ecdsa::SigningKey,
    prelude::SignerMiddleware,
    providers::{Http, Middleware, Provider},
    signers::Wallet,
    types::{
        transaction::eip2718::TypedTransaction, Address, BlockId, Bytes, NameOrAddress, Signature,
        TransactionRequest, U256, U64,
    },
    utils::{
        keccak256,
        rlp::{Rlp, RlpStream},
        Units,
    },
};

pub async fn deploy_extrospection(
) -> anyhow::Result<Extrospection<SignerMiddleware<Provider<Http>, Wallet<SigningKey>>>> {
    let rpc = get_rpc_provider().await?;
    let wallet = get_wallets_handler().get_client(0).await?;

    let chain_id: U64 = rpc.get_provider().get_chainid().await?.as_u64().into();
    let gas_price = U256::from_dec_str("1980000104")?;
    let gas = U256::from_dec_str("5000000")?;
    let nonce = U256::zero();
    let data_bytes: Bytes = EXTROSPECTION_BYTECODE.clone();

    // Fill the tx request
    let tx_req = TransactionRequest {
        to: None,
        data: Some(data_bytes),
        from: Some(wallet.address()),
        chain_id: Some(chain_id),
        gas_price: Some(gas_price),
        value: Some(U256::zero()),
        nonce: Some(nonce),
        gas: Some(gas),
    };
    let tx: TypedTransaction = tx_req.into();

    // Set the signature
    let signature = Signature {
        r: U256::from_str_radix(
            "0x1231231231231231231231231231231231231231231231231231231231231231",
            16,
        )?,
        s: U256::from_str_radix(
            "0x1231231231231231231231231231231231231231231231231231231231231231",
            16,
        )?,
        v: 27,
    };

    // Serialize the transaction
    let deploy_tx = tx.rlp_signed(&signature);
    let ave_rlp = Rlp::new(&deploy_tx);
    let (tx_dec, ..) = TransactionRequest::decode_signed_rlp(&ave_rlp)?;

    // The deployer address of the contract
    let deployer_address = tx_dec.from.unwrap();

    // Calculate the contract address
    let contract_address = calculate_contract_address(deployer_address, nonce);

    let code = rpc
        .get_provider()
        .get_code(
            contract_address,
            BlockId::from(rpc.get_block_number().await?).into(),
        )
        .await?;

    if code == Bytes::default() {
        // Send ethers to deployer address
        let amount = ethers::utils::parse_ether(Units::Ether)?;
        let tx_request = TransactionRequest {
            to: Some(NameOrAddress::Address(deployer_address)),
            value: Some(amount),
            ..Default::default()
        };
        // Send tx for ethers
        rpc.get_provider()
            .send_transaction(tx_request, None)
            .await?
            .await?;

        // Deploy contract
        rpc.get_provider()
            .send_raw_transaction(deploy_tx)
            .await?
            .await?;
    };

    Ok(Extrospection::new(contract_address, wallet))
}

// fn calculate_contract_address(sender: Address, nonce: u64) -> Address {
fn calculate_contract_address(sender: Address, nonce: U256) -> Address {
    let mut stream = RlpStream::new_list(2);
    stream.append(&sender.0.to_vec());
    stream.append(&nonce.as_u64());

    let rlp_bytes = stream.out();
    let hash = keccak256(rlp_bytes);

    // Take the last 20 bytes to get the contract address
    let contract_address = Address::from_slice(&hash[12..32]);
    contract_address
}
