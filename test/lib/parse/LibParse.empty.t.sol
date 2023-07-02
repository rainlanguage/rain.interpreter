// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseEmptyTest
/// Tests parsing empty sources and constants. All we want to check is that the
/// parser doesn't revert and the correct number of sources and constants are
/// returned.
contract LibParseEmptyTest is Test {
    /// Check truly empty input bytes. Should not revert and return length 0
    /// sources and constants.
    function testParseEmpty00() external {
        (bytes[] memory sources0, uint256[] memory constants0) = LibParse.parse("", "");
        assertEq(sources0.length, 0);
        assertEq(constants0.length, 0);
    }

    /// Check a single empty expression. Should not revert and return length 1
    /// sources and constants.
    function testParseEmpty01() external {
        (bytes[] memory sources1, uint256[] memory constants1) = LibParse.parse(":;", "");
        assertEq(sources1.length, 1);
        assertEq(sources1[0].length, 0);
        assertEq(constants1.length, 0);
    }

    /// Check two empty expressions. Should not revert and return length 2
    /// sources and constants.
    function testParseEmpty02() external {
        (bytes[] memory sources2, uint256[] memory constants2) = LibParse.parse(":;:;", "");
        assertEq(sources2.length, 2);
        assertEq(sources2[0].length, 0);
        assertEq(sources2[1].length, 0);
        assertEq(constants2.length, 0);
    }

    /// Check three empty expressions. Should not revert and return length 3
    /// sources and constants.
    function testParseEmpty03() external {
        (bytes[] memory sources3, uint256[] memory constants3) = LibParse.parse(":;:;:;", "");
        assertEq(sources3.length, 3);
        assertEq(sources3[0].length, 0);
        assertEq(sources3[1].length, 0);
        assertEq(sources3[2].length, 0);
        assertEq(constants3.length, 0);
    }

    /// Check four empty expressions. Should not revert and return length 4
    /// sources and constants.
    function testParseEmpty04() external {
        (bytes[] memory sources4, uint256[] memory constants4) = LibParse.parse(":;:;:;:;", "");
        assertEq(sources4.length, 4);
        assertEq(sources4[0].length, 0);
        assertEq(sources4[1].length, 0);
        assertEq(sources4[2].length, 0);
        assertEq(sources4[3].length, 0);
        assertEq(constants4.length, 0);
    }

    /// Five sources is a MaxSources error.
    function testParseEmptyError05() external {
        vm.expectRevert(abi.encodeWithSelector(MaxSources.selector));
        (bytes[] memory sources5, uint256[] memory constants5) = LibParse.parse(":;:;:;:;:;", "");
        (sources5);
        (constants5);
    }
}
