// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572
contract ErrSubParse {}

/// @notice Thrown when a subparser is asked to build an extern dispatch when the
/// constants height is outside the range a single byte can represent.
/// @param constantsHeight The constants height that overflowed.
error ExternDispatchConstantsHeightOverflow(uint256 constantsHeight);

/// @notice Thrown when a subparser is asked to build a constant opcode when the
/// constants height overflows the 16-bit operand encoding.
/// @param constantsHeight The constants height that overflowed.
error ConstantOpcodeConstantsHeightOverflow(uint256 constantsHeight);

/// @notice Thrown when a context column or row overflows uint8.
/// @param column The column value that overflowed.
/// @param row The row value that overflowed.
error ContextGridOverflow(uint256 column, uint256 row);
