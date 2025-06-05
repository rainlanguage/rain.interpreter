use alloy::primitives::*;
use alloy_ethers_typecast::transaction::{
    ReadContractParametersBuilder, ReadContractParametersBuilderError, ReadableClient,
    ReadableClientError,
};
use rain_interpreter_bindings::DeployerISP;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum DISPairError {
    #[error(transparent)]
    ReadableClientError(#[from] ReadableClientError),
    #[error(transparent)]
    ReadContractParametersBuilderError(#[from] ReadContractParametersBuilderError),
}

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
    pub async fn from_deployer(
        deployer: Address,
        client: ReadableClient,
    ) -> Result<Self, DISPairError> {
        Ok(DISPair {
            deployer,
            interpreter: client
                .read(
                    ReadContractParametersBuilder::default()
                        .address(deployer)
                        .call(DeployerISP::iInterpreterCall {})
                        .build()
                        .map_err(DISPairError::ReadContractParametersBuilderError)?,
                )
                .await
                .map_err(DISPairError::ReadableClientError)?,
            store: client
                .read(
                    ReadContractParametersBuilder::default()
                        .address(deployer)
                        .call(DeployerISP::iStoreCall {})
                        .build()
                        .map_err(DISPairError::ReadContractParametersBuilderError)?,
                )
                .await
                .map_err(DISPairError::ReadableClientError)?,
            parser: client
                .read(
                    ReadContractParametersBuilder::default()
                        .address(deployer)
                        .call(DeployerISP::iParserCall {})
                        .build()
                        .map_err(DISPairError::ReadContractParametersBuilderError)?,
                )
                .await
                .map_err(DISPairError::ReadableClientError)?,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use alloy::primitives::Address;
    use ethers::providers::{MockProvider, MockResponse, Provider};
    use serde_json::json;
    use tracing_subscriber::FmtSubscriber;

    #[tokio::test]
    async fn test_from_deployer() {
        setup_tracing();

        // MockProvider for testing
        let transport = MockProvider::default();
        let deployer_address = "0x1234567890123456789012345678901234567890"
            .parse::<Address>()
            .unwrap();
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
        let dispair = DISPair::from_deployer(deployer_address, client)
            .await
            .unwrap();

        assert_eq!(dispair.deployer, deployer_address);
        assert_eq!(
            dispair.interpreter,
            interpreter_address.parse::<Address>().unwrap()
        );
        assert_eq!(dispair.store, store_address.parse::<Address>().unwrap());
        assert_eq!(dispair.parser, parser_address.parse::<Address>().unwrap());
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
