// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {IExpressionDeployerV3} from "src/interface/unstable/IExpressionDeployerV3.sol";
import {LibDeployerDiscoverable} from "src/lib/caller/LibDeployerDiscoverable.sol";

contract TestDeployerV2 is IExpressionDeployerV2 {
    function deployExpression(bytes memory, uint256[] memory, uint256[] memory)
        external
        returns (IInterpreterV1, IInterpreterStoreV1, address)
    {}
}

contract LibDeployerV2DiscoverableTest is Test {
    /// MUST be possible to touch a deployer with 0 data to support discovery.
    function testTouchDeployerV2Mock() external {
        TestDeployerV2 deployer = new TestDeployerV2();
        vm.expectCall(
            address(deployer),
            abi.encodeWithSelector(
                IExpressionDeployerV2.deployExpression.selector, "", new uint256[](0), new uint256[](0)
            ),
            1
        );
        LibDeployerDiscoverable.touchDeployerV2(address(deployer));
    }
}
