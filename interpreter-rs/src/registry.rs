use ethers::contract::abigen;

abigen!(IInterpreterV2, "./abis/IInterpreterV2.json");
abigen!(IInterpreterStoreV1, "./abis/IInterpreterStoreV1.json");
abigen!(IParserV1, "./abis/IParserV1.json");
abigen!(
    IExpressionDeployerV3,
    r#"[
        function iInterpreter() public view returns(address)
        function iStore() public view returns(address)
        function iParser() public view returns(address)
    ]"#,
);
