use crate::registry::{IExpressionDeployerV3, IInterpreterStoreV1, IInterpreterV2, IParserV1};
use ethers::contract::ContractError;
use ethers::{
    providers::{Http, Provider},
    types::H160,
};

/// DISPair
/// Struct representing DISP instances.
pub struct DISPair {
    pub deployer: IExpressionDeployerV3<Provider<Http>>,
    pub interpreter: IInterpreterV2<Provider<Http>>,
    pub store: IInterpreterStoreV1<Provider<Http>>,
    pub parser: IParserV1<Provider<Http>>,
}

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

#[cfg(test)]
pub mod test {
    use ethers::contract::ContractError;
    use ethers::providers::{Http, Provider};
    use crate::registry::IExpressionDeployerV3;
    use std::str::FromStr;
    use std::sync::Arc;
    use ethers::types::{H160, Address};

    #[tokio::test]
    pub async fn test_dispair_happy_path() -> Result<(),ContractError<Provider<Http>>>  {
        let rpc_url = "https://polygon.llamarpc.com/".to_string();
        let provider = Provider::<Http>::try_from(rpc_url.clone()).unwrap();
        let deployer_npe2_address = H160::from_str("0xD61d03501E95D4B507566fB42Ca2299595c4B1e6").unwrap();
        let deployer_npe2: IExpressionDeployerV3<ethers::providers::Provider<ethers::providers::Http>> =
        IExpressionDeployerV3::new(deployer_npe2_address, Arc::new(provider.clone()));  

        let disp = deployer_npe2.try_build_dispair().await?; 

        assert_eq!(H160::from_str("0xD61d03501E95D4B507566fB42Ca2299595c4B1e6").unwrap(),disp.deployer.address());
        assert_eq!(H160::from_str("0xf374faFE473D76bf9518e437B484FbdD5674daFf").unwrap(),disp.interpreter.address());
        assert_eq!(H160::from_str("0x5b777FAca336c648262e9c65a3c7A372a08c205b").unwrap(),disp.store.address());
        assert_eq!(H160::from_str("0x63954a113cbDB20A4fD1Ac7DD76c9eDA29727f2D").unwrap(),disp.parser.address());

        Ok(())
    }

    #[tokio::test]
    pub async fn test_dispair_fail() -> Result<(),ContractError<Provider<Http>>>  {
        let rpc_url = "https://polygon.llamarpc.com/".to_string();
        let provider = Provider::<Http>::try_from(rpc_url.clone()).unwrap();
        let deployer_npe2_address = Address::zero();
        let deployer_npe2: IExpressionDeployerV3<ethers::providers::Provider<ethers::providers::Http>> =
        IExpressionDeployerV3::new(deployer_npe2_address, Arc::new(provider.clone()));  

        let disp = deployer_npe2.try_build_dispair().await; 
        assert!(disp.is_err());
    
        Ok(())
    }
}