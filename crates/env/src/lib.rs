use alloy_primitives::{Address, BlockNumber};
use once_cell::sync::Lazy;

#[cfg(test)]
pub const CI_DEPLOY_SEPOLIA_RPC_URL: &str = env!(
    "CI_DEPLOY_SEPOLIA_RPC_URL",
    "$CI_DEPLOY_SEPOLIA_RPC_URL not set."
);

#[cfg(test)]
pub static CI_FORK_SEPOLIA_DEPLOYER_ADDRESS: Lazy<Address> = Lazy::new(|| {
    env!(
        "CI_FORK_SEPOLIA_DEPLOYER_ADDRESS",
        "$CI_FORK_SEPOLIA_DEPLOYER_ADDRESS not set."
    )
    .parse()
    .unwrap()
});

#[cfg(test)]
pub static CI_FORK_SEPOLIA_BLOCK_NUMBER: Lazy<BlockNumber> = Lazy::new(|| {
    env!(
        "CI_FORK_SEPOLIA_BLOCK_NUMBER",
        "$CI_FORK_SEPOLIA_BLOCK_NUMBER not set."
    )
    .parse()
    .unwrap()
});
