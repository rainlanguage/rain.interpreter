// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../../interface/IInterpreterV1.sol";
import "./LibParseCMask.sol";
import "./LibParse.sol";
import "./LibParseLiteral.sol";

uint8 constant OPERAND_PARSER_OFFSET_DISALLOWED = 0;
uint8 constant OPERAND_PARSER_OFFSET_SINGLE_FULL = 0x10;

error UnexpectedOperand(uint256 offset);

error OperandOverflow(uint256 offset);

error UnclosedOperand(uint256 offset);

library LibParseOperand {
    function buildOperandParsers() internal pure returns (uint256 operandParsers) {
        function(uint256, bytes memory, uint256) pure returns (uint256, Operand) operandParserDisallowed =
            LibParseOperand.parseOperandDisallowed;
        uint256 parseOperandDisallowedOffset = OPERAND_PARSER_OFFSET_DISALLOWED;
        assembly {
            operandParsers := or(operandParsers, shl(parseOperandDisallowedOffset, operandParserDisallowed))
        }
        function(uint256, bytes memory, uint256) pure returns (uint256, Operand) operandParserSingleFull =
            LibParseOperand.parseOperandSingleFull;
        uint256 parseOperandSingleFullOffset = OPERAND_PARSER_OFFSET_SINGLE_FULL;
        assembly {
            operandParsers := or(operandParsers, shl(parseOperandSingleFullOffset, operandParserSingleFull))
        }
    }

    /// Operand is disallowed for this word.
    function parseOperandDisallowed(uint256, bytes memory data, uint256 cursor)
        internal
        pure
        returns (uint256, Operand)
    {
        uint256 char;
        assembly {
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
            assembly {
                end := add(data, add(mload(data), 0x20))
                //slither-disable-next-line incorrect-shift
                char := shl(byte(0, mload(cursor)), 1)
            }
            if (char == CMASK_OPERAND_START) {
                cursor = LibParse.skipMask(cursor + 1, end, CMASK_WHITESPACE);
                (
                    function(bytes memory, uint256, uint256) pure returns (uint256) literalParser,
                    uint256 innerStart,
                    uint256 innerEnd,
                    uint256 outerEnd
                ) = LibParseLiteral.boundLiteral(literalParsers, data, cursor);
                uint256 value = literalParser(data, innerStart, innerEnd);
                if (value > type(uint16).max) {
                    revert OperandOverflow(LibParse.parseErrorOffset(data, cursor));
                }
                cursor = outerEnd;
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
}
