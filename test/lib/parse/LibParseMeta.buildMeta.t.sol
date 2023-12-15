// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {LibParseMeta, AuthoringMeta} from "src/lib/parse/LibParseMeta.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibBloom} from "test/util/lib/bloom/LibBloom.sol";
import {LibParseOperand, Operand} from "src/lib/parse/LibParseOperand.sol";

contract LibParseMetaBuildMetaTest is Test {
    using LibParseState for ParseState;
    using LibParseMeta for ParseState;

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

    function testRoundMetaExpanderShallow(
        ParseState memory state,
        AuthoringMeta[] memory authoringMeta,
        uint8 j,
        bytes32 notFound
    ) external {
        vm.assume(authoringMeta.length > 0);
        vm.assume(!LibBloom.bloomFindsDupes(LibParseMeta.copyWordsFromAuthoringMeta(authoringMeta)));
        for (uint256 i = 0; i < authoringMeta.length; i++) {
            vm.assume(authoringMeta[i].word != notFound);
        }
        j = uint8(bound(j, uint8(0), uint8(authoringMeta.length) - 1));

        // Defined for assembly blocks.
        uint256 operandParsers = state.operandParsers;
        state.meta = LibParseMeta.buildParseMeta(authoringMeta, expanderDepth(authoringMeta.length));
        (bool exists, uint256 k, function(ParseState memory, uint256) pure returns (uint256, Operand) operandParserK) =
            state.lookupWord(authoringMeta[j].word);
        uint256 operandParserKActual;
        assembly ("memory-safe") {
            operandParserKActual := operandParserK
        }
        uint256 operandParserKExpected;
        uint256 operandParserKOffset = authoringMeta[j].operandParserOffset;
        assembly ("memory-safe") {
            operandParserKExpected := and(shr(operandParserKOffset, operandParsers), 0xFFFF)
        }
        assertEq(operandParserKExpected, operandParserKActual, "operandParserK");
        assertTrue(exists, "exists");
        assertEq(j, k, "k");

        (bool notExists, uint256 l, function(ParseState memory, uint256) pure returns (uint256, Operand) operandParserL)
        = state.lookupWord(notFound);
        uint256 operandParserLActual;
        assembly ("memory-safe") {
            operandParserLActual := operandParserL
        }
        assertEq(0, operandParserLActual, "operandParserL");
        assertTrue(!notExists, "notExists");
        assertEq(0, l, "l");
    }

    function testRoundMetaExpanderDeeper(
        ParseState memory state,
        AuthoringMeta[] memory authoringMeta,
        uint8 j,
        bytes32 notFound
    ) external {
        vm.assume(authoringMeta.length > 50);
        vm.assume(!LibBloom.bloomFindsDupes(LibParseMeta.copyWordsFromAuthoringMeta(authoringMeta)));
        for (uint256 i = 0; i < authoringMeta.length; i++) {
            vm.assume(authoringMeta[i].word != notFound);
        }
        j = uint8(bound(j, uint8(0), uint8(authoringMeta.length) - 1));

        state.operandParsers = LibParseOperand.buildOperandParsers();
        // Defined for assembly blocks.
        uint256 operandParsers = state.operandParsers;
        state.meta = LibParseMeta.buildParseMeta(authoringMeta, expanderDepth(authoringMeta.length));

        (bool exists, uint256 k, function(ParseState memory, uint256) pure returns (uint256, Operand) operandParserK) =
            state.lookupWord(authoringMeta[j].word);
        uint256 operandParserKActual;
        assembly ("memory-safe") {
            operandParserKActual := operandParserK
        }
        uint256 operandParserKExpected;
        uint256 operandParserKOffset = authoringMeta[j].operandParserOffset;
        assembly ("memory-safe") {
            operandParserKExpected := and(shr(operandParserKOffset, operandParsers), 0xFFFF)
        }
        assertEq(operandParserKExpected, operandParserKActual, "operandParserK");
        assertTrue(exists, "exists");
        assertEq(j, k, "k");

        (bool notExists, uint256 l, function(ParseState memory, uint256) pure returns (uint256, Operand) operandParserL)
        = state.lookupWord(notFound);
        uint256 operandParserLActual;
        assembly ("memory-safe") {
            operandParserLActual := operandParserL
        }
        assertEq(0, operandParserLActual, "operandParserL");
        assertTrue(!notExists, "notExists");
        assertEq(0, l, "l");
    }
}
