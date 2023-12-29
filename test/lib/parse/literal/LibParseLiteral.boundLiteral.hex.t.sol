// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {ParseLiteralTest} from "test/util/abstract/ParseLiteralTest.sol";
import {ParseState} from "src/lib/parse/LibParseState.sol";
import {LibParseLiteral} from "src/lib/parse/literal/LibParseLiteral.sol";
import {LibLiteralString} from "test/util/lib/literal/LibLiteralString.sol";
import {CMASK_HEX} from "src/lib/parse/LibParseCMask.sol";

/// @title LibParseLiteralBoundLiteralHexTest
/// Tests parsing bound literal hex values.
contract LibParseLiteralBoundLiteralHexTest is ParseLiteralTest {
// function checkHexBounds(
//     bytes memory data,
//     uint256 expectedInnerStart,
//     uint256 expectedInnerEnd,
//     uint256 expectedOuterEnd
// ) internal {
//     uint256 hexParser;
//     function (ParseState memory, uint256, uint256) pure returns (uint256) parseLiteralHex =
//         LibParseLiteral.parseLiteralHex;
//     assembly ("memory-safe") {
//         hexParser := parseLiteralHex
//     }
//     checkLiteralBounds(data, expectedInnerStart, expectedInnerEnd, expectedOuterEnd, hexParser);
// }

// /// Check some bounds for some strings.
// function testParseLiteralBoundLiteralHexBounds() external {
//     checkHexBounds("0x", 2, 2, 2);
//     checkHexBounds("0x00", 2, 4, 4);
//     checkHexBounds("0x0000", 2, 6, 6);
// }

// /// Fuzz the parser with hex data.
// function testParseLiteralBoundLiteralHexFuzz(string memory str, bytes1 delimByte, string memory anyOtherString)
//     external
// {
//     LibLiteralString.conformStringToHexDigits(str);
//     string memory delimString = string(abi.encodePacked(delimByte));
//     LibLiteralString.conformStringToMask(delimString, ~CMASK_HEX, 0x100);
//     checkHexBounds(
//         bytes(string.concat("0x", str, delimString, anyOtherString)),
//         2,
//         bytes(str).length + 2,
//         bytes(str).length + 2
//     );
// }
}
