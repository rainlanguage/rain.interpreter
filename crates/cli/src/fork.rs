use clap::Args;

#[derive(Args, Clone, Debug)]
pub struct NewForkedEvmCliArgs {
    #[arg(short = 'i', long, help = "RPC url for the fork")]
    pub fork_url: String,
    #[arg(short = 'i', long, help = "Optional block number to fork from")]
    pub fork_block_number: Option<u64>,
}
