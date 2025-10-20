// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibParsePragma, PRAGMA_KEYWORD_BYTES_LENGTH, PRAGMA_KEYWORD_BYTES} from "src/lib/parse/LibParsePragma.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {
    CMASK_WHITESPACE,
    CMASK_LITERAL_HEX_DISPATCH_START,
    CMASK_INTERSTITIAL_HEAD,
    CMASK_HEX
} from "rain.string/lib/parse/LibParseCMask.sol";
import {LibConformString} from "rain.string/lib/mut/LibConformString.sol";
import {NoWhitespaceAfterUsingWordsFrom} from "src/error/ErrParse.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibAllStandardOps} from "src/lib/op/LibAllStandardOps.sol";

/// @title LibParsePragmaKeywordTest
contract LibParsePragmaKeywordTest is Test {
    using LibParsePragma for ParseState;
    using LibBytes for bytes;
    using Strings for address;

    function checkPragmaParsing(
        string memory str,
        uint256 expectedCursorDiff,
        address[] memory values,
        string memory err
    ) internal pure {
        ParseState memory state =
            LibParseState.newState(bytes(str), "", "", LibAllStandardOps.literalParserFunctionPointers());
        uint256 cursor = Pointer.unwrap(bytes(str).dataPointer());
        uint256 end = Pointer.unwrap(bytes(str).endDataPointer());
        uint256 cursorAfter = state.parsePragma(cursor, end);
        assertEq(cursorAfter - cursor, expectedCursorDiff, err);

        if (values.length > 0) {
            uint256 j = values.length - 1;
            bytes32 deref = state.subParsers;
            uint256 pointer = uint256(deref) >> 0xF0;
            while (deref != 0) {
                assertEq(uint160(uint256(deref)), uint160(values[j]));

                assembly ("memory-safe") {
                    deref := mload(pointer)
                }
                pointer = uint256(deref) >> 0xF0;
                // This underflows exactly when deref is zero and the loop
                // terminates.
                unchecked {
                    --j;
                }
            }
        }
    }

    function externalParsePragma(string memory str) external pure {
        ParseState memory state =
            LibParseState.newState(bytes(str), "", "", LibAllStandardOps.literalParserFunctionPointers());
        uint256 cursor = Pointer.unwrap(bytes(str).dataPointer());
        uint256 end = Pointer.unwrap(bytes(str).endDataPointer());
        uint256 cursorAfter = state.parsePragma(cursor, end);
        (cursorAfter);
    }

    /// Anything that DOES NOT start with the keyword should be a noop.
    /// forge-config: default.fuzz.runs = 100
    function testPragmaKeywordNoop(ParseState memory state, string calldata calldataStr) external pure {
        if (bytes(calldataStr).length >= PRAGMA_KEYWORD_BYTES_LENGTH) {
            bytes memory prefix = bytes(calldataStr)[0:PRAGMA_KEYWORD_BYTES_LENGTH];
            assert(keccak256(prefix) != keccak256(PRAGMA_KEYWORD_BYTES));
        }
        string memory str = calldataStr;

        uint256 cursor = Pointer.unwrap(bytes(str).dataPointer());
        uint256 end = Pointer.unwrap(bytes(str).endDataPointer());
        uint256 cursorAfter = state.parsePragma(cursor, end);
        assertEq(cursorAfter, cursor);
    }

    /// Anything that DOES start with the keyword but WITHOUT whitespace should
    /// error.
    /// forge-config: default.fuzz.runs = 100
    function testPragmaKeywordNoWhitespace(uint256 seed, string memory str) external {
        bytes1 notWhitespace = LibConformString.charFromMask(seed, ~CMASK_WHITESPACE);
        string memory fullString =
            string.concat(string(PRAGMA_KEYWORD_BYTES), string(abi.encodePacked(notWhitespace)), str);
        vm.expectRevert(abi.encodeWithSelector(NoWhitespaceAfterUsingWordsFrom.selector, PRAGMA_KEYWORD_BYTES_LENGTH));
        this.externalParsePragma(fullString);
    }

    /// Anything that DOES start with the keyword and WITH whitespace BUT NOT
    /// hex values should more the cursor forward exactly the length of the
    /// keyword + the whitespace char.
    /// forge-config: default.fuzz.runs = 100
    function testPragmaKeywordWhitespaceNoHex(uint256 seed, string calldata calldataStr) external pure {
        seed = bound(seed, 0, type(uint256).max - 1);
        bytes1 whitespace = LibConformString.charFromMask(seed, CMASK_WHITESPACE);
        bytes1 notInterstitialHead = LibConformString.charFromMask(seed + 1, ~CMASK_INTERSTITIAL_HEAD);
        if (bytes(calldataStr).length > 2) {
            vm.assume(
                keccak256(bytes(calldataStr[0:2]))
                // CMASK_LITERAL_HEX_DISPATCH_START is a constant that is
                // definitely a uint16 so this is safe.
                //forge-lint: disable-next-line(unsafe-typecast)
                != keccak256(abi.encodePacked(uint16(CMASK_LITERAL_HEX_DISPATCH_START)))
            );
        }
        string memory str = string.concat(
            string(PRAGMA_KEYWORD_BYTES), string(abi.encodePacked(whitespace, notInterstitialHead)), calldataStr
        );
        ParseState memory state =
            LibParseState.newState(bytes(str), "", "", LibAllStandardOps.literalParserFunctionPointers());

        uint256 cursor = Pointer.unwrap(bytes(str).dataPointer());
        uint256 end = Pointer.unwrap(bytes(str).endDataPointer());
        uint256 cursorAfter = state.parsePragma(cursor, end);
        assertEq(cursorAfter, cursor + PRAGMA_KEYWORD_BYTES_LENGTH + 1);
    }

    /// Anything that DOES start with the keyword and WITH whitespace then some
    /// hex address should push the hex address to the state as a sub parser.
    /// forge-config: default.fuzz.runs = 100
    function testPragmaKeywordParseSubParserBasic(
        string memory whitespace,
        address subParser,
        uint256 seed,
        string calldata suffix
    ) external pure {
        vm.assume(bytes(whitespace).length > 0);
        bytes1 notHexData = LibConformString.charFromMask(seed, ~CMASK_HEX);
        LibConformString.conformStringToMask(whitespace, CMASK_WHITESPACE, 0x80);
        string memory str = string.concat(
            string(PRAGMA_KEYWORD_BYTES),
            whitespace,
            subParser.toHexString(),
            string(abi.encodePacked(notHexData)),
            suffix
        );
        ParseState memory state =
            LibParseState.newState(bytes(str), "", "", LibAllStandardOps.literalParserFunctionPointers());
        uint256 cursor = Pointer.unwrap(bytes(str).dataPointer());
        uint256 end = Pointer.unwrap(bytes(str).endDataPointer());
        uint256 cursorAfter = state.parsePragma(cursor, end);

        // The cursor should be pointing after the sub parser.
        assertEq(cursorAfter, cursor + PRAGMA_KEYWORD_BYTES_LENGTH + bytes(whitespace).length + 42);

        // The sub parser should be pushed to the state.
        bytes32 deref = state.subParsers;
        assertEq(uint160(uint256(deref)), uint160(subParser));
        uint256 pointer = uint256(deref) >> 0xF0;
        assembly ("memory-safe") {
            deref := mload(pointer)
        }
        assertEq(deref, 0);
    }

    /// Can parse a couple of addresses cleanly.
    /// forge-config: default.fuzz.runs = 100
    function testPragmaKeywordParseSubParserCoupleOfAddresses(
        string memory whitespace0,
        string memory whitespace1,
        address subParser0,
        address subParser1,
        uint256 seed,
        string calldata suffix
    ) external pure {
        vm.assume(bytes(whitespace0).length > 0);
        vm.assume(bytes(whitespace1).length > 0);

        bytes1 notHexData = LibConformString.charFromMask(seed, ~CMASK_HEX);

        LibConformString.conformStringToMask(whitespace0, CMASK_WHITESPACE, 0x80);
        LibConformString.conformStringToMask(whitespace1, CMASK_WHITESPACE, 0x80);

        string memory str = string.concat(
            string.concat(
                string(PRAGMA_KEYWORD_BYTES),
                whitespace0,
                subParser0.toHexString(),
                whitespace1,
                subParser1.toHexString(),
                string(abi.encodePacked(notHexData))
            ),
            suffix
        );

        ParseState memory state =
            LibParseState.newState(bytes(str), "", "", LibAllStandardOps.literalParserFunctionPointers());

        uint256 cursor = Pointer.unwrap(bytes(str).dataPointer());
        uint256 end = Pointer.unwrap(bytes(str).endDataPointer());
        uint256 cursorAfter = state.parsePragma(cursor, end);

        // The cursor should be pointing after the sub parser.
        assertEq(
            cursorAfter,
            cursor + PRAGMA_KEYWORD_BYTES_LENGTH + bytes(whitespace0).length + 42 + bytes(whitespace1).length + 42
        );

        // The sub parsers should both be pushed to the state.
        bytes32 deref = state.subParsers;
        assertEq(uint160(uint256(deref)), uint160(subParser1));
        uint256 pointer = uint256(deref) >> 0xF0;
        assembly ("memory-safe") {
            deref := mload(pointer)
        }
        assertEq(uint160(uint256(deref)), uint160(subParser0));
        pointer = uint256(deref) >> 0xF0;
        assembly ("memory-safe") {
            deref := mload(pointer)
        }
        assertEq(deref, 0);
    }

    /// Test a specific string.
    function testPragmaKeywordParseSubParserSpecificStrings() external pure {
        string memory str =
            "using-words-from 0x1234567890123456789012345678901234567890 0x1234567890123456789012345678901234567891";
        address[] memory values = new address[](2);
        values[0] = 0x1234567890123456789012345678901234567890;
        values[1] = 0x1234567890123456789012345678901234567891;

        checkPragmaParsing(str, 102, values, "should parse two addresses");

        str = "using-words-from 0x1234567890123456789012345678901234567890 0x1234567890123456789012345678901234567891 ";
        checkPragmaParsing(str, 103, values, "should parse two addresses with trailing whitespace");

        str = "using-words-from 0x1234567890123456789012345678901234567890 0x1234567890123456789012345678901234567891  ";
        checkPragmaParsing(str, 104, values, "should parse two addresses with more trailing whitespace");

        str =
            "using-words-from 0x1234567890123456789012345678901234567890 0x1234567890123456789012345678901234567891  \n";
        checkPragmaParsing(str, 105, values, "should parse two addresses with trailing whitespace and newline");

        str =
            "using-words-from 0x1234567890123456789012345678901234567890 0x1234567890123456789012345678901234567891  \n\n";
        checkPragmaParsing(str, 106, values, "should parse two addresses with trailing whitespace and newlines");

        str = "using-words-from 0x1234567890123456789012345678901234567890";
        values = new address[](1);
        values[0] = 0x1234567890123456789012345678901234567890;
        checkPragmaParsing(str, 59, values, "should parse one address");

        str = "using-words-from 0x1234567890123456789012345678901234567890 ";
        checkPragmaParsing(str, 60, values, "should parse one address with trailing whitespace");

        str = "using-words-from 0x1234567890123456789012345678901234567890  ";
        checkPragmaParsing(str, 61, values, "should parse one address with more trailing whitespace");

        str = "using-words-from 0x1234567890123456789012345678901234567890  \n";
        checkPragmaParsing(str, 62, values, "should parse one address with trailing whitespace and newline");

        str = "using-words-from 0x1234567890123456789012345678901234567890  \n\n";
        checkPragmaParsing(str, 63, values, "should parse one address with trailing whitespace and newlines");

        values = new address[](0);
        str = "using-words-from ";
        checkPragmaParsing(str, 17, values, "should parse no addresses with trailing whitespace");

        str = "using-words-from  ";
        checkPragmaParsing(str, 18, values, "should parse no addresses with more trailing whitespace");

        str = "using-words-from  \n";
        checkPragmaParsing(str, 19, values, "should parse no addresses with trailing whitespace and newline");

        str = "using-words-from  \n\n";
        checkPragmaParsing(str, 20, values, "should parse no addresses with trailing whitespace and newlines");

        str = "";
        checkPragmaParsing(str, 0, values, "should parse no addresses with empty string as noop");

        str = " ";
        checkPragmaParsing(str, 0, values, "should parse no addresses with whitespace as noop");

        str = "using-words-frum ";
        checkPragmaParsing(str, 0, values, "should parse no addresses with typo as noop");
    }
}
