// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Script, console2} from "forge-std/Script.sol";
import {RainterpreterStore} from "../src/concrete/RainterpreterStore.sol";
import {Rainterpreter} from "../src/concrete/Rainterpreter.sol";
import {RainterpreterParser} from "../src/concrete/RainterpreterParser.sol";
import {LibRainDeploy} from "rain.deploy/lib/LibRainDeploy.sol";
import {LibInterpreterDeploy} from "../src/lib/deploy/LibInterpreterDeploy.sol";
import {LibDecimalFloatDeploy} from "rain.math.float/lib/deploy/LibDecimalFloatDeploy.sol";
import {RainterpreterExpressionDeployer} from "../src/concrete/RainterpreterExpressionDeployer.sol";
import {RainterpreterDISPaiRegistry} from "../src/concrete/RainterpreterDISPaiRegistry.sol";
import {UnknownDeploymentSuite} from "../src/error/ErrDeploy.sol";

/// @dev Deployment suite selector for the parser.
bytes32 constant DEPLOYMENT_SUITE_PARSER = keccak256("parser");
/// @dev Deployment suite selector for the store.
bytes32 constant DEPLOYMENT_SUITE_STORE = keccak256("store");
/// @dev Deployment suite selector for the interpreter.
bytes32 constant DEPLOYMENT_SUITE_INTERPRETER = keccak256("interpreter");
/// @dev Deployment suite selector for the expression deployer.
bytes32 constant DEPLOYMENT_SUITE_EXPRESSION_DEPLOYER = keccak256("expression-deployer");
/// @dev Deployment suite selector for the DISPaiR registry.
bytes32 constant DEPLOYMENT_SUITE_DISPAIR_REGISTRY = keccak256("dispair-registry");

/// @title Deploy
/// @notice Forge script that deploys a single interpreter component to all
/// supported networks. The `DEPLOYMENT_SUITE` env var selects which component
/// to deploy: "parser", "store", "interpreter", or "expression-deployer".
/// Defaults to "parser" if not set.
contract Deploy is Script {
    /// Deploys the component selected by the `DEPLOYMENT_SUITE` env var.
    /// Reverts if the suite is not recognised.
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYMENT_KEY");

        address[] memory deps = new address[](1);
        deps[0] = LibDecimalFloatDeploy.ZOLTU_DEPLOYED_LOG_TABLES_ADDRESS;

        bytes32 suite = keccak256(bytes(vm.envOr("DEPLOYMENT_SUITE", string("parser"))));

        if (suite == DEPLOYMENT_SUITE_PARSER) {
            console2.log("Deploying RainterpreterParser...");
            LibRainDeploy.deployAndBroadcastToSupportedNetworks(
                vm,
                LibRainDeploy.supportedNetworks(),
                deployerPrivateKey,
                type(RainterpreterParser).creationCode,
                "src/concrete/RainterpreterParser.sol:RainterpreterParser",
                LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS,
                LibInterpreterDeploy.PARSER_DEPLOYED_CODEHASH,
                deps
            );
        } else if (suite == DEPLOYMENT_SUITE_STORE) {
            console2.log("Deploying RainterpreterStore...");
            LibRainDeploy.deployAndBroadcastToSupportedNetworks(
                vm,
                LibRainDeploy.supportedNetworks(),
                deployerPrivateKey,
                type(RainterpreterStore).creationCode,
                "src/concrete/RainterpreterStore.sol:RainterpreterStore",
                LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS,
                LibInterpreterDeploy.STORE_DEPLOYED_CODEHASH,
                deps
            );
        } else if (suite == DEPLOYMENT_SUITE_INTERPRETER) {
            console2.log("Deploying Rainterpreter...");
            LibRainDeploy.deployAndBroadcastToSupportedNetworks(
                vm,
                LibRainDeploy.supportedNetworks(),
                deployerPrivateKey,
                type(Rainterpreter).creationCode,
                "src/concrete/Rainterpreter.sol:Rainterpreter",
                LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS,
                LibInterpreterDeploy.INTERPRETER_DEPLOYED_CODEHASH,
                deps
            );
        } else if (suite == DEPLOYMENT_SUITE_EXPRESSION_DEPLOYER) {
            console2.log("Deploying RainterpreterExpressionDeployer...");
            address[] memory deployerDeps = new address[](4);
            deployerDeps[0] = LibDecimalFloatDeploy.ZOLTU_DEPLOYED_LOG_TABLES_ADDRESS;
            deployerDeps[1] = LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS;
            deployerDeps[2] = LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS;
            deployerDeps[3] = LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS;
            LibRainDeploy.deployAndBroadcastToSupportedNetworks(
                vm,
                LibRainDeploy.supportedNetworks(),
                deployerPrivateKey,
                type(RainterpreterExpressionDeployer).creationCode,
                "src/concrete/RainterpreterExpressionDeployer.sol:RainterpreterExpressionDeployer",
                LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS,
                LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH,
                deployerDeps
            );
        } else if (suite == DEPLOYMENT_SUITE_DISPAIR_REGISTRY) {
            console2.log("Deploying RainterpreterDISPaiRegistry...");
            address[] memory registryDeps = new address[](4);
            registryDeps[0] = LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS;
            registryDeps[1] = LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS;
            registryDeps[2] = LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS;
            registryDeps[3] = LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS;
            LibRainDeploy.deployAndBroadcastToSupportedNetworks(
                vm,
                LibRainDeploy.supportedNetworks(),
                deployerPrivateKey,
                type(RainterpreterDISPaiRegistry).creationCode,
                "src/concrete/RainterpreterDISPaiRegistry.sol:RainterpreterDISPaiRegistry",
                LibInterpreterDeploy.DISPAIR_REGISTRY_DEPLOYED_ADDRESS,
                LibInterpreterDeploy.DISPAIR_REGISTRY_DEPLOYED_CODEHASH,
                registryDeps
            );
        } else {
            revert UnknownDeploymentSuite(suite);
        }
    }
}
