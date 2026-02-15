// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572
contract ErrEval {}

/// Thrown when the stack underflows during eval.
error StackPointerUnderflow();
