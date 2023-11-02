// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";
import "src/interface/deprecated/IExpressionDeployerV1.sol";
import "src/lib/caller/LibDeployerDiscoverable.sol";

import "test/util/lib/etch/LibEtch.sol";

contract TestDeployerV1 is IExpressionDeployerV1 {
    function deployExpression(bytes[] memory, uint256[] memory, uint256[] memory)
        external
        returns (IInterpreterV2, IInterpreterStoreV1, address)
    {}
}

contract LibDeployerV1DiscoverableTest is Test {
    /// MUST be possible to touch a deployer with 0 data to support discovery.
    function testTouchDeployerV1Mock() external {
        TestDeployerV1 deployer = new TestDeployerV1();
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
