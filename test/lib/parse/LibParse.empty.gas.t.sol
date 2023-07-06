// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseEmptyGasTest
/// Exercise a few different sized empty expressions to get a gas snapshot of the
/// parsing cost.
contract LibParseEmptyGasTest is Test {
    /// Test parsing "" (0 chars) an empty expression.
    function testParseGasEmpty00() external pure {
        LibParse.parse("", "");
    }

    /// Test parsing ":;" (2 chars) an empty expression.
    function testParseGasEmpty01() external pure {
        LibParse.parse(":;", "");
    }

    /// Test parsing ":;:;" (4 chars) an empty expression.
    function testParseGasEmpty02() external pure {
        LibParse.parse(":;:;", "");
    }

    /// Test parsing ":;:;:;" (6 chars) an empty expression.
    function testParseGasEmpty03() external pure {
        LibParse.parse(":;:;:;", "");
    }

    /// Test parsing ":;:;:;:;" (8 chars) an empty expression.
    function testParseGasEmpty04() external pure {
        LibParse.parse(":;:;:;:;", "");
    }
}
