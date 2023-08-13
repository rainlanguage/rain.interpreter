// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParseMeta.sol";
import "test/util/lib/bloom/LibBloom.sol";

contract LibParseMetaBuildMetaTest is Test {
    /// This is super loose from limited empirical testing.
    function expanderDepth(uint256 n) internal pure returns (uint8) {
        // Number of fully saturated expanders
        // + 1 for solidity flooring everything
        // + 1 for a non-fully saturated but still quite full expander
        // + 1 for a potentially nearly empty expander
        return uint8(n / type(uint8).max + 3);
    }

    function testBuildMeta(AuthoringMeta[] memory authoringMeta) external pure {
        vm.assume(!LibBloom.bloomFindsDupes(LibParseMeta.copyWordsFromAuthoringMeta(authoringMeta)));
        bytes memory meta = LibParseMeta.buildParseMeta(authoringMeta, expanderDepth(authoringMeta.length));
        (meta);
    }

    function testRoundMetaExpanderShallow(AuthoringMeta[] memory authoringMeta, uint8 j, bytes32 notFound) external {
        vm.assume(authoringMeta.length > 0);
        vm.assume(!LibBloom.bloomFindsDupes(LibParseMeta.copyWordsFromAuthoringMeta(authoringMeta)));
        for (uint256 i = 0; i < authoringMeta.length; i++) {
            vm.assume(authoringMeta[i].word != notFound);
        }
        j = uint8(bound(j, uint8(0), uint8(authoringMeta.length) - 1));

        uint256 operandParsers = LibParseOperand.buildOperandParsers();
        bytes memory meta = LibParseMeta.buildParseMeta(authoringMeta, expanderDepth(authoringMeta.length));
        (bool exists, uint256 k, function(uint256, bytes memory, uint256) pure returns (uint256, Operand) operandParserK) =
            LibParseMeta.lookupWord(meta, operandParsers, authoringMeta[j].word);
        // @todo test parser.
        assertTrue(false);
        assertTrue(exists);
        assertEq(j, k);

        (bool notExists, uint256 l, function(uint256, bytes memory, uint256) pure returns (uint256, Operand) operandParserL) =
            LibParseMeta.lookupWord(meta, operandParsers, notFound);
        // @todo test parser.
        assertTrue(false);
        assertTrue(!notExists);
        assertEq(0, l);
    }

    function testRoundMetaExpanderDeeper(AuthoringMeta[] memory authoringMeta, uint8 j, bytes32 notFound) external {
        vm.assume(authoringMeta.length > 50);
        vm.assume(!LibBloom.bloomFindsDupes(LibParseMeta.copyWordsFromAuthoringMeta(authoringMeta)));
        for (uint256 i = 0; i < authoringMeta.length; i++) {
            vm.assume(authoringMeta[i].word != notFound);
        }
        j = uint8(bound(j, uint8(0), uint8(authoringMeta.length) - 1));

        uint256 operandParsers = LibParseOperand.buildOperandParsers();
        bytes memory meta = LibParseMeta.buildParseMeta(authoringMeta, expanderDepth(authoringMeta.length));
        (bool exists, uint256 k, function(uint256, bytes memory, uint256) pure returns (uint256, Operand) operandParserK) =
            LibParseMeta.lookupWord(meta, operandParsers, authoringMeta[j].word);
        // @todo test parser.
        assertTrue(false);
        assertTrue(exists);
        assertEq(j, k);

        (bool notExists, uint256 l, function(uint256, bytes memory, uint256) pure returns (uint256, Operand) operandParserL) =
            LibParseMeta.lookupWord(meta, operandParsers, notFound);
        // @todo test parser.
        assertTrue(false);
        assertTrue(!notExists);
        assertEq(0, l);
    }
}
