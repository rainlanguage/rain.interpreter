// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

/// Thrown when parsing a source string and an operand opening `<` paren is found
/// somewhere that we don't expect it or can't handle it.
/// @param offset The offset in the source string where the error occurred.
error UnexpectedOperand(uint256 offset);

/// Thrown when parsing an operand and some required component of the operand is
/// not found in the source string.
/// @param offset The offset in the source string where the error occurred.
error ExpectedOperand(uint256 offset);

/// Thrown when parsing an operand and the literal in the source string is too
/// large to fit in the bits allocated for it in the operand.
/// @param offset The offset in the source string where the error occurred.
error OperandOverflow(uint256 offset);

/// Thrown when parsing an operand and the closing `>` paren is not found.
/// @param offset The offset in the source string where the error occurred.
error UnclosedOperand(uint256 offset);
