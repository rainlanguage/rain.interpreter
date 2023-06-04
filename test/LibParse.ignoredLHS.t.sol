// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/LibParse.sol";

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

    function testParseIgnoredGas0() external {
        LibParse.parse("_:;");
    }

    function testParseIgnoredGas1() external {
        LibParse.parse("_a:;");
    }

    function testParseIgnoredGas2() external {
        LibParse.parse("_aa:;");
    }

    function testParseIgnoredGas3() external {
        LibParse.parse("_aaa:;");
    }

    function testParseIgnoredGas4() external {
        LibParse.parse("_aaaa:;");
    }

    function testParseIgnoredGas5() external {
        LibParse.parse("_aaaaa:;");
    }

    function testParseIgnoredGas6() external {
        LibParse.parse("_aaaaaa:;");
    }

    function testParseIgnoredGas7() external {
        LibParse.parse("_aaaaaaa:;");
    }

    function testParseIgnoredGas8() external {
        LibParse.parse("_aaaaaaaa:;");
    }

    function testParseIgnoredGas9() external {
        LibParse.parse("_aaaaaaaaa:;");
    }

    function testParseIgnoredGas10() external {
        LibParse.parse("_aaaaaaaaaa:;");
    }

    function testParseIgnoredGas11() external {
        LibParse.parse("_aaaaaaaaaaa:;");
    }

    function testParseIgnoredGas12() external {
        LibParse.parse("_aaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas13() external {
        LibParse.parse("_aaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas14() external {
        LibParse.parse("_aaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas15() external {
        LibParse.parse("_aaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas16() external {
        LibParse.parse("_aaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas17() external {
        LibParse.parse("_aaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas18() external {
        LibParse.parse("_aaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas19() external {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas20() external {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas21() external {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas22() external {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas23() external {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas24() external {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas25() external {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas26() external {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas27() external {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas28() external {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas29() external {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas30() external {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas31() external {
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }

    function testParseIgnoredGas32() external {
        vm.expectRevert(abi.encodeWithSelector(WordTooLong.selector, 0));
        LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    }
}
