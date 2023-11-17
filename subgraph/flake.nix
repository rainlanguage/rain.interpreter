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

      in rec {
        packages = rec {
          init-setup =  pkgs.writeShellScriptBin "init-setup" (''
            git submodule update --init --recursive --depth 1 rain.extrospection/

          '');

          default = init-setup;
        };
      }
    );
}
