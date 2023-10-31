// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IExpressionDeployerV3} from "../../interface/unstable/IExpressionDeployerV3.sol";
import {IInterpreterStoreV1} from "../../interface/IInterpreterStoreV1.sol";
import {IInterpreterV2} from "../../interface/unstable/IInterpreterV2.sol";

library LibDeployerDiscoverable {
    /// Hack so that some deployer will emit an event with the sender as the
    /// caller of `touchDeployer`. This MAY be needed by indexers such as
    /// subgraph that can only index events from the first moment they are aware
    /// of some contract. The deployer MUST be registered in ERC1820 registry
    /// before it is touched, THEN the caller meta MUST be emitted after the
    /// deployer is touched. This allows indexers such as subgraph to index the
    /// deployer, then see the caller, then see the caller's meta emitted in the
    /// same transaction.
    /// This is NOT required if ANY other expression is deployed in the same
    /// transaction as the caller meta, there only needs to be one expression on
    /// ANY deployer known to ERC1820.
    function touchDeployerV3(address deployer) internal {
        (IInterpreterV2 interpreter, IInterpreterStoreV1 store, address expression) =
            IExpressionDeployerV3(deployer).deployExpression2("", new uint256[](0), new uint256[](0));
        (interpreter);
        (store);
        (expression);
    }
}
