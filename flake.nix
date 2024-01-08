{
  description = "Flake for development workflows.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rainix.url = "github:rainprotocol/rainix/18b1d1aea4ad69b2a18070f49af669e72d32d000";
  };

  outputs = { self, flake-utils, rainix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = rainix.pkgs.${system};
        mkTaskLocal = name: rainix.mkTask.${system} { name = name; body = (builtins.readFile ./task/${name}.sh); };
      in {
        packages = rec {
          build-meta = mkTaskLocal "build-meta";
        } // rainix.packages.${system};

        devShells = rainix.devShells.${system};
      }
    );
}