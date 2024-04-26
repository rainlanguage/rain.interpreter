// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {
    RainterpreterParserNPE2
} from "src/concrete/RainterpreterParserNPE2.sol";
import {IParserPragmaV1, PragmaV1} from "rain.interpreter.interface/interface/unstable/IParserPragmaV1.sol";

contract RainterpreterParserNPE2ParserPragma {
    function checkPragma(bytes memory source, address[] memory expectedAddresses) internal {
        RainterpreterParserNPE2 parser = new RainterpreterParserNPE2();
        PragmaV1 memory pragmaV2 = parser.parsePragma1(source);
        assert(pragmaV2.usingWordsFrom.length == expectedAddresses.length);
        for (uint256 i = 0; i < expectedAddresses.length; i++) {
            assert(pragmaV2.usingWordsFrom[i] == expectedAddresses[i]);
        }
    }

    function testParsePragmaNoPragma() external {
        checkPragma(":;", new address[](0));
        checkPragma("using-words-from :;", new address[](0));
        checkPragma("using-words-from foo:;", new address[](0));
        checkPragma("using-words-from foo:1;", new address[](0));
        checkPragma("using-words-from _:1;", new address[](0));
    }
}