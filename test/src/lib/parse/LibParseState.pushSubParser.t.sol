// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {InvalidSubParser} from "src/error/ErrParse.sol";

/// @title LibParseStatePushSubParserTest
contract LibParseStatePushSubParserTest is Test {
    using LibParseState for ParseState;
    using LibBytes for bytes;

    /// Pushing any value onto the sub parser that exceeds the maximum value
    /// should revert.
    function testPushSubParserOverflow(ParseState memory state, uint256 value) external {
        value = bound(value, uint256(type(uint160).max) + 1, type(uint256).max);

        state.subParsers = 0;
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(InvalidSubParser.selector, 0));
        state.pushSubParser(cursor, bytes32(value));
    }

    /// Pushing any value onto an empty sub parser LL should result in that value
    /// in the state with a pointer to 0.
    function testPushSubParserZero(ParseState memory state, address value) external pure {
        state.subParsers = 0;
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        state.pushSubParser(cursor, bytes32(uint256(uint160(value))));

        assertEq(uint160(uint256(state.subParsers)), uint160(value));
        uint256 pointer = uint256(state.subParsers) >> 0xF0;
        bytes32 deref;
        assembly ("memory-safe") {
            deref := mload(pointer)
        }
        assertEq(deref, 0);
    }

    /// Can push multiple values onto the sub parser LL.
    function testPushSubParserMultiple(ParseState memory state, address value0, address value1, address value2)
        external
        pure
    {
        {
            uint256 cursor = Pointer.unwrap(state.data.dataPointer());
            state.subParsers = 0;
            state.pushSubParser(cursor, bytes32(uint256(uint160(value0))));
            state.pushSubParser(cursor, bytes32(uint256(uint160(value1))));
            state.pushSubParser(cursor, bytes32(uint256(uint160(value2))));
        }

        assertEq(uint160(uint256(state.subParsers)), uint256(uint160(value2)));
        uint256 pointer = uint256(state.subParsers) >> 0xF0;
        bytes32 deref;
        assembly ("memory-safe") {
            deref := mload(pointer)
        }
        assertEq(uint160(uint256(deref)), uint256(uint160(value1)));

        pointer = uint256(deref) >> 0xF0;
        assembly ("memory-safe") {
            deref := mload(pointer)
        }
        assertEq(uint160(uint256(deref)), uint256(uint160(value0)));

        pointer = uint256(deref) >> 0xF0;
        assembly ("memory-safe") {
            deref := mload(pointer)
        }
        assertEq(deref, 0);
    }

    /// Pushing a whole list of values onto the sub parser LL.
    function testPushSubParserList(ParseState memory state, address[] memory values) external pure {
        vm.assume(values.length > 0);
        state.subParsers = 0;
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        for (uint256 i = 0; i < values.length; i++) {
            state.pushSubParser(cursor, bytes32(uint256(uint160(values[i]))));
        }

        uint256 j = values.length - 1;
        bytes32 deref = state.subParsers;
        uint256 pointer = uint256(deref) >> 0xF0;
        while (deref != 0) {
            assertEq(uint160(uint256(deref)), uint160(values[j]));

            assembly ("memory-safe") {
                deref := mload(pointer)
            }
            pointer = uint256(deref) >> 0xF0;
            // This underflows exactly when deref is zero and the loop
            // terminates.
            unchecked {
                --j;
            }
        }
    }
}
