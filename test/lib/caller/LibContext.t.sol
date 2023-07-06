// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

import "forge-std/Test.sol";
import "src/lib/caller/LibContext.sol";
import "./LibContextSlow.sol";

contract LibContextTest is Test {
    function testBase() public {
        uint256[] memory baseContext = LibContext.base();

        assertEq(baseContext.length, 2);
        assertEq(baseContext[0], uint256(uint160(msg.sender)));
        assertEq(baseContext[1], uint256(uint160(address(this))));
        assertTrue(msg.sender != address(this));
    }

    function testBuildStructureReferenceImplementation(uint256[][] memory base) public {
        // @todo support signed context testing, currently fails due to invalid
        // signatures blocking the build process.
        SignedContextV1[] memory signedContexts = new SignedContextV1[](0);

        uint256[][] memory expected = LibContextSlow.buildStructureSlow(base, signedContexts);
        uint256[][] memory actual = LibContext.build(base, signedContexts);
        assertEq(expected.length, actual.length);

        for (uint256 i = 0; i < expected.length; i++) {
            assertEq(expected[i], actual[i]);
        }
    }

    function testBuild0() public {
        // @todo test this better.
        uint256[][] memory expected = new uint256[][](1);
        expected[0] = LibContext.base();
        uint256[][] memory built = LibContext.build(new uint256[][](0), new SignedContextV1[](0));
        assertEq(expected.length, built.length);

        for (uint256 i = 0; i < expected.length; i++) {
            assertEq(expected[i], built[i]);
        }
    }

    function testBuildGas0() public view {
        LibContext.build(new uint256[][](0), new SignedContextV1[](0));
    }
}
