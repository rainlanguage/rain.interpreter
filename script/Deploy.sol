// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {RainterpreterStore} from "../src/concrete/RainterpreterStore.sol";
import {Rainterpreter} from "../src/concrete/Rainterpreter.sol";
import {RainterpreterParser} from "../src/concrete/RainterpreterParser.sol";
import {LibRainDeploy} from "rain.deploy/lib/LibRainDeploy.sol";
import {LibInterpreterDeploy} from "../src/lib/deploy/LibInterpreterDeploy.sol";
import {LibDecimalFloatDeploy} from "rain.math.float/lib/deploy/LibDecimalFloatDeploy.sol";
import {ProdRainterpreterExpressionDeployer} from "../src/concrete/ProdRainterpreterExpressionDeployer.sol";

/// @title Deploy
contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYMENT_KEY");

        address[] memory deps = new address[](1);
        deps[0] = LibDecimalFloatDeploy.ZOLTU_DEPLOYED_LOG_TABLES_ADDRESS;
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

        LibRainDeploy.deployAndBroadcastToSupportedNetworks(
            vm,
            LibRainDeploy.supportedNetworks(),
            deployerPrivateKey,
            type(RainterpreterStore).creationCode,
            "src/concrete/RainterpreterStore.sol:RainterpreterStore",
            LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS,
            LibInterpreterDeploy.STORE_DEPLOYED_CODEHASH,
            new address[](0)
        );

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

        LibRainDeploy.deployAndBroadcastToSupportedNetworks(
            vm,
            LibRainDeploy.supportedNetworks(),
            deployerPrivateKey,
            type(ProdRainterpreterExpressionDeployer).creationCode,
            "src/concrete/ProdRainterpreterExpressionDeployer.sol:ProdRainterpreterExpressionDeployer",
            LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS,
            LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH,
            deps
        );
    }
}
