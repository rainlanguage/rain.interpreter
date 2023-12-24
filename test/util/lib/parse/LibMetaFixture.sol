// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {AuthoringMetaV2} from "src/interface/IParserV1.sol";
import {LibParseMeta} from "src/lib/parse/LibParseMeta.sol";

library LibMetaFixture {
    function authoringMetaV2() internal pure returns (AuthoringMetaV2[] memory) {
        AuthoringMetaV2[] memory meta = new AuthoringMetaV2[](18);
        meta[0] = AuthoringMetaV2("stack", "reads from the stack");
        meta[1] = AuthoringMetaV2("constant", "copies a constant to the stack");
        meta[2] = AuthoringMetaV2("a", "a");
        meta[3] = AuthoringMetaV2("b", "b");
        meta[4] = AuthoringMetaV2("c", "c");
        meta[5] = AuthoringMetaV2("d", "d");
        meta[6] = AuthoringMetaV2("e", "e");
        meta[7] = AuthoringMetaV2("f", "f");
        meta[8] = AuthoringMetaV2("g", "g");
        meta[9] = AuthoringMetaV2("h", "h");
        meta[10] = AuthoringMetaV2("i", "i");
        meta[11] = AuthoringMetaV2("j", "j");
        meta[12] = AuthoringMetaV2("k", "k");
        meta[13] = AuthoringMetaV2("l", "l");
        meta[14] = AuthoringMetaV2("m", "m");
        meta[15] = AuthoringMetaV2("n", "n");
        meta[16] = AuthoringMetaV2("o", "o");
        meta[17] = AuthoringMetaV2("p", "p");
        return meta;
    }

    function parseMetaV2() internal pure returns (bytes memory) {
        return LibParseMeta.buildParseMetaV2(authoringMetaV2(), 1);
    }
}
