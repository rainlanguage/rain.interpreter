// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "src/lib/parse/LibParseMeta.sol";

library LibMetaFixture {
    function authoringMeta() internal pure returns (AuthoringMeta[] memory) {
        AuthoringMeta[] memory meta = new AuthoringMeta[](17);
        meta[0] = AuthoringMeta("stack", 0, "reads from the stack");
        meta[1] = AuthoringMeta("constant", 0, "copies a constant to the stack");
        meta[2] = AuthoringMeta("a", 0, "a");
        meta[2] = AuthoringMeta("b", 0, "b");
        meta[3] = AuthoringMeta("c", 0, "c");
        meta[4] = AuthoringMeta("d", 0, "d");
        meta[5] = AuthoringMeta("e", 0, "e");
        meta[6] = AuthoringMeta("f", 0, "f");
        meta[7] = AuthoringMeta("g", 0, "g");
        meta[8] = AuthoringMeta("h", 0, "h");
        meta[9] = AuthoringMeta("i", 0, "i");
        meta[10] = AuthoringMeta("j", 0, "j");
        meta[11] = AuthoringMeta("k", 0, "k");
        meta[12] = AuthoringMeta("l", 0, "l");
        meta[13] = AuthoringMeta("m", 0, "m");
        meta[14] = AuthoringMeta("n", 0, "n");
        meta[15] = AuthoringMeta("o", 0, "o");
        meta[16] = AuthoringMeta("p", 0, "p");
        return meta;
    }

    function parseMeta() internal pure returns (bytes memory) {
        return LibParseMeta.buildParseMeta(authoringMeta(), 1);
    }
}
