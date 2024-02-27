use alloy_primitives::{Address, U256};
use alloy_sol_types::SolCall;
use rain_interpreter_bindings::DeployerISP::{iInterpreterCall, iParserCall, iStoreCall};
use rain_interpreter_bindings::IExpressionDeployerV3::deployExpression2Call;
use rain_interpreter_bindings::IInterpreterStoreV1::FullyQualifiedNamespace;
use rain_interpreter_bindings::IInterpreterV2::eval2Call;
use rain_interpreter_bindings::IParserV1::parseCall;
use revm::interpreter::InstructionResult;

use crate::dispatch::CreateEncodedDispatch;
use crate::error::{selector_registry_abi_decode, ForkCallError};
use crate::fork::{ForkTypedReturn, Forker};

#[derive(Debug, Clone)]
pub struct ForkEvalArgs {
    pub rainlang_string: String,
    pub source_index: u16,
    pub deployer: Address,
    pub namespace: FullyQualifiedNamespace,
    pub context: Vec<Vec<U256>>,
}

#[derive(Debug, Clone)]
pub struct ForkParseArgs {
    pub rainlang_string: String,
    pub deployer: Address,
}

impl From<ForkEvalArgs> for ForkParseArgs {
    fn from(args: ForkEvalArgs) -> Self {
        ForkParseArgs {
            rainlang_string: args.rainlang_string,
            deployer: args.deployer,
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
    /// fork's current block.
    ///
    /// # Returns
    ///
    /// The typed return of the parse and deployExpression2, plus Foundry's RawCallResult struct.
    pub async fn fork_parse(
        &mut self,
        args: ForkParseArgs,
    ) -> Result<
        (
            ForkTypedReturn<parseCall>,
            ForkTypedReturn<deployExpression2Call>,
        ),
        ForkCallError,
    > {
        let ForkParseArgs {
            rainlang_string,
            deployer,
        } = args;
        let parser = self
            .alloy_call(Address::default(), deployer, iParserCall {})?
            .typed_return
            ._0;

        let parse_call = parseCall {
            data: rainlang_string.as_bytes().to_vec(),
        };

        let parse_raw_result = self.call(
            Address::default().as_slice(),
            parser.as_slice(),
            &parse_call.abi_encode(),
        )?;

        if parse_raw_result.exit_reason == InstructionResult::Revert {
            // decode result bytes to error selectors if it was a revert
            return Err(ForkCallError::AbiDecodedError(
                selector_registry_abi_decode(&parse_raw_result.result).await?,
            ));
        }
        if !parse_raw_result.exit_reason.is_ok() {
            return Err(ForkCallError::Failed(parse_raw_result));
        }

        let parse_result: ForkTypedReturn<parseCall> = ForkTypedReturn {
            typed_return: parseCall::abi_decode_returns(&parse_raw_result.result.0, true).map_err(
                |e| ForkCallError::TypedError(format!("Call:\"parseCall\" Error:{:?}", e)),
            )?,
            raw: parse_raw_result,
        };

        // Call deployer: deployExpression2Call
        let call = deployExpression2Call {
            constants: parse_result.typed_return.constants.clone(),
            bytecode: parse_result.typed_return.bytecode.clone(),
        };
        let integrity_raw_result = self.call(
            Address::default().as_slice(),
            deployer.as_slice(),
            &call.abi_encode(),
        )?;

        if integrity_raw_result.exit_reason == InstructionResult::Revert {
            // decode result bytes to error selectors if it was a revert
            return Err(ForkCallError::AbiDecodedError(
                selector_registry_abi_decode(&integrity_raw_result.result).await?,
            ));
        }
        if !integrity_raw_result.exit_reason.is_ok() {
            return Err(ForkCallError::Failed(integrity_raw_result));
        }

        let integrity_result: ForkTypedReturn<deployExpression2Call> = ForkTypedReturn {
            typed_return: deployExpression2Call::abi_decode_returns(
                &integrity_raw_result.result.0,
                true,
            )
            .map_err(|e| {
                ForkCallError::TypedError(format!("Call:\"deployExpression2Call\" Error:{:?}", e))
            })?,
            raw: integrity_raw_result,
        };

        Ok((parse_result, integrity_result))
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
        &mut self,
        args: ForkEvalArgs,
    ) -> Result<ForkTypedReturn<eval2Call>, ForkCallError> {
        let ForkEvalArgs {
            rainlang_string,
            source_index,
            deployer,
            namespace,
            context,
        } = args;
        let (expression_config_result, _) = self
            .fork_parse(ForkParseArgs {
                rainlang_string: rainlang_string.clone(),
                deployer,
            })
            .await?;
        let expression_config = expression_config_result.typed_return;

        let store = self
            .alloy_call(Address::default(), deployer, iStoreCall {})?
            .typed_return
            ._0;

        let interpreter = self
            .alloy_call(Address::default(), deployer, iInterpreterCall {})?
            .typed_return
            ._0;

        let deploy_call = deployExpression2Call {
            bytecode: expression_config.bytecode,
            constants: expression_config.constants,
        };

        let deploy_return = self
            .alloy_call_committing(Address::default(), deployer, deploy_call, U256::from(0))?
            .typed_return;

        let dispatch =
            CreateEncodedDispatch::encode(&deploy_return.expression, source_index, u16::MAX);

        let eval_args = eval2Call {
            store,
            namespace: namespace.into(),
            dispatch: dispatch.into(),
            context,
            inputs: vec![],
        };

        self.alloy_call(Address::default(), interpreter, eval_args)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::fork::NewForkedEvm;
    use alloy_primitives::{BlockNumber, Bytes};

    const FORK_URL: &str = "https://rpc.ankr.com/polygon_mumbai";
    const FORK_BLOCK_NUMBER: BlockNumber = 45658085;

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_fork_parse() {
        let deployer: Address = "0x0754030e91F316B2d0b992fe7867291E18200A77"
            .parse::<Address>()
            .unwrap();
        let args = NewForkedEvm {
            fork_url: FORK_URL.to_owned(),
            fork_block_number: Some(FORK_BLOCK_NUMBER),
        };
        let mut fork = Forker::new_with_fork(args, None, None).await;
        let res = fork
            .fork_parse(ForkParseArgs {
                rainlang_string: r"_: int-add(1 2);".to_owned(),
                deployer,
            })
            .await
            .unwrap();

        let res_bytecode = res.0.typed_return.bytecode;
        let expected_bytes = "0x01000003020001010000010100000038020000"
            .parse::<Bytes>()
            .unwrap()
            .to_vec();

        assert_eq!(res_bytecode, expected_bytes);

        let res_constants = res.0.typed_return.constants;
        let expected_constants = vec![U256::from(1), U256::from(2)];

        assert_eq!(res_constants, expected_constants);
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_fork_eval() {
        let deployer: Address = "0x0754030e91F316B2d0b992fe7867291E18200A77"
            .parse::<Address>()
            .unwrap();
        let args = NewForkedEvm {
            fork_url: FORK_URL.to_owned(),
            fork_block_number: Some(FORK_BLOCK_NUMBER),
        };
        let mut fork = Forker::new_with_fork(args, None, None).await;
        let res = fork
            .fork_eval(ForkEvalArgs {
                rainlang_string: r"_: int-add(1 2);".into(),
                source_index: 0,
                deployer,
                namespace: FullyQualifiedNamespace::default(),
                context: vec![],
            })
            .await
            .unwrap();

        // stack
        let expected_stack = vec![U256::from(3)];
        assert_eq!(res.typed_return.stack, expected_stack);

        // storage writes
        let expected_writes = vec![];
        assert_eq!(res.typed_return.writes, expected_writes);

        // stack in the trace for source index 0
        let mut expected_stack_trace = vec![0u8, 0u8, 0u8, 0u8];
        expected_stack_trace.append(&mut U256::from(3).to_be_bytes_vec());
        let source_index_zero_trace = res.raw.traces.unwrap().into_nodes()[1].to_owned().trace;
        assert_eq!(source_index_zero_trace.data, expected_stack_trace);

        // asserting the known trace address
        let expected_trace_address = "0xF06Cd48c98d7321649dB7D8b2C396A81A2046555"
            .parse::<Address>()
            .unwrap();
        let trace_address = Address::from(source_index_zero_trace.address.into_array());
        assert_eq!(trace_address, expected_trace_address);
    }
}
