// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {LibParse} from "src/lib/parse/LibParse.sol";
import {LibMetaFixture} from "test/lib/parse/LibMetaFixture.sol";
import {ParseState} from "src/lib/parse/LibParseState.sol";

/// @title LibParseEmptyGasTest
/// Exercise a few different sized empty expressions to get a gas snapshot of the
/// parsing cost.
contract LibParseEmptyGasTest is Test {
    using LibParse for ParseState;

    /// Test parsing "" (0 chars) an empty expression.
    function testParseGasEmpty00() external pure {
        LibMetaFixture.newState("").parse();
    }

    /// Test parsing ":;" (2 chars) an empty expression.
    function testParseGasEmpty01() external pure {
        LibMetaFixture.newState(":;").parse();
    }

    /// Test parsing ":;:;" (4 chars) an empty expression.
    function testParseGasEmpty02() external pure {
        LibMetaFixture.newState(":;:;").parse();
    }

    /// Test parsing ":;:;:;" (6 chars) an empty expression.
    function testParseGasEmpty03() external pure {
        LibMetaFixture.newState(":;:;:;").parse();
    }

    /// Test parsing ":;:;:;:;" (8 chars) an empty expression.
    function testParseGasEmpty04() external pure {
        LibMetaFixture.newState(":;:;:;:;").parse();
    }
}
