use crate::execute::Execute;
use crate::fork::NewForkedEvmCliArgs;
use crate::output::SupportedOutputEncoding;
use alloy_primitives::Address;
use anyhow::anyhow;
use anyhow::Result;
use clap::Args;
use rain_interpreter_eval::eval::ForkParseArgs;
use rain_interpreter_eval::fork::Forker;
use std::path::PathBuf;

#[derive(Args, Clone, Debug)]
pub struct ForkParseArgsCli {
    #[arg(short, long, help = "The address of the deployer")]
    deployer: Address,

    #[arg(short, long, help = "The Rainlang string to parse")]
    rainlang_string: String,
}

#[derive(Args, Clone)]
pub struct Parse {
    /// Output path. If not specified, the output is written to stdout.
    #[arg(short, long)]
    output_path: Option<PathBuf>,
    /// Output encoding. If not specified, the output is written in binary format.
    #[arg(short = 'E', long, default_value = "binary")]
    output_encoding: SupportedOutputEncoding,

    #[command(flatten)]
    forked_evm: NewForkedEvmCliArgs,

    #[command(flatten)]
    fork_parse_args: ForkParseArgsCli,
}

impl From<ForkParseArgsCli> for ForkParseArgs {
    fn from(args: ForkParseArgsCli) -> Self {
        ForkParseArgs {
            deployer: args.deployer,
            rainlang_string: args.rainlang_string,
        }
    }
}

impl Execute for Parse {
    async fn execute(&self) -> Result<()> {
        let mut forker = Forker::new_with_fork(self.forked_evm.clone().into(), None, None).await;
        let result = forker.fork_parse(self.fork_parse_args.clone().into()).await;

        match result {
            Ok((res, _)) => crate::output::output(
                &self.output_path,
                self.output_encoding.clone(),
                res.raw.result.to_owned().to_vec().as_slice(),
            ),
            Err(e) => Err(anyhow!("Error: {:?}", e)),
        }
    }
}
