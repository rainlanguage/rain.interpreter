// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {IExpressionDeployerV3} from "src/interface/unstable/IExpressionDeployerV3.sol";
import {LibDeployerDiscoverable} from "src/lib/caller/LibDeployerDiscoverable.sol";
import {IInterpreterV2} from "src/interface/unstable/IInterpreterV2.sol";
import {IInterpreterStoreV1} from "src/interface/IInterpreterStoreV1.sol";

contract TestDeployerV3 is IExpressionDeployerV3 {
    function deployExpression2(bytes memory, uint256[] memory)
        external
        returns (IInterpreterV2, IInterpreterStoreV1, address, bytes memory)
    {}
}

contract LibDeployerV3DiscoverableTest is Test {
    /// MUST be possible to touch a deployer with 0 data to support discovery.
    function testTouchDeployerV3Mock() external {
        TestDeployerV3 deployer = new TestDeployerV3();
        vm.expectCall(
            address(deployer),
            abi.encodeWithSelector(
                IExpressionDeployerV3.deployExpression2.selector, "", new uint256[](0), new uint256[](0)
            ),
            1
        );
        LibDeployerDiscoverable.touchDeployerV3(address(deployer));
    }
}
