use alloy::primitives::{Address, BlockNumber};
use once_cell::sync::Lazy;

pub static CI_DEPLOY_SEPOLIA_RPC_URL: Lazy<String> = Lazy::new(|| {
    env!(
        "CI_DEPLOY_SEPOLIA_RPC_URL",
        "$CI_DEPLOY_SEPOLIA_RPC_URL not set."
    )
    .to_string()
});

pub static CI_FORK_SEPOLIA_DEPLOYER_ADDRESS: Lazy<Address> = Lazy::new(|| {
    env!(
        "CI_FORK_SEPOLIA_DEPLOYER_ADDRESS",
        "$CI_FORK_SEPOLIA_DEPLOYER_ADDRESS not set."
    )
    .parse()
    .unwrap()
});

pub static CI_FORK_SEPOLIA_BLOCK_NUMBER: Lazy<BlockNumber> = Lazy::new(|| {
    env!(
        "CI_FORK_SEPOLIA_BLOCK_NUMBER",
        "$CI_FORK_SEPOLIA_BLOCK_NUMBER not set."
    )
    .parse()
    .unwrap()
});

pub static CI_FORK_POLYGON_RPC_URL: Lazy<String> = Lazy::new(|| {
    env!(
        "CI_FORK_POLYGON_RPC_URL",
        "$CI_FORK_POLYGON_RPC_URL not set."
    )
    .to_string()
});

pub static CI_FORK_BSC_RPC_URL: Lazy<String> =
    Lazy::new(|| env!("CI_FORK_BSC_RPC_URL", "$CI_FORK_BSC_RPC_URL not set.").to_string());
