// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "../../../lib/forge-std/src/Test.sol";
import "../../../src/interface/IExpressionDeployerV1.sol";
import "../../../src/lib/caller/LibDeployerDiscoverable.sol";

contract TestDeployer is IExpressionDeployerV1 {
    function deployExpression(bytes[] memory, uint256[] memory, uint256[] memory)
        external
        returns (IInterpreterV1, IInterpreterStoreV1, address)
    {}
}

contract LibDeployerDiscoverableTest is Test {
    function testTouchDeployer() external {
        TestDeployer deployer = new TestDeployer();
        vm.expectCall(
            address(deployer),
            abi.encodeWithSelector(
                IExpressionDeployerV1.deployExpression.selector, new bytes[](0), new uint256[](0), new uint256[](0)
            ),
            1
        );
        LibDeployerDiscoverable.touchDeployer(address(deployer));
    }
}
