use ethers::contract::abigen;

abigen!(IInterpreterV1, "src/interpreter/abi/IInterpreterV1.json");
abigen!(IInterpreterV2, "src/interpreter/abi/IInterpreterV2.json");
abigen!(IExpressionDeployerV2, "src/interpreter/abi/IExpressionDeployerV2.json");
abigen!(IExpressionDeployerV3, "src/interpreter/abi/IExpressionDeployerV3.json");
abigen!(IInterpreterStoreV1, "src/interpreter/abi/IInterpreterStoreV1.json");
abigen!(IParserV1, "src/interpreter/abi/IParserV1.json");

