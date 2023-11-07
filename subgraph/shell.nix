let
  pkgs = import
    (builtins.fetchTarball {
      name = "nixos-unstable-2021-10-01";
      url = "https://github.com/nixos/nixpkgs/archive/d3d2c44a26b693293e8c79da0c3e3227fc212882.tar.gz";
      sha256 = "0vi4r7sxzfdaxzlhpmdkvkn3fjg533fcwsy3yrcj5fiyqip2p3kl";
    })
    { };

  command = pkgs.writeShellScriptBin "command" ''
  '';

  hardhat-node = pkgs.writeShellScriptBin "hardhat-node" ''
    npx hardhat node
  '';

  graph-node = pkgs.writeShellScriptBin "graph-node" ''
    npm run graph-node
  '';

  graph-node-up = pkgs.writeShellScriptBin "graph-node-up" ''
    npm run graph-node-up
    sleep 30s # Waits 30 seconds
  '';

  graph-node-down = pkgs.writeShellScriptBin "graph-node-down" ''
    npm run graph-node-down
  '';

  graph-test = pkgs.writeShellScriptBin "graph-test" ''
    npx hardhat test
  '';

  deploy-subgraph = pkgs.writeShellScriptBin "deploy-subgraph" ''
    ts-node scripts/index.ts
  '';

  prepare-deploy-ci-mumbai = pkgs.writeShellScriptBin "prepare-deploy-ci-mumbai" ''
    npx mustache config/mumbai.json subgraph.template.yaml subgraph.yaml
    npm run generate-schema && npm run codegen && npm run build
  '';

  prepare-deploy-ci-polygon = pkgs.writeShellScriptBin "prepare-deploy-ci-polygon" ''
    npx mustache config/polygon.json subgraph.template.yaml subgraph.yaml
    npm run generate-schema && npm run codegen && npm run build
  '';
  
  prepare-deploy-ci-ethereum = pkgs.writeShellScriptBin "prepare-deploy-ci-ethereum" ''
    npx mustache config/ethereum.json subgraph.template.yaml subgraph.yaml
    npm run generate-schema && npm run codegen && npm run build
  '';

  compile = pkgs.writeShellScriptBin "compile" ''
    forge build
    hardhat compile --force
  '';

  install-submodules = pkgs.writeShellScriptBin "install-submodules" ''
    mkdir -p lib

    git -C lib clone https://github.com/foundry-rs/forge-std.git
    git -C lib clone https://github.com/rainprotocol/rain.cooldown.git
    git -C lib clone https://github.com/rainprotocol/rain.math.saturating.git
    git -C lib clone https://github.com/rainprotocol/sol.lib.binmaskflag.git
    git -C lib clone https://github.com/rainprotocol/sol.lib.datacontract.git
    git -C lib clone https://github.com/rainprotocol/sol.metadata.git

    git -C lib/forge-std checkout 2b58ecb
    git -C lib/rain.cooldown checkout 621c02d
    git -C lib/rain.math.saturating checkout 8d8406a
    git -C lib/sol.lib.binmaskflag checkout 214473a
    git -C lib/sol.lib.datacontract checkout 80aaaa8
    git -C lib/sol.metadata checkout fdb9a5f

    git submodule add https://github.com/foundry-rs/forge-std.git lib/forge-std
    git submodule add https://github.com/rainprotocol/rain.cooldown.git lib/rain.cooldown
    git submodule add https://github.com/rainprotocol/rain.math.saturating.git lib/rain.math.saturating
    git submodule add https://github.com/rainprotocol/sol.lib.binmaskflag.git lib/sol.lib.binmaskflag
    git submodule add https://github.com/rainprotocol/sol.lib.datacontract.git lib/sol.lib.datacontract
    git submodule add https://github.com/rainprotocol/sol.metadata.git lib/sol.metadata
    
    forge install --root lib/forge-std
    forge install --root lib/rain.cooldown
    forge install --root lib/rain.math.saturating
    forge install --root lib/sol.lib.binmaskflag
    forge install --root lib/sol.lib.datacontract
    forge install --root lib/sol.metadata

    forge build --root lib/forge-std
    forge build --root lib/rain.cooldown
    forge build --root lib/rain.math.saturating
    forge build --root lib/sol.lib.binmaskflag
    forge build --root lib/sol.lib.datacontract
    forge build --root lib/sol.metadata
  '';

  copy-abis = pkgs.writeShellScriptBin "copy-abis" ''
    mkdir -p abis
    
    cp artifacts/contracts/extrospection/Extrospection.sol/Extrospection.json abis
    cp artifacts/contracts/interpreter/shared/Rainterpreter.sol/Rainterpreter.json abis
    cp artifacts/contracts/interpreter/shared/RainterpreterExpressionDeployer.sol/RainterpreterExpressionDeployer.json abis
    cp artifacts/contracts/interpreter/shared/RainterpreterStore.sol/RainterpreterStore.json abis

    # This changed the name of the json to have the MetaV1 event and use it on those 
    cp artifacts/lib/sol.metadata/src/IMetaV1.sol/IMetaV1.json abis/InterpreterCallerV1.json

  '';

  init = pkgs.writeShellScriptBin "init" ''
    npm install
    # rm -rf docker/data
    # mkdir -p contracts && cp -r node_modules/@rainprotocol/rain-protocol/contracts .
    # mkdir -p schema && cp -r node_modules/@rainprotocol/rain-protocol/schema .
    # mkdir -p utils && cp -r node_modules/@rainprotocol/rain-protocol/utils .
    # cp node_modules/@rainprotocol/rain-protocol/foundry.toml .
    # install-submodules
    # compile
    # copy-abis
  '';

  flush-all = pkgs.writeShellScriptBin "flush-all" ''
    rm -rf cache
    rm -rf cache_forge
    rm -rf node_modules
    rm -rf artifacts
    rm -rf build
    rm -rf contracts
    rm -rf generated
    rm -rf typechain
    rm -rf schema
    rm -rf utils
    rm -rf out
    rm -rf foundry.toml
    rm -rf docker/data
  '';

  codegen = pkgs.writeShellScriptBin "codegen" ''
    graph codegen
  '';

  docker-up = pkgs.writeShellScriptBin "docker-up" ''
    docker-compose -f docker/docker-compose.yml up --build -d
  '';

  docker-down = pkgs.writeShellScriptBin "docker-down" ''
    docker-compose -f docker/docker-compose.yml down
  '';

  ci-test = pkgs.writeShellScriptBin "ci-test" ''
    # Relevant the flag, don't delete
    npx hardhat test --no-compile
  '';
  
in
pkgs.stdenv.mkDerivation {
 name = "shell";
 buildInputs = [
  pkgs.nodejs-16_x
  pkgs.jq
  command
  hardhat-node
  graph-node
  graph-node-up
  graph-node-down
  graph-test
  deploy-subgraph
  prepare-deploy-ci-mumbai
  prepare-deploy-ci-polygon
  prepare-deploy-ci-ethereum
  init
  compile
  install-submodules
  copy-abis
  codegen
  docker-up
  docker-down
  ci-test
  flush-all
 ];

 shellHook = ''
  export PATH=$( npm bin ):$PATH
  # keep it fresh
 '';
}