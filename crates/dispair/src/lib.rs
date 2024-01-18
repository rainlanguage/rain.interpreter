use alloy_ethers_typecast::transaction::{ReadContractParametersBuilder, ReadableClient};
use alloy_primitives::*;
use anyhow::*;
use ethers::providers::JsonRpcClient;
use rain_interpreter_bindings::DeployerISP;

mod from_deployer;
mod parse;

/// DISPair
/// Struct representing DISP instances.
#[derive(Clone, Default)]
pub struct DISPair {
    pub deployer: Address,
    pub interpreter: Address,
    pub store: Address,
    pub parser: Address,
}
