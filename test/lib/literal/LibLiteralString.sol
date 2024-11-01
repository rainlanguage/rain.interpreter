// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {CMASK_STRING_LITERAL_TAIL, CMASK_HEX, CMASK_WHITESPACE} from "rain.string/lib/parse/LibParseCMask.sol";

library LibLiteralString {
    function conformStringToMask(string memory str, uint256 mask, uint256 max) internal pure {
        uint256 seed = 0;
        for (uint256 i = 0; i < bytes(str).length; i++) {
            uint256 char = uint256(uint8(bytes(str)[i]));
            // If the char is not in the mask, roll it.
            while (1 << char & mask == 0) {
                assembly ("memory-safe") {
                    mstore(0, char)
                    mstore(0x20, seed)
                    seed := keccak256(0, 0x40)
                    // Eliminate everything out of range to give us a better
                    // chance of hitting the mask.
                    char := mod(byte(0, seed), max)
                }
            }
            bytes(str)[i] = bytes1(uint8(char));
        }
    }

    function conformStringToMask(string memory str, uint256 mask) internal pure {
        // Assume that we want to restrict to ASCII range.
        conformStringToMask(str, mask, 0x80);
    }

    function conformStringToAscii(string memory str) internal pure {
        conformStringToMask(str, type(uint128).max, 0x80);
    }

    function conformStringToHexDigits(string memory str) internal pure {
        // 0x7B is '{' which is just after 'z'.
        conformStringToMask(str, CMASK_HEX, 0x7B);
    }

    function conformValidPrintableStringContent(string memory str) internal pure {
        conformStringToMask(str, CMASK_STRING_LITERAL_TAIL, 0x80);
    }

    function conformStringToWhitespace(string memory str) internal pure {
        // 33 is ! which is after space.
        conformStringToMask(str, CMASK_WHITESPACE, 33);
    }

    function corruptSingleChar(string memory str, uint256 index) internal pure {
        uint256 char = uint256(uint8(bytes(str)[index]));
        uint256 seed = 0;
        while (1 << char & ~CMASK_STRING_LITERAL_TAIL == 0 || char == uint8(bytes1("\""))) {
            assembly ("memory-safe") {
                mstore(0, char)
                mstore(0x20, seed)
                seed := keccak256(0, 0x40)
                char := byte(0, seed)
            }
        }
        bytes(str)[index] = bytes1(uint8(char));
    }

    function charFromMask(uint256 seed, uint256 mask) internal pure returns (bytes1) {
        uint256 char = 0;
        while (1 << char & mask == 0) {
            assembly ("memory-safe") {
                mstore(0, char)
                mstore(0x20, seed)
                seed := keccak256(0, 0x40)
                char := byte(0, seed)
            }
        }
        return bytes1(uint8(char));
    }
}
