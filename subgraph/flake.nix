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
          concrete-contracts = ["RainterpreterExpressionDeployerNP" "RainterpreterNP" "RainterpreterStore"];

          copy-abis = contract: ''
            cp ../out/${contract}.sol/${contract}.json ./tests/generated/
          '';

          remove-duplicate-component = ''
            # Remove a component duplicated on RainterpreterExpressionDeployerNP abi that conflict with abigen
            contract_path="tests/generated/RainterpreterExpressionDeployerNP.json"
            ${jq} '.abi |= map(select(.name != "StackUnderflow"))' $contract_path > updated_contract.json
            mv updated_contract.json $contract_path
          '';

          init-setup =  pkgs.writeShellScriptBin "init-setup" (''
            forge build --root ../

            rm -rf ./abis ./tests/generated
            mkdir ./abis ./tests/generated

            cp ../out/IMetaV1.sol/IMetaV1.json ./abis/
            cp ../out/IERC1820Registry.sol/IERC1820Registry.json ./abis/
          '');

          default = init-setup;
        };
      }
    );
}
