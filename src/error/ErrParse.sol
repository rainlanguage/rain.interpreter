// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572
contract ErrParse {}

/// Thrown when parsing a source string and an operand opening `<` paren is found
/// somewhere that we don't expect it or can't handle it.
error UnexpectedOperand();

/// Thrown when there are more operand values in the operand than the handler
/// is expecting.
error UnexpectedOperandValue();

/// Thrown when parsing an operand and some required component of the operand is
/// not found in the source string.
error ExpectedOperand();

/// Thrown when the number of values encountered in a single operand parsing is
/// longer than the memory allocated to hold them.
/// @param offset The offset in the source string where the error occurred.
error OperandValuesOverflow(uint256 offset);

/// Thrown when parsing an operand and the closing `>` paren is not found.
/// @param offset The offset in the source string where the error occurred.
error UnclosedOperand(uint256 offset);

/// The parser tried to bound an unsupported literal that we have no type for.
error UnsupportedLiteralType(uint256 offset);

/// Encountered a string literal that is larger than supported.
error StringTooLong(uint256 offset);

/// Encountered a string that does not have a valid end, e.g. we found some char
/// that was not printable ASCII and had to stop.
error UnclosedStringLiteral(uint256 offset);

/// Encountered a literal that is larger than supported.
error HexLiteralOverflow(uint256 offset);

/// Encountered a zero length hex literal.
error ZeroLengthHexLiteral(uint256 offset);

/// Encountered an odd sized hex literal.
error OddLengthHexLiteral(uint256 offset);

/// Encountered a hex literal with an invalid character.
error MalformedHexLiteral(uint256 offset);

/// Encountered a decimal literal with an exponent that has too many or no
/// digits.
error MalformedExponentDigits(uint256 offset);

/// Encountered a decimal literal with a malformed decimal point.
error MalformedDecimalPoint(uint256 offset);

/// The expression does not finish with a semicolon (EOF).
error MissingFinalSemi(uint256 offset);

/// Encountered an unexpected character on the LHS.
error UnexpectedLHSChar(uint256 offset);

/// Encountered an unexpected character on the RHS.
error UnexpectedRHSChar(uint256 offset);

/// More specific version of UnexpectedRHSChar where we specifically expected
/// a left paren but got some other char.
error ExpectedLeftParen(uint256 offset);

/// Encountered a right paren without a matching left paren.
error UnexpectedRightParen(uint256 offset);

/// Encountered an unclosed left paren.
error UnclosedLeftParen(uint256 offset);

/// Encountered a comment outside the interstitial space between lines.
error UnexpectedComment(uint256 offset);

/// Encountered a comment that never ends.
error UnclosedComment(uint256 offset);

/// Encountered a comment start sequence that is malformed.
error MalformedCommentStart(uint256 offset);

/// @dev Thrown when a stack name is duplicated. Shadowing in all forms is
/// disallowed in Rainlang.
/// @param offset The byte offset of the duplicate item in the parse data.
error DuplicateLHSItem(uint256 offset);

/// Encountered too many LHS items.
error ExcessLHSItems(uint256 offset);

/// Encountered inputs where they can't be handled.
error NotAcceptingInputs(uint256 offset);

/// Encountered too many RHS items.
error ExcessRHSItems(uint256 offset);

/// Encountered a word that is longer than 32 bytes.
error WordSize(string word);

/// Parsed a word that is not in the meta.
error UnknownWord(string word);

/// The parser exceeded the maximum number of sources that it can build.
error MaxSources();

/// The parser encountered a dangling source. This is a bug in the parser.
error DanglingSource();

/// The parser moved past the end of the data.
error ParserOutOfBounds();

/// The parser encountered a stack deeper than it can process in the memory
/// region allocated for stack names.
error ParseStackOverflow();

/// The parser encountered a stack underflow.
error ParseStackUnderflow();

/// The parser encountered a paren group deeper than it can process in the
/// memory region allocated for paren tracking.
error ParenOverflow();

/// The parser did not find any whitespace after the pragma keyword.
error NoWhitespaceAfterUsingWordsFrom(uint256 offset);

/// The parser encountered a literal that it cannot use as a sub parser.
error InvalidSubParser(uint256 offset);

/// The parser encountered an unclosed sub parsed literal.
error UnclosedSubParseableLiteral(uint256 offset);

/// The parser encountered a sub parseable literal with a missing dispatch.
error SubParseableMissingDispatch(uint256 offset);

/// The sub parser returned some bytecode that the main parser could not
/// understand.
error BadSubParserResult(bytes bytecode);

/// Thrown when there are more than 16 inputs or outputs for a given opcode.
error OpcodeIOOverflow(uint256 offset);

/// Thrown when an operand value is larger than the maximum allowed.
error OperandOverflow();

/// The parser's free memory pointer exceeded 0x10000, which would corrupt
/// the 16-bit pointers used internally by the parse system.
/// @param freeMemoryPointer The free memory pointer value that exceeded the limit.
error ParseMemoryOverflow(uint256 freeMemoryPointer);
