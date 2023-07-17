// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "../../../lib/forge-std/src/Test.sol";

import "../../../src/lib/parse/LibParse.sol";

/// @title LibParseInputsOnlyGasTest
/// Exercise a few different sized inputs-only expressions to get a gas
/// snapshot of the parsing cost.
contract LibParseInputsOnlyGasTest is Test {
    /// Test parsing "_:;" (3 chars) an inputs-only expression.
    function testParseGasInputsOnly00() external pure {
        LibParse.parse("_:;", "");
    }

    /// Test parsing "_ _:;" (5 chars) an inputs-only expression.
    function testParseGasInputsOnly01() external pure {
        LibParse.parse("_ _:;", "");
    }

    /// Test parsing "_ _ _:;" (7 chars) an inputs-only expression.
    function testParseGasInputsOnly02() external pure {
        LibParse.parse("_ _ _:;", "");
    }

    /// Test parsing "_ _ _ _:;" (9 chars) an inputs-only expression.
    function testParseGasInputsOnly03() external pure {
        LibParse.parse("_ _ _ _:;", "");
    }

    /// Test parsing "_ _ _ _ _:;" (11 chars) an inputs-only expression.
    function testParseGasInputsOnly04() external pure {
        LibParse.parse("_ _ _ _ _:;", "");
    }

    /// Test parsing "_ _ _ _ _ _:;" (13 chars) an inputs-only expression.
    function testParseGasInputsOnly05() external pure {
        LibParse.parse("_ _ _ _ _ _:;", "");
    }

    /// Test parsing "_ _ _ _ _ _ _:;" (15 chars) an inputs-only expression.
    function testParseGasInputsOnly06() external pure {
        LibParse.parse("_ _ _ _ _ _ _:;", "");
    }

    /// Test parsing "_ _ _ _ _ _ _ _:;" (17 chars) an inputs-only expression.
    function testParseGasInputsOnly07() external pure {
        LibParse.parse("_ _ _ _ _ _ _ _:;", "");
    }

    /// Test parsing "_ _ _ _ _ _ _ _ _:;" (19 chars) an inputs-only expression.
    function testParseGasInputsOnly08() external pure {
        LibParse.parse("_ _ _ _ _ _ _ _ _:;", "");
    }

    /// Test parsing "_ _ _ _ _ _ _ _ _ _:;" (21 chars) an inputs-only expression.
    function testParseGasInputsOnly09() external pure {
        LibParse.parse("_ _ _ _ _ _ _ _ _ _:;", "");
    }
}
