// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {LibDeployerDiscoverable} from "rain.interpreter.interface/lib/caller/LibDeployerDiscoverable.sol";
import {RainterpreterExpressionDeployerNPE2DeploymentTest} from
    "test/abstract/RainterpreterExpressionDeployerNPE2DeploymentTest.sol";
import {IExpressionDeployerV3} from "rain.interpreter.interface/interface/IExpressionDeployerV3.sol";

contract RainterpreterExpressionDeployerNPE2TouchDeployer is RainterpreterExpressionDeployerNPE2DeploymentTest {
    /// MUST be possible to test a real deployer with 0 data to support discovery.
    function testTouchRealDeployer() external {
        vm.expectCall(
            address(iDeployer),
            abi.encodeWithSelector(IExpressionDeployerV3.deployExpression2.selector, "", new uint256[](0)),
            1
        );
        LibDeployerDiscoverable.touchDeployerV3(address(iDeployer));
    }
}
