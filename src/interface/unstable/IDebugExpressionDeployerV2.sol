// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../IInterpreterV1.sol";

interface IDebugExpressionDeployerV2 {
    function offchainDebugEval(
        bytes memory expressionData,
        FullyQualifiedNamespace namespace,
        uint256[][] memory context,
        SourceIndex sourceIndex,
        uint256[] memory initialStack,
        uint8 minOutputs
    ) external view returns (uint256[] memory finalStack, uint256[] memory kvs);
}
