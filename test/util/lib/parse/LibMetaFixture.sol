// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "src/lib/parse/LibParseMeta.sol";

library LibMetaFixture {
    function authoringMeta() internal pure returns (AuthoringMeta[] memory) {
        AuthoringMeta[] memory meta = new AuthoringMeta[](18);
        meta[0] = AuthoringMeta("stack", 0, "reads from the stack");
        meta[1] = AuthoringMeta("constant", 0, "copies a constant to the stack");
        meta[2] = AuthoringMeta("a", 0, "a");
        meta[3] = AuthoringMeta("b", 0, "b");
        meta[4] = AuthoringMeta("c", 0, "c");
        meta[5] = AuthoringMeta("d", 0, "d");
        meta[6] = AuthoringMeta("e", 0, "e");
        meta[7] = AuthoringMeta("f", 0, "f");
        meta[8] = AuthoringMeta("g", 0, "g");
        meta[9] = AuthoringMeta("h", 0, "h");
        meta[10] = AuthoringMeta("i", 0, "i");
        meta[11] = AuthoringMeta("j", 0, "j");
        meta[12] = AuthoringMeta("k", 0, "k");
        meta[13] = AuthoringMeta("l", 0, "l");
        meta[14] = AuthoringMeta("m", 0, "m");
        meta[15] = AuthoringMeta("n", 0, "n");
        meta[16] = AuthoringMeta("o", 0, "o");
        meta[17] = AuthoringMeta("p", 0, "p");
        return meta;
    }

    function parseMeta() internal pure returns (bytes memory) {
        return LibParseMeta.buildParseMeta(authoringMeta(), 1);
    }
}
