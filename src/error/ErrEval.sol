// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572
contract ErrEval {}

/// Thrown when the stack underflows during eval.
error StackPointerUnderflow();

/// Thrown when the inputs length does not match the expected inputs length.
/// @param expected The expected number of inputs.
/// @param actual The actual number of inputs.
error InputsLengthMismatch(uint256 expected, uint256 actual);
