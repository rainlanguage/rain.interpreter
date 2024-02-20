use crate::execute::Execute;
use crate::fork::NewForkedEvmCliArgs;
use crate::output::SupportedOutputEncoding;
use alloy_primitives::Address;
use alloy_sol_types::SolCall;
use anyhow::anyhow;
use anyhow::Result;
use clap::Args;
use rain_interpreter_bindings::IParserV1::parseCall;
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

impl Execute for Parse {
    async fn execute(&self) -> Result<()> {
        let mut forker = Forker::new_with_fork(
            &self.forked_evm.fork_url,
            self.forked_evm.fork_block_number,
            None,
            None,
        )
        .await;
        let result = forker
            .fork_parse(
                &self.fork_parse_args.rainlang_string,
                self.fork_parse_args.deployer,
            )
            .await;

        match result {
            Ok(res) => crate::output::output(
                &self.output_path,
                self.output_encoding.clone(),
                parseCall::abi_encode_returns(&(res.bytecode, res.constants)).as_slice(),
            ),
            Err(e) => Err(anyhow!("Error: {:?}", e)),
        }
    }
}
