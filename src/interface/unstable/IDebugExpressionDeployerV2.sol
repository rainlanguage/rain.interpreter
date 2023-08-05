// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../IInterpreterV1.sol";

interface IDebugExpressionDeployerV2 {
    /// Deployer level equivalent of `IDebugInterpreterV2.offchainDebugEval`.
    /// Includes an integrity check on the bytecode to ensure that it is
    /// not going to attempt OOB reads at runtime, etc.
    /// The integrity check MUST function identically to the check in
    /// `IExpressionDeployerV1.deploy`, implementations are encouraged to set
    /// aside shared logic for both internally.
    /// The eval component MUST be identical to the associated interpreter for
    /// this deployer. Implementations SHOULD call the interpreter directly
    /// to ensure consistency of the debug eval.
    function offchainDebugEval(
        FullyQualifiedNamespace namespace,
        bytes memory expressionData,
        SourceIndex sourceIndex,
        uint256 maxOutputs,
        uint256[][] memory context,
        uint256[] memory inputs,
        uint256 minOutputs
    ) external view returns (uint256[] memory finalStack, uint256[] memory kvs);
}
