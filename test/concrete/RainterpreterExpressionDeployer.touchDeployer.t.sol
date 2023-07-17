// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/caller/LibDeployerDiscoverable.sol";
import "test/util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";

contract RainterpreterExpressionDeployerTouchDeployer is RainterpreterExpressionDeployerDeploymentTest {
    /// MUST be possible to test a real deployer with 0 data to support discovery.
    function testTouchRealDeployer() external {
        vm.expectCall(
            address(iDeployer),
            abi.encodeWithSelector(
                IExpressionDeployerV1.deployExpression.selector, new bytes[](0), new uint256[](0), new uint8[](0)
            ),
            1
        );
        LibDeployerDiscoverable.touchDeployerV1(address(iDeployer));
    }
}
