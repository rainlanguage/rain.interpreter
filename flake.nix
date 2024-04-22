{
  description = "Flake for development workflows.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rainix.url = "github:rainprotocol/rainix/5d9cd739180d9f7d7421228eddf7eb77126d3235";
  };

  outputs = { self, flake-utils, rainix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = rainix.pkgs.${system};
      in rec {
        packages = rec {
          i9r-prelude = rainix.mkTask.${system} {
            name = "i9r-prelude";
            body = ''
              set -euxo pipefail

              # Needed by deploy script.
              mkdir -p deployments/latest;

              # Build metadata that is needed for deployments.
              mkdir -p meta;
              forge script --silent ./script/BuildAuthoringMeta.sol;
              rain meta build \
                -i <(cat ./meta/AuthoringMeta.rain.meta) \
                -m authoring-meta-v2 \
                -t cbor \
                -e deflate \
                -l none \
                -o meta/RainterpreterExpressionDeployerNPE2.rain.meta \
              ;

              rain meta build \
                -i <(cat ./meta/RainterpreterReferenceExternNPE2AuthoringMeta.rain.meta) \
                -m authoring-meta-v2 \
                -t cbor \
                -e deflate \
                -l none \
                -o meta/RainterpreterReferenceExternNPE2.rain.meta \
            '';
            additionalBuildInputs = rainix.sol-build-inputs.${system};
          };
        } // rainix.packages.${system};

        devShells.default = pkgs.mkShell {
          packages = [ packages.i9r-prelude ];
          inputsFrom = [ rainix.devShells.${system}.default ];
        };
      }
    );
}