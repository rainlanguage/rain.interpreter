// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.18;

import {
    ExpectedOperand,
    UnclosedOperand,
    OperandValuesOverflow,
    UnexpectedOperand,
    UnexpectedOperandValue
} from "../../error/ErrParse.sol";
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV3.sol";
import {LibParse} from "./LibParse.sol";
import {LibParseLiteral} from "./literal/LibParseLiteral.sol";
import {CMASK_OPERAND_END, CMASK_WHITESPACE, CMASK_OPERAND_START} from "./LibParseCMask.sol";
import {ParseState, OPERAND_VALUES_LENGTH, FSM_YANG_MASK} from "./LibParseState.sol";
import {LibParseError} from "./LibParseError.sol";
import {LibParseInterstitial} from "./LibParseInterstitial.sol";
import {LibFixedPointDecimalScale, DECIMAL_MAX_SAFE_INT} from "rain.math.fixedpoint/lib/LibFixedPointDecimalScale.sol";

library LibParseOperand {
    using LibParseError for ParseState;
    using LibParseLiteral for ParseState;
    using LibParseOperand for ParseState;
    using LibParseInterstitial for ParseState;

    function parseOperand(ParseState memory state, uint256 cursor, uint256 end) internal pure returns (uint256) {
        uint256 char;
        assembly ("memory-safe") {
            //slither-disable-next-line incorrect-shift
            char := shl(byte(0, mload(cursor)), 1)
        }

        // Reset operand values to length 0 to avoid any previous values bleeding
        // into processing this operand.
        uint256[] memory operandValues = state.operandValues;
        assembly ("memory-safe") {
            mstore(operandValues, 0)
        }

        // There may not be an operand. Only process if there is.
        if (char == CMASK_OPERAND_START) {
            // Move past the opening character.
            ++cursor;
            // Let the state be yin so we can parse literals.
            state.fsm &= ~FSM_YANG_MASK;

            // Load the next char.
            assembly ("memory-safe") {
                //slither-disable-next-line incorrect-shift
                char := shl(byte(0, mload(cursor)), 1)
            }
            uint256 i = 0;
            bool success = false;
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
                // Attempt to parse literals if we're not yang.
                else if (state.fsm & FSM_YANG_MASK == 0) {
                    // We can't exceed the initial length of the operand values
                    // that was allocated when the parse state was created.
                    if (i == OPERAND_VALUES_LENGTH) {
                        revert OperandValuesOverflow(state.parseErrorOffset(cursor));
                    }
                    uint256 value;
                    (cursor, value) = state.parseLiteral(cursor, end);
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
                    // Set yang so we don't attempt to parse a literal straight
                    // off the back of this literal without some whitespace.
                    state.fsm |= FSM_YANG_MASK;
                    ++i;
                }
                // Something failed here so let's say the author forgot to close
                // the operand, which is a little arbitrary but at least it's
                // a consistent error.
                else {
                    revert UnclosedOperand(state.parseErrorOffset(cursor));
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

    /// Standard dispatch for handling an operand after it is parsed, using the
    /// encoded function pointers on the current parse state. Requires that the
    /// word index has been looked up by the parser, exists, and the literal
    /// values have all been parsed out of the operand string. In the case of
    /// the main parser this will all be done inline, but in the case of a sub
    /// parser the literal extraction will be done first, then the word lookup
    /// will have to be done by the sub parser, alongside the values provided
    /// by the main parser.
    function handleOperand(ParseState memory state, uint256 wordIndex) internal pure returns (Operand) {
        function (uint256[] memory) internal pure returns (Operand) handler;
        bytes memory handlers = state.operandHandlers;
        assembly ("memory-safe") {
            // There is no bounds check here because the indexes are calcualted
            // by the parser itself, NOT provided by the user. Therefore the
            // scope of corrupt data is limited to a bug in the parser itself,
            // which can and should have direct test coverage.
            handler := and(mload(add(handlers, add(2, mul(wordIndex, 2)))), 0xFFFF)
        }
        return handler(state.operandValues);
    }

    function handleOperandDisallowed(uint256[] memory values) internal pure returns (Operand) {
        if (values.length != 0) {
            revert UnexpectedOperand();
        }
        return Operand.wrap(0);
    }

    function handleOperandDisallowedAlwaysOne(uint256[] memory values) internal pure returns (Operand) {
        if (values.length != 0) {
            revert UnexpectedOperand();
        }
        return Operand.wrap(1);
    }

    /// There must be one or zero values. The fallback is 0 if nothing is
    /// provided, else the provided value MUST fit in two bytes and is used as
    /// is.
    function handleOperandSingleFull(uint256[] memory values) internal pure returns (Operand operand) {
        // Happy path at the top for efficiency.
        if (values.length == 1) {
            assembly ("memory-safe") {
                operand := mload(add(values, 0x20))
            }
            operand = Operand.wrap(
                LibFixedPointDecimalScale.decimalOrIntToInt(Operand.unwrap(operand), uint256(type(uint16).max))
            );
        } else if (values.length == 0) {
            operand = Operand.wrap(0);
        } else {
            revert UnexpectedOperandValue();
        }
    }

    /// There must be exactly one value. There is no default fallback.
    function handleOperandSingleFullNoDefault(uint256[] memory values) internal pure returns (Operand operand) {
        // Happy path at the top for efficiency.
        if (values.length == 1) {
            assembly ("memory-safe") {
                operand := mload(add(values, 0x20))
            }
            operand = Operand.wrap(
                LibFixedPointDecimalScale.decimalOrIntToInt(Operand.unwrap(operand), uint256(type(uint16).max))
            );
        } else if (values.length == 0) {
            revert ExpectedOperand();
        } else {
            revert UnexpectedOperandValue();
        }
    }

    /// There must be exactly two values. There is no default fallback. Each
    /// value MUST fit in one byte and is used as is.
    function handleOperandDoublePerByteNoDefault(uint256[] memory values) internal pure returns (Operand operand) {
        // Happy path at the top for efficiency.
        if (values.length == 2) {
            uint256 a;
            uint256 b;
            assembly ("memory-safe") {
                a := mload(add(values, 0x20))
                b := mload(add(values, 0x40))
            }
            a = LibFixedPointDecimalScale.decimalOrIntToInt(a, type(uint8).max);
            b = LibFixedPointDecimalScale.decimalOrIntToInt(b, type(uint8).max);

            operand = Operand.wrap(a | (b << 8));
        } else if (values.length < 2) {
            revert ExpectedOperand();
        } else {
            revert UnexpectedOperandValue();
        }
    }

    /// 8 bit value then maybe 1 bit flag then maybe 1 bit flag. Fallback to 0
    /// for both flags if not provided.
    function handleOperand8M1M1(uint256[] memory values) internal pure returns (Operand operand) {
        // Happy path at the top for efficiency.
        uint256 length = values.length;
        if (length >= 1 && length <= 3) {
            uint256 a;
            uint256 b;
            uint256 c;
            assembly ("memory-safe") {
                a := mload(add(values, 0x20))
            }

            if (length >= 2) {
                assembly ("memory-safe") {
                    b := mload(add(values, 0x40))
                }
            } else {
                b = 0;
            }

            if (length == 3) {
                assembly ("memory-safe") {
                    c := mload(add(values, 0x60))
                }
            } else {
                c = 0;
            }

            a = LibFixedPointDecimalScale.decimalOrIntToInt(a, type(uint8).max);
            b = LibFixedPointDecimalScale.decimalOrIntToInt(b, 1);
            c = LibFixedPointDecimalScale.decimalOrIntToInt(c, 1);

            operand = Operand.wrap(a | (b << 8) | (c << 9));
        } else if (length == 0) {
            revert ExpectedOperand();
        } else {
            revert UnexpectedOperandValue();
        }
    }

    /// 2x maybe 1 bit flags. Fallback to 0 for both flags if not provided.
    function handleOperandM1M1(uint256[] memory values) internal pure returns (Operand operand) {
        // Happy path at the top for efficiency.
        uint256 length = values.length;
        if (length < 3) {
            uint256 a;
            uint256 b;

            if (length >= 1) {
                assembly ("memory-safe") {
                    a := mload(add(values, 0x20))
                }
            } else {
                a = 0;
            }

            if (length == 2) {
                assembly ("memory-safe") {
                    b := mload(add(values, 0x40))
                }
            } else {
                b = 0;
            }

            a = LibFixedPointDecimalScale.decimalOrIntToInt(a, 1);
            b = LibFixedPointDecimalScale.decimalOrIntToInt(b, 1);

            operand = Operand.wrap(a | (b << 1));
        } else {
            revert UnexpectedOperandValue();
        }
    }
}
