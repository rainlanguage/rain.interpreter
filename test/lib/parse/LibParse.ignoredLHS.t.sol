// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

contract LibParseIgnoredLHSTest is Test {
    function testParseIgnoredLHSSimple() external {
        string[3] memory examples0 = ["_a:;", "_a _b:;", "_foo _bar:;"];
        for (uint256 i = 0; i < examples0.length; i++) {
            (bytes[] memory sources0, uint256[] memory constants0) = LibParse.parse(bytes(examples0[i]));
            assertEq(sources0.length, 1);
            assertEq(sources0[0].length, 0);
            assertEq(constants0.length, 0);
        }

        (bytes[] memory sources1, uint256[] memory constants1) = LibParse.parse("_a:;_b:;");
        assertEq(sources1.length, 2);
        assertEq(sources1[0].length, 0);
        assertEq(sources1[1].length, 0);
        assertEq(constants1.length, 0);
    }

    function testParseIgnoredGas00() external pure {
        LibParse.parse("_:;");
    }

    function testParseIgnoredGas01() external pure {
        LibParse.parse("_a:;");
    }

    function testParseIgnoredGas02() external pure {
        LibParse.parse("_aa:;");
    }

    function testParseIgnoredGas03() external pure {
        LibParse.parse("_aaa:;");
    }

    function testParseIgnoredGas04() external pure {
        LibParse.parse("_aaaa:;");
    }

    function testParseIgnoredGas05() external pure {
        LibParse.parse("_aaaaa:;");
    }

    function testParseIgnoredGas06() external pure {
        LibParse.parse("_aaaaaa:;");
    }

    function testParseIgnoredGas07() external pure {
        LibParse.parse("_aaaaaaa:;");
    }

    function testParseIgnoredGas08() external pure {
        LibParse.parse("_aaaaaaaa:;");
    }

    function testParseIgnoredGas09() external pure {
        LibParse.parse("_aaaaaaaaa:;");
    }

    function testParseIgnoredGas10() external pure {
        LibParse.parse("_aaaaaaaaaa:;");
    }

    function testParseIgnoredGas11() external pure {
        LibParse.parse("_aaaaaaaaaaa:;");
    }

    function testParseIgnoredGas12() external pure {
        LibParse.parse("_aaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas13() external pure {
        LibParse.parse("_aaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas14() external pure {
        LibParse.parse("_aaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas15() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas16() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas17() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas18() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas19() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas20() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas21() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas22() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas23() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas24() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas25() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas26() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas27() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas28() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas29() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas30() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas31() external pure {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas32() external {
        vm.expectRevert(abi.encodeWithSelector(WordTooLong.selector, 0));
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }
}
