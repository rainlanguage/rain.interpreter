use crate::execute::Execute;
use crate::fork::NewForkedEvmCliArgs;
use crate::output::SupportedOutputEncoding;
use alloy_primitives::{Address, U256};
use anyhow::anyhow;
use anyhow::Context;
use anyhow::Result;
use clap::Args;
use rain_interpreter_bindings::IInterpreterStoreV1::FullyQualifiedNamespace;
use rain_interpreter_eval::eval::ForkEvalArgs;
use rain_interpreter_eval::fork::ForkedEvm;
use rain_interpreter_eval::trace::RainEvalResult;
use std::path::PathBuf;

#[derive(Args, Clone, Debug)]
pub struct ForkEvalCliArgs {
    #[arg(short, long, help = "The Rainlang string to parse")]
    pub rainlang_string: String,

    #[arg(short, long, help = "The source index")]
    pub source_index: u16,

    // Assuming `Address` can be parsed directly from a string argument
    #[arg(short, long, help = "The address of the deployer")]
    pub deployer: Address,

    #[arg(short, long, help = "The namespace")]
    pub namespace: String,

    // Accept context as a vector of string key-value pairs
    #[arg(
        short,
        long,
        help = "The context in key=value format, key is the context column name and value is the context rows as a comma separated list"
    )]
    pub context: Vec<String>,
}

impl TryFrom<ForkEvalCliArgs> for ForkEvalArgs {
    type Error = anyhow::Error;

    fn try_from(args: ForkEvalCliArgs) -> Result<Self> {
        let namespace = parse_int_or_hex(&args.namespace).context("Invalid namespace format")?;

        let context = args
            .context
            .into_iter()
            .map(|ctx_str| {
                ctx_str
                    .split(',')
                    .map(|v| parse_int_or_hex(v).context("Invalid context value"))
                    .collect::<Result<Vec<U256>>>()
            })
            .collect::<Result<Vec<Vec<U256>>>>()?;

        Ok(ForkEvalArgs {
            rainlang_string: args.rainlang_string,
            source_index: args.source_index,
            deployer: args.deployer,
            namespace: FullyQualifiedNamespace::from(namespace),
            context,
        })
    }
}

// Helper function to parse a string as either integer or hex-encoded value
fn parse_int_or_hex(value: &str) -> Result<U256> {
    if value.starts_with("0x") || value.starts_with("0X") {
        U256::from_str_radix(&value[2..], 16).map_err(|e| e.into())
    } else {
        value.parse::<U256>().map_err(|e| e.into())
    }
}

#[derive(Args, Clone)]
pub struct Eval {
    /// Output path. If not specified, the output is written to stdout.
    #[arg(short, long)]
    output_path: Option<PathBuf>,

    #[command(flatten)]
    forked_evm: NewForkedEvmCliArgs,

    #[command(flatten)]
    fork_eval_args: ForkEvalCliArgs,
}

impl Execute for Eval {
    async fn execute(&self) -> Result<()> {
        let mut forked_evm = ForkedEvm::new(self.forked_evm.clone().into()).await;
        let result = forked_evm
            .fork_eval(self.fork_eval_args.clone().try_into()?)
            .await;

        match result {
            Ok(res) => {
                let rain_eval_result: RainEvalResult = res.into();
                crate::output::output(
                    &self.output_path,
                    SupportedOutputEncoding::Binary,
                    format!("{:#?}", rain_eval_result).as_bytes(),
                )
            }
            Err(e) => Err(anyhow!("Error: {:?}", e)),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_int_or_hex() {
        assert_eq!(parse_int_or_hex("123").unwrap(), U256::from(123));
        assert_eq!(parse_int_or_hex("0xabc").unwrap(), U256::from(2748));
        assert_eq!(parse_int_or_hex("0XFF").unwrap(), U256::from(255));
        assert!(parse_int_or_hex("invalid").is_err());
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_execute() {
        let eval = Eval {
            output_path: None,
            forked_evm: NewForkedEvmCliArgs {
                fork_url: "https://rpc.ankr.com/polygon_mumbai".into(),
                fork_block_number: Some(45658085),
            },
            fork_eval_args: ForkEvalCliArgs {
                rainlang_string: r"_: int-add(10 2), _: context<0 0>(), _:context<0 1>();".into(),
                source_index: 0,
                deployer: "0x0754030e91F316B2d0b992fe7867291E18200A77"
                    .parse()
                    .unwrap(),
                namespace: "0x123".into(),
                context: vec!["0x06,99".into()],
            },
        };

        let result = eval.execute().await;
        println!("{:?}", result);
        assert!(result.is_ok());
    }
}
