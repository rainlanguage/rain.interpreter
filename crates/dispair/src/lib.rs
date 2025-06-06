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
    use alloy::providers::mock::Asserter;
    use tracing_subscriber::FmtSubscriber;

    #[tokio::test]
    async fn test_from_deployer() {
        setup_tracing();

        let asserter = Asserter::new();
        let deployer_address = "0x1111111111111111111111111111111111111111"
            .parse::<Address>()
            .unwrap();
        let interpreter_address = "2222222222222222222222222222222222222222";
        let store_address = "3333333333333333333333333333333333333333";
        let parser_address = "4444444444444444444444444444444444444444";

        asserter.push_success(&format!("0x{interpreter_address:0>64}"));
        asserter.push_success(&format!("0x{store_address:0>64}"));
        asserter.push_success(&format!("0x{parser_address:0>64}"));

        let client = ReadableClient::new_mocked(asserter);
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
