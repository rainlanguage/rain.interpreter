// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OPERAND_PARSER_OFFSET_DISALLOWED, OPERAND_PARSER_OFFSET_SINGLE_FULL, OPERAND_PARSER_OFFSET_DOUBLE_PERBYTE_NO_DEFAULT, OPERAND_PARSER_OFFSET_M1_M1, OPERAND_PARSER_OFFSET_8_M1_M1} from "src/lib/parse/LibParseOperand.sol";
import {LibParseMeta, AuthoringMeta} from "src/lib/parse/LibParseMeta.sol";

library LibMetaFixture {
    function authoringMeta() internal pure returns (AuthoringMeta[] memory) {
        AuthoringMeta[] memory meta = new AuthoringMeta[](18);
        meta[0] = AuthoringMeta("stack", OPERAND_PARSER_OFFSET_DISALLOWED, "reads from the stack");
        meta[1] = AuthoringMeta("constant", OPERAND_PARSER_OFFSET_DISALLOWED, "copies a constant to the stack");
        meta[2] = AuthoringMeta("a", OPERAND_PARSER_OFFSET_DISALLOWED, "a");
        meta[3] = AuthoringMeta("b", OPERAND_PARSER_OFFSET_SINGLE_FULL, "b");
        meta[4] = AuthoringMeta("c", OPERAND_PARSER_OFFSET_DOUBLE_PERBYTE_NO_DEFAULT, "c");
        meta[5] = AuthoringMeta("d", OPERAND_PARSER_OFFSET_M1_M1, "d");
        meta[6] = AuthoringMeta("e", OPERAND_PARSER_OFFSET_8_M1_M1, "e");
        meta[7] = AuthoringMeta("f", OPERAND_PARSER_OFFSET_DISALLOWED, "f");
        meta[8] = AuthoringMeta("g", OPERAND_PARSER_OFFSET_DISALLOWED, "g");
        meta[9] = AuthoringMeta("h", OPERAND_PARSER_OFFSET_DISALLOWED, "h");
        meta[10] = AuthoringMeta("i", OPERAND_PARSER_OFFSET_DISALLOWED, "i");
        meta[11] = AuthoringMeta("j", OPERAND_PARSER_OFFSET_DISALLOWED, "j");
        meta[12] = AuthoringMeta("k", OPERAND_PARSER_OFFSET_DISALLOWED, "k");
        meta[13] = AuthoringMeta("l", OPERAND_PARSER_OFFSET_DISALLOWED, "l");
        meta[14] = AuthoringMeta("m", OPERAND_PARSER_OFFSET_DISALLOWED, "m");
        meta[15] = AuthoringMeta("n", OPERAND_PARSER_OFFSET_DISALLOWED, "n");
        meta[16] = AuthoringMeta("o", OPERAND_PARSER_OFFSET_DISALLOWED, "o");
        meta[17] = AuthoringMeta("p", OPERAND_PARSER_OFFSET_DISALLOWED, "p");
        return meta;
    }

    function parseMeta() internal pure returns (bytes memory) {
        return LibParseMeta.buildParseMeta(authoringMeta(), 1);
    }
}
