{
  description = "Flake for development workflows.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/ec750fd01963ab6b20ee1f0cb488754e8036d89d";
    rain.url = "github:rainprotocol/rain.cli/6a912680be6d967fd6114aafab793ebe8503d27b";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    foundry.url = "github:shazow/foundry.nix/monthly";
  };

  outputs = { self, nixpkgs, rain, flake-utils, rust-overlay, foundry, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # pkgs = nixpkgs.legacyPackages.${system};
        overlays =[ (import rust-overlay) foundry.overlay ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rain-cli-bin = "${rain.defaultPackage.${system}}/bin/rain";
        forge-bin = "${foundry.defaultPackage.${system}}/bin/forge";

      in with pkgs; rec {
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

          # nativeBuildInputs = [
          #   pkgs.gmp
          #   pkgs.iconv
          # ];
        };

          # For `nix develop`:
        devShells.default = pkgs.mkShell {
          buildInputs = [
            rust-bin.stable."1.75.0".default
            foundry-bin
          ] ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [
            pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
          ]);
        };
      }
    );
}