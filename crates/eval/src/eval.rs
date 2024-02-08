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
        let parser = self
            .read(Address::default(), deployer, iParserCall {})
            .unwrap()
            .typed_return
            ._0;

        let parse_call = parseCall {
            data: rainlang_string.as_bytes().to_vec(),
        };

        let parse_result = self.read(Address::default(), parser, parse_call).unwrap();

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
        let expression_config = self
            .fork_parse(rainlang_string, deployer)
            .await
            .unwrap()
            .typed_return;

        let store = self
            .read(Address::default(), deployer, iStoreCall {})
            .unwrap()
            .typed_return
            ._0;

        let interpreter = self
            .read(Address::default(), deployer, iInterpreterCall {})
            .unwrap()
            .typed_return
            ._0;

        let deploy_call = deployExpression2Call {
            bytecode: expression_config.bytecode,
            constants: expression_config.constants,
        };

        let deploy_return = self
            .read(Address::default(), deployer, deploy_call)
            .unwrap()
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

        let eval_result = self
            .read(Address::default(), interpreter, eval_args)
            .unwrap();

        Ok(eval_result)
    }
}
