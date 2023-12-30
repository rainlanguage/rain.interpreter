pub mod interpreter;
pub mod registry;


#[cfg(test)]
pub mod test {
    use ethers::{
        core::utils::Anvil,
        providers::{Http, Provider}, types::{H160,Address},
    };
    use std::{convert::TryFrom, sync::Arc};
    use crate::{
        interpreter::{MockIExpressionDeployerV3, DISPair},
        registry::{IInterpreterV2, IInterpreterStoreV1, IParserV1, IExpressionDeployerV3}
    };

    #[tokio::test]
    pub async fn test_foo() -> Result<(), Box<dyn std::error::Error>>  {

        let anvil = Anvil::new().spawn(); 
        let provider =
        Provider::<Http>::try_from(anvil.endpoint()).unwrap(); 

        let client = Arc::new(provider); 

        let mut mock = MockIExpressionDeployerV3::new();
        mock.expect_try_build_dispair().returning(move || {

            let i = IInterpreterV2::new(H160::random(),client.clone());
            let s = IInterpreterStoreV1::new(H160::random(),client.clone());
            let p = IParserV1::new(H160::random(),client.clone());
            let d = IExpressionDeployerV3::new(H160::random(),client.clone()); 

            let disp: DISPair = DISPair{
                interpreter: i,
                store: s,
                parser:p,
                deployer:d
            }; 
            Ok(disp)
        }); 

        let dispair: DISPair = mock.try_build_dispair().await?; 

        assert!(dispair.interpreter.address().ne(&Address::zero()));
        assert!(dispair.store.address().ne(&Address::zero()));
        assert!(dispair.parser.address().ne(&Address::zero()));
        assert!(dispair.deployer.address().ne(&Address::zero()));

        Ok(())

    }
}