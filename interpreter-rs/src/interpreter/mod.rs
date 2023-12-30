
use crate::registry::IExpressionDeployerV3; 
use crate::registry::{ IInterpreterStoreV1, IInterpreterV2, IParserV1};
use ethers::contract::ContractError;
use ethers::{
    providers::{Http, Provider},
    types::H160,
};
use mockall::automock;


/// DISPair
/// Struct representing DISP instances.
pub struct DISPair {
    pub deployer: IExpressionDeployerV3<Provider<Http>>,
    pub interpreter: IInterpreterV2<Provider<Http>>,
    pub store: IInterpreterStoreV1<Provider<Http>>,
    pub parser: IParserV1<Provider<Http>>,
}

#[automock]
/// Implementation to build DISPair from Deployer instance.
impl IExpressionDeployerV3<Provider<Http>> {
    pub async fn try_build_dispair(&self) -> Result<DISPair, ContractError<Provider<Http>>> {
        let arc_client = self.client();
        let interpreter_address: H160 = self.i_interpreter().call().await?.to_fixed_bytes().into();
        let store_address: H160 = self.i_store().call().await?.to_fixed_bytes().into();
        let parser_address: H160 = self.i_parser().call().await?.to_fixed_bytes().into();

        Ok(DISPair {
            deployer: self.clone(),
            interpreter: IInterpreterV2::new(interpreter_address, arc_client.clone()),
            store: IInterpreterStoreV1::new(store_address, arc_client.clone()),
            parser: IParserV1::new(parser_address, arc_client.clone()),
        })
    }
}
