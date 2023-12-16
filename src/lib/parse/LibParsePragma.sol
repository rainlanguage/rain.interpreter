// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {ParseState} from "./LibParseState.sol";
import {CMASK_WHITESPACE, CMASK_LITERAL_HEX_DISPATCH_START} from "./LibParseCMask.sol";
import {NoWhitespaceAfterUsingWordsFrom} from "../../error/ErrParse.sol";
import {LibParseError} from "./LibParseError.sol";
import {LibParseInterstitial} from "./LibParseInterstitial.sol";
import {LibParseLiteral} from "./LibParseLiteral.sol";

bytes constant PRAGMA_KEYWORD_BYTES = bytes("using-words-from");
bytes32 constant PRAGMA_KEYWORD_BYTES32 = bytes32(PRAGMA_KEYWORD_BYTES);
uint256 constant PRAGMA_KEYWORD_BYTES_LENGTH = 16;
bytes32 constant PRAGMA_KEYWORD_MASK = bytes32(~((1 << (32 - PRAGMA_KEYWORD_BYTES_LENGTH) * 8) - 1));

library LibParsePragma {
    using LibParseError for ParseState;
    using LibParseInterstitial for ParseState;
    using LibParseLiteral for ParseState;
    using LibParsePragma for ParseState;

    function pushSubParser(ParseState memory state, uint256 subParser) internal pure {
        uint256 tail = state.subParsers;
        // Move the tail off to a new allocation.
        uint256 tailPointer;
        assembly ("memory-safe") {
            tailPointer := mload(0x40)
            mstore(0x40, add(tailPointer, 0x20))
            mstore(tailPointer, tail)
        }
        // Put the tail pointer in the high bits of the new head.
        state.subParsers = subParser | tailPointer << 0xF0;
    }

    function parsePragma(ParseState memory state, uint256 cursor, uint256 end) internal pure returns (uint256) {
        unchecked {
            // Not-pragma guard.
            {
                // There is a pragma if the cursor is pointing exactly at the bytes of
                // the pragma.
                bytes32 maybePragma;
                assembly ("memory-safe") {
                    maybePragma := mload(cursor)
                }
                // Bail without modifying the cursor if there's no pragma.
                if (maybePragma & PRAGMA_KEYWORD_MASK != PRAGMA_KEYWORD_BYTES32) {
                    return cursor;
                }
            }

            {
                // Move past the pragma keyword.
                cursor += PRAGMA_KEYWORD_BYTES_LENGTH;

                // Need at least one whitespace char after the pragma keyword.
                uint256 char;
                assembly ("memory-safe") {
                    char := shl(byte(0, mload(cursor)), 1)
                }
                if (char & CMASK_WHITESPACE == 0) {
                    revert NoWhitespaceAfterUsingWordsFrom(state.parseErrorOffset(cursor));
                }
                ++cursor;
            }

            while (cursor < end) {
                // It's fine to add comments for each pragma address.
                cursor = state.parseInterstitial(cursor, end);

                // If the cursor is NOT pointing at the start of a hex literal
                // then we're done with the pragma.
                {
                    uint256 mustBe0x;
                    assembly ("memory-safe") {
                        mustBe0x := mload(sub(cursor, 30))
                    }
                    if (uint16(mustBe0x) != CMASK_LITERAL_HEX_DISPATCH_START) {
                        break;
                    }
                }

                (
                    function(ParseState memory, uint256, uint256) pure returns (uint256) literalHexAddressParser,
                    uint256 innerStart,
                    uint256 innerEnd,
                    uint256 outerEnd
                ) = state.boundLiteralHexAddress(cursor, end);

                // Parse and push the sub parser
                state.pushSubParser(literalHexAddressParser(state, innerStart, innerEnd));
                cursor = outerEnd;
            }

            return cursor;
        }
    }
}
