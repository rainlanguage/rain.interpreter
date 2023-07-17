// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";
import "src/interface/IExpressionDeployerV1.sol";
import "src/lib/caller/LibDeployerDiscoverable.sol";

import "test/util/lib/etch/LibEtch.sol";

contract TestDeployer is IExpressionDeployerV1 {
    function deployExpression(bytes[] memory, uint256[] memory, uint256[] memory)
        external
        returns (IInterpreterV1, IInterpreterStoreV1, address)
    {}
}

contract LibDeployerDiscoverableTest is Test {
    /// MUST be possible to touch a deployer with 0 data to support discovery.
    function testTouchDeployerMock() external {
        TestDeployer deployer = new TestDeployer();
        vm.expectCall(
            address(deployer),
            abi.encodeWithSelector(
                IExpressionDeployerV1.deployExpression.selector, new bytes[](0), new uint256[](0), new uint256[](0)
            ),
            1
        );
        LibDeployerDiscoverable.touchDeployerV1(address(deployer));
    }
}
