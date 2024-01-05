pub mod interpreter;
pub mod registry;

#[cfg(test)]
pub mod test {
    use crate::{interpreter::DISPair, registry::IExpressionDeployerV3};
    use ethers::{
        abi::Token,
        contract::abigen,
        contract::ContractFactory,
        core::utils::Anvil,
        middleware::SignerMiddleware,
        providers::{Http, Provider},
        signers::{LocalWallet, Signer},
    };
    use std::{convert::TryFrom, sync::Arc, time::Duration};

    abigen!(
        RainterpreterNPE2,
        "../out/RainterpreterNPE2.sol/RainterpreterNPE2.json",
        derives(serde::Deserialize, serde::Serialize)
    );
    abigen!(
        RainterpreterStoreNPE2,
        "../out/RainterpreterStoreNPE2.sol/RainterpreterStoreNPE2.json",
        derives(serde::Deserialize, serde::Serialize)
    );
    abigen!(
        RainterpreterParserNPE2,
        "../out/RainterpreterParserNPE2.sol/RainterpreterParserNPE2.json",
        derives(serde::Deserialize, serde::Serialize)
    );
    abigen!(
        RainterpreterExpressionDeployerNPE2,
        "../out/RainterpreterExpressionDeployerNPE2.sol/RainterpreterExpressionDeployerNPE2.json",
        derives(serde::Deserialize, serde::Serialize)
    );

    #[tokio::test]
    pub async fn test_disp() -> Result<(), Box<dyn std::error::Error>> {
        let anvil = Anvil::new().spawn();

        let wallet: LocalWallet = anvil.keys()[0].clone().into();

        let provider =
            Provider::<Http>::try_from(anvil.endpoint())?.interval(Duration::from_millis(10u64));

        let client = Arc::new(SignerMiddleware::new(
            provider.clone(),
            wallet.with_chain_id(anvil.chain_id()),
        ));

        let rainterpreter_npe2 = RainterpreterNPE2::deploy(client.clone(), ())
            .unwrap()
            .send()
            .await
            .unwrap();

        let rainterpreter_store_npe2 = RainterpreterStoreNPE2::deploy(client.clone(), ())
            .unwrap()
            .send()
            .await
            .unwrap();

        let rainterpreter_parser_npe2 = RainterpreterParserNPE2::deploy(client.clone(), ())
            .unwrap()
            .send()
            .await
            .unwrap();

        let meta_bytes = std::fs::read("../meta/RainterpreterExpressionDeployerNPE2.rain.meta")?;

        let args = vec![Token::Tuple(vec![
            Token::Address(rainterpreter_npe2.address()),
            Token::Address(rainterpreter_store_npe2.address()),
            Token::Address(rainterpreter_parser_npe2.address()),
            Token::Bytes(meta_bytes),
        ])];

        let deploy_transaction = ContractFactory::new(
            RAINTERPRETEREXPRESSIONDEPLOYERNPE2_ABI.clone(),
            RAINTERPRETEREXPRESSIONDEPLOYERNPE2_BYTECODE.clone(),
            client.clone(),
        );
        let deployed_contract = deploy_transaction.deploy_tokens(args)?.send().await?;

        let rainterpreter_expressiondeployer_npe2 =
            IExpressionDeployerV3::new(deployed_contract.address(), Arc::new(provider.clone()));

        let dispair: DISPair = rainterpreter_expressiondeployer_npe2
            .try_build_dispair()
            .await?;

        assert!(dispair
            .interpreter
            .address()
            .eq(&rainterpreter_npe2.address()));
        assert!(dispair
            .store
            .address()
            .eq(&rainterpreter_store_npe2.address()));
        assert!(dispair
            .parser
            .address()
            .eq(&rainterpreter_parser_npe2.address()));
        assert!(dispair
            .deployer
            .address()
            .eq(&rainterpreter_expressiondeployer_npe2.address()));

        drop(anvil);
        Ok(())
    }
}
