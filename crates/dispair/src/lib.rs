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
    use rain_interpreter_test_fixtures::LocalEvm;

    #[tokio::test]
    async fn test_from_deployer() {
        let local_evm = LocalEvm::new().await;
        let deployer = *local_evm.deployer.address();
        let client = ReadableClient::new_from_url(local_evm.url())
            .await
            .expect("Failed to create ReadableClient");
        let dispair = DISPair::from_deployer(deployer, client).await.unwrap();

        assert_eq!(dispair.deployer, deployer);
        assert_eq!(dispair.interpreter, *local_evm.interpreter.address());
        assert_eq!(dispair.store, *local_evm.store.address());
        assert_eq!(dispair.parser, *local_evm.parser.address());
    }
}
