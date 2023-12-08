use crate::{generated::RainterpreterExpressionDeployer, utils::deploy::deploy1820};
use anyhow::Result;
use ethers::{
    core::k256::ecdsa::SigningKey,
    prelude::SignerMiddleware,
    providers::{Http, Provider},
    signers::Wallet,
};
use once_cell::sync::Lazy;
use rain_cli_subgraph::subgraph;
use subgraph_rust_setup_utils::{WalletHandler, RPC};
use tokio::sync::OnceCell;

use super::deploy::touch_deployer;

// Initialize just once
static RPC_PROVIDER: Lazy<RPC> = Lazy::new(|| RPC::default());
static WALLETS_HANDLER: Lazy<WalletHandler> = Lazy::new(|| WalletHandler::default());
static DEPLOYER: Lazy<
    OnceCell<RainterpreterExpressionDeployer<SignerMiddleware<Provider<Http>, Wallet<SigningKey>>>>,
> = Lazy::new(|| OnceCell::new());

async fn init_deployer(
) -> Result<RainterpreterExpressionDeployer<SignerMiddleware<Provider<Http>, Wallet<SigningKey>>>> {
    tracing::subscriber::set_global_default(tracing_subscriber::fmt::Subscriber::new())?;

    let rpc_provider = get_rpc_provider().await?;
    let block = rpc_provider.get_block_number().await?;

    // Always checking if the Registry1820 is deployed. Deploy it otherwise
    deploy1820(rpc_provider.get_provider()).await?;

    let deployer = touch_deployer().await?;

    let build_args = subgraph::build::BuildArgs {
        address: Some("0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24".to_string()), // The registry address
        block_number: Some(block.as_u64()),
        network: Some("localhost".to_string()),
        template_path: None,
        output_path: None,
    };
    let resp_build = subgraph::build::build(build_args);
    if resp_build.is_err() {
        return Err(anyhow::anyhow!(resp_build.err().unwrap()));
    }

    let deploy_args = subgraph::deploy::DeployArgs {
        subgraph_name: "test/test".to_string(),
        endpoint: Some("http://localhost:8020/".to_string()),
        token_access: None,
    };

    let resp_deploy = subgraph::deploy::deploy(deploy_args);
    if resp_deploy.is_err() {
        return Err(anyhow::anyhow!(resp_deploy.err().unwrap()));
    }

    Ok(deployer)
}

pub async fn get_deployer() -> Result<
    &'static RainterpreterExpressionDeployer<SignerMiddleware<Provider<Http>, Wallet<SigningKey>>>,
> {
    let deployer_lazy = DEPLOYER
        .get_or_try_init(|| async { init_deployer().await })
        .await
        .map_err(|err| err);

    match deployer_lazy {
        Ok(contract) => Ok(contract),
        Err(e) => return Err(anyhow::Error::msg(e.to_string())),
    }
}

pub async fn get_rpc_provider() -> Result<&'static RPC> {
    Ok(&*RPC_PROVIDER)
}

pub fn get_wallets_handler() -> &'static WalletHandler {
    &*WALLETS_HANDLER
}
