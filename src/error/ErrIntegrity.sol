// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

/// @dev There are more entrypoints defined by the minimum stack outputs than
/// there are provided sources. This means the calling contract WILL attempt to
/// eval a dangling reference to a non-existent source at some point, so this
/// MUST REVERT.
error EntrypointMissing(uint256 expectedEntrypoints, uint256 actualEntrypoints);

/// Thrown when some entrypoint has non-zero inputs. This is not allowed as
/// only internal dispatches can have source level inputs.
error EntrypointNonZeroInput(uint256 entrypointIndex, uint256 inputsLength);

/// The bytecode and integrity function disagree on number of inputs.
error BadOpInputsLength(uint256 opIndex, uint256 calculatedInputs, uint256 bytecodeInputs);

/// The stack underflowed during integrity check.
error StackUnderflow(uint256 opIndex, uint256 stackIndex, uint256 calculatedInputs);

/// The stack underflowed the highwater during integrity check.
error StackUnderflowHighwater(uint256 opIndex, uint256 stackIndex, uint256 stackHighwater);

/// The bytecode stack allocation does not match the allocation calculated by
/// the integrity check.
error StackAllocationMismatch(uint256 stackMaxIndex, uint256 bytecodeAllocation);

/// The final stack index does not match the bytecode outputs.
error StackOutputsMismatch(uint256 stackIndex, uint256 bytecodeOutputs);
