// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572
contract ErrStore {}

/// Thrown when a `set` call is made with an odd number of arguments.
/// @param length The length of the key/value array.
error OddSetLength(uint256 length);
