use alloy_ethers_typecast::transaction::{ReadContractParametersBuilder, ReadableClientHttp};
use alloy_primitives::*;
use anyhow::*;
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
    pub async fn from_deployer(
        deployer: Address,
        client: ReadableClientHttp,
    ) -> anyhow::Result<Self> {
        let mut dispair = Self::default();

        dispair.deployer = deployer;

        dispair.interpreter = client
            .read(
                ReadContractParametersBuilder::default()
                    .address(deployer)
                    .call(DeployerISP::iInterpreterCall {})
                    .build()?,
            )
            .await?
            ._0;

        dispair.store = client
            .read(
                ReadContractParametersBuilder::default()
                    .address(deployer)
                    .call(DeployerISP::iStoreCall {})
                    .build()?,
            )
            .await?
            ._0;

        dispair.parser = client
            .read(
                ReadContractParametersBuilder::default()
                    .address(deployer)
                    .call(DeployerISP::iParserCall {})
                    .build()?,
            )
            .await?
            ._0;

        Ok(dispair)
    }
}
