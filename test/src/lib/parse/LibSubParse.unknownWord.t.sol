// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibParse} from "src/lib/parse/LibParse.sol";
import {UnknownWord} from "src/error/ErrParse.sol";
import {ISubParserV4} from "rain.interpreter.interface/interface/ISubParserV4.sol";

contract LibSubParseUnknownWordTest is Test {
    using LibParseState for ParseState;
    using LibParse for ParseState;

    /// External wrapper so expectRevert works.
    function externalParseUnknownWord(bytes memory data, address subParser) external view {
        ParseState memory state = LibParseState.newState(data, "", "", "");
        state.pushSubParser(0, bytes32(uint256(uint160(subParser))));
        (bytes memory bytecode, bytes32[] memory constants) = state.parse();
        (bytecode, constants);
    }

    /// When the only sub-parser rejects a word, parse must revert with
    /// UnknownWord.
    function testUnknownWordSingleSubParser(string memory name) external {
        address subParser = makeAddr(name);

        // Mock the sub-parser to reject all words.
        vm.mockCall(
            subParser,
            abi.encodeWithSelector(ISubParserV4.subParseWord2.selector),
            abi.encode(false, bytes(""), new bytes32[](0))
        );

        vm.expectRevert(abi.encodeWithSelector(UnknownWord.selector, "foo"));
        this.externalParseUnknownWord(bytes("_: foo();"), subParser);
    }
}
