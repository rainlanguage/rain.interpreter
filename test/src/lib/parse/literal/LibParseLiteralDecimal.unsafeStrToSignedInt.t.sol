// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {LibParseLiteralDecimal} from "src/lib/parse/literal/LibParseLiteralDecimal.sol";

/// @title TestLibParseLiteralDecimalUnsafeStrToSignedInt
contract TestLibParseLiteralDecimalUnsafeStrToSignedInt is Test {
    using Strings for uint256;
    using LibBytes for bytes;
    using LibParseLiteralDecimal for ParseState;

    function unsafeStrToSignedIntExternal(bytes memory data) external pure returns (int256) {
        ParseState memory state = LibParseState.newState(data, "", "", "");
        return state.unsafeStrToSignedInt(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
    }

    /// Test round tripping strings through the unsafeStrToSignedInt function.
    function testUnsafeStrToSignedIntRoundTrip(uint256 value, uint8 leadingZerosCount, bool isNeg) external pure {
        value = bound(value, 0, uint256(type(int256).max) + (isNeg ? 1 : 0));
        string memory str = value.toString();

        string memory leadingZeros = new string(leadingZerosCount);
        for (uint8 i = 0; i < leadingZerosCount; i++) {
            bytes(leadingZeros)[i] = "0";
        }

        string memory input = string(abi.encodePacked((isNeg ? "-" : ""), leadingZeros, str));

        ParseState memory state = LibParseState.newState(bytes(input), "", "", "");

        int256 result = state.unsafeStrToSignedInt(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        if (isNeg) {
            if (result == type(int256).min) {
                assertEq(value, uint256(type(int256).max) + 1);
            } else {
                assertEq(result, -int256(value));
            }
        } else {
            assertEq(result, int256(value));
        }
    }

    /// Test positive overflow.
    function testUnsafeStrToSignedIntOverflowPositive(uint256 value, uint8 leadingZerosCount) external {
        value = bound(value, uint256(type(int256).max) + 1, type(uint256).max);
        string memory str = value.toString();

        string memory leadingZeros = new string(leadingZerosCount);
        for (uint8 i = 0; i < leadingZerosCount; i++) {
            bytes(leadingZeros)[i] = "0";
        }

        string memory input = string(abi.encodePacked(leadingZeros, str));

        vm.expectRevert();
        this.unsafeStrToSignedIntExternal(bytes(input));
    }

    /// Test negative overflow.
    function testUnsafeStrToSignedIntOverflowNegative(uint256 value, uint8 leadingZerosCount) external {
        value = bound(value, uint256(type(int256).max) + 2, type(uint256).max);
        string memory str = value.toString();

        string memory leadingZeros = new string(leadingZerosCount);
        for (uint8 i = 0; i < leadingZerosCount; i++) {
            bytes(leadingZeros)[i] = "0";
        }

        string memory input = string(abi.encodePacked("-", leadingZeros, str));

        vm.expectRevert();
        this.unsafeStrToSignedIntExternal(bytes(input));
    }
}
