// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572
contract ErrIntegrity {}

/// The bytecode and integrity function disagree on number of inputs.
error BadOpInputsLength(uint256 opIndex, uint256 calculatedInputs, uint256 bytecodeInputs);

/// The bytecode and integrity function disagree on number of outputs.
error BadOpOutputsLength(uint256 opIndex, uint256 calculatedOutputs, uint256 bytecodeOutputs);

/// The stack underflowed during integrity check.
error StackUnderflow(uint256 opIndex, uint256 stackIndex, uint256 calculatedInputs);

/// The stack underflowed the highwater during integrity check.
error StackUnderflowHighwater(uint256 opIndex, uint256 stackIndex, uint256 stackHighwater);

/// The bytecode stack allocation does not match the allocation calculated by
/// the integrity check.
error StackAllocationMismatch(uint256 stackMaxIndex, uint256 bytecodeAllocation);

/// The final stack index does not match the bytecode outputs.
error StackOutputsMismatch(uint256 stackIndex, uint256 bytecodeOutputs);

/// Thrown when a constant read index is outside the constants array.
error OutOfBoundsConstantRead(uint256 opIndex, uint256 constantsLength, uint256 constantRead);
