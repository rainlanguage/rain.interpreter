use ethers::contract::abigen;

abigen!(IInterpreterV1, "src/abi/IInterpreterV1.json");
abigen!(IInterpreterV2, "src/abi/IInterpreterV2.json");
abigen!(IExpressionDeployerV2, "src/abi/IExpressionDeployerV2.json");
abigen!(IExpressionDeployerV3, "src/abi/IExpressionDeployerV3.json");
abigen!(IInterpreterStoreV1, "src/abi/IInterpreterStoreV1.json");
abigen!(
    IParserV1,
    "src/abi/IParserV1.json",
    derives(serde::Deserialize, serde::Serialize),
);
