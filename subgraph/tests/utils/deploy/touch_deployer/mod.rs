use crate::generated::{
    Rainterpreter, RainterpreterExpressionDeployer, RainterpreterParser, RainterpreterStore,
    RAINTERPRETEREXPRESSIONDEPLOYER_ABI, RAINTERPRETEREXPRESSIONDEPLOYER_BYTECODE,
};
use crate::utils::setup::get_wallets_handler;
use anyhow::Result;
use ethers::{
    abi::Token,
    contract::ContractFactory,
    core::k256::ecdsa::SigningKey,
    prelude::SignerMiddleware,
    providers::{Http, Provider},
    signers::Wallet,
    types::H160,
};

pub async fn touch_deployer(
) -> Result<RainterpreterExpressionDeployer<SignerMiddleware<Provider<Http>, Wallet<SigningKey>>>> {
    let rainterpreter = rainterpreter_deploy().await?;
    let store = rainterpreter_store_deploy().await?;
    let parser = rainterpreter_parser_deploy().await?;
    let expression_deployer = rainterpreter_expression_deployer_deploy(
        rainterpreter.address(),
        store.address(),
        parser.address(),
    )
    .await?;

    Ok(expression_deployer)
}

pub async fn rainterpreter_deploy(
) -> Result<Rainterpreter<SignerMiddleware<Provider<Http>, Wallet<SigningKey>>>> {
    let deployer = get_wallets_handler().get_client(0).await?;
    Ok(Rainterpreter::deploy(deployer, ())?.send().await?)
}

pub async fn rainterpreter_store_deploy(
) -> Result<RainterpreterStore<SignerMiddleware<Provider<Http>, Wallet<SigningKey>>>> {
    let deployer = get_wallets_handler().get_client(0).await?;
    Ok(RainterpreterStore::deploy(deployer, ())?.send().await?)
}

pub async fn rainterpreter_parser_deploy(
) -> Result<RainterpreterParser<SignerMiddleware<Provider<Http>, Wallet<SigningKey>>>> {
    let deployer = get_wallets_handler().get_client(0).await?;
    Ok(RainterpreterParser::deploy(deployer, ())?.send().await?)
}

pub async fn rainterpreter_expression_deployer_deploy(
    rainiterpreter_address: H160,
    store_address: H160,
    parser_address: H160,
) -> Result<RainterpreterExpressionDeployer<SignerMiddleware<Provider<Http>, Wallet<SigningKey>>>> {
    let meta_bytes = get_deployer_construction_meta()?;

    let args = vec![Token::Tuple(vec![
        Token::Address(rainiterpreter_address),
        Token::Address(store_address),
        Token::Address(parser_address),
        Token::Bytes(meta_bytes),
    ])];

    let deployer = get_wallets_handler().get_client(0).await?;

    let deploy_transaction = ContractFactory::new(
        RAINTERPRETEREXPRESSIONDEPLOYER_ABI.clone(),
        RAINTERPRETEREXPRESSIONDEPLOYER_BYTECODE.clone(),
        deployer.clone(),
    );
    let contract = deploy_transaction.deploy_tokens(args)?.send().await?;

    Ok(RainterpreterExpressionDeployer::new(
        contract.address(),
        deployer,
    ))
}

pub fn get_deployer_construction_meta() -> anyhow::Result<Vec<u8>> {
    Ok(std::fs::read(
        "../meta/RainterpreterExpressionDeployerNPE2.rain.meta",
    )?)
}
