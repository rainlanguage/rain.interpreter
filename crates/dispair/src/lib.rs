use alloy::primitives::*;
use alloy_ethers_typecast::{
    ReadContractParametersBuilder, ReadContractParametersBuilderError, ReadableClient,
    ReadableClientError,
};
use rain_interpreter_bindings::DeployerISP::{interpreterCall, parserCall, storeCall};
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
                        .call(interpreterCall {})
                        .build()
                        .map_err(DISPairError::ReadContractParametersBuilderError)?,
                )
                .await
                .map_err(DISPairError::ReadableClientError)?,
            store: client
                .read(
                    ReadContractParametersBuilder::default()
                        .address(deployer)
                        .call(storeCall {})
                        .build()
                        .map_err(DISPairError::ReadContractParametersBuilderError)?,
                )
                .await
                .map_err(DISPairError::ReadableClientError)?,
            parser: client
                .read(
                    ReadContractParametersBuilder::default()
                        .address(deployer)
                        .call(parserCall {})
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
        // The deployer returns the deterministic Zoltu addresses, not the
        // addresses where the contracts were originally deployed.
        let expected_interpreter: Address = "0x288F6ef6f56617963B80c6136eB93b3b9839Dfc2"
            .parse()
            .unwrap();
        let expected_store: Address = "0x08d847643144D0bC1964b024b2CcCFFB94836f79"
            .parse()
            .unwrap();
        let expected_parser: Address = "0x34ACfD304C67a78b8b3b64a1A3ae19b6854Fb5C1"
            .parse()
            .unwrap();
        assert_eq!(dispair.interpreter, expected_interpreter);
        assert_eq!(dispair.store, expected_store);
        assert_eq!(dispair.parser, expected_parser);
    }
}
