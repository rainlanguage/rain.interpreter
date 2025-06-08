use crate::error::ForkCallError;
use crate::fork::{ForkTypedReturn, Forker};
use alloy::primitives::{Address, U256};
use rain_interpreter_bindings::DeployerISP::{iInterpreterCall, iStoreCall};
use rain_interpreter_bindings::IInterpreterStoreV3::FullyQualifiedNamespace;
use rain_interpreter_bindings::IInterpreterV4::{EvalV4, eval4Call};
use rain_interpreter_bindings::IParserV2::parse2Call;

#[derive(Debug, Clone)]
/// Arguments for evaluating a Rainlang string in a forked EVM context
pub struct ForkEvalArgs {
    /// The Rainalang string to evaluate
    pub rainlang_string: String,
    /// The source index of the rainlang to evaluate
    pub source_index: u16,
    /// The address of the deployer
    pub deployer: Address,
    /// The fully qualified namespace
    pub namespace: FullyQualifiedNamespace,
    /// The context matrix, that will be available in "context" word and its aliases
    pub context: Vec<Vec<U256>>,
    /// Whether to decode errors from the registry
    pub decode_errors: bool,
    /// Inputs vector which are prepopulated stack items
    pub inputs: Vec<U256>,
    /// Applies to the state before evaluation to facilitate "what if" analysis
    pub state_overlay: Vec<U256>,
}

#[derive(Debug, Clone)]
/// Arguments for parsing a Rainlang string in a forked EVM context
pub struct ForkParseArgs {
    /// The Rainlang string to parse
    pub rainlang_string: String,
    /// The address of the deployer
    pub deployer: Address,
    /// Whether to decode errors from the registry
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
    /// * `args` - The fork eval arguments for the evaluation
    ///
    /// # Returns
    ///
    /// The typed return of the eval, plus Foundry's RawCallResult struct, including the trace.
    pub async fn fork_eval(
        &self,
        args: ForkEvalArgs,
    ) -> Result<ForkTypedReturn<eval4Call>, ForkCallError> {
        let ForkEvalArgs {
            rainlang_string,
            source_index,
            deployer,
            namespace,
            context,
            decode_errors,
            inputs,
            state_overlay,
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
            .typed_return;

        let interpreter = self
            .alloy_call(
                Address::default(),
                deployer,
                iInterpreterCall {},
                decode_errors,
            )
            .await?
            .typed_return;

        let eval_args = eval4Call {
            eval: EvalV4 {
                bytecode: parse_result.typed_return,
                sourceIndex: U256::from(source_index),
                store,
                namespace: namespace.into(),
                context: context
                    .into_iter()
                    .map(|v| v.into_iter().map(Into::into).collect())
                    .collect(),
                inputs: inputs.into_iter().map(Into::into).collect(),
                stateOverlay: state_overlay.into_iter().map(Into::into).collect(),
            },
        };

        let res = self
            .alloy_call(Address::default(), interpreter, eval_args, decode_errors)
            .await?;

        Ok(res)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::fork::NewForkedEvm;
    use alloy::primitives::FixedBytes;
    use foundry_evm::traces::CallTraceArena;
    use rain_interpreter_test_fixtures::LocalEvm;
    use std::sync::Arc;

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_fork_parse() {
        let local_evm = LocalEvm::new().await;
        let deployer = *local_evm.deployer.address();
        let args = NewForkedEvm {
            fork_url: local_evm.url(),
            fork_block_number: None,
        };
        let fork = Forker::new_with_fork(args, None, None).await.unwrap();

        let res = fork
            .fork_parse(ForkParseArgs {
                rainlang_string: r"_: 1;".to_owned(),
                deployer,
                decode_errors: true,
            })
            .await
            .unwrap();

        let expected_bytes: Vec<u8> = alloy::hex::decode("0x00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000b0100000101000101100000").unwrap();
        assert_eq!(res.typed_return.0, expected_bytes);
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_fork_eval() {
        let local_evm = LocalEvm::new().await;
        let deployer = *local_evm.deployer.address();
        let args = NewForkedEvm {
            fork_url: local_evm.url(),
            fork_block_number: None,
        };
        let fork = Forker::new_with_fork(args, None, None).await.unwrap();
        let res = fork
            .fork_eval(ForkEvalArgs {
                rainlang_string: r"_: 3;".into(),
                source_index: 0,
                deployer,
                namespace: FullyQualifiedNamespace::default(),
                context: vec![],
                decode_errors: true,
                state_overlay: vec![],
                inputs: vec![],
            })
            .await
            .unwrap();

        // stack
        let expected_stack: Vec<FixedBytes<32>> = vec![FixedBytes::left_padding_from(&[3u8])];
        assert_eq!(res.typed_return.stack, expected_stack);

        // storage writes
        let expected_writes: Vec<FixedBytes<32>> = vec![];
        assert_eq!(res.typed_return.writes, expected_writes);

        // stack in the trace for source index 0
        let mut expected_stack_trace = vec![0u8, 0u8, 0u8, 0u8];
        expected_stack_trace.append(&mut <FixedBytes<32>>::left_padding_from(&[3u8]).to_vec());

        let sparsed_trace_arena = res.raw.traces.unwrap();
        let source_index_zero_trace = <CallTraceArena as Clone>::clone(&sparsed_trace_arena)
            .into_nodes()[1]
            .to_owned()
            .trace;
        assert_eq!(source_index_zero_trace.data.to_vec(), expected_stack_trace);

        // asserting the known trace address
        let expected_trace_address = "0xF06Cd48c98d7321649dB7D8b2C396A81A2046555"
            .parse::<Address>()
            .unwrap();
        let trace_address = Address::from(source_index_zero_trace.address.into_array());
        assert_eq!(trace_address, expected_trace_address);
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 10)]
    async fn test_fork_eval_parallel() {
        let local_evm = LocalEvm::new().await;
        let deployer = *local_evm.deployer.address();
        let args = NewForkedEvm {
            fork_url: local_evm.url(),
            fork_block_number: None,
        };
        let fork = Forker::new_with_fork(args, None, None).await.unwrap();
        let fork = Arc::new(fork); // Wrap in Arc for shared ownership

        let mut handles = vec![];
        for _ in 0..1000 {
            let fork_clone = Arc::clone(&fork); // Clone the Arc for each thread
            let handle = tokio::spawn(async move {
                fork_clone
                    .fork_eval(ForkEvalArgs {
                        rainlang_string: r"_: 3;".into(),
                        source_index: 0,
                        deployer,
                        namespace: FullyQualifiedNamespace::default(),
                        context: vec![],
                        decode_errors: true,
                        state_overlay: vec![],
                        inputs: vec![],
                    })
                    .await
                    .unwrap()
            });
            handles.push(handle);
        }

        for handle in handles {
            let res = handle.await.unwrap();
            assert_eq!(
                res.typed_return.stack,
                vec![FixedBytes::left_padding_from(&[3u8])]
            );
        }
    }
}
