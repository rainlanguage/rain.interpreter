// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity ^0.8.18;

import {ParseState} from "./LibParseState.sol";

library LibParseStackName {
    /// Push a word onto the stack name stack.
    /// @return exists Whether the word already existed.
    /// @return index The new index after the word was pushed. Will be unchanged
    /// if the word already existed.
    function pushStackName(ParseState memory state, bytes32 word) internal pure returns (bool exists, uint256 index) {
        unchecked {
            (exists, index) = stackNameIndex(state, word);
            if (!exists) {
                uint256 fingerprint;
                uint256 ptr;
                uint256 oldStackNames = state.stackNames;
                assembly ("memory-safe") {
                    ptr := mload(0x40)
                    mstore(ptr, word)
                    fingerprint := and(keccak256(ptr, 0x20), not(0xFFFFFFFF))
                    mstore(ptr, oldStackNames)
                    mstore(0x40, add(ptr, 0x20))
                }
                // Add the start of line height to the LHS line parse count.
                uint256 stackLHSIndex = state.topLevel1 & 0xFF;
                state.stackNames = fingerprint | (stackLHSIndex << 0x10) | ptr;
                index = stackLHSIndex + 1;
            }
        }
    }

    /// Retrieve the index of a previously pushed stack name.
    function stackNameIndex(ParseState memory state, bytes32 word) internal pure returns (bool exists, uint256 index) {
        uint256 fingerprint;
        uint256 stackNames = state.stackNames;
        uint256 stackNameBloom = state.stackNameBloom;
        uint256 bloom;
        assembly ("memory-safe") {
            mstore(0, word)
            fingerprint := shr(0x20, keccak256(0, 0x20))
            //slither-disable-next-line incorrect-shift
            bloom := shl(and(fingerprint, 0xFF), 1)

            // If the bloom matches then maybe the stack name is in the stack.
            if and(bloom, stackNameBloom) {
                for { let ptr := and(stackNames, 0xFFFF) } iszero(iszero(ptr)) {
                    stackNames := mload(ptr)
                    ptr := and(stackNames, 0xFFFF)
                } {
                    if eq(fingerprint, shr(0x20, stackNames)) {
                        exists := true
                        index := and(shr(0x10, stackNames), 0xFFFF)
                        break
                    }
                }
            }
        }
        state.stackNameBloom = bloom | stackNameBloom;
    }
}
