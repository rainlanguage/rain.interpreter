{
  description = "Flake for development workflows.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rainix.url = "github:rainprotocol/rainix/e58f5e9646afa9a9e23e91109904c6296bfcee57";
  };

  outputs = { self, flake-utils, rainix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = rainix.pkgs.${system};
        rain-cli-bin = "${pkgs.rain}/bin/rain";
        forge-bin = "${pkgs.foundry-bin}/bin/forge";
      in {
        packages = rec {
          build-dispair-meta-cmd = ''
            ${rain-cli-bin} meta build \
              -i <(${rain-cli-bin} meta solc artifact -c abi -i out/RainterpreterExpressionDeployerNPE2.sol/RainterpreterExpressionDeployerNPE2.json) -m solidity-abi-v2 -t json -e deflate -l en \
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
        } // rainix.packages;

        devShells = rainix.devShells;
      }
    );
}