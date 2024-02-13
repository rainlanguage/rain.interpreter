use ::rain_interpreter_eval::fork::NewForkedEvm;
use alloy_primitives::BlockNumber;
use clap::Args;

#[derive(Args, Clone, Debug)]
pub struct NewForkedEvmCliArgs {
    #[arg(short = 'i', long, help = "RPC url for the fork")]
    pub fork_url: String,
    #[arg(short = 'i', long, help = "Optional block number to fork from")]
    pub fork_block_number: Option<BlockNumber>,
}

impl From<NewForkedEvmCliArgs> for NewForkedEvm {
    fn from(args: NewForkedEvmCliArgs) -> Self {
        NewForkedEvm {
            fork_url: args.fork_url,
            fork_block_number: args.fork_block_number,
        }
    }
}
