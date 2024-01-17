use rain_interpreter_bindings::{
    IExpressionDeployerV3, IInterpreterStoreV1, IInterpreterV2, IParserV1,
};

/// DISPair
/// Struct representing DISP instances.
pub struct DISPair {
    pub deployer: IExpressionDeployerV3,
    pub interpreter: IInterpreterV2<Provider<Http>>,
    pub store: IInterpreterStoreV1<Provider<Http>>,
    pub parser: IParserV1<Provider<Http>>,
}

/// Implementation to build DISPair from Deployer instance.
impl IExpressionDeployerV {
    pub async fn try_build_dispair(&self) -> Result<DISPair, ContractError<Provider<Http>>> {
        Ok(DISPair {
            deployer: self.clone(),
            interpreter: IInterpreterV2::new(
                H160::from(self.i_interpreter().call().await?.to_fixed_bytes()),
                self.client().clone(),
            ),
            store: IInterpreterStoreV1::new(
                H160::from(self.i_store().call().await?.to_fixed_bytes()),
                self.client().clone(),
            ),
            parser: IParserV1::new(
                H160::from(self.i_parser().call().await?.to_fixed_bytes()),
                self.client().clone(),
            ),
        })
    }
}
