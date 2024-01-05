// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {ParseState, Pointer, LibParseState} from "src/lib/parse/LibParseState.sol";
import {LibBytes} from "rain.solmem/lib/LibBytes.sol";
import {LibParseLiteralSubParseable} from "src/lib/parse/literal/LibParseLiteralSubParseable.sol";
import {UnclosedSubParseableLiteral, SubParseableMissingDispatch} from "src/error/ErrParse.sol";

contract LibParseLiteralSubParseableTest is Test {
    using LibBytes for bytes;
    using LibParseState for ParseState;
    using LibParseLiteralSubParseable for ParseState;

    function checkParseSubParseable(
        string memory data,
        string memory expectedDispatch,
        string memory expectedBody,
        uint256 expectedCursorAfter
    ) internal {
        ParseState memory state = LibParseState.newState(bytes(data), "", "", "");
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        address subParser = address(0x1234567890123456789012345678901234567890);
        state.pushSubParser(0, uint256(subParser));
        bytes memory subParseData = bytes.concat(
            bytes2(uint16(expectedDispatch.length)),
            bytes(expectedDispatch),
            bytes(expectedBody)
        );
        vm.mockCall(
            subParser,
            abi.encodeWithSelector(
                ISubParserV2.subParseLiteral,
                COMPATIBLITY_V2,
                subParseData
            ),
            abi.encode(0, 0)
        );
        (uint256 cursorAfter, uint256 value) = state.parseSubParseable(cursor, Pointer.unwrap(state.data.endDataPointer()));
        assertEq(cursorAfter - cursor, expectedCursorAfter);
    }

    function checkParseSubParseableError(
        string memory data,
        bytes memory err
    ) internal {
        vm.expectRevert(err);
        checkParseSubParseable(data, 0);
    }

    /// An unclosed sub parseable literal is an error.
    function testParseLiteralSubParseableUnclosed3() external {
        checkParseSubParseableError("[a", abi.encodeWithSelector(
                UnclosedSubParseableLiteral.selector,
                2
            ));
    }

    /// An unclosed sub parseable literal is an error.
    function testParseLiteralSubParseableUnclosed4() external {
        checkParseSubParseableError("[a ", abi.encodeWithSelector(
                UnclosedSubParseableLiteral.selector,
                3
            ));
    }

    /// An unclosed sub parseable literal is an error.
    function testParseLiteralSubParseableUnclosed5() external {
        checkParseSubParseableError("[[", abi.encodeWithSelector(
                UnclosedSubParseableLiteral.selector,
                2
            ));
    }

    /// An empty sub parseable literal is an error.
    function testParseLiteralSubParseableUnclosed6() external {
        checkParseSubParseableError("[]", abi.encodeWithSelector(
                SubParseableMissingDispatch.selector,
                1
            ));
    }

    /// An unclosed sub parseable literal with no dispatch is an error.
    function testParseLiteralSubParseableUnclosed0() external {
        checkParseSubParseableError("[", abi.encodeWithSelector(
                SubParseableMissingDispatch.selector,
                1
            ));
    }

    /// An unclosed sub parseable literal with no dispatch is an error.
    function testParseLiteralSubParseableUnclosed1() external {
        checkParseSubParseableError("[ ", abi.encodeWithSelector(
                SubParseableMissingDispatch.selector,
                1
            ));
    }

    /// An unclosed sub parseable literal with no dispatch is an error.
    function testParseLiteralSubParseableUnclosed2() external {
        checkParseSubParseableError("[  ", abi.encodeWithSelector(
                SubParseableMissingDispatch.selector,
                1
            ));
    }

    /// A dispatch with an empty body is allowed.
    function testParseLiteralSubParseableEmpty() external {
        checkParseSubParseable("[pi]", 4);
    }
}