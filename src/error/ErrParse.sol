// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572
contract ErrParse {}

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

/// Encountered a decimal literal that is larger than supported.
error DecimalLiteralOverflow(uint256 offset);

/// Encountered a decimal literal with an exponent that has too many or no
/// digits.
error MalformedExponentDigits(uint256 offset);

/// Encountered a zero length decimal literal.
error ZeroLengthDecimal(uint256 offset);

/// The expression does not finish with a semicolon (EOF).
error MissingFinalSemi(uint256 offset);

/// Enountered an unexpected character on the LHS.
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
error DuplicateLHSItem(uint256 errorOffset);

/// Encountered too many LHS items.
error ExcessLHSItems(uint256 offset);

/// Encountered inputs where they can't be handled.
error NotAcceptingInputs(uint256 offset);

/// Encountered too many RHS items.
error ExcessRHSItems(uint256 offset);

/// Encountered a word that is longer than 32 bytes.
error WordSize(string word);

/// Parsed a word that is not in the meta.
error UnknownWord(uint256 offset);

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

/// The parser encountered a hex literal that is the wrong size to be an address.
error InvalidAddressLength(uint256 offset);
