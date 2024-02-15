// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {AuthoringMetaV2} from "src/interface/IParserV1.sol";
import {LibParseMeta} from "src/lib/parse/LibParseMeta.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibBloom} from "test/lib/bloom/LibBloom.sol";
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

    function testBuildMeta(AuthoringMetaV2[] memory authoringMeta) external pure {
        vm.assume(!LibBloom.bloomFindsDupes(LibParseMeta.copyWordsFromAuthoringMeta(authoringMeta)));
        bytes memory meta = LibParseMeta.buildParseMetaV2(authoringMeta, expanderDepth(authoringMeta.length));
        (meta);
    }

    function testRoundMetaExpanderShallow(
        ParseState memory state,
        AuthoringMetaV2[] memory authoringMeta,
        uint8 j,
        bytes32 notFound
    ) external {
        vm.assume(authoringMeta.length > 0);
        vm.assume(!LibBloom.bloomFindsDupes(LibParseMeta.copyWordsFromAuthoringMeta(authoringMeta)));
        for (uint256 i = 0; i < authoringMeta.length; i++) {
            vm.assume(authoringMeta[i].word != notFound);
        }
        j = uint8(bound(j, uint8(0), uint8(authoringMeta.length) - 1));

        state.meta = LibParseMeta.buildParseMetaV2(authoringMeta, expanderDepth(authoringMeta.length));
        (bool exists, uint256 k) = state.lookupWord(authoringMeta[j].word);
        assertTrue(exists, "exists");
        assertEq(j, k, "k");

        (bool notExists, uint256 l) = state.lookupWord(notFound);
        assertTrue(!notExists, "notExists");
        assertEq(0, l, "l");
    }

    function testRoundMetaExpanderDeeper(
        ParseState memory state,
        AuthoringMetaV2[] memory authoringMeta,
        uint8 j,
        bytes32 notFound
    ) external {
        vm.assume(authoringMeta.length > 50);
        vm.assume(!LibBloom.bloomFindsDupes(LibParseMeta.copyWordsFromAuthoringMeta(authoringMeta)));
        for (uint256 i = 0; i < authoringMeta.length; i++) {
            vm.assume(authoringMeta[i].word != notFound);
        }
        j = uint8(bound(j, uint8(0), uint8(authoringMeta.length) - 1));

        state.meta = LibParseMeta.buildParseMetaV2(authoringMeta, expanderDepth(authoringMeta.length));

        (bool exists, uint256 k) = state.lookupWord(authoringMeta[j].word);
        assertTrue(exists, "exists");
        assertEq(j, k, "k");

        (bool notExists, uint256 l) = state.lookupWord(notFound);
        assertTrue(!notExists, "notExists");
        assertEq(0, l, "l");
    }
}
