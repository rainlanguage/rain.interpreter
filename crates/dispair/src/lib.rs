use alloy_ethers_typecast::transaction::{ReadContractParametersBuilder, ReadableClient};
use alloy_primitives::*;
use anyhow::*;
use ethers::providers::JsonRpcClient;
use rain_interpreter_bindings::DeployerISP;

/// DISPair
/// Struct representing DISP instances.
#[derive(Clone, Default)]
pub struct DISPair {
    pub deployer: Address,
    pub interpreter: Address,
    pub store: Address,
    pub parser: Address,
}

/// Implementation to build DISPair from Deployer address.
impl DISPair {
    pub async fn from_deployer<T: JsonRpcClient>(
        deployer: Address,
        client: ReadableClient<T>,
    ) -> anyhow::Result<Self> {
        Ok(DISPair {
            deployer,
            interpreter: client
                .read(
                    ReadContractParametersBuilder::default()
                        .address(deployer)
                        .call(DeployerISP::iInterpreterCall {})
                        .build()?,
                )
                .await?
                ._0,
            store: client
                .read(
                    ReadContractParametersBuilder::default()
                        .address(deployer)
                        .call(DeployerISP::iStoreCall {})
                        .build()?,
                )
                .await?
                ._0,
            parser: client
                .read(
                    ReadContractParametersBuilder::default()
                        .address(deployer)
                        .call(DeployerISP::iParserCall {})
                        .build()?,
                )
                .await?
                ._0,
        })
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
    async fn test_from_deployer() -> Result<(), Error> {
        setup_tracing();

        // MockProvider for testing
        let transport = MockProvider::default();
        let deployer_address = "0x1234567890123456789012345678901234567890".parse::<Address>()?;
        let interpreter_address = "1234567890123456789012345678901234567891";
        let store_address = "1234567890123456789012345678901234567892";
        let parser_address = "1234567890123456789012345678901234567893";

        // Mock responses for the read calls - the responses will be popped off
        // the stack in the reverse order they are pushed on.
        transport.push_response(MockResponse::Value(json!(format!(
            "0x{:0>64}",
            parser_address
        ))));

        transport.push_response(MockResponse::Value(json!(format!(
            "0x{:0>64}",
            store_address
        ))));

        transport.push_response(MockResponse::Value(json!(format!(
            "0x{:0>64}",
            interpreter_address
        ))));

        let client = ReadableClient::new(Provider::new(transport));
        let dispair = DISPair::from_deployer(deployer_address, client).await?;

        assert_eq!(dispair.deployer, deployer_address);
        assert_eq!(dispair.interpreter, interpreter_address.parse::<Address>()?);
        assert_eq!(dispair.store, store_address.parse::<Address>()?);
        assert_eq!(dispair.parser, parser_address.parse::<Address>()?);
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
