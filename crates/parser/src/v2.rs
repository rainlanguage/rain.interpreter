use crate::error::ParserError;
use alloy_ethers_typecast::transaction::{ReadContractParametersBuilder, ReadableClient};
use alloy_primitives::*;
use ethers::providers::JsonRpcClient;
use rain_interpreter_bindings::IParserV2::*;
use rain_interpreter_dispair::DISPair;

pub trait Parser2 {
    /// Call Parser contract to parse the provided rainlang text.
    fn parse_text<T: JsonRpcClient>(
        &self,
        text: &str,
        client: ReadableClient<T>,
    ) -> impl std::future::Future<Output = Result<parse2Return, ParserError>> + Send
    where
        Self: Sync,
    {
        self.parse(text.as_bytes().to_vec(), client)
    }

    /// Call Parser contract to parse the provided data
    /// The provided data must contain valid UTF-8 encoding of valid rainlang text.
    fn parse<T: JsonRpcClient>(
        &self,
        data: Vec<u8>,
        client: ReadableClient<T>,
    ) -> impl std::future::Future<Output = Result<parse2Return, ParserError>> + Send;
}
/// ParserV2
/// Struct representing ParserV2 instances.
#[derive(Clone, Default)]
pub struct ParserV2 {
    pub deployer_address: Address,
}

impl From<DISPair> for ParserV2 {
    fn from(val: DISPair) -> Self {
        Self {
            deployer_address: val.deployer,
        }
    }
}

impl Parser2 for ParserV2 {
    async fn parse<T: JsonRpcClient>(
        &self,
        data: Vec<u8>,
        client: ReadableClient<T>,
    ) -> Result<parse2Return, ParserError> {
        client
            .read(
                ReadContractParametersBuilder::default()
                    .address(self.deployer_address)
                    .call(parse2Call { data })
                    .build()
                    .map_err(ParserError::ReadContractParametersBuilderError)?,
            )
            .await
            .map_err(ParserError::ReadableClientError)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use alloy_primitives::Address;
    use ethers::providers::{MockProvider, MockResponse, Provider};

    #[tokio::test]
    async fn test_from_dispair() {
        let deployer_address = Address::repeat_byte(0x4);

        let dispair = DISPair {
            deployer: deployer_address,
            interpreter: Address::repeat_byte(0x2),
            store: Address::repeat_byte(0x3),
            parser: Address::repeat_byte(0x1),
        };

        let parser: ParserV2 = dispair.clone().into();

        assert_eq!(parser.deployer_address, dispair.deployer);
        assert_eq!(parser.deployer_address, deployer_address);
    }

    #[tokio::test]
    async fn test_parse() {
        let transport = MockProvider::default();
        transport.push_response(MockResponse::Value(serde_json::Value::String(
            [
                "0x0000000000000000000000000000000000000000000000000000000000000020", // offset to start of bytecode
                "0000000000000000000000000000000000000000000000000000000000000002", // length of bytecode
                "1234000000000000000000000000000000000000000000000000000000000000", // bytecode
            ]
            .concat(),
        )));

        let client = ReadableClient::new(Provider::new(transport));
        let parser = ParserV2 {
            deployer_address: Address::repeat_byte(0x1),
        };

        let result = parser.parse_text("my rainlang", client).await.unwrap();

        assert_eq!(result.bytecode, hex!("1234"));
    }

    #[tokio::test]
    async fn test_parse_text() {
        let rainlang = "my rainlang";

        let transport = MockProvider::default();
        transport.push_response(MockResponse::Value(serde_json::Value::String(
            [
                "0x0000000000000000000000000000000000000000000000000000000000000020", // length of bytecode
                "000000000000000000000000000000000000000000000000000000000000000b", // offset to start of bytecode
                "6d79207261696e6c616e67000000000000000000000000000000000000000000", // bytecode
            ]
            .concat(),
        )));

        let client = ReadableClient::new(Provider::new(transport));
        let parser = ParserV2 {
            deployer_address: Address::repeat_byte(0x1),
        };

        let result = parser.parse_text(rainlang, client).await.unwrap();

        assert_eq!(result.bytecode, hex!("6d79207261696e6c616e67"));
    }
}
