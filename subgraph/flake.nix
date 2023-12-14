{
  description = "Flake for development interpreter subgraph workflows.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/ec750fd01963ab6b20ee1f0cb488754e8036d89d";
    flake-utils.url = "github:numtide/flake-utils";
    rain.url = "github:rainlanguage/rain.cli/5d083a449ca876c1b1736507b8e89957f0b8f6f8";
  };


  outputs = { self, nixpkgs, rain, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        rain-cli = "${rain.defaultPackage.${system}}/bin/rain";
        graphql-client = "${pkgs.graphql-client}/bin/graphql-client";

      in rec {
        packages = rec {
          sg-abi-path = "./abis/";
          test-abi-path = "./tests/generated/";

          copy-abi = { origin_root, destiny, contract }: ''
            cp ${origin_root}/out/${contract}.sol/${contract}.json ${destiny}
          '';

          copy-subgraph-abis = ''
            # Copying contract ABIs needed for subgraph
            ${pkgs.lib.concatStrings (
              map (
                contract: copy-abi {
                  origin_root = "../";
                  destiny = sg-abi-path;
                  contract = contract; 
                })
              ["IERC1820Registry" "DeployerDiscoverableMetaV3" "RainterpreterNPE2" "RainterpreterStoreNPE2" "RainterpreterParserNPE2" "RainterpreterExpressionDeployerNPE2"]
            )}

            ${pkgs.lib.concatStrings (
              map (
                contract: copy-abi {
                  origin_root = "./rain.extrospection";
                  destiny = sg-abi-path;
                  contract = contract; 
                })
              ["Extrospection"]
            )}
          '';

          copy-test-abis = ''
            # Copying contract ABIs needed for tests
            ${pkgs.lib.concatStrings (
              map (
                contract: copy-abi {
                  origin_root = "../";
                  destiny = test-abi-path;
                  contract = contract; 
                })
              ["RainterpreterNPE2" "RainterpreterStoreNPE2" "RainterpreterParserNPE2" "RainterpreterExpressionDeployerNPE2"]
            )}
            ${pkgs.lib.concatStrings (
              map (
                contract: copy-abi {
                  origin_root = "./rain.extrospection";
                  destiny = test-abi-path;
                  contract = contract; 
                })
              ["Extrospection"]
            )}
          '';

          init-setup =  pkgs.writeShellScriptBin "init-setup" (''
            forge build --root ../
            forge build --root ./rain.extrospection/

            rm -rf ./abis ./tests/generated/*.json
            mkdir ./abis

            ${copy-subgraph-abis}
            ${copy-test-abis}
          '');
          ci-test = pkgs.writeShellScriptBin "ci-test" (''
            cargo test -- --test-threads=1 --nocapture;
          '');

          build = pkgs.writeShellScriptBin  "build" (''
            ${rain-cli} subgraph build --address 0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24
          '');

          rain_cli = pkgs.writeShellScriptBin "rain_cli" (''
            ${rain-cli} $@
          '');

          docker-up = pkgs.writeShellScriptBin "docker-up" ''
            docker compose -f docker/docker-compose.yaml up --build -d
          '';

          docker-down = pkgs.writeShellScriptBin "docker-down" ''
            docker compose -f docker/docker-compose.yaml down
          '';

          generate-sg-schema =  pkgs.writeShellScriptBin "generate-sg-schema" (''
            ${rain-cli} subgraph build
            ${rain-cli} subgraph deploy --endpoint http://localhost:8020 --subgraph-name "test/test"

            # Wait for 1 second to the subgraph be totally deployed
            sleep 1

            ${graphql-client} introspect-schema --output tests/utils/subgraph/wait/schema.json http://localhost:8030/graphql
            ${graphql-client} introspect-schema --output tests/utils/subgraph/query/schema.json http://localhost:8000/subgraphs/name/test/test
          '');

          default = rain_cli;
        };
      }
    );
}
