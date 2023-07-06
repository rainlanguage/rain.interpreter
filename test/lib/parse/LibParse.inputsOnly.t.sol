// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseInputsOnlyTest
/// @notice Tests that inputs (leading LHS items without RHS items) to an
/// expression are parsed correctly. This test only considers the case where
/// the expression is empty, and the inputs are the entire expression.
/// I.e. the expression is basically an identity function.
contract LibParseInputsOnlyTest is Test {
    /// Some inputs-only examples. Should produce an empty source.
    function testParseInputsOnly() external {
        string[2] memory examples = ["_:;", "_ _:;"];
        for (uint256 i = 0; i < examples.length; i++) {
            (bytes[] memory sources1, uint256[] memory constants1) = LibParse.parse(bytes(examples[i]), "");
            assertEq(sources1.length, 1);
            assertEq(sources1[0].length, 0);
            assertEq(constants1.length, 0);
        }
    }
}
