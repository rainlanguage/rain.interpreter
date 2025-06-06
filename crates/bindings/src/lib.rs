use alloy::sol;

// interpreters
sol!(
    #![sol(all_derives = true)]
    IInterpreterV2,
    "../../out/IInterpreterV2.sol/IInterpreterV2.json"
);
sol!(
    #![sol(all_derives = true)]
    IInterpreterV3,
    "../../out/IInterpreterV3.sol/IInterpreterV3.json"
);
sol!(
    #![sol(all_derives = true)]
    IInterpreterV4,
    "../../out/IInterpreterV4.sol/IInterpreterV4.json"
);

// stores
sol!(
    #![sol(all_derives = true)]
    IInterpreterStoreV1,
    "../../out/IInterpreterStoreV1.sol/IInterpreterStoreV1.json"
);
sol!(
    #![sol(all_derives = true)]
    IInterpreterStoreV2,
    "../../out/IInterpreterStoreV2.sol/IInterpreterStoreV2.json"
);
sol!(
    #![sol(all_derives = true)]
    IInterpreterStoreV3,
    "../../out/IInterpreterStoreV3.sol/IInterpreterStoreV3.json"
);

// parsers
sol!(
    #![sol(all_derives = true)]
    IParserV1, "../../out/IParserV1.sol/IParserV1.json"
);
sol!(
    #![sol(all_derives = true)]
    IParserV2, "../../out/IParserV2.sol/IParserV2.json"
);

// pragma
sol!(
    #![sol(all_derives = true)]
    IParserPragmaV1, "../../out/IParserPragmaV1.sol/IParserPragmaV1.json"
);

// deployer
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
