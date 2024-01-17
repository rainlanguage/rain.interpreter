use alloy_sol_types::sol;

sol!(
    #![sol(all_derives = true)]
    IInterpreterV2,
    "../../out/IInterpreterV2.sol/IInterpreterV2.json"
);
sol!(
    #![sol(all_derives = true)]
    IInterpreterStoreV1,
    "../../out/IInterpreterStoreV1.sol/IInterpreterStoreV1.json"
);
sol!(
    #![sol(all_derives = true)]
    IParserV1, "../../out/IParserV1.sol/IParserV1.json");
sol!(
    #![sol(all_derives = true)]
    IExpressionDeployerV3,
    "../../out/IExpressionDeployerV3.sol/IExpressionDeployerV3.json"
);
