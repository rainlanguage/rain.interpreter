{
  description = "Flake for development workflows.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rainix.url = "github:rainprotocol/rainix/915ad139d76afd9aab098cc88191be20c1bbfd07";
  };

  outputs = { self, flake-utils, rainix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        rain-cli-bin = "${rainix.rain.defaultPackage.${system}}/bin/rain";
        forge-bin = "${rainix.foundry.defaultPackage.${system}}/bin/forge";
        pkgs = rainix.pkgs.${system};
      in {
        packages = rec {
          build-dispair-meta-cmd = ''
            ${rain-cli-bin} meta build \
              -i <(${rain-cli-bin} meta solc artifact -c abi -i out/RainterpreterExpressionDeployerNPE2.sol/RainterpreterExpressionDeployerNPE2.json) -m solidity-abi-v2 -t json -e deflate -l en \
              -i <(${forge-bin} script --silent ./script/GetAuthoringMeta.sol && cat ./meta/AuthoringMeta.rain.meta) -m authoring-meta-v1 -t cbor -e deflate -l none \
          '';

          build-meta = rainix.pkgs.writeShellScriptBin "build-meta" ''
            mkdir -p meta;
            ${forge-bin} build --force;
            ${(build-dispair-meta-cmd)} -o meta/RainterpreterExpressionDeployerNPE2.rain.meta;
          '';

          deploy-dispair = rainix.pkgs.writeShellScriptBin "deploy-dispair" (''
            set -euo pipefail;
            mkdir -p meta;
            ${forge-bin} build --force;
            ${forge-bin} script -vvvvv script/DeployDISPair.sol --legacy --verify --broadcast --rpc-url "''${CI_DEPLOY_RPC_URL}" --etherscan-api-key "''${EXPLORER_VERIFICATION_KEY}" \
              --sig='run(bytes)' \
              "$( ${(build-dispair-meta-cmd)} -E hex )" \
            ;
          '');

          default = build-meta;
        };

          # For `nix develop`:
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.rust-bin.stable."1.75.0".default
            pkgs.foundry-bin
            pkgs.slither-analyzer
          ] ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [
            pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
          ]);
        };
      }
    );
}