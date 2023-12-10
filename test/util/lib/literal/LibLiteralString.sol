// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {CMASK_STRING_LITERAL_TAIL} from "src/lib/parse/LibParseCMask.sol";

library LibLiteralString {
    function conformValidPrintableStringContent(string memory str) internal pure {
        uint256 seed = 0;
        for (uint256 i = 0; i < bytes(str).length; i++) {
            uint256 char = uint256(uint8(bytes(str)[i]));
            // If the char is not a string literal tail, roll it.
            while (1 << char & CMASK_STRING_LITERAL_TAIL == 0) {
                assembly ("memory-safe") {
                    mstore(0, char)
                    mstore(0x20, seed)
                    seed := keccak256(0, 0x40)
                    // Eliminate everything out of ASCII range to give us a
                    // better chance of hitting a string literal tail.
                    char := mod(byte(0, seed), 0x80)
                }
            }
            bytes(str)[i] = bytes1(uint8(char));
        }
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
}
