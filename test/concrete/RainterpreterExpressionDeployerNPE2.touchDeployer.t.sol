// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {LibDeployerDiscoverable} from "src/lib/caller/LibDeployerDiscoverable.sol";
import {RainterpreterExpressionDeployerNPE2DeploymentTest} from
    "test/util/abstract/RainterpreterExpressionDeployerNPE2DeploymentTest.sol";
import {IExpressionDeployerV3} from "src/interface/unstable/IExpressionDeployerV3.sol";

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
