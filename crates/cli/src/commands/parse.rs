use anyhow::anyhow;
use std::path::PathBuf;

use crate::execute::Execute;
use crate::fork::NewForkedEvmCliArgs;
use crate::output::SupportedOutputEncoding;
use alloy_primitives::Address;
use anyhow::Result;
use clap::Args;
use rain_interpreter_eval::fork::ForkedEvm;

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

    #[arg(short, long, help = "The address of the deployer")]
    deployer: Address,

    #[arg(short, long, help = "The Rainlang string to parse")]
    rainlang_string: String,
}

impl Execute for Parse {
    async fn execute(&self) -> Result<()> {
        let mut forked_evm = ForkedEvm::new(self.forked_evm.clone().into()).await;
        let result = forked_evm
            .fork_parse(&self.rainlang_string, self.deployer)
            .await;

        match result {
            Ok(res) => crate::output::output(
                &self.output_path,
                self.output_encoding.clone(),
                res.raw.result.to_owned().to_vec().as_slice(),
            ),
            Err(e) => Err(anyhow!("Error: {:?}", e)),
        }
    }
}
