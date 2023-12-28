// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";

/// @title LibParseStatePushConstantValueTest
contract LibParseStatePushConstantValueTest is Test {
    using LibParseState for ParseState;

    struct FingerprintValue {
        uint256 fingerprint;
        uint256 value;
    }

    /// A new state should have an empty constants LL.
    function testPushConstantValueEmpty(
        bytes memory data,
        bytes memory meta,
        bytes memory operandHandlers,
        bytes memory literalParsers
    ) external {
        // Start with a fresh state.
        ParseState memory state = LibParseState.newState(data, meta, operandHandlers, literalParsers);

        assertEq(state.constantsBuilder, 0);
        assertEq(state.literalBloom, 0);
    }

    /// Pushing any value onto an empty constants LL should result in that value
    /// in the state with a pointer to 0.
    function testPushConstantValueSingle(FingerprintValue memory fingerprintValue) external {
        // Start with a fresh state.
        ParseState memory state = LibParseState.newState("", "", "", "");

        assertEq(state.constantsBuilder, 0);
        assertEq(state.literalBloom, 0);

        state.pushConstantValue(fingerprintValue.fingerprint, fingerprintValue.value);

        // The constants builder low bits should now be 1 as the length of the
        // LL.
        assertEq(state.constantsBuilder & 0xFFFF, 1);

        // The constants builder should now point to the fingerprint and value.
        uint256 pointer = state.constantsBuilder >> 0x10;
        uint256 loadedFingerprint;
        uint256 loadedValue;
        uint256 loadedNext;
        assembly ("memory-safe") {
            loadedFingerprint := and(mload(pointer), not(0xFFFF))
            loadedValue := mload(add(pointer, 0x20))
            loadedNext := and(mload(pointer), 0xFFFF)
        }

        // Only the high bits of the fingerprint are stored in the LL, as the low
        // bits are reserved for the pointer to the next LL item.
        assertEq(loadedFingerprint, fingerprintValue.fingerprint & ~uint256(0xFFFF));
        assertEq(loadedValue, fingerprintValue.value);
        assertEq(loadedNext, 0);
        // We bloom off the high byte of the fingerprint.
        assertEq(state.literalBloom, 1 << (fingerprintValue.fingerprint >> 0xF8));
    }

    /// Can push many values to the constants LL.
    function testPushConstantValueMany(FingerprintValue[] memory fingerprintValues) external {
        vm.assume(fingerprintValues.length > 0);
        // Start with a fresh state.
        ParseState memory state = LibParseState.newState("", "", "", "");

        assertEq(state.constantsBuilder, 0);
        assertEq(state.literalBloom, 0);

        for (uint256 i = 0; i < fingerprintValues.length; i++) {
            state.pushConstantValue(fingerprintValues[i].fingerprint, fingerprintValues[i].value);
        }

        // The constants builder low bits should now be the length of the list
        // of fingerprint values. The deduping of the fingerprints is NOT done
        // by the constant value push, the caller is expected to do that.
        assertEq(state.constantsBuilder & 0xFFFF, fingerprintValues.length);

        // Looping down the pointers should give us the values in reverse order.
        FingerprintValue[] memory loadedFinalValues = new FingerprintValue[](fingerprintValues.length);
        uint256 pointer = state.constantsBuilder >> 0x10;
        uint256 j = loadedFinalValues.length - 1;
        while (pointer != 0) {
            uint256 loadedFingerprint;
            uint256 loadedValue;
            assembly ("memory-safe") {
                loadedFingerprint := and(mload(pointer), not(0xFFFF))
                loadedValue := mload(add(pointer, 0x20))
                pointer := and(mload(pointer), 0xFFFF)
            }

            // Only the high bits of the fingerprint are stored in the LL, as the low
            // bits are reserved for the pointer to the next LL item.
            loadedFinalValues[j] = FingerprintValue(loadedFingerprint, loadedValue);

            // This will underflow on the final iteration, which is fine because
            // we don't use it after that.
            unchecked {
                --j;
            }
        }

        for (uint256 k = 0; k < fingerprintValues.length; k++) {
            assertEq(loadedFinalValues[k].fingerprint, fingerprintValues[k].fingerprint & ~uint256(0xFFFF));
            assertEq(loadedFinalValues[k].value, fingerprintValues[k].value);
            assertTrue(state.literalBloom & (1 << (fingerprintValues[k].fingerprint >> 0xF8)) != 0);
        }
    }
}
