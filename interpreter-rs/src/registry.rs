use ethers::contract::abigen; 

abigen!(IInterpreterV2, "../out/IInterpreterV2.sol/IInterpreterV2.json");
abigen!(IInterpreterStoreV1, "../out/IInterpreterStoreV1.sol/IInterpreterStoreV1.json");
abigen!(IParserV1, "../out/IParserV1.sol/IParserV1.json");
abigen!(
    IExpressionDeployerV3,
    r#"[
        function iInterpreter() public view returns(address)
        function iStore() public view returns(address)
        function iParser() public view returns(address)
    ]"#,
);