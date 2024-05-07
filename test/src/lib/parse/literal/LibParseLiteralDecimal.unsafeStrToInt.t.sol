// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibParseLiteralDecimal} from "src/lib/parse/literal/LibParseLiteralDecimal.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {DecimalLiteralOverflow} from "src/error/ErrParse.sol";

/// @title TestLibParseLiteralDecimalUnsafeStrToInt
/// @dev Test the LibParseLiteralDecimal.unsafeStrToInt function.
contract TestLibParseLiteralDecimalUnsafeStrToInt is Test {
    using Strings for uint256;
    using LibParseLiteralDecimal for ParseState;
    using LibBytes for bytes;

    /// Test round tripping strings through the unsafeStrToInt function.
    function testUnsafeStrToIntRoundTrip(uint256 value, uint8 leadingZerosCount) external pure {
        string memory str = value.toString();

        string memory leadingZeros = new string(leadingZerosCount);
        for (uint8 i = 0; i < leadingZerosCount; i++) {
            bytes(leadingZeros)[i] = "0";
        }

        string memory input = string(abi.encodePacked(leadingZeros, str));

        ParseState memory state = LibParseState.newState(bytes(input), "", "", "");

        uint256 result =
            state.unsafeStrToInt(Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer()));
        assert(result == value);
    }

    /// Test very large number overflow.
    function testUnsafeStrToIntOverflowVeryLarge(uint256 high, uint256 low, uint8 leadingZerosCount) external {
        vm.assume(high > 0);
        low = bound(low, 1 << 0xFF, type(uint256).max);
        string memory strHigh = high.toString();
        string memory strLow = low.toString();

        string memory leadingZeros = new string(leadingZerosCount);
        for (uint8 i = 0; i < leadingZerosCount; i++) {
            bytes(leadingZeros)[i] = "0";
        }

        string memory input = string(abi.encodePacked(strHigh, strLow));

        ParseState memory state = LibParseState.newState(bytes(input), "", "", "");

        vm.expectRevert(bytes(abi.encodeWithSelector(DecimalLiteralOverflow.selector, 0)));
        state.unsafeStrToInt(Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer()));
    }
}
