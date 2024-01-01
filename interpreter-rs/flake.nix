{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, naersk, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
        };

        naersk' = pkgs.callPackage naersk {};

      in rec {
        packages = rec {
          abi-path = "./abis/";

          copy-abi = { origin_root, destiny, contract }: ''
            cp ${origin_root}/out/${contract}.sol/${contract}.json ${destiny}
          ''; 

          copy-abis = ''
            # Copying contract ABIs needed
            ${pkgs.lib.concatStrings (
              map (
                contract: copy-abi {
                  origin_root = "../";
                  destiny = abi-path;
                  contract = contract; 
                })
              ["RainterpreterNPE2" "RainterpreterStoreNPE2" "RainterpreterParserNPE2" "RainterpreterExpressionDeployerNPE2" "IInterpreterV2" "IInterpreterStoreV1" "IParserV1"]
            )}
          '';

          gen-artifacts =  pkgs.writeShellScriptBin "gen-artifacts" (''
            forge build --root ../

            rm -rf ./abis
            mkdir ./abis

            ${copy-abis}
          ''); 

          test = pkgs.writeShellScriptBin "test" ''
            cargo test --all-features
          '';

          docgen = pkgs.writeShellScriptBin "docgen" ''
            cargo doc --all-features
          '';

          lint-check = pkgs.writeShellScriptBin "lint-check" ''
            cargo fmt --check && cargo clippy
          '';

          lint-fix = pkgs.writeShellScriptBin "lint-fix" ''
            cargo fmt && cargo clippy --fix
          '';
        };

        # For `nix build` & `nix run`:
        defaultPackage = naersk'.buildPackage {
          src = ./.;
          nativeBuildInputs = with pkgs; [ 
            gmp 
            iconv 
            openssl 
            pkg-config
          ] ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [
            pkgs.libiconv
            pkgs.darwin.apple_sdk.frameworks.Security
            pkgs.darwin.apple_sdk.frameworks.CoreServices
            pkgs.darwin.apple_sdk.frameworks.CoreFoundation
            pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
          ]);
          cargoBuildOptions = (prev: prev ++ [ "--all-features" ]);
          cargoBuild = (prev: [ "gen-artifacts" ] ++ prev);
          # cargoBuild = (prev: ''gen-artifacts && ''  ++ prev);

        };

        # For `nix develop`:
        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ 
            gmp 
            iconv 
            rustup 
          ] ++ (with packages; [
            gen-artifacts
            test
            docgen
            lint-fix
            lint-check
          ]) ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [
            pkgs.libiconv
            pkgs.darwin.apple_sdk.frameworks.Security
            pkgs.darwin.apple_sdk.frameworks.CoreServices
            pkgs.darwin.apple_sdk.frameworks.CoreFoundation
            pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
          ]);
        };
      }
    );
}