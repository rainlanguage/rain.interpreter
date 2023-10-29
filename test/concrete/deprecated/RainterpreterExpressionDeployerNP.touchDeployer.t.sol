// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {LibDeployerDiscoverable} from "src/lib/caller/LibDeployerDiscoverable.sol";
import {RainterpreterExpressionDeployerNPDeploymentTest} from
    "test/util/abstract/RainterpreterExpressionDeployerNPDeploymentTest.sol";
import {IExpressionDeployerV2} from "src/interface/IExpressionDeployerV2.sol";

contract RainterpreterExpressionDeployerNPTouchDeployer is RainterpreterExpressionDeployerNPDeploymentTest {
    /// MUST be possible to test a real deployer with 0 data to support discovery.
    function testTouchRealDeployer() external {
        vm.expectCall(
            address(iDeployer),
            abi.encodeWithSelector(
                IExpressionDeployerV2.deployExpression.selector, "", new uint256[](0), new uint256[](0)
            ),
            1
        );
        LibDeployerDiscoverable.touchDeployerV2(address(iDeployer));
    }
}
