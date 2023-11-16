{
  description = "Flake for development interpreter subgraph workflows.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/ec750fd01963ab6b20ee1f0cb488754e8036d89d";
    flake-utils.url = "github:numtide/flake-utils";
  };


  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        jq = "${pkgs.jq}/bin/jq";

      in rec {
        packages = rec {
          test-contracts = ["RainterpreterExpressionDeployerNP" "RainterpreterNP" "RainterpreterStore"];
          subgraph-contracts = ["IMetaV1" "IERC1820Registry" "RainterpreterExpressionDeployerNP" "RainterpreterNP" "RainterpreterStore"];

          copy-root-test-abis = contract: ''
            cp ../out/${contract}.sol/${contract}.json ./tests/generated/
          '';

          copy-root-sg-abis = contract: ''
            cp ../out/${contract}.sol/${contract}.json ./abis/
          '';

          copy-test-abis = ''
            ${pkgs.lib.concatStrings (map copy-root-test-abis test-contracts)}
            cp ./rain.extrospection/out/Extrospection.sol/Extrospection.json ./tests/generated/
          '';

          copy-subgraph-abis = ''
            ${pkgs.lib.concatStrings (map copy-root-sg-abis subgraph-contracts)}
            cp ./rain.extrospection/out/Extrospection.sol/Extrospection.json ./abis/
          '';

          remove-duplicate-component = ''
            # Remove a component duplicated on RainterpreterExpressionDeployerNP abi that conflict with abigen
            contract_path="tests/generated/RainterpreterExpressionDeployerNP.json"
            ${jq} '.abi |= map(select(.name != "StackUnderflow"))' $contract_path > updated_contract.json
            mv updated_contract.json $contract_path
          '';

          initialize-contracts = pkgs.writeShellScriptBin " initialize-contracts" (''
            forge install --root ../ --shallow
            git submodule update && forge install --root ./rain.extrospection/ --shallow
          '');

          init-setup =  pkgs.writeShellScriptBin "init-setup" (''
            forge build --root ../
            forge build --root ./rain.extrospection/

            rm -rf ./abis ./tests/generated
            mkdir ./abis ./tests/generated

            ${copy-test-abis}
            ${copy-subgraph-abis}
            ${remove-duplicate-component}
          '');

          default = init-setup;
        };
      }
    );
}
