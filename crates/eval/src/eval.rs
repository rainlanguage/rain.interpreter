use alloy_primitives::{Address, U256};
use rain_interpreter_bindings::DeployerISP::{iInterpreterCall, iParserCall, iStoreCall};
use rain_interpreter_bindings::IExpressionDeployerV3::deployExpression2Call;
use rain_interpreter_bindings::IInterpreterStoreV1::FullyQualifiedNamespace;
use rain_interpreter_bindings::IInterpreterV2::eval2Call;
use rain_interpreter_bindings::IParserV1::parseCall;

use crate::dispatch::CreateEncodedDispatch;
use crate::fork::{ForkCallError, ForkTypedReturn, ForkedEvm};

impl ForkedEvm {
    pub async fn fork_parse(
        self: &mut ForkedEvm,
        rainlang_string: &str,
        deployer: Address,
    ) -> Result<ForkTypedReturn<parseCall>, ForkCallError> {
        let mut executor = self.build_executor();
        let parser = self
            .read(
                Some(&mut executor),
                Address::default(),
                deployer,
                iParserCall {},
            )?
            .typed_return
            ._0;

        let parse_call = parseCall {
            data: rainlang_string.as_bytes().to_vec(),
        };

        let parse_result = self
            .read(Some(&mut executor), Address::default(), parser, parse_call)
            .unwrap();

        Ok(parse_result)
    }

    pub async fn fork_eval(
        self: &mut ForkedEvm,
        rainlang_string: &str,
        source_index: u16,
        deployer: Address,
        namespace: FullyQualifiedNamespace,
        context: Vec<Vec<U256>>,
    ) -> Result<ForkTypedReturn<eval2Call>, ForkCallError> {
        let mut executor = self.build_executor();
        let expression_config = self
            .fork_parse(rainlang_string, deployer)
            .await?
            .typed_return;

        let store = self
            .read(
                Some(&mut executor),
                Address::default(),
                deployer,
                iStoreCall {},
            )?
            .typed_return
            ._0;

        let interpreter = self
            .read(
                Some(&mut executor),
                Address::default(),
                deployer,
                iInterpreterCall {},
            )?
            .typed_return
            ._0;

        let deploy_call = deployExpression2Call {
            bytecode: expression_config.bytecode,
            constants: expression_config.constants,
        };

        let deploy_return = self
            .write(
                Some(&mut executor),
                Address::default(),
                deployer,
                deploy_call,
                U256::from(0),
            )?
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

        let eval_result = self.read(
            Some(&mut executor),
            Address::default(),
            interpreter,
            eval_args,
        );

        eval_result
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use alloy_primitives::BlockNumber;

    const FORK_URL: &str = "https://rpc.ankr.com/polygon_mumbai";
    const FORK_BLOCK_NUMBER: BlockNumber = 45658085;

    // 0xF06Cd48c98d7321649dB7D8b2C396A81A2046555

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_fork_eval() {
        let deployer_address: Address = "0x0754030e91F316B2d0b992fe7867291E18200A77"
            .parse::<Address>()
            .unwrap();
        let mut fork = ForkedEvm::new(FORK_URL, Some(FORK_BLOCK_NUMBER)).await;
        match fork
            .fork_eval(
                r"_: int-add(1 2);",
                0,
                deployer_address,
                FullyQualifiedNamespace::default(),
                vec![],
            )
            .await
        {
            Ok(result) => {
                println!("{:?}", result.raw.traces);
            }
            Err(e) => {
                println!("{:?}", e);
            }
        }
    }
}
