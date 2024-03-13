use crate::error::{selector_registry_abi_decode, ForkCallError};
use crate::fork::{ForkTypedReturn, Forker};
use alloy_primitives::{Address, U256};
use alloy_sol_types::SolCall;
use rain_interpreter_bindings::DeployerISP::{iInterpreterCall, iParserCall, iStoreCall};
use rain_interpreter_bindings::IExpressionDeployerV3::deployExpression2Call;
use rain_interpreter_bindings::IInterpreterStoreV1::FullyQualifiedNamespace;
use rain_interpreter_bindings::IInterpreterV3::eval3Call;
use rain_interpreter_bindings::IParserV2::parse2Call;
use revm::interpreter::InstructionResult;

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
            ForkTypedReturn<parse2Call>,
            ForkTypedReturn<deployExpression2Call>,
        ),
        ForkCallError,
    > {
        let ForkParseArgs {
            rainlang_string,
            deployer,
        } = args;

        let parse_call = parse2Call {
            data: rainlang_string.as_bytes().to_vec(),
        };

        let parse_raw_result = self.call(
            Address::default().as_slice(),
            deployer.as_slice(),
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

        let parse_result: ForkTypedReturn<parse2Call> = ForkTypedReturn {
            typed_return: parse2Call::abi_decode_returns(&parse_raw_result.result.0, true)
                .map_err(|e| {
                    ForkCallError::TypedError(format!("Call:\"parseCall\" Error:{:?}", e))
                })?,
            raw: parse_raw_result,
        };

        println!("parse_result: {:?}", parse_result.raw);

        let (bytecode, constants) = Forker::deserialize(&parse_result.raw.result)?;

        // Call deployer: deployExpression2Call
        let call = deployExpression2Call {
            constants,
            bytecode: bytecode.clone(),
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
    ) -> Result<ForkTypedReturn<eval3Call>, ForkCallError> {
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

        let store = self
            .alloy_call(Address::default(), deployer, iStoreCall {})?
            .typed_return
            ._0;

        let interpreter = self
            .alloy_call(Address::default(), deployer, iInterpreterCall {})?
            .typed_return
            ._0;

        println!(
            "expression_config_result: {:?}",
            expression_config_result.raw.result
        );

        let eval_args = eval3Call {
            bytecode: expression_config_result.raw.result.to_vec(),
            sourceIndex: U256::from(source_index),
            store,
            namespace: namespace.into(),
            context,
            inputs: vec![],
        };

        self.alloy_call(Address::default(), interpreter, eval_args)
    }

    fn deserialize(bytecode_and_constants: &[u8]) -> Result<(Vec<u8>, Vec<U256>), ForkCallError> {
        if bytecode_and_constants.len() < 64 {
            // Ensure there's enough data for at least one constant and the 0x40 bytes
            return Err(ForkCallError::DeserializeFailed("Data too short".into()));
        }

        // Calculate the start of the constants section, assuming the last 64 bytes are for constants count and alignment
        let constants_start = bytecode_and_constants.len() - 64;
        let constants_bytes = &bytecode_and_constants[constants_start..(constants_start + 32)]; // Assuming the 32 bytes before the last 32 bytes represent the constants

        // Calculate the number of constants. Assuming each constant is 32 bytes and the total size includes the 0x40 bytes metadata.
        let constants_count = (constants_bytes.len() - 64) / 32;

        // Extract the bytecode
        let bytecode = bytecode_and_constants[..constants_start].to_vec();

        // Extract the constants
        let mut constants = Vec::new();
        for i in 0..constants_count {
            let start = constants_start + i * 32;
            let end = start + 32;
            let mut constant = [0u8; 32];
            constant.copy_from_slice(&bytecode_and_constants[start..end]);
            let u256 = U256::from_be_bytes(constant);
            constants.push(u256);
        }

        Ok((bytecode, constants))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::fork::NewForkedEvm;
    use alloy_primitives::{BlockNumber, Bytes};

    const FORK_URL: &str = "https://rpc.ankr.com/polygon_mumbai";
    const FORK_BLOCK_NUMBER: BlockNumber = 46995226;

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_fork_parse() {
        let deployer: Address = "0x9F83166c8BCB340D494f7cd1313cC36A59E9e75B"
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

        let (bytecode, constants) = Forker::deserialize(&res_bytecode).unwrap();

        let expected_bytes: Vec<u8> =
            vec![1, 0, 0, 3, 2, 0, 1, 1, 16, 0, 1, 1, 16, 0, 0, 61, 18, 0, 0];
        assert_eq!(bytecode, expected_bytes);

        let expected_constants = vec![U256::from(1), U256::from(2)];

        assert_eq!(constants, expected_constants);
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_fork_eval() {
        let deployer: Address = "0x9F83166c8BCB340D494f7cd1313cC36A59E9e75B"
            .parse::<Address>()
            .unwrap();
        let args = NewForkedEvm {
            fork_url: FORK_URL.to_owned(),
            fork_block_number: Some(FORK_BLOCK_NUMBER),
        };
        let mut fork = Forker::new_with_fork(args, None, None).await;
        let res = fork
            .fork_eval(ForkEvalArgs {
                rainlang_string: r"_: int-add(1 6);".into(),
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
