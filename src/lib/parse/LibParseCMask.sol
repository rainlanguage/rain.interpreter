// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572
contract LibParseCMask {}

/// @dev ASCII null
uint128 constant CMASK_NULL = uint128(1) << uint128(uint8(bytes1("\x00")));

/// @dev ASCII start of heading
uint128 constant CMASK_START_OF_HEADING = uint128(1) << uint128(uint8(bytes1("\x01")));

/// @dev ASCII start of text
uint128 constant CMASK_START_OF_TEXT = uint128(1) << uint128(uint8(bytes1("\x02")));

/// @dev ASCII end of text
uint128 constant CMASK_END_OF_TEXT = uint128(1) << uint128(uint8(bytes1("\x03")));

/// @dev ASCII end of transmission
uint128 constant CMASK_END_OF_TRANSMISSION = uint128(1) << uint128(uint8(bytes1("\x04")));

/// @dev ASCII enquiry
uint128 constant CMASK_ENQUIRY = uint128(1) << uint128(uint8(bytes1("\x05")));

/// @dev ASCII acknowledge
uint128 constant CMASK_ACKNOWLEDGE = uint128(1) << uint128(uint8(bytes1("\x06")));

/// @dev ASCII bell
uint128 constant CMASK_BELL = uint128(1) << uint128(uint8(bytes1("\x07")));

/// @dev ASCII backspace
uint128 constant CMASK_BACKSPACE = uint128(1) << uint128(uint8(bytes1("\x08")));

/// @dev ASCII horizontal tab
uint128 constant CMASK_HORIZONTAL_TAB = uint128(1) << uint128(uint8(bytes1("\t")));

/// @dev ASCII line feed
uint128 constant CMASK_LINE_FEED = uint128(1) << uint128(uint8(bytes1("\n")));

/// @dev ASCII vertical tab
uint128 constant CMASK_VERTICAL_TAB = uint128(1) << uint128(uint8(bytes1("\x0B")));

/// @dev ASCII form feed
uint128 constant CMASK_FORM_FEED = uint128(1) << uint128(uint8(bytes1("\x0C")));

/// @dev ASCII carriage return
uint128 constant CMASK_CARRIAGE_RETURN = uint128(1) << uint128(uint8(bytes1("\r")));

/// @dev ASCII shift out
uint128 constant CMASK_SHIFT_OUT = uint128(1) << uint128(uint8(bytes1("\x0E")));

/// @dev ASCII shift in
uint128 constant CMASK_SHIFT_IN = uint128(1) << uint128(uint8(bytes1("\x0F")));

/// @dev ASCII data link escape
uint128 constant CMASK_DATA_LINK_ESCAPE = uint128(1) << uint128(uint8(bytes1("\x10")));

/// @dev ASCII device control 1
uint128 constant CMASK_DEVICE_CONTROL_1 = uint128(1) << uint128(uint8(bytes1("\x11")));

/// @dev ASCII device control 2
uint128 constant CMASK_DEVICE_CONTROL_2 = uint128(1) << uint128(uint8(bytes1("\x12")));

/// @dev ASCII device control 3
uint128 constant CMASK_DEVICE_CONTROL_3 = uint128(1) << uint128(uint8(bytes1("\x13")));

/// @dev ASCII device control 4
uint128 constant CMASK_DEVICE_CONTROL_4 = uint128(1) << uint128(uint8(bytes1("\x14")));

/// @dev ASCII negative acknowledge
uint128 constant CMASK_NEGATIVE_ACKNOWLEDGE = uint128(1) << uint128(uint8(bytes1("\x15")));

/// @dev ASCII synchronous idle
uint128 constant CMASK_SYNCHRONOUS_IDLE = uint128(1) << uint128(uint8(bytes1("\x16")));

/// @dev ASCII end of transmission block
uint128 constant CMASK_END_OF_TRANSMISSION_BLOCK = uint128(1) << uint128(uint8(bytes1("\x17")));

/// @dev ASCII cancel
uint128 constant CMASK_CANCEL = uint128(1) << uint128(uint8(bytes1("\x18")));

/// @dev ASCII end of medium
uint128 constant CMASK_END_OF_MEDIUM = uint128(1) << uint128(uint8(bytes1("\x19")));

/// @dev ASCII substitute
uint128 constant CMASK_SUBSTITUTE = uint128(1) << uint128(uint8(bytes1("\x1A")));

/// @dev ASCII escape
uint128 constant CMASK_ESCAPE = uint128(1) << uint128(uint8(bytes1("\x1B")));

/// @dev ASCII file separator
uint128 constant CMASK_FILE_SEPARATOR = uint128(1) << uint128(uint8(bytes1("\x1C")));

/// @dev ASCII group separator
uint128 constant CMASK_GROUP_SEPARATOR = uint128(1) << uint128(uint8(bytes1("\x1D")));

/// @dev ASCII record separator
uint128 constant CMASK_RECORD_SEPARATOR = uint128(1) << uint128(uint8(bytes1("\x1E")));

/// @dev ASCII unit separator
uint128 constant CMASK_UNIT_SEPARATOR = uint128(1) << uint128(uint8(bytes1("\x1F")));

/// @dev ASCII space
uint128 constant CMASK_SPACE = uint128(1) << uint128(uint8(bytes1(" ")));

/// @dev ASCII !
uint128 constant CMASK_EXCLAMATION_MARK = uint128(1) << uint128(uint8(bytes1("!")));

/// @dev ASCII "
uint128 constant CMASK_QUOTATION_MARK = uint128(1) << uint128(uint8(bytes1("\"")));

/// @dev ASCII #
uint128 constant CMASK_NUMBER_SIGN = uint128(1) << uint128(uint8(bytes1("#")));

/// @dev ASCII $
uint128 constant CMASK_DOLLAR_SIGN = uint128(1) << uint128(uint8(bytes1("$")));

/// @dev ASCII %
uint128 constant CMASK_PERCENT_SIGN = uint128(1) << uint128(uint8(bytes1("%")));

/// @dev ASCII &
uint128 constant CMASK_AMPERSAND = uint128(1) << uint128(uint8(bytes1("&")));

/// @dev ASCII '
uint128 constant CMASK_APOSTROPHE = uint128(1) << uint128(uint8(bytes1("'")));

/// @dev ASCII (
uint128 constant CMASK_LEFT_PAREN = uint128(1) << uint128(uint8(bytes1("(")));

/// @dev ASCII )
uint128 constant CMASK_RIGHT_PAREN = uint128(1) << uint128(uint8(bytes1(")")));

/// @dev ASCII *
uint128 constant CMASK_ASTERISK = uint128(1) << uint128(uint8(bytes1("*")));

/// @dev ASCII +
uint128 constant CMASK_PLUS_SIGN = uint128(1) << uint128(uint8(bytes1("+")));

/// @dev ASCII ,
uint128 constant CMASK_COMMA = uint128(1) << uint128(uint8(bytes1(",")));

/// @dev ASCII -
uint128 constant CMASK_DASH = uint128(1) << uint128(uint8(bytes1("-")));

/// @dev ASCII .
uint128 constant CMASK_FULL_STOP = uint128(1) << uint128(uint8(bytes1(".")));

/// @dev ASCII /
uint128 constant CMASK_SLASH = uint128(1) << uint128(uint8(bytes1("/")));

/// @dev ASCII 0
uint128 constant CMASK_ZERO = uint128(1) << uint128(uint8(bytes1("0")));

/// @dev ASCII 1
uint128 constant CMASK_ONE = uint128(1) << uint128(uint8(bytes1("1")));

/// @dev ASCII 2
uint128 constant CMASK_TWO = uint128(1) << uint128(uint8(bytes1("2")));

/// @dev ASCII 3
uint128 constant CMASK_THREE = uint128(1) << uint128(uint8(bytes1("3")));

/// @dev ASCII 4
uint128 constant CMASK_FOUR = uint128(1) << uint128(uint8(bytes1("4")));

/// @dev ASCII 5
uint128 constant CMASK_FIVE = uint128(1) << uint128(uint8(bytes1("5")));

/// @dev ASCII 6
uint128 constant CMASK_SIX = uint128(1) << uint128(uint8(bytes1("6")));

/// @dev ASCII 7
uint128 constant CMASK_SEVEN = uint128(1) << uint128(uint8(bytes1("7")));

/// @dev ASCII 8
uint128 constant CMASK_EIGHT = uint128(1) << uint128(uint8(bytes1("8")));

/// @dev ASCII 9
uint128 constant CMASK_NINE = uint128(1) << uint128(uint8(bytes1("9")));

/// @dev ASCII :
uint128 constant CMASK_COLON = uint128(1) << uint128(uint8(bytes1(":")));

/// @dev ASCII ;
uint128 constant CMASK_SEMICOLON = uint128(1) << uint128(uint8(bytes1(";")));

/// @dev ASCII <
uint128 constant CMASK_LESS_THAN_SIGN = uint128(1) << uint128(uint8(bytes1("<")));

/// @dev ASCII =
uint128 constant CMASK_EQUALS_SIGN = uint128(1) << uint128(uint8(bytes1("=")));

/// @dev ASCII >
uint128 constant CMASK_GREATER_THAN_SIGN = uint128(1) << uint128(uint8(bytes1(">")));

/// @dev ASCII ?
uint128 constant CMASK_QUESTION_MARK = uint128(1) << uint128(uint8(bytes1("?")));

/// @dev ASCII @
uint128 constant CMASK_AT_SIGN = uint128(1) << uint128(uint8(bytes1("@")));

/// @dev ASCII A
uint128 constant CMASK_UPPER_A = uint128(1) << uint128(uint8(bytes1("A")));

/// @dev ASCII B
uint128 constant CMASK_UPPER_B = uint128(1) << uint128(uint8(bytes1("B")));

/// @dev ASCII C
uint128 constant CMASK_UPPER_C = uint128(1) << uint128(uint8(bytes1("C")));

/// @dev ASCII D
uint128 constant CMASK_UPPER_D = uint128(1) << uint128(uint8(bytes1("D")));

/// @dev ASCII E
uint128 constant CMASK_UPPER_E = uint128(1) << uint128(uint8(bytes1("E")));

/// @dev ASCII F
uint128 constant CMASK_UPPER_F = uint128(1) << uint128(uint8(bytes1("F")));

/// @dev ASCII G
uint128 constant CMASK_UPPER_G = uint128(1) << uint128(uint8(bytes1("G")));

/// @dev ASCII H
uint128 constant CMASK_UPPER_H = uint128(1) << uint128(uint8(bytes1("H")));

/// @dev ASCII I
uint128 constant CMASK_UPPER_I = uint128(1) << uint128(uint8(bytes1("I")));

/// @dev ASCII J
uint128 constant CMASK_UPPER_J = uint128(1) << uint128(uint8(bytes1("J")));

/// @dev ASCII K
uint128 constant CMASK_UPPER_K = uint128(1) << uint128(uint8(bytes1("K")));

/// @dev ASCII L
uint128 constant CMASK_UPPER_L = uint128(1) << uint128(uint8(bytes1("L")));

/// @dev ASCII M
uint128 constant CMASK_UPPER_M = uint128(1) << uint128(uint8(bytes1("M")));

/// @dev ASCII N
uint128 constant CMASK_UPPER_N = uint128(1) << uint128(uint8(bytes1("N")));

/// @dev ASCII O
uint128 constant CMASK_UPPER_O = uint128(1) << uint128(uint8(bytes1("O")));

/// @dev ASCII P
uint128 constant CMASK_UPPER_P = uint128(1) << uint128(uint8(bytes1("P")));

/// @dev ASCII Q
uint128 constant CMASK_UPPER_Q = uint128(1) << uint128(uint8(bytes1("Q")));

/// @dev ASCII R
uint128 constant CMASK_UPPER_R = uint128(1) << uint128(uint8(bytes1("R")));

/// @dev ASCII S
uint128 constant CMASK_UPPER_S = uint128(1) << uint128(uint8(bytes1("S")));

/// @dev ASCII T
uint128 constant CMASK_UPPER_T = uint128(1) << uint128(uint8(bytes1("T")));

/// @dev ASCII U
uint128 constant CMASK_UPPER_U = uint128(1) << uint128(uint8(bytes1("U")));

/// @dev ASCII V
uint128 constant CMASK_UPPER_V = uint128(1) << uint128(uint8(bytes1("V")));

/// @dev ASCII W
uint128 constant CMASK_UPPER_W = uint128(1) << uint128(uint8(bytes1("W")));

/// @dev ASCII X
uint128 constant CMASK_UPPER_X = uint128(1) << uint128(uint8(bytes1("X")));

/// @dev ASCII Y
uint128 constant CMASK_UPPER_Y = uint128(1) << uint128(uint8(bytes1("Y")));

/// @dev ASCII Z
uint128 constant CMASK_UPPER_Z = uint128(1) << uint128(uint8(bytes1("Z")));

/// @dev ASCII [
uint128 constant CMASK_LEFT_SQUARE_BRACKET = uint128(1) << uint128(uint8(bytes1("[")));

/// @dev ASCII \
uint128 constant CMASK_BACKSLASH = uint128(1) << uint128(uint8(bytes1("\\")));

/// @dev ASCII ]
uint128 constant CMASK_RIGHT_SQUARE_BRACKET = uint128(1) << uint128(uint8(bytes1("]")));

/// @dev ASCII ^
uint128 constant CMASK_CIRCUMFLEX_ACCENT = uint128(1) << uint128(uint8(bytes1("^")));

/// @dev ASCII _
uint128 constant CMASK_UNDERSCORE = uint128(1) << uint128(uint8(bytes1("_")));

/// @dev ASCII `
uint128 constant CMASK_GRAVE_ACCENT = uint128(1) << uint128(uint8(bytes1("`")));

/// @dev ASCII a
uint128 constant CMASK_LOWER_A = uint128(1) << uint128(uint8(bytes1("a")));

/// @dev ASCII b
uint128 constant CMASK_LOWER_B = uint128(1) << uint128(uint8(bytes1("b")));

/// @dev ASCII c
uint128 constant CMASK_LOWER_C = uint128(1) << uint128(uint8(bytes1("c")));

/// @dev ASCII d
uint128 constant CMASK_LOWER_D = uint128(1) << uint128(uint8(bytes1("d")));

/// @dev ASCII e
uint128 constant CMASK_LOWER_E = uint128(1) << uint128(uint8(bytes1("e")));

/// @dev ASCII f
uint128 constant CMASK_LOWER_F = uint128(1) << uint128(uint8(bytes1("f")));

/// @dev ASCII g
uint128 constant CMASK_LOWER_G = uint128(1) << uint128(uint8(bytes1("g")));

/// @dev ASCII h
uint128 constant CMASK_LOWER_H = uint128(1) << uint128(uint8(bytes1("h")));

/// @dev ASCII i
uint128 constant CMASK_LOWER_I = uint128(1) << uint128(uint8(bytes1("i")));

/// @dev ASCII j
uint128 constant CMASK_LOWER_J = uint128(1) << uint128(uint8(bytes1("j")));

/// @dev ASCII k
uint128 constant CMASK_LOWER_K = uint128(1) << uint128(uint8(bytes1("k")));

/// @dev ASCII l
uint128 constant CMASK_LOWER_L = uint128(1) << uint128(uint8(bytes1("l")));

/// @dev ASCII m
uint128 constant CMASK_LOWER_M = uint128(1) << uint128(uint8(bytes1("m")));

/// @dev ASCII n
uint128 constant CMASK_LOWER_N = uint128(1) << uint128(uint8(bytes1("n")));

/// @dev ASCII o
uint128 constant CMASK_LOWER_O = uint128(1) << uint128(uint8(bytes1("o")));

/// @dev ASCII p
uint128 constant CMASK_LOWER_P = uint128(1) << uint128(uint8(bytes1("p")));

/// @dev ASCII q
uint128 constant CMASK_LOWER_Q = uint128(1) << uint128(uint8(bytes1("q")));

/// @dev ASCII r
uint128 constant CMASK_LOWER_R = uint128(1) << uint128(uint8(bytes1("r")));

/// @dev ASCII s
uint128 constant CMASK_LOWER_S = uint128(1) << uint128(uint8(bytes1("s")));

/// @dev ASCII t
uint128 constant CMASK_LOWER_T = uint128(1) << uint128(uint8(bytes1("t")));

/// @dev ASCII u
uint128 constant CMASK_LOWER_U = uint128(1) << uint128(uint8(bytes1("u")));

/// @dev ASCII v
uint128 constant CMASK_LOWER_V = uint128(1) << uint128(uint8(bytes1("v")));

/// @dev ASCII w
uint128 constant CMASK_LOWER_W = uint128(1) << uint128(uint8(bytes1("w")));

/// @dev ASCII x
uint128 constant CMASK_LOWER_X = uint128(1) << uint128(uint8(bytes1("x")));

/// @dev ASCII y
uint128 constant CMASK_LOWER_Y = uint128(1) << uint128(uint8(bytes1("y")));

/// @dev ASCII z
uint128 constant CMASK_LOWER_Z = uint128(1) << uint128(uint8(bytes1("z")));

/// @dev ASCII {
uint128 constant CMASK_LEFT_CURLY_BRACKET = uint128(1) << uint128(uint8(bytes1("{")));

/// @dev ASCII |
uint128 constant CMASK_VERTICAL_BAR = uint128(1) << uint128(uint8(bytes1("|")));

/// @dev ASCII }
uint128 constant CMASK_RIGHT_CURLY_BRACKET = uint128(1) << uint128(uint8(bytes1("}")));

/// @dev ASCII ~
uint128 constant CMASK_TILDE = uint128(1) << uint128(uint8(bytes1("~")));

/// @dev ASCII delete
uint128 constant CMASK_DELETE = uint128(1) << uint128(uint8(bytes1("\x7F")));

/// @dev ASCII printable characters is everything 0x20 and above, except 0x7F
uint128 constant CMASK_PRINTABLE = ~(
    CMASK_NULL | CMASK_START_OF_HEADING | CMASK_START_OF_TEXT | CMASK_END_OF_TEXT | CMASK_END_OF_TRANSMISSION
        | CMASK_ENQUIRY | CMASK_ACKNOWLEDGE | CMASK_BELL | CMASK_BACKSPACE | CMASK_HORIZONTAL_TAB | CMASK_LINE_FEED
        | CMASK_VERTICAL_TAB | CMASK_FORM_FEED | CMASK_CARRIAGE_RETURN | CMASK_SHIFT_OUT | CMASK_SHIFT_IN
        | CMASK_DATA_LINK_ESCAPE | CMASK_DEVICE_CONTROL_1 | CMASK_DEVICE_CONTROL_2 | CMASK_DEVICE_CONTROL_3
        | CMASK_DEVICE_CONTROL_4 | CMASK_NEGATIVE_ACKNOWLEDGE | CMASK_SYNCHRONOUS_IDLE | CMASK_END_OF_TRANSMISSION_BLOCK
        | CMASK_CANCEL | CMASK_END_OF_MEDIUM | CMASK_SUBSTITUTE | CMASK_ESCAPE | CMASK_FILE_SEPARATOR
        | CMASK_GROUP_SEPARATOR | CMASK_RECORD_SEPARATOR | CMASK_UNIT_SEPARATOR | CMASK_DELETE
);

/// @dev numeric 0-9
uint128 constant CMASK_NUMERIC_0_9 = CMASK_ZERO | CMASK_ONE | CMASK_TWO | CMASK_THREE | CMASK_FOUR | CMASK_FIVE
    | CMASK_SIX | CMASK_SEVEN | CMASK_EIGHT | CMASK_NINE;

/// @dev e notation eE
uint128 constant CMASK_E_NOTATION = CMASK_LOWER_E | CMASK_UPPER_E;

/// @dev decimal point .
uint128 constant CMASK_DECIMAL_POINT = CMASK_FULL_STOP;

/// @dev negative sign -
uint128 constant CMASK_NEGATIVE_SIGN = CMASK_DASH;

/// @dev lower alpha a-z
uint128 constant CMASK_LOWER_ALPHA_A_Z = CMASK_LOWER_A | CMASK_LOWER_B | CMASK_LOWER_C | CMASK_LOWER_D | CMASK_LOWER_E
    | CMASK_LOWER_F | CMASK_LOWER_G | CMASK_LOWER_H | CMASK_LOWER_I | CMASK_LOWER_J | CMASK_LOWER_K | CMASK_LOWER_L
    | CMASK_LOWER_M | CMASK_LOWER_N | CMASK_LOWER_O | CMASK_LOWER_P | CMASK_LOWER_Q | CMASK_LOWER_R | CMASK_LOWER_S
    | CMASK_LOWER_T | CMASK_LOWER_U | CMASK_LOWER_V | CMASK_LOWER_W | CMASK_LOWER_X | CMASK_LOWER_Y | CMASK_LOWER_Z;

/// @dev upper alpha A-Z
uint128 constant CMASK_UPPER_ALPHA_A_Z = CMASK_UPPER_A | CMASK_UPPER_B | CMASK_UPPER_C | CMASK_UPPER_D | CMASK_UPPER_E
    | CMASK_UPPER_F | CMASK_UPPER_G | CMASK_UPPER_H | CMASK_UPPER_I | CMASK_UPPER_J | CMASK_UPPER_K | CMASK_UPPER_L
    | CMASK_UPPER_M | CMASK_UPPER_N | CMASK_UPPER_O | CMASK_UPPER_P | CMASK_UPPER_Q | CMASK_UPPER_R | CMASK_UPPER_S
    | CMASK_UPPER_T | CMASK_UPPER_U | CMASK_UPPER_V | CMASK_UPPER_W | CMASK_UPPER_X | CMASK_UPPER_Y | CMASK_UPPER_Z;

/// @dev lower alpha a-f (hex)
uint128 constant CMASK_LOWER_ALPHA_A_F =
    CMASK_LOWER_A | CMASK_LOWER_B | CMASK_LOWER_C | CMASK_LOWER_D | CMASK_LOWER_E | CMASK_LOWER_F;

/// @dev upper alpha A-F (hex)
uint128 constant CMASK_UPPER_ALPHA_A_F =
    CMASK_UPPER_A | CMASK_UPPER_B | CMASK_UPPER_C | CMASK_UPPER_D | CMASK_UPPER_E | CMASK_UPPER_F;

/// @dev hex 0-9 a-f A-F
uint128 constant CMASK_HEX = CMASK_NUMERIC_0_9 | CMASK_LOWER_ALPHA_A_F | CMASK_UPPER_ALPHA_A_F;

/// @dev Rainlang end of line is ,
uint128 constant CMASK_EOL = CMASK_COMMA;

/// @dev Rainlang LHS/RHS delimiter is :
uint128 constant CMASK_LHS_RHS_DELIMITER = CMASK_COLON;

/// @dev Rainlang end of source is ;
uint128 constant CMASK_EOS = CMASK_SEMICOLON;

/// @dev Rainlang stack head is lower alpha and underscore a-z _
uint128 constant CMASK_LHS_STACK_HEAD = CMASK_LOWER_ALPHA_A_Z | CMASK_UNDERSCORE;

/// @dev Rainlang identifier head is lower alpha a-z
uint128 constant CMASK_IDENTIFIER_HEAD = CMASK_LOWER_ALPHA_A_Z;
uint128 constant CMASK_RHS_WORD_HEAD = CMASK_IDENTIFIER_HEAD;

/// @dev Rainlang stack/identifier tail is lower alphanumeric kebab a-z 0-9 -
uint128 constant CMASK_IDENTIFIER_TAIL = CMASK_IDENTIFIER_HEAD | CMASK_NUMERIC_0_9 | CMASK_DASH;
uint128 constant CMASK_LHS_STACK_TAIL = CMASK_IDENTIFIER_TAIL;
uint128 constant CMASK_RHS_WORD_TAIL = CMASK_IDENTIFIER_TAIL;

/// @dev Rainlang operand start is <
uint128 constant CMASK_OPERAND_START = CMASK_LESS_THAN_SIGN;

/// @dev Rainlang operand end is >
uint128 constant CMASK_OPERAND_END = CMASK_GREATER_THAN_SIGN;

/// @dev NOT lower alphanumeric kebab
uint128 constant CMASK_NOT_IDENTIFIER_TAIL = ~CMASK_IDENTIFIER_TAIL;

/// @dev Rainlang whitespace is \n \r \t space
uint128 constant CMASK_WHITESPACE = CMASK_LINE_FEED | CMASK_CARRIAGE_RETURN | CMASK_HORIZONTAL_TAB | CMASK_SPACE;

/// @dev Rainlang stack item delimiter is whitespace
uint128 constant CMASK_LHS_STACK_DELIMITER = CMASK_WHITESPACE;

/// @dev Rainlang supports numeric literals as anything starting with 0-9 or -
uint128 constant CMASK_NUMERIC_LITERAL_HEAD = CMASK_NUMERIC_0_9 | CMASK_NEGATIVE_SIGN;

/// @dev Rainlang supports string literals as anything starting with "
uint128 constant CMASK_STRING_LITERAL_HEAD = CMASK_QUOTATION_MARK;

/// @dev Rainlang supports sub parseable literals as anything starting with [
uint128 constant CMASK_SUB_PARSEABLE_LITERAL_HEAD = CMASK_LEFT_SQUARE_BRACKET;

/// @dev Rainlang ends a sub parseable literal with ]
uint128 constant CMASK_SUB_PARSEABLE_LITERAL_END = CMASK_RIGHT_SQUARE_BRACKET;

/// @dev Rainlang string end is "
uint128 constant CMASK_STRING_LITERAL_END = CMASK_QUOTATION_MARK;

/// @dev Rainlang string tail is any printable ASCII except " which ends it.
uint128 constant CMASK_STRING_LITERAL_TAIL = ~CMASK_STRING_LITERAL_END & CMASK_PRINTABLE;

/// @dev Rainlang literal head
uint128 constant CMASK_LITERAL_HEAD =
    CMASK_NUMERIC_LITERAL_HEAD | CMASK_STRING_LITERAL_HEAD | CMASK_SUB_PARSEABLE_LITERAL_HEAD;

/// @dev Rainlang comment head is /
uint128 constant CMASK_COMMENT_HEAD = CMASK_SLASH;

/// @dev Rainlang interstitial head could be some whitespace or a comment head.
uint128 constant CMASK_INTERSTITIAL_HEAD = CMASK_WHITESPACE | CMASK_COMMENT_HEAD;

/// @dev Rainlang comment starting sequence is /*
uint256 constant COMMENT_START_SEQUENCE = uint256(uint16(bytes2("/*")));

/// @dev Rainlang comment ending sequence is */
uint256 constant COMMENT_END_SEQUENCE = uint256(uint16(bytes2("*/")));

/// @dev Rainlang comment end sequence end byte is / */
uint256 constant CMASK_COMMENT_END_SEQUENCE_END = COMMENT_END_SEQUENCE & 0xFF;

/// @dev Rainlang literal hexadecimal dispatch is 0x
/// We compare the head and dispatch together to avoid a second comparison.
/// This is safe because the head is prefiltered to be 0-9 due to the numeric
/// literal head, therefore the only possible match is 0x (not x0).
uint128 constant CMASK_LITERAL_HEX_DISPATCH = CMASK_ZERO | CMASK_LOWER_X;

/// @dev We may want to match the exact start of a hex literal.
uint256 constant CMASK_LITERAL_HEX_DISPATCH_START = uint256(uint16(bytes2("0x")));
