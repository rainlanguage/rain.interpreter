// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibRainDeploy} from "rain.deploy/lib/LibRainDeploy.sol";
import {LibInterpreterDeploy} from "src/lib/deploy/LibInterpreterDeploy.sol";
import {RainterpreterParser} from "src/concrete/RainterpreterParser.sol";

contract LibInterpreterDeployTest is Test {
    function testDeployAddress() external {
        vm.createSelectFork(vm.envString("CI_FORK_ETH_RPC_URL"));

        address deployedAddress = LibRainDeploy.deployZoltu(type(RainterpreterParser).creationCode);

        assertEq(deployedAddress, LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS);
        assertTrue(address(deployedAddress).code.length > 0, "Deployed address has no code");

        assertEq(address(deployedAddress).codehash, LibInterpreterDeploy.PARSER_DEPLOYED_CODEHASH);
    }

    function testExpectedCodeHash() external {
        RainterpreterParser parser = new RainterpreterParser();

        assertEq(address(parser).codehash, LibInterpreterDeploy.PARSER_DEPLOYED_CODEHASH);
    }
}
