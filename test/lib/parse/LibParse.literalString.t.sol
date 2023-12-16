// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibBytecode} from "src/lib/bytecode/LibBytecode.sol";
import {LibParse} from "src/lib/parse/LibParse.sol";
import {LibMetaFixture} from "test/util/lib/parse/LibMetaFixture.sol";
import {IntOrAString, LibIntOrAString} from "rain.intorastring/src/lib/LibIntOrAString.sol";
import {StringTooLong, UnclosedStringLiteral} from "src/error/ErrParse.sol";
import {LibLiteralString} from "test/util/lib/literal/LibLiteralString.sol";

/// @title LibParseLiteralStringTest
contract LibParseLiteralStringTest is Test {
    /// External parse function to allow us to assert reverts.
    function externalParse(bytes memory str) external pure returns (bytes memory, uint256[] memory) {
        return LibParse.parse(str, LibMetaFixture.parseMeta());
    }

    /// Check an empty string literal. Should not revert and return length 1
    /// sources and constants.
    function testParseStringLiteralEmpty() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_: \"\";", LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);

        assertEq(constants.length, 1);
        assertEq(constants[0], IntOrAString.unwrap(LibIntOrAString.fromString("")));
    }

    /// Check a simple string `"a"` literal. Should not revert and return
    /// length 1 sources and constants.
    function testParseStringLiteralSimple() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_: \"a\";", LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);

        assertEq(constants.length, 1);
        assertEq(constants[0], IntOrAString.unwrap(LibIntOrAString.fromString("a")));
    }

    /// Any ASCII printable string shorter than 32 bytes should be parsed
    /// correctly.
    function testParseStringLiteralShortASCII(string memory str) external {
        vm.assume(bytes(str).length < 0x20);
        LibLiteralString.conformValidPrintableStringContent(str);

        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes(string.concat("_: \"", str, "\";")), LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);

        assertEq(constants.length, 1);
        assertEq(constants[0], IntOrAString.unwrap(LibIntOrAString.fromString(str)));
    }

    /// Can parse 2 valid strings.
    function testParseStringLiteralTwo(string memory strA, string memory strB) external {
        vm.assume(bytes(strA).length < 0x20);
        LibLiteralString.conformValidPrintableStringContent(strA);
        vm.assume(bytes(strB).length < 0x20);
        LibLiteralString.conformValidPrintableStringContent(strB);
        vm.assume(keccak256(bytes(strA)) != keccak256(bytes(strB)));

        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes(string.concat("_ _: \"", strA, "\"\"", strB, "\";")), LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 2);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 2);

        assertEq(constants.length, 2);
        assertEq(constants[0], IntOrAString.unwrap(LibIntOrAString.fromString(strA)));
        assertEq(constants[1], IntOrAString.unwrap(LibIntOrAString.fromString(strB)));
    }

    /// Valid ASCII printable strings 32 bytes or longer should error.
    function testParseStringLiteralLongASCII(string memory str) external {
        vm.assume(bytes(str).length >= 0x20);
        LibLiteralString.conformValidPrintableStringContent(str);

        vm.expectRevert(abi.encodeWithSelector(StringTooLong.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) =
            this.externalParse(bytes(string.concat("_: \"", str, "\";")));
        (bytecode, constants);
    }

    /// Invalid chars beyond the 31 byte valid range will not be parsed. Instead
    /// a `StringTooLong` error will be thrown.
    function testParseStringLiteralInvalidCharAfter(string memory strA, string memory strB) external {
        vm.assume(bytes(strA).length >= 0x20);
        LibLiteralString.conformValidPrintableStringContent(strA);
        assembly ("memory-safe") {
            // Force truncate the string to 32 bytes.
            mstore(strA, 0x20)
        }

        vm.expectRevert(abi.encodeWithSelector(StringTooLong.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) =
            this.externalParse(bytes(string.concat("_: \"", strA, strB, "\";")));
        (bytecode, constants);
    }

    /// Invalid chars anywhere in the parsed string will cause an unclosed
    /// string literal error.
    function testParseStringLiteralInvalidCharWithin(string memory str, uint256 badIndex) external {
        vm.assume(bytes(str).length > 0);
        LibLiteralString.conformValidPrintableStringContent(str);
        badIndex = bound(badIndex, 0, (bytes(str).length > 0x1F ? 0x1F : bytes(str).length) - 1);

        LibLiteralString.corruptSingleChar(str, badIndex);

        vm.expectRevert(abi.encodeWithSelector(UnclosedStringLiteral.selector, 4 + badIndex));
        (bytes memory bytecode, uint256[] memory constants) =
            this.externalParse(bytes(string.concat("_: \"", str, "\";")));
        (bytecode, constants);
    }
}
