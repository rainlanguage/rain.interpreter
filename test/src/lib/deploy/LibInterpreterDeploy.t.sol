// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {LibRainDeploy} from "rain.deploy/lib/LibRainDeploy.sol";
import {LibInterpreterDeploy} from "src/lib/deploy/LibInterpreterDeploy.sol";
import {RainterpreterParser} from "src/concrete/RainterpreterParser.sol";
import {RainterpreterStore} from "src/concrete/RainterpreterStore.sol";
import {Rainterpreter} from "src/concrete/Rainterpreter.sol";
import {RainterpreterExpressionDeployer} from "src/concrete/RainterpreterExpressionDeployer.sol";
import {RainterpreterDISPaiRegistry} from "src/concrete/RainterpreterDISPaiRegistry.sol";

contract LibInterpreterDeployTest is Test {
    function testDeployAddressParser() external {
        vm.createSelectFork(vm.envString("CI_FORK_ETH_RPC_URL"));

        console2.logBytes(LibRainDeploy.ZOLTU_FACTORY.code);

        address deployedAddress = LibRainDeploy.deployZoltu(type(RainterpreterParser).creationCode);

        assertEq(deployedAddress, LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS);
        assertTrue(address(deployedAddress).code.length > 0, "Deployed address has no code");

        assertEq(address(deployedAddress).codehash, LibInterpreterDeploy.PARSER_DEPLOYED_CODEHASH);
    }

    function testExpectedCodeHashParser() external {
        RainterpreterParser parser = new RainterpreterParser();

        assertEq(address(parser).codehash, LibInterpreterDeploy.PARSER_DEPLOYED_CODEHASH);
    }

    function testDeployAddressStore() external {
        vm.createSelectFork(vm.envString("CI_FORK_ETH_RPC_URL"));

        address deployedAddress = LibRainDeploy.deployZoltu(type(RainterpreterStore).creationCode);

        assertEq(deployedAddress, LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS);
        assertTrue(address(deployedAddress).code.length > 0, "Deployed address has no code");

        assertEq(address(deployedAddress).codehash, LibInterpreterDeploy.STORE_DEPLOYED_CODEHASH);
    }

    function testExpectedCodeHashStore() external {
        RainterpreterStore store = new RainterpreterStore();

        assertEq(address(store).codehash, LibInterpreterDeploy.STORE_DEPLOYED_CODEHASH);
    }

    function testDeployAddressInterpreter() external {
        vm.createSelectFork(vm.envString("CI_FORK_ETH_RPC_URL"));

        address deployedAddress = LibRainDeploy.deployZoltu(type(Rainterpreter).creationCode);

        assertEq(deployedAddress, LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS);
        assertTrue(address(deployedAddress).code.length > 0, "Deployed address has no code");

        assertEq(address(deployedAddress).codehash, LibInterpreterDeploy.INTERPRETER_DEPLOYED_CODEHASH);
    }

    function testExpectedCodeHashInterpreter() external {
        Rainterpreter interpreter = new Rainterpreter();

        assertEq(address(interpreter).codehash, LibInterpreterDeploy.INTERPRETER_DEPLOYED_CODEHASH);
    }

    function testDeployAddressExpressionDeployer() external {
        vm.createSelectFork(vm.envString("CI_FORK_ETH_RPC_URL"));

        address deployedAddress = LibRainDeploy.deployZoltu(type(RainterpreterExpressionDeployer).creationCode);

        console2.log("Deployed address:", deployedAddress);

        assertEq(deployedAddress, LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS);
        assertTrue(address(deployedAddress).code.length > 0, "Deployed address has no code");

        assertEq(address(deployedAddress).codehash, LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH);
    }

    function testExpectedCodeHashExpressionDeployer() external {
        RainterpreterExpressionDeployer expressionDeployer = new RainterpreterExpressionDeployer();

        assertEq(address(expressionDeployer).codehash, LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH);
    }

    function testDeployAddressDISPaiRegistry() external {
        vm.createSelectFork(vm.envString("CI_FORK_ETH_RPC_URL"));

        address deployedAddress = LibRainDeploy.deployZoltu(type(RainterpreterDISPaiRegistry).creationCode);

        assertEq(deployedAddress, LibInterpreterDeploy.DISPAIR_REGISTRY_DEPLOYED_ADDRESS);
        assertTrue(address(deployedAddress).code.length > 0, "Deployed address has no code");

        assertEq(address(deployedAddress).codehash, LibInterpreterDeploy.DISPAIR_REGISTRY_DEPLOYED_CODEHASH);
    }

    function testExpectedCodeHashDISPaiRegistry() external {
        RainterpreterDISPaiRegistry registry = new RainterpreterDISPaiRegistry();

        assertEq(address(registry).codehash, LibInterpreterDeploy.DISPAIR_REGISTRY_DEPLOYED_CODEHASH);
    }
}
