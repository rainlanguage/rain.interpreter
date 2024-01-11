{
  description = "Flake for development workflows.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rainix.url = "github:rainprotocol/rainix";
  };

  outputs = { self, flake-utils, rainix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = rainix.pkgs.${system};
        mkTaskLocal = name: rainix.mkTask.${system} { name = name; body = (builtins.readFile ./task/${name}.sh); };
      in {
        packages = rec {
          build-dispair-meta = mkTaskLocal "build-dispair-meta";
        } // rainix.packages.${system};

        devShells = rainix.devShells.${system};
      }
    );
}