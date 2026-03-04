// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572
contract ErrStore {}

/// @notice Thrown when a key-value array has an odd number of elements.
/// Used by both `set` calls and `eval4` state overlay validation.
/// @param length The length of the key/value array.
error OddSetLength(uint256 length);
