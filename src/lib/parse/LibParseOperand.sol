// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {ExpectedOperand, UnclosedOperand, OperandOverflow, OperandValuesOverflow, UnexpectedOperand} from "../../error/ErrParse.sol";
import {Operand} from "../../interface/unstable/IInterpreterV2.sol";
import {LibParse} from "./LibParse.sol";
import {LibParseLiteral} from "./LibParseLiteral.sol";
import {CMASK_OPERAND_END, CMASK_WHITESPACE, CMASK_OPERAND_START} from "./LibParseCMask.sol";
import {ParseState, OPERAND_VALUES_LENGTH} from "./LibParseState.sol";
import {LibParseError} from "./LibParseError.sol";
import {LibParseInterstitial} from "./LibParseInterstitial.sol";

uint8 constant OPERAND_PARSER_OFFSET_DISALLOWED = 0;
uint8 constant OPERAND_PARSER_OFFSET_SINGLE_FULL = 0x10;
uint8 constant OPERAND_PARSER_OFFSET_DOUBLE_PERBYTE_NO_DEFAULT = 0x20;
uint8 constant OPERAND_PARSER_OFFSET_M1_M1 = 0x30;
uint8 constant OPERAND_PARSER_OFFSET_8_M1_M1 = 0x40;

library LibParseOperand {
    using LibParseError for ParseState;
    using LibParseLiteral for ParseState;
    using LibParseOperand for ParseState;
    using LibParseInterstitial for ParseState;

    function buildOperandParsers() internal pure returns (uint256 operandParsers) {
        function(ParseState memory, uint256, uint256) pure returns (uint256, Operand) operandParserDisallowed =
            LibParseOperand.parseOperandDisallowed;
        uint256 parseOperandDisallowedOffset = OPERAND_PARSER_OFFSET_DISALLOWED;
        assembly ("memory-safe") {
            operandParsers := or(operandParsers, shl(parseOperandDisallowedOffset, operandParserDisallowed))
        }
        function(ParseState memory, uint256, uint256) pure returns (uint256, Operand) operandParserSingleFull =
            LibParseOperand.parseOperandSingleFull;
        uint256 parseOperandSingleFullOffset = OPERAND_PARSER_OFFSET_SINGLE_FULL;
        assembly ("memory-safe") {
            operandParsers := or(operandParsers, shl(parseOperandSingleFullOffset, operandParserSingleFull))
        }
        function(ParseState memory, uint256, uint256) pure returns (uint256, Operand)
            operandParserDoublePerByteNoDefault = LibParseOperand.parseOperandDoublePerByteNoDefault;
        uint256 parseOperandDoublePerByteNoDefaultOffset = OPERAND_PARSER_OFFSET_DOUBLE_PERBYTE_NO_DEFAULT;
        assembly ("memory-safe") {
            operandParsers :=
                or(operandParsers, shl(parseOperandDoublePerByteNoDefaultOffset, operandParserDoublePerByteNoDefault))
        }
        function(ParseState memory, uint256, uint256) pure returns (uint256, Operand) operandParser_m1_m1 =
            LibParseOperand.parseOperandM1M1;
        uint256 parseOperand_m1_m1Offset = OPERAND_PARSER_OFFSET_M1_M1;
        assembly ("memory-safe") {
            operandParsers := or(operandParsers, shl(parseOperand_m1_m1Offset, operandParser_m1_m1))
        }
        function(ParseState memory, uint256, uint256) pure returns (uint256, Operand) operandParser_8_m1_m1 =
            LibParseOperand.parseOperand8M1M1;
        uint256 parseOperand_8_m1_m1Offset = OPERAND_PARSER_OFFSET_8_M1_M1;
        assembly ("memory-safe") {
            operandParsers := or(operandParsers, shl(parseOperand_8_m1_m1Offset, operandParser_8_m1_m1))
        }
    }

    function parseOperand(ParseState memory state, uint256 cursor, uint256 end) internal pure returns (uint256) {
        uint256 char;
        assembly ("memory-safe") {
            //slither-disable-next-line incorrect-shift
            char := shl(byte(0, mload(cursor)), 1)
        }

        // There may not be an operand. Only process if there is.
        if (char == CMASK_OPERAND_START) {
            // Move past the opening character.
            ++cursor;

            // Load the next char.
            assembly ("memory-safe") {
                //slither-disable-next-line incorrect-shift
                char := shl(byte(0, mload(cursor)), 1)
            }
            uint256 i = 0;
            bool success = false;
            uint256[] memory operandValues = state.operandValues;
            while (cursor < end) {
                // Load the next char.
                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    char := shl(byte(0, mload(cursor)), 1)
                }

                // Handle any whitespace.
                // We DO NOT currently support full interstitial parsing here.
                if (char & CMASK_WHITESPACE != 0) {
                    // Move past the whitespace.
                    cursor = state.skipWhitespace(cursor, end);
                }
                // If the operand has ended break.
                else if (char & CMASK_OPERAND_END != 0) {
                    // Move past the operand end.
                    ++cursor;
                    success = true;
                    break;
                }
                // Attempt to parse literals.
                else {
                    (
                        function(ParseState memory, uint256, uint256) pure returns (uint256) literalParser,
                        uint256 innerStart,
                        uint256 innerEnd,
                        uint256 outerEnd
                    ) = state.boundLiteral(cursor, end);
                    uint256 value = literalParser(state, innerStart, innerEnd);
                    // We manipulate the operand values array directly in
                    // assembly because if we used the Solidity indexing syntax
                    // it would bounds check against the _current_ length of the
                    // operand values array, not the length it was when the
                    // parse state was created. The current length is just
                    // whatever it happened to be for the last operand that was
                    // parsed, so it's not useful for us here.
                    assembly ("memory-safe") {
                        mstore(add(operandValues, add(0x20, mul(i, 0x20))), value)
                    }
                    // We can't exceed the initial length of the operand values
                    // that was allocated when the parse state was created.
                    if (i++ == OPERAND_VALUES_LENGTH) {
                        revert OperandValuesOverflow(state.parseErrorOffset(cursor));
                    }
                    cursor = outerEnd;
                }
            }
            if (!success) {
                revert UnclosedOperand(state.parseErrorOffset(cursor));
            }
            assembly ("memory-safe") {
                mstore(operandValues, i)
            }
        }

        return cursor;
    }

    /// Move past an operand that may or may not exist.
    function skipOperand(ParseState memory state, uint256 cursor, uint256 end) internal pure returns (uint256) {
        uint256 char;
        assembly ("memory-safe") {
            //slither-disable-next-line incorrect-shift
            char := shl(byte(0, mload(cursor)), 1)
        }
        // If the operand is opening, skip it. Don't pretend to understand it.
        if (char == CMASK_OPERAND_START) {
            cursor = LibParse.skipMask(cursor + 1, end, ~CMASK_OPERAND_END);
            // If the cursor is right at the end then it never found the operand
            // closing character.
            if (cursor >= end) {
                revert UnclosedOperand(state.parseErrorOffset(cursor));
            }
            // Move pase the operand end.
            ++cursor;
        }
        return cursor;
    }

    /// Parse a literal for an operand.
    function parseOperandLiteral(ParseState memory state, uint256 maxValue, uint256 cursor, uint256 end)
        internal
        pure
        returns (uint256, uint256)
    {
        uint256 char;
        assembly ("memory-safe") {
            //slither-disable-next-line incorrect-shift
            char := shl(byte(0, mload(cursor)), 1)
        }
        if (char == CMASK_OPERAND_END) {
            revert ExpectedOperand(state.parseErrorOffset(cursor));
        }
        (
            function(ParseState memory, uint256, uint256) pure returns (uint256) literalParser,
            uint256 innerStart,
            uint256 innerEnd,
            uint256 outerEnd
        ) = state.boundLiteral(cursor, end);
        uint256 value = literalParser(state, innerStart, innerEnd);
        if (value > maxValue) {
            revert OperandOverflow(state.parseErrorOffset(cursor));
        }
        return (outerEnd, value);
    }

    /// Operand is disallowed for this word.
    function parseOperandDisallowed(ParseState memory state, uint256 cursor, uint256)
        internal
        pure
        returns (uint256, Operand)
    {
        uint256 char;
        assembly ("memory-safe") {
            //slither-disable-next-line incorrect-shift
            char := shl(byte(0, mload(cursor)), 1)
        }
        if (char == CMASK_OPERAND_START) {
            revert UnexpectedOperand(state.parseErrorOffset(cursor));
        }
        // Don't move the cursor. This is a no-op.
        return (cursor, Operand.wrap(0));
    }

    /// Operand is a 16-bit unsigned integer.
    function parseOperandSingleFull(ParseState memory state, uint256 cursor, uint256 end)
        internal
        pure
        returns (uint256, Operand)
    {
        unchecked {
            uint256 char;
            assembly ("memory-safe") {
                //slither-disable-next-line incorrect-shift
                char := shl(byte(0, mload(cursor)), 1)
            }
            if (char == CMASK_OPERAND_START) {
                cursor = LibParse.skipMask(cursor + 1, end, CMASK_WHITESPACE);

                uint256 value;
                (cursor, value) = state.parseOperandLiteral(type(uint16).max, cursor, end);

                cursor = LibParse.skipMask(cursor, end, CMASK_WHITESPACE);
                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    char := shl(byte(0, mload(cursor)), 1)
                }
                if (char != CMASK_OPERAND_END) {
                    revert UnclosedOperand(state.parseErrorOffset(cursor));
                }
                return (cursor + 1, Operand.wrap(value));
            }
            // Default is 0.
            else {
                return (cursor, Operand.wrap(0));
            }
        }
    }

    /// Operand is two bytes.
    function parseOperandDoublePerByteNoDefault(ParseState memory state, uint256 cursor, uint256 end)
        internal
        pure
        returns (uint256, Operand)
    {
        unchecked {
            uint256 char;
            assembly ("memory-safe") {
                //slither-disable-next-line incorrect-shift
                char := shl(byte(0, mload(cursor)), 1)
            }
            if (char == CMASK_OPERAND_START) {
                cursor = LibParse.skipMask(cursor + 1, end, CMASK_WHITESPACE);

                uint256 a;
                (cursor, a) = parseOperandLiteral(state, type(uint8).max, cursor, end);
                Operand operand = Operand.wrap(a);

                cursor = LibParse.skipMask(cursor, end, CMASK_WHITESPACE);

                uint256 b;
                (cursor, b) = parseOperandLiteral(state, type(uint8).max, cursor, end);
                operand = Operand.wrap(Operand.unwrap(operand) | (b << 8));

                cursor = LibParse.skipMask(cursor, end, CMASK_WHITESPACE);

                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    char := shl(byte(0, mload(cursor)), 1)
                }
                if (char != CMASK_OPERAND_END) {
                    revert UnclosedOperand(state.parseErrorOffset(cursor));
                }
                return (cursor + 1, operand);
            }
            // There is no default fallback value.
            else {
                revert ExpectedOperand(state.parseErrorOffset(cursor));
            }
        }
    }

    /// 8 bit value, maybe 1 bit flag, maybe 1 big flag.
    function parseOperand8M1M1(ParseState memory state, uint256 cursor, uint256 end)
        internal
        pure
        returns (uint256, Operand)
    {
        unchecked {
            uint256 char;
            assembly ("memory-safe") {
                //slither-disable-next-line incorrect-shift
                char := shl(byte(0, mload(cursor)), 1)
            }
            if (char == CMASK_OPERAND_START) {
                cursor = LibParse.skipMask(cursor + 1, end, CMASK_WHITESPACE);

                // 8 bit value. Required.
                uint256 a;
                (cursor, a) = state.parseOperandLiteral(type(uint8).max, cursor, end);
                cursor = LibParse.skipMask(cursor, end, CMASK_WHITESPACE);

                // Maybe 1 bit flag.
                uint256 b;
                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    char := shl(byte(0, mload(cursor)), 1)
                }
                if (char == CMASK_OPERAND_END) {
                    b = 0;
                } else {
                    (cursor, b) = state.parseOperandLiteral(1, cursor, end);
                    cursor = LibParse.skipMask(cursor, end, CMASK_WHITESPACE);
                }

                // Maybe 1 bit flag.
                uint256 c;
                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    char := shl(byte(0, mload(cursor)), 1)
                }
                if (char == CMASK_OPERAND_END) {
                    c = 0;
                } else {
                    (cursor, c) = state.parseOperandLiteral(1, cursor, end);
                    cursor = LibParse.skipMask(cursor, end, CMASK_WHITESPACE);
                }

                Operand operand = Operand.wrap(a | (b << 8) | (c << 9));

                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    char := shl(byte(0, mload(cursor)), 1)
                }
                if (char != CMASK_OPERAND_END) {
                    revert UnclosedOperand(state.parseErrorOffset(cursor));
                }
                return (cursor + 1, operand);
            }
            // There is no default fallback value. The first 8 bits are
            // required.
            else {
                revert ExpectedOperand(state.parseErrorOffset(cursor));
            }
        }
    }

    /// 2x maybe 1 bit flags.
    function parseOperandM1M1(ParseState memory state, uint256 cursor, uint256 end)
        internal
        pure
        returns (uint256, Operand)
    {
        unchecked {
            uint256 char;
            assembly ("memory-safe") {
                //slither-disable-next-line incorrect-shift
                char := shl(byte(0, mload(cursor)), 1)
            }
            if (char == CMASK_OPERAND_START) {
                cursor = LibParse.skipMask(cursor + 1, end, CMASK_WHITESPACE);

                uint256 a;
                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    char := shl(byte(0, mload(cursor)), 1)
                }
                if (char == CMASK_OPERAND_END) {
                    a = 0;
                } else {
                    (cursor, a) = state.parseOperandLiteral(1, cursor, end);
                    cursor = LibParse.skipMask(cursor, end, CMASK_WHITESPACE);
                }

                uint256 b;
                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    char := shl(byte(0, mload(cursor)), 1)
                }
                if (char == CMASK_OPERAND_END) {
                    b = 0;
                } else {
                    (cursor, b) = state.parseOperandLiteral(1, cursor, end);
                    cursor = LibParse.skipMask(cursor, end, CMASK_WHITESPACE);
                }

                Operand operand = Operand.wrap(a | (b << 1));

                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    char := shl(byte(0, mload(cursor)), 1)
                }
                if (char != CMASK_OPERAND_END) {
                    revert UnclosedOperand(state.parseErrorOffset(cursor));
                }
                return (cursor + 1, operand);
            }
            // Default is 0.
            else {
                return (cursor, Operand.wrap(0));
            }
        }
    }
}
