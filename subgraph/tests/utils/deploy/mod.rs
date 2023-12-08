// mod erc20;

mod registry1820;
mod touch_deployer;

// pub use erc20::deploy_erc20;

pub use registry1820::deploy1820;
pub use touch_deployer::{get_deployer_construction_meta, touch_deployer};
