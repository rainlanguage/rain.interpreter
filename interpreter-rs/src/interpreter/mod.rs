use alloy_primitives::{Bytes, U256};
use ethers::{
    providers::{Http, Provider},
    types::H160,
};
use std::str::FromStr;
use ethers::contract::ContractError;
use crate::registry::{IExpressionDeployerV3, IInterpreterStoreV1, IInterpreterV2, IParserV1};

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
    pub async fn try_build_dispair(&self) -> Result<DISPair,ContractError<Provider<Http>>> {
        
        let arc_client = self.client();
        let interpreter_address: H160 = self.i_interpreter().call().await?.to_fixed_bytes().into();
        let store_address: H160 = self.i_store().call().await?.to_fixed_bytes().into();
        let parser_address: H160 = self.i_parser().call().await?.to_fixed_bytes().into();

        
        Ok(DISPair{
                deployer: self.clone(),
                interpreter: IInterpreterV2::new(interpreter_address,arc_client.clone()),
                store: IInterpreterStoreV1::new(store_address,arc_client.clone()),
                parser: IParserV1::new(parser_address,arc_client.clone()),
        })
    }
}

/// Implementation to parse a expression string and get the corresponding bytecode and constants
impl IParserV1<Provider<Http>> {
    pub async fn parser_expression(&self,expression: String) -> Result<(Bytes, Vec<U256>),ContractError<Provider<Http>>> {
        let (sources, constants) = self
        .parse(ethers::types::Bytes::from(expression.as_bytes().to_vec()))
        .call()
        .await?;

        let bytecode_npe2 = Bytes::from(sources.to_vec());

        let mut constants_npe2: Vec<U256> = vec![];

        for i in constants.into_iter() {
            constants_npe2.push(U256::from_str(i.to_string().as_str()).unwrap());
        }

        Ok((bytecode_npe2, constants_npe2))
    }
}






