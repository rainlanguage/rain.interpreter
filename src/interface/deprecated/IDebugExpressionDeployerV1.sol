// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {FullyQualifiedNamespace} from "../IInterpreterStoreV1.sol";
import {IInterpreterV1, SourceIndex} from "../IInterpreterV1.sol";

interface IDebugExpressionDeployerV1 {
    function offchainDebugEval(
        bytes[] memory sources,
        uint256[] memory constants,
        FullyQualifiedNamespace namespace,
        uint256[][] memory context,
        SourceIndex sourceIndex,
        uint256[] memory initialStack,
        uint8 minOutputs
    ) external view returns (uint256[] memory finalStack, uint256[] memory kvs);
}
