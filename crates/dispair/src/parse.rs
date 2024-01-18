use super::*;
use rain_interpreter_bindings::IParserV1;

impl DISPair {
    pub async fn parse<T: JsonRpcClient>(
        &self,
        input: &str,
        client: ReadableClient<T>,
    ) -> anyhow::Result<IParserV1::parseReturn> {
        let result = client
            .read(
                ReadContractParametersBuilder::default()
                    .address(self.parser)
                    .call(IParserV1::parseCall {
                        data: input.as_bytes().to_vec(),
                    })
                    .build()?,
            )
            .await?;
        Ok(result)
    }
}

// #[cfg(test)]
// mod tests {
//     use std::str::FromStr;

//     use super::*;
//     use alloy_primitives::Address;
//     use ethers::providers::{MockProvider, MockResponse, Provider};
//     use serde_json::json;

//     #[tokio::test]
//     async fn test_parse() -> Result<(), Error> {
//         // MockProvider for testing
//         let transport = MockProvider::default();
//         let deployer_address = "0x1234567890123456789012345678901234567890".parse::<Address>()?;
//         let interpreter_address = "1234567890123456789012345678901234567891";
//         let store_address = "1234567890123456789012345678901234567892";
//         let parser_address = "1234567890123456789012345678901234567893";

//         // Mock responses for the read calls - the responses will be popped off
//         // the stack in the reverse order they are pushed on.
//         transport.push_response(MockResponse::Value(json!(format!(
//             "0x{:0>64}",
//             parser_address
//         ))));

//         transport.push_response(MockResponse::Value(json!(format!(
//             "0x{:0>64}",
//             store_address
//         ))));

//         transport.push_response(MockResponse::Value(json!(format!(
//             "0x{:0>64}",
//             interpreter_address
//         ))));

//         let client = ReadableClient::new(Provider::new(transport));
//         let dispair = DISPair::from_deployer(deployer_address, client).await?;

//         let expected_return = IParserV1::parseReturn {
//             bytecode: hex!("1234").to_vec(),
//             constants: vec![U256::from_str("0x1234")?, U256::from_str("0x1234")?],
//         };

//         let transport = MockProvider::default();
//         transport.push_response(MockResponse::Value(json!([
//             "0x0000000000000000000000000000000000000000000000000000000000000060",
//             "0000000000000000000000000000000000000000000000000000000000001234",
//             "0000000000000000000000000000000000000000000000000000000000001234",
//             "0000000000000000000000000000000000000000000000000000000000000002",
//             "0000000000000000000000000000000000000000000000000000000000001234"
//         ]
//         .concat())));
//         let client = ReadableClient::new(Provider::new(transport));

//         let result = dispair.parse("this doesn't matter", client).await?;

//         assert_eq!(result.bytecode, hex!("1234"));
//         assert_eq!(
//             result.constants,
//             vec![U256::from_str("0x1234")?, U256::from_str("0x1234")?]
//         );
//         Ok(())
//     }
// }
