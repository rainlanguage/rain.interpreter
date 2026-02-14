// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Script, console2} from "forge-std/Script.sol";
import {RainterpreterStore} from "../src/concrete/RainterpreterStore.sol";
import {Rainterpreter} from "../src/concrete/Rainterpreter.sol";
import {RainterpreterParser} from "../src/concrete/RainterpreterParser.sol";
import {LibRainDeploy} from "rain.deploy/lib/LibRainDeploy.sol";
import {LibInterpreterDeploy} from "../src/lib/deploy/LibInterpreterDeploy.sol";
import {LibDecimalFloatDeploy} from "rain.math.float/lib/deploy/LibDecimalFloatDeploy.sol";
import {RainterpreterExpressionDeployer} from "../src/concrete/RainterpreterExpressionDeployer.sol";

bytes32 constant DEPLOYMENT_SUITE_PARSER = keccak256("parser");
bytes32 constant DEPLOYMENT_SUITE_STORE = keccak256("store");
bytes32 constant DEPLOYMENT_SUITE_INTERPRETER = keccak256("interpreter");
bytes32 constant DEPLOYMENT_SUITE_EXPRESSION_DEPLOYER = keccak256("expression-deployer");

/// @title Deploy
contract Deploy is Script {
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
            LibRainDeploy.deployAndBroadcastToSupportedNetworks(
                vm,
                LibRainDeploy.supportedNetworks(),
                deployerPrivateKey,
                type(RainterpreterExpressionDeployer).creationCode,
                "src/concrete/RainterpreterExpressionDeployer.sol:RainterpreterExpressionDeployer",
                LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS,
                LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH,
                deps
            );
        }
    }
}
