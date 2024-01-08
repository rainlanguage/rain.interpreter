{
  description = "Flake for development workflows.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rainix.url = "github:rainprotocol/rainix/91cf58dcb2a866571f1b0427b4cfa33f9543ca85";
  };

  outputs = { self, flake-utils, rainix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = rainix.pkgs.${system};
      in {
        packages = rec {
          build-meta = rainix.mkTask.${system} { name = "build-meta"; };
        } // rainix.packages.${system};

        devShells = rainix.devShells.${system};
      }
    );
}