use crate::error::ForkCallError;
use crate::fork::{ForkTypedReturn, Forker};
use alloy::primitives::{Address, U256};
use rain_interpreter_bindings::DeployerISP::{iInterpreterCall, iStoreCall};
use rain_interpreter_bindings::IInterpreterStoreV1::FullyQualifiedNamespace;
use rain_interpreter_bindings::IInterpreterV3::eval3Call;
use rain_interpreter_bindings::IParserV2::parse2Call;

#[derive(Debug, Clone)]
pub struct ForkEvalArgs {
    pub rainlang_string: String,
    pub source_index: u16,
    pub deployer: Address,
    pub namespace: FullyQualifiedNamespace,
    pub context: Vec<Vec<U256>>,
    pub decode_errors: bool,
}

#[derive(Debug, Clone)]
pub struct ForkParseArgs {
    pub rainlang_string: String,
    pub deployer: Address,
    pub decode_errors: bool,
}

impl From<ForkEvalArgs> for ForkParseArgs {
    fn from(args: ForkEvalArgs) -> Self {
        ForkParseArgs {
            rainlang_string: args.rainlang_string,
            deployer: args.deployer,
            decode_errors: args.decode_errors,
        }
    }
}

impl Forker {
    /// Parses Rainlang string and returns the parsed result.
    ///
    /// # Arguments
    ///
    /// * `rainlang_string` - The Rainlang string to parse.
    /// * `deployer` - The address of the deployer. Must be deployed before the
    ///   fork's current block.
    ///
    /// # Returns
    ///
    /// The typed return of the parse and deployExpression2, plus Foundry's RawCallResult struct.
    pub async fn fork_parse(
        &self,
        args: ForkParseArgs,
    ) -> Result<ForkTypedReturn<parse2Call>, ForkCallError> {
        let ForkParseArgs {
            rainlang_string,
            deployer,
            decode_errors,
        } = args;

        let parse_call = parse2Call {
            data: rainlang_string.as_bytes().to_vec().into(),
        };

        let parse_result = self
            .alloy_call(Address::default(), deployer, parse_call, decode_errors)
            .await?;

        Ok(parse_result)
    }

    /// Evaluates the Rain language string and returns the evaluation result.
    ///
    /// # Arguments
    /// * `rainlang_string` - The Rainalang string to evaluate.
    /// * `source_index` - The source index.
    /// * `deployer` - The address of the deployer.
    /// * `namespace` - The fully qualified namespace.
    /// * `context` - The context vector.
    ///
    /// # Returns
    ///
    /// The typed return of the eval, plus Foundry's RawCallResult struct, including the trace.
    pub async fn fork_eval(
        &self,
        args: ForkEvalArgs,
    ) -> Result<ForkTypedReturn<eval3Call>, ForkCallError> {
        let ForkEvalArgs {
            rainlang_string,
            source_index,
            deployer,
            namespace,
            context,
            decode_errors,
        } = args;
        let parse_result = self
            .fork_parse(ForkParseArgs {
                rainlang_string: rainlang_string.clone(),
                deployer,
                decode_errors,
            })
            .await?;

        let store = self
            .alloy_call(Address::default(), deployer, iStoreCall {}, decode_errors)
            .await?
            .typed_return
            ._0;

        let interpreter = self
            .alloy_call(
                Address::default(),
                deployer,
                iInterpreterCall {},
                decode_errors,
            )
            .await?
            .typed_return
            ._0;

        let eval_args = eval3Call {
            bytecode: parse_result.typed_return.bytecode,
            sourceIndex: U256::from(source_index),
            store,
            namespace: namespace.into(),
            context,
            inputs: vec![],
        };

        let res = self
            .alloy_call(Address::default(), interpreter, eval_args, decode_errors)
            .await?;

        Ok(res)
    }
}

#[cfg(test)]
mod tests {
    use alloy::primitives::utils::parse_ether;
    use rain_interpreter_env::{
        CI_DEPLOY_SEPOLIA_RPC_URL, CI_FORK_SEPOLIA_BLOCK_NUMBER, CI_FORK_SEPOLIA_DEPLOYER_ADDRESS,
    };

    use std::sync::Arc;

    use super::*;
    use crate::fork::NewForkedEvm;

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_fork_parse() {
        let deployer: Address = *CI_FORK_SEPOLIA_DEPLOYER_ADDRESS;
        let args = NewForkedEvm {
            fork_url: CI_DEPLOY_SEPOLIA_RPC_URL.to_string(),
            fork_block_number: Some(*CI_FORK_SEPOLIA_BLOCK_NUMBER),
        };
        let fork = Forker::new_with_fork(args, None, None).await.unwrap();
        let res = fork
            .fork_parse(ForkParseArgs {
                rainlang_string: r"_: add(1 2);".to_owned(),
                deployer,
                decode_errors: true,
            })
            .await
            .unwrap();

        let expected_bytes: Vec<u8> = alloy::hex::decode("0x00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000de0b6b3a76400000000000000000000000000000000000000000000000000001bc16d674ec8000000000000000000000000000000000000000000000000000000000000000000130100000302000101100001011000002b120000").unwrap();
        assert_eq!(res.typed_return.bytecode, expected_bytes);
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_fork_eval() {
        let deployer: Address = *CI_FORK_SEPOLIA_DEPLOYER_ADDRESS;
        let args = NewForkedEvm {
            fork_url: CI_DEPLOY_SEPOLIA_RPC_URL.to_owned(),
            fork_block_number: Some(*CI_FORK_SEPOLIA_BLOCK_NUMBER),
        };
        let fork = Forker::new_with_fork(args, None, None).await.unwrap();
        let res = fork
            .fork_eval(ForkEvalArgs {
                rainlang_string: r"_: add(1 2);".into(),
                source_index: 0,
                deployer,
                namespace: FullyQualifiedNamespace::default(),
                context: vec![],
                decode_errors: true,
            })
            .await
            .unwrap();

        // stack
        let expected_stack = vec![parse_ether("3").unwrap()];
        assert_eq!(res.typed_return.stack, expected_stack);

        // storage writes
        let expected_writes = vec![];
        assert_eq!(res.typed_return.writes, expected_writes);

        // stack in the trace for source index 0
        let mut expected_stack_trace = vec![0u8, 0u8, 0u8, 0u8];
        expected_stack_trace.append(&mut parse_ether("3").unwrap().to_be_bytes_vec());
        let source_index_zero_trace = res.raw.traces.unwrap().into_nodes()[1].to_owned().trace;
        assert_eq!(source_index_zero_trace.data, expected_stack_trace);

        // asserting the known trace address
        let expected_trace_address = "0xF06Cd48c98d7321649dB7D8b2C396A81A2046555"
            .parse::<Address>()
            .unwrap();
        let trace_address = Address::from(source_index_zero_trace.address.into_array());
        assert_eq!(trace_address, expected_trace_address);
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 10)]
    async fn test_fork_eval_parallel() {
        let deployer: Address = *CI_FORK_SEPOLIA_DEPLOYER_ADDRESS;
        let args = NewForkedEvm {
            fork_url: CI_DEPLOY_SEPOLIA_RPC_URL.to_string(),
            fork_block_number: Some(*CI_FORK_SEPOLIA_BLOCK_NUMBER),
        };
        let fork = Forker::new_with_fork(args, None, None).await.unwrap();
        let fork = Arc::new(fork); // Wrap in Arc for shared ownership

        let mut handles = vec![];
        for _ in 0..1000 {
            let fork_clone = Arc::clone(&fork); // Clone the Arc for each thread
            let handle = tokio::spawn(async move {
                fork_clone
                    .fork_eval(ForkEvalArgs {
                        rainlang_string: r"_: add(1 2);".into(),
                        source_index: 0,
                        deployer,
                        namespace: FullyQualifiedNamespace::default(),
                        context: vec![],
                        decode_errors: true,
                    })
                    .await
                    .unwrap()
            });
            handles.push(handle);
        }

        for handle in handles {
            let res = handle.await.unwrap();
            assert_eq!(res.typed_return.stack, vec![parse_ether("3").unwrap()]);
        }
    }
}
