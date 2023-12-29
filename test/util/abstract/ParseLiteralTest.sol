// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibParseLiteral, UnsupportedLiteralType} from "src/lib/parse/literal/LibParseLiteral.sol";
import {LibAllStandardOpsNP} from "src/lib/op/LibAllStandardOpsNP.sol";

contract ParseLiteralTest is Test {
    using LibBytes for bytes;
    using LibParseLiteral for ParseState;

    function checkUnsupportedLiteralType(bytes memory data, uint256 offset) internal {
        ParseState memory state =
            LibParseState.newState(data, "", "", LibAllStandardOpsNP.literalParserFunctionPointers());
        state.literalParsers = LibAllStandardOpsNP.literalParserFunctionPointers();
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        uint256 cursor = outerStart;
        uint256 end = outerStart + data.length;
        vm.expectRevert(abi.encodeWithSelector(UnsupportedLiteralType.selector, offset));
        uint256 value;
        (cursor, value) = state.parseLiteral(cursor, end);
        (cursor, value);
    }

    // function checkLiteralBounds(
    //     function (ParseState memory state, uint256 cursor, uint256 end) pure returns (uint256, uint256, uint256) bounder,
    //     bytes memory data,
    //     uint256 expectedInnerEnd,
    //     uint256 expectedOuterEnd,
    //     uint256 expectedFinalCursor
    // ) internal {
    //     ParseState memory state =
    //         LibParseState.newState(data, "", "", LibAllStandardOpsNP.literalParserFunctionPointers());
    //     state.literalParsers = LibAllStandardOpsNP.literalParserFunctionPointers();
    //     uint256 outerStart = Pointer.unwrap(data.dataPointer());
    //     uint256 cursor = outerStart;
    //     uint256 end = outerStart + data.length;
    //     uint256 value;
    //     (
    //         cursor, value
    //     ) = state.parseLiteral(cursor, end);
    //     uint256 actualParser;
    //     assembly ("memory-safe") {
    //         actualParser := parser
    //     }
    //     assertEq(actualParser, expectedParser, "parser");
    //     assertEq(innerStart, outerStart + expectedInnerStart, "innerStart");
    //     assertEq(innerEnd, outerStart + expectedInnerEnd, "innerEnd");
    //     assertEq(outerEnd, outerStart + expectedOuterEnd, "outerEnd");
    // }
}
