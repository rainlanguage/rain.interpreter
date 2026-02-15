// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572
contract ErrIntegrity {}

/// The bytecode and integrity function disagree on number of inputs.
/// @param opIndex The index of the op in the source.
/// @param calculatedInputs The number of inputs calculated by the integrity
/// function.
/// @param bytecodeInputs The number of inputs specified in the bytecode.
error BadOpInputsLength(uint256 opIndex, uint256 calculatedInputs, uint256 bytecodeInputs);

/// The bytecode and integrity function disagree on number of outputs.
/// @param opIndex The index of the op in the source.
/// @param calculatedOutputs The number of outputs calculated by the integrity
/// function.
/// @param bytecodeOutputs The number of outputs specified in the bytecode.
error BadOpOutputsLength(uint256 opIndex, uint256 calculatedOutputs, uint256 bytecodeOutputs);

/// The stack underflowed during integrity check.
/// @param opIndex The index of the op in the source.
/// @param stackIndex The current stack index at the point of underflow.
/// @param calculatedInputs The number of inputs that caused the underflow.
error StackUnderflow(uint256 opIndex, uint256 stackIndex, uint256 calculatedInputs);

/// The stack underflowed the highwater during integrity check.
/// @param opIndex The index of the op in the source.
/// @param stackIndex The current stack index at the point of underflow.
/// @param stackHighwater The highwater mark that was underflowed.
error StackUnderflowHighwater(uint256 opIndex, uint256 stackIndex, uint256 stackHighwater);

/// The bytecode stack allocation does not match the allocation calculated by
/// the integrity check.
/// @param stackMaxIndex The maximum stack index calculated by integrity.
/// @param bytecodeAllocation The stack allocation specified in the bytecode.
error StackAllocationMismatch(uint256 stackMaxIndex, uint256 bytecodeAllocation);

/// The final stack index does not match the bytecode outputs.
/// @param stackIndex The final stack index after integrity check.
/// @param bytecodeOutputs The number of outputs specified in the bytecode.
error StackOutputsMismatch(uint256 stackIndex, uint256 bytecodeOutputs);

/// Thrown when a constant read index is outside the constants array.
/// @param opIndex The index of the op in the source.
/// @param constantsLength The length of the constants array.
/// @param constantRead The out-of-bounds constant index that was attempted.
error OutOfBoundsConstantRead(uint256 opIndex, uint256 constantsLength, uint256 constantRead);

/// Thrown when a stack read index is outside the current stack top.
/// @param opIndex The index of the op in the source.
/// @param stackTopIndex The current stack top index.
/// @param stackRead The out-of-bounds stack index that was attempted.
error OutOfBoundsStackRead(uint256 opIndex, uint256 stackTopIndex, uint256 stackRead);

/// Thrown when the outputs requested by the operand exceed the outputs
/// available from the source.
/// @param sourceOutputs The number of outputs available from the source.
/// @param outputs The number of outputs requested by the operand.
error CallOutputsExceedSource(uint256 sourceOutputs, uint256 outputs);
