// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../IInterpreterV1.sol";

interface IDebugInterpreterV2 {
    function offchainDebugEval(
        IInterpreterStoreV1 store,
        bytes calldata expressionData,
        FullyQualifiedNamespace namespace,
        uint256[][] calldata context,
        uint256[] calldata initialStack,
        SourceIndex sourceIndex_
    ) external view returns (uint256[] calldata finalStack, uint256[] calldata kvs);
}
