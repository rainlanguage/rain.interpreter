use alloy::sol;

sol!(
    #![sol(all_derives = true)]
    IInterpreterV4,
    "../../out/IInterpreterV4.sol/IInterpreterV4.json"
);

sol!(
    #![sol(all_derives = true)]
    IInterpreterStoreV3,
    "../../out/IInterpreterStoreV3.sol/IInterpreterStoreV3.json"
);

sol!(
    #![sol(all_derives = true)]
    IParserV2, "../../out/IParserV2.sol/IParserV2.json"
);

sol!(
    #![sol(all_derives = true)]
    IParserPragmaV1, "../../out/IParserPragmaV1.sol/IParserPragmaV1.json"
);

sol!(
    #![sol(all_derives = true)]
    IExpressionDeployerV3,
    "../../out/IExpressionDeployerV3.sol/IExpressionDeployerV3.json"
);

// dispair binding
sol! {
    #![sol(all_derives = true)]
    interface  DeployerISP {
        function iInterpreter() public view returns(address);
        function iStore() public view returns(address);
        function iParser() public view returns(address);
    }
}
