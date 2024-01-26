use alloy_ethers_typecast::transaction::{
    ReadContractParametersBuilder, ReadContractParametersBuilderError, ReadableClient,
    ReadableClientError,
};
use alloy_primitives::*;
use ethers::providers::JsonRpcClient;
use rain_interpreter_bindings::IParserV1::*;
use rain_interpreter_dispair::DISPair;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ParserError {
    #[error(transparent)]
    ReadableClientError(#[from] ReadableClientError),
    #[error(transparent)]
    ReadContractParametersBuilderError(#[from] ReadContractParametersBuilderError),
}

pub trait Parser {
    /// Call Parser contract to parse the provided rainlang text.
    fn parse_text<T: JsonRpcClient>(
        &self,
        text: &str,
        client: ReadableClient<T>,
    ) -> impl std::future::Future<Output = Result<parseReturn, ParserError>> + Send
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
    ) -> impl std::future::Future<Output = Result<parseReturn, ParserError>> + Send;
}
/// ParserV1
/// Struct representing ParserV1 instances.
#[derive(Clone, Default)]
pub struct ParserV1 {
    pub address: Address,
}

impl From<DISPair> for ParserV1 {
    fn from(val: DISPair) -> Self {
        Self {
            address: val.parser,
        }
    }
}

impl Parser for ParserV1 {
    async fn parse<T: JsonRpcClient>(
        &self,
        data: Vec<u8>,
        client: ReadableClient<T>,
    ) -> Result<parseReturn, ParserError> {
        client
            .read(
                ReadContractParametersBuilder::default()
                    .address(self.address)
                    .call(parseCall { data })
                    .build()
                    .map_err(|e| ParserError::ReadContractParametersBuilderError(e))?,
            )
            .await
            .map_err(|e| ParserError::ReadableClientError(e))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use alloy_primitives::{Address, U256};
    use ethers::providers::{MockProvider, MockResponse, Provider};

    #[tokio::test]
    async fn test_from_dispair() {
        let parser_address = Address::repeat_byte(0x4);

        let dispair = DISPair {
            deployer: Address::repeat_byte(0x1),
            interpreter: Address::repeat_byte(0x2),
            store: Address::repeat_byte(0x3),
            parser: parser_address,
        };

        let parser: ParserV1 = dispair.clone().into();

        assert_eq!(parser.address, dispair.parser);
        assert_eq!(parser.address, parser_address);
    }

    #[tokio::test]
    async fn test_parse() {
        let transport = MockProvider::default();
        transport.push_response(MockResponse::Value(serde_json::Value::String(
            [
                "0x0000000000000000000000000000000000000000000000000000000000000040", // offset to start of bytecode
                "0000000000000000000000000000000000000000000000000000000000000080", // offset to start of constants
                "0000000000000000000000000000000000000000000000000000000000000002", // length of bytecode
                "1234000000000000000000000000000000000000000000000000000000000000", // bytecode
                "0000000000000000000000000000000000000000000000000000000000000002", // length of constants
                "0000000000000000000000000000000000000000000000000000000000000003", // constants[0]
                "0000000000000000000000000000000000000000000000000000000000000004",
            ]
            .concat(),
        )));

        let client = ReadableClient::new(Provider::new(transport));
        let parser = ParserV1 {
            address: Address::repeat_byte(0x1),
        };

        let result = parser.parse_text("my rainlang", client).await.unwrap();

        assert_eq!(result.bytecode, hex!("1234"));
        assert_eq!(result.constants, vec![U256::from(3), U256::from(4)]);
    }

    #[tokio::test]
    async fn test_parse_text() {
        let rainlang = "my rainlang";

        let transport = MockProvider::default();
        transport.push_response(MockResponse::Value(serde_json::Value::String(
            [
                "0x0000000000000000000000000000000000000000000000000000000000000040", // offset to start of bytecode
                "0000000000000000000000000000000000000000000000000000000000000080", // offset to start of constants
                "000000000000000000000000000000000000000000000000000000000000000b", // length of bytecode
                "6d79207261696e6c616e67000000000000000000000000000000000000000000", // bytecode
                "0000000000000000000000000000000000000000000000000000000000000002", // length of constants
                "0000000000000000000000000000000000000000000000000000000000000003", // constants[0]
                "0000000000000000000000000000000000000000000000000000000000000004",
            ]
            .concat(),
        )));

        let client = ReadableClient::new(Provider::new(transport));
        let parser = ParserV1 {
            address: Address::repeat_byte(0x1),
        };

        let result = parser.parse_text(rainlang, client).await.unwrap();

        assert_eq!(result.bytecode, hex!("6d79207261696e6c616e67"));
        assert_eq!(result.constants, vec![U256::from(3), U256::from(4)]);
    }
}
