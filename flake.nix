{
  description = "Flake for development workflows.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rainix.url = "github:rainprotocol/rainix/511d871b1d1c3e8bf8084dbdfb54b00add52d1e1";
  };

  outputs = { self, flake-utils, rainix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = rainix.pkgs.${system};
      in {
        packages = rec {
          build-dispair-meta-cmd = ''
            rain meta build \
              -i <(forge script --silent ./script/GetAuthoringMeta.sol && cat ./meta/AuthoringMeta.rain.meta) -m authoring-meta-v1 -t cbor -e deflate -l none \
          '';

          build-meta = rainix.mkTask.${system} { name = "build-meta"; body = ''
            mkdir -p meta;
            forge build --force;
            ${(build-dispair-meta-cmd)} -o meta/RainterpreterExpressionDeployerNPE2.rain.meta;
          ''; };

          deploy-dispair = rainix.mkTask.${system} {name = "deploy-dispair"; body = (''
            set -euo pipefail;
            mkdir -p meta;
            forge build --force;
            forge script -vvvvv script/DeployDISPair.sol --legacy --verify --broadcast --rpc-url "''${CI_DEPLOY_RPC_URL}" --etherscan-api-key "''${EXPLORER_VERIFICATION_KEY}" \
              --sig='run(bytes)' \
              "$( ${(build-dispair-meta-cmd)} -E hex )" \
            ;
          ''); };

          ci-prep = rainix.mkTask.${system} { name = "ci-prep"; body = ''
            mkdir -p meta;
            forge install --shallow;
            forge build --force;
            ${(build-dispair-meta-cmd)} -o meta/RainterpreterExpressionDeployerNPE2.rain.meta;
          ''; };

          default = build-meta;
        } // rainix.packages.${system};

        devShells = rainix.devShells.${system};
      }
    );
}