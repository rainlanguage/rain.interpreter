use crate::execute::Execute;
use crate::fork::NewForkedEvmCliArgs;
use alloy_primitives::Address;
use anyhow::Result;
use clap::Args;
use rain_interpreter_bindings::IInterpreterStoreV1::FullyQualifiedNamespace;
use rain_interpreter_eval::fork::ForkedEvm;
use rain_interpreter_eval::trace::RainEvalResult;
use std::fmt::Write;

#[derive(Args, Clone)]
pub struct Eval {
    #[command(flatten)]
    forked_evm: NewForkedEvmCliArgs,

    #[arg(short, long, help = "The address of the deployer")]
    deployer: Address,

    #[arg(short, long, help = "The Rainlang string to parse")]
    rainlang_string: String,

    #[arg(short, long, help = "The source index")]
    source_index: u16,
}

impl Execute for Eval {
    async fn execute(&self) -> Result<()> {
        let mut forked_evm = ForkedEvm::new(self.forked_evm.clone().into()).await;
        let result = forked_evm
            .fork_eval(
                &self.rainlang_string,
                self.source_index,
                self.deployer,
                FullyQualifiedNamespace::default(),
                vec![],
            )
            .await;
        let rain_eval_result: RainEvalResult = result.unwrap().into();

        let mut line = String::new();

        for trace in rain_eval_result.traces {
            for value in &trace.stack {
                // Convert each U256 value to a string
                let value_str = format!("{:x}", value);

                // Append the value to the line, followed by a comma
                write!(line, "{},", value_str).unwrap(); // Use write! macro to append to the string
            }
        }

        // Remove the trailing comma
        if !line.is_empty() {
            line.pop();
        }

        // Print the line to stdout
        println!("{}", line);

        Ok(())
    }
}
