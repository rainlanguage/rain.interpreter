// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity ^0.8.19;

/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572
contract ErrOpList {}

/// Thrown when a dynamic length array is NOT 1 more than a fixed length array.
/// Should never happen outside a major breaking change to memory layouts.
error BadDynamicLength(uint256 dynamicLength, uint256 standardOpsLength);
