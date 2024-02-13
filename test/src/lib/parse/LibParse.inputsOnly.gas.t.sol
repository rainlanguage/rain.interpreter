// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {LibParse} from "src/lib/parse/LibParse.sol";
import {LibMetaFixture} from "test/lib/parse/LibMetaFixture.sol";
import {ParseState} from "src/lib/parse/LibParseState.sol";

/// @title LibParseInputsOnlyGasTest
/// Exercise a few different sized inputs-only expressions to get a gas
/// snapshot of the parsing cost.
contract LibParseInputsOnlyGasTest is Test {
    using LibParse for ParseState;

    /// Test parsing "_:;" (3 chars) an inputs-only expression.
    function testParseGasInputsOnly00() external pure {
        LibMetaFixture.newState("_:;").parse();
    }

    /// Test parsing "_ _:;" (5 chars) an inputs-only expression.
    function testParseGasInputsOnly01() external pure {
        LibMetaFixture.newState("_ _:;").parse();
    }

    /// Test parsing "_ _ _:;" (7 chars) an inputs-only expression.
    function testParseGasInputsOnly02() external pure {
        LibMetaFixture.newState("_ _ _:;").parse();
    }

    /// Test parsing "_ _ _ _:;" (9 chars) an inputs-only expression.
    function testParseGasInputsOnly03() external pure {
        LibMetaFixture.newState("_ _ _ _:;").parse();
    }

    /// Test parsing "_ _ _ _ _:;" (11 chars) an inputs-only expression.
    function testParseGasInputsOnly04() external pure {
        LibMetaFixture.newState("_ _ _ _ _:;").parse();
    }

    /// Test parsing "_ _ _ _ _ _:;" (13 chars) an inputs-only expression.
    function testParseGasInputsOnly05() external pure {
        LibMetaFixture.newState("_ _ _ _ _ _:;").parse();
    }

    /// Test parsing "_ _ _ _ _ _ _:;" (15 chars) an inputs-only expression.
    function testParseGasInputsOnly06() external pure {
        LibMetaFixture.newState("_ _ _ _ _ _ _:;").parse();
    }

    /// Test parsing "_ _ _ _ _ _ _ _:;" (17 chars) an inputs-only expression.
    function testParseGasInputsOnly07() external pure {
        LibMetaFixture.newState("_ _ _ _ _ _ _ _:;").parse();
    }

    /// Test parsing "_ _ _ _ _ _ _ _ _:;" (19 chars) an inputs-only expression.
    function testParseGasInputsOnly08() external pure {
        LibMetaFixture.newState("_ _ _ _ _ _ _ _ _:;").parse();
    }

    /// Test parsing "_ _ _ _ _ _ _ _ _ _:;" (21 chars) an inputs-only expression.
    function testParseGasInputsOnly09() external pure {
        LibMetaFixture.newState("_ _ _ _ _ _ _ _ _ _:;").parse();
    }
}
