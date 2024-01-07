{
  description = "Flake for development workflows.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rainix.url = "github:rainprotocol/rainix/2929bbde2c0e439a9d7451a8eaa4f46afae929d7";
    rain.url = "github:rainprotocol/rain.cli/6a912680be6d967fd6114aafab793ebe8503d27b";
  };

  outputs = { self, flake-utils, rainix, rain, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = rainix.pkgs.${system};
        forge-bin = "${pkgs.foundry-bin}/bin/forge";
        rain-bin = "${rain.defaultPackage.${system}}/bin/rain";
      in {
        packages = rec {
          build-dispair-meta-cmd = ''
            ${rain-bin} meta build \
              -i <(${rain-bin} meta solc artifact -c abi -i out/RainterpreterExpressionDeployerNPE2.sol/RainterpreterExpressionDeployerNPE2.json) -m solidity-abi-v2 -t json -e deflate -l en \
              -i <(${forge-bin} script --silent ./script/GetAuthoringMeta.sol && cat ./meta/AuthoringMeta.rain.meta) -m authoring-meta-v1 -t cbor -e deflate -l none \
          '';

          build-meta = pkgs.writeShellScriptBin "build-meta" ''
            mkdir -p meta;
            ${forge-bin} build --force;
            ${(build-dispair-meta-cmd)} -o meta/RainterpreterExpressionDeployerNPE2.rain.meta;
          '';

          deploy-dispair = pkgs.writeShellScriptBin "deploy-dispair" (''
            set -euo pipefail;
            mkdir -p meta;
            ${forge-bin} build --force;
            ${forge-bin} script -vvvvv script/DeployDISPair.sol --legacy --verify --broadcast --rpc-url "''${CI_DEPLOY_RPC_URL}" --etherscan-api-key "''${EXPLORER_VERIFICATION_KEY}" \
              --sig='run(bytes)' \
              "$( ${(build-dispair-meta-cmd)} -E hex )" \
            ;
          '');

          default = build-meta;
          ci-prep = build-meta;
        } // rainix.packages.${system};

        devShells = rainix.devShells.${system};
      }
    );
}