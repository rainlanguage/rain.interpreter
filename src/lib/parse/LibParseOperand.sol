// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {ExpectedOperand, UnclosedOperand, OperandOverflow, UnexpectedOperand} from "../../error/ErrParse.sol";
import {Operand} from "../../interface/unstable/IInterpreterV2.sol";
import {LibParse} from "./LibParse.sol";
import {LibParseLiteral} from "./LibParseLiteral.sol";
import {CMASK_OPERAND_END, CMASK_WHITESPACE, CMASK_OPERAND_START} from "./LibParseCMask.sol";

uint8 constant OPERAND_PARSER_OFFSET_DISALLOWED = 0;
uint8 constant OPERAND_PARSER_OFFSET_SINGLE_FULL = 0x10;
uint8 constant OPERAND_PARSER_OFFSET_DOUBLE_PERBYTE_NO_DEFAULT = 0x20;
uint8 constant OPERAND_PARSER_OFFSET_M1_M1 = 0x30;
uint8 constant OPERAND_PARSER_OFFSET_8_M1_M1 = 0x40;

library LibParseOperand {
    function buildOperandParsers() internal pure returns (uint256 operandParsers) {
        function(uint256, bytes memory, uint256) pure returns (uint256, Operand) operandParserDisallowed =
            LibParseOperand.parseOperandDisallowed;
        uint256 parseOperandDisallowedOffset = OPERAND_PARSER_OFFSET_DISALLOWED;
        assembly ("memory-safe") {
            operandParsers := or(operandParsers, shl(parseOperandDisallowedOffset, operandParserDisallowed))
        }
        function(uint256, bytes memory, uint256) pure returns (uint256, Operand) operandParserSingleFull =
            LibParseOperand.parseOperandSingleFull;
        uint256 parseOperandSingleFullOffset = OPERAND_PARSER_OFFSET_SINGLE_FULL;
        assembly ("memory-safe") {
            operandParsers := or(operandParsers, shl(parseOperandSingleFullOffset, operandParserSingleFull))
        }
        function(uint256, bytes memory, uint256) pure returns (uint256, Operand) operandParserDoublePerByteNoDefault =
            LibParseOperand.parseOperandDoublePerByteNoDefault;
        uint256 parseOperandDoublePerByteNoDefaultOffset = OPERAND_PARSER_OFFSET_DOUBLE_PERBYTE_NO_DEFAULT;
        assembly ("memory-safe") {
            operandParsers :=
                or(operandParsers, shl(parseOperandDoublePerByteNoDefaultOffset, operandParserDoublePerByteNoDefault))
        }
        function(uint256, bytes memory, uint256) pure returns (uint256, Operand) operandParser_m1_m1 =
            LibParseOperand.parseOperandM1M1;
        uint256 parseOperand_m1_m1Offset = OPERAND_PARSER_OFFSET_M1_M1;
        assembly ("memory-safe") {
            operandParsers := or(operandParsers, shl(parseOperand_m1_m1Offset, operandParser_m1_m1))
        }
        function(uint256, bytes memory, uint256) pure returns (uint256, Operand) operandParser_8_m1_m1 =
            LibParseOperand.parseOperand8M1M1;
        uint256 parseOperand_8_m1_m1Offset = OPERAND_PARSER_OFFSET_8_M1_M1;
        assembly ("memory-safe") {
            operandParsers := or(operandParsers, shl(parseOperand_8_m1_m1Offset, operandParser_8_m1_m1))
        }
    }

    /// Parse a literal for an operand.
    function parseOperandLiteral(uint256 literalParsers, bytes memory data, uint256 max, uint256 cursor)
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
            revert ExpectedOperand(LibParse.parseErrorOffset(data, cursor));
        }
        (
            function(bytes memory, uint256, uint256) pure returns (uint256) literalParser,
            uint256 innerStart,
            uint256 innerEnd,
            uint256 outerEnd
        ) = LibParseLiteral.boundLiteral(literalParsers, data, cursor);
        uint256 value = literalParser(data, innerStart, innerEnd);
        if (value > max) {
            revert OperandOverflow(LibParse.parseErrorOffset(data, cursor));
        }
        return (outerEnd, value);
    }

    /// Operand is disallowed for this word.
    function parseOperandDisallowed(uint256, bytes memory data, uint256 cursor)
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
            revert UnexpectedOperand(LibParse.parseErrorOffset(data, cursor));
        }
        // Don't move the cursor. This is a no-op.
        return (cursor, Operand.wrap(0));
    }

    /// Operand is a 16-bit unsigned integer.
    function parseOperandSingleFull(uint256 literalParsers, bytes memory data, uint256 cursor)
        internal
        pure
        returns (uint256, Operand)
    {
        unchecked {
            uint256 char;
            uint256 end;
            assembly ("memory-safe") {
                end := add(data, add(mload(data), 0x20))
                //slither-disable-next-line incorrect-shift
                char := shl(byte(0, mload(cursor)), 1)
            }
            if (char == CMASK_OPERAND_START) {
                cursor = LibParse.skipMask(cursor + 1, end, CMASK_WHITESPACE);

                uint256 value;
                (cursor, value) = parseOperandLiteral(literalParsers, data, type(uint16).max, cursor);

                cursor = LibParse.skipMask(cursor, end, CMASK_WHITESPACE);
                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    char := shl(byte(0, mload(cursor)), 1)
                }
                if (char != CMASK_OPERAND_END) {
                    revert UnclosedOperand(LibParse.parseErrorOffset(data, cursor));
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
    function parseOperandDoublePerByteNoDefault(uint256 literalParsers, bytes memory data, uint256 cursor)
        internal
        pure
        returns (uint256, Operand)
    {
        unchecked {
            uint256 char;
            uint256 end;
            assembly ("memory-safe") {
                end := add(data, add(mload(data), 0x20))
                //slither-disable-next-line incorrect-shift
                char := shl(byte(0, mload(cursor)), 1)
            }
            if (char == CMASK_OPERAND_START) {
                cursor = LibParse.skipMask(cursor + 1, end, CMASK_WHITESPACE);

                uint256 a;
                (cursor, a) = parseOperandLiteral(literalParsers, data, type(uint8).max, cursor);
                Operand operand = Operand.wrap(a);

                cursor = LibParse.skipMask(cursor, end, CMASK_WHITESPACE);

                uint256 b;
                (cursor, b) = parseOperandLiteral(literalParsers, data, type(uint8).max, cursor);
                operand = Operand.wrap(Operand.unwrap(operand) | (b << 8));

                cursor = LibParse.skipMask(cursor, end, CMASK_WHITESPACE);

                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    char := shl(byte(0, mload(cursor)), 1)
                }
                if (char != CMASK_OPERAND_END) {
                    revert UnclosedOperand(LibParse.parseErrorOffset(data, cursor));
                }
                return (cursor + 1, operand);
            }
            // There is no default fallback value.
            else {
                revert ExpectedOperand(LibParse.parseErrorOffset(data, cursor));
            }
        }
    }

    /// 8 bit value, maybe 1 bit flag, maybe 1 big flag.
    function parseOperand8M1M1(uint256 literalParsers, bytes memory data, uint256 cursor)
        internal
        pure
        returns (uint256, Operand)
    {
        unchecked {
            uint256 char;
            uint256 end;
            assembly ("memory-safe") {
                end := add(data, add(mload(data), 0x20))
                //slither-disable-next-line incorrect-shift
                char := shl(byte(0, mload(cursor)), 1)
            }
            if (char == CMASK_OPERAND_START) {
                cursor = LibParse.skipMask(cursor + 1, end, CMASK_WHITESPACE);

                // 8 bit value. Required.
                uint256 a;
                (cursor, a) = parseOperandLiteral(literalParsers, data, type(uint8).max, cursor);
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
                    (cursor, b) = parseOperandLiteral(literalParsers, data, 1, cursor);
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
                    (cursor, c) = parseOperandLiteral(literalParsers, data, 1, cursor);
                    cursor = LibParse.skipMask(cursor, end, CMASK_WHITESPACE);
                }

                Operand operand = Operand.wrap(a | (b << 8) | (c << 9));

                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    char := shl(byte(0, mload(cursor)), 1)
                }
                if (char != CMASK_OPERAND_END) {
                    revert UnclosedOperand(LibParse.parseErrorOffset(data, cursor));
                }
                return (cursor + 1, operand);
            }
            // There is no default fallback value. The first 8 bits are
            // required.
            else {
                revert ExpectedOperand(LibParse.parseErrorOffset(data, cursor));
            }
        }
    }

    /// 2x maybe 1 bit flags.
    function parseOperandM1M1(uint256 literalParsers, bytes memory data, uint256 cursor)
        internal
        pure
        returns (uint256, Operand)
    {
        unchecked {
            uint256 char;
            uint256 end;
            assembly ("memory-safe") {
                end := add(data, add(mload(data), 0x20))
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
                    (cursor, a) = parseOperandLiteral(literalParsers, data, 1, cursor);
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
                    (cursor, b) = parseOperandLiteral(literalParsers, data, 1, cursor);
                    cursor = LibParse.skipMask(cursor, end, CMASK_WHITESPACE);
                }

                Operand operand = Operand.wrap(a | (b << 1));

                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    char := shl(byte(0, mload(cursor)), 1)
                }
                if (char != CMASK_OPERAND_END) {
                    revert UnclosedOperand(LibParse.parseErrorOffset(data, cursor));
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
