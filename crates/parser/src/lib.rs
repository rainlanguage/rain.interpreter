use alloy_ethers_typecast::transaction::{ReadContractParametersBuilder, ReadableClient};
use alloy_primitives::*;
use anyhow::{anyhow, Result};
use ethers::providers::JsonRpcClient;
use rain_interpreter_bindings::IParserV1;
use rain_interpreter_dispair::DISPair;

pub trait Parser {
  /// Call Parser contract to parse the provided rainlang text.
  pub async fn parse_text(&self, rainlang: String) -> Result<Parse> {
    self.parse(text.as_bytes())
  }

  /// Call Parser contract to parse the provided data
  /// The provided data must contain valid UTF-8 encoding of valid rainlang text.
  pub async fn parse(
    &self,
    data: Vec<u8>
    client: ReadableClient<T>,
  ) -> Result<Parse>;
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
    pub async fn parse(
      &self,
      data: Vec<u8>
      client: ReadableClient<T>,
    ) -> Result<Parse> {
        Ok(
          client
            .read(
                ReadContractParametersBuilder::default()
                    .address(self.address)
                    .call(ParserV1 {
                      data
                    })
                    .build()?,
            )
            .await?
            ._0
          )
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use alloy_primitives::Address;
    use ethers::providers::{MockProvider, MockResponse, Provider};
    use serde_json::json;
    use tracing_subscriber::FmtSubscriber;

    #[tokio::test]
    async fn test_from_dispair() -> Result<(), Error> {
        setup_tracing();

        let parser_address = "1234567890123456789012345678901234567893";

        let dispair = DISPair {
          deployer: "",
          interpreter: "",
          store: "",
          parser: parser_address
        };

        let parser: ParserV1 = DISPair.into();

        assert_eq!(parser.address, dispair.parser);
        assert_eq!(parser.address, parser_address.parse::<Address>()?);
        Ok(())
    }

    #[tokio::test]
    async fn test_parse() -> Result<(), Error> {
        setup_tracing();

        // @todo add expected bytecode and constant values
        // Mock responses for the read calls - the responses will be popped off
        // the stack in the reverse order they are pushed on.
        let transport = MockProvider::default();
        transport.push_response(MockResponse::Value(json!(
          ("bytecode", "constants")
        )));

        let parser = ParserV1 {
          address: "1234567890123456789012345678901234567893"
        }; 
        let rainlang = "start-time: 160000,
end-time: 160600,
start-price: 100e18,
rate: 1e16

:ensure(
    every(
        gt(now() start-time))
        lt(now() end-time)),
    )
),

elapsed: sub(now() start-time),

max-amount: 1000e18,
price: sub(start-price mul(rate elapsed))
";
        let rainlang_utf8 = rainlang.as_bytes();
      
        let client = ReadableClient::new(Provider::new(transport));
        let response = parser.parse(rainlang_utf8, client).await?;

        Ok(())
    }

    #[tokio::test]
    async fn test_parse_text() -> Result<(), Error> {
        setup_tracing();

        // @todo add expected bytecode and constant values
        // Mock responses for the read calls - the responses will be popped off
        // the stack in the reverse order they are pushed on.
        let transport = MockProvider::default();
        transport.push_response(MockResponse::Value(json!(
          ("bytecode", "constants")
        )));

        let parser = ParserV1 {
          address: "1234567890123456789012345678901234567893"
        };
        let rainlang = "start-time: 160000,
end-time: 160600,
start-price: 100e18,
rate: 1e16

:ensure(
    every(
        gt(now() start-time))
        lt(now() end-time)),
    )
),

elapsed: sub(now() start-time),

max-amount: 1000e18,
price: sub(start-price mul(rate elapsed))
";

        let client = ReadableClient::new(Provider::new(transport));
        let response = parser.parse_text(rainlang, client).await?;        
        
        Ok(())
    }


    #[allow(dead_code)]
    fn setup_tracing() {
        let subscriber = FmtSubscriber::builder()
            .with_max_level(tracing::Level::DEBUG)
            .finish();

        tracing::subscriber::set_global_default(subscriber)
            .expect("Failed to set tracing subscriber");
    }
}
