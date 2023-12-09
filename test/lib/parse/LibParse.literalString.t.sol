// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {LibBytecode} from "src/lib/bytecode/LibBytecode.sol";
import {LibParse} from "src/lib/parse/LibParse.sol";
import {LibMetaFixture} from "test/util/lib/parse/LibMetaFixture.sol";
import {IntOrAString, LibIntOrAString} from "rain.intorastring/src/lib/LibIntOrAString.sol";
import {CMASK_STRING_LITERAL_TAIL} from "src/lib/parse/LibParseCMask.sol";
import {StringTooLong, UnclosedStringLiteral} from "src/error/ErrParse.sol";

/// @title LibParseLiteralStringTest
contract LibParseLiteralStringTest is Test {
    function conformValidPrintableStringContent(string memory str) internal pure {
        uint256 seed = 0;
        for (uint256 i = 0; i < bytes(str).length; i++) {
            uint256 char = uint256(uint8(bytes(str)[i]));
            // If the char is not a string literal tail, roll it.
            while (1 << char & CMASK_STRING_LITERAL_TAIL == 0) {
                assembly ("memory-safe") {
                    mstore(0, char)
                    mstore(0x20, seed)
                    seed := keccak256(0, 0x40)
                    // Eliminate everything out of ASCII range to give us a
                    // better chance of hitting a string literal tail.
                    char := mod(byte(0, seed), 0x80)
                }
            }
            bytes(str)[i] = bytes1(uint8(char));
        }
    }

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

    /// Check "_: \"/29MpY\\RZ\\`pjr'e.UK;=PB5.]=tb*\";" as it is was flagged by
    /// the fuzzer.
    function testParseStringLiteralFuzz0() external {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_: \"/29MpY\\RZ\\`pjr'e.UK;=PB5.]=tb*\";"), LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);

        assertEq(constants.length, 1);
        assertEq(constants[0], IntOrAString.unwrap(LibIntOrAString.fromString("/29MpY\\RZ\\`pjr'e.UK;=PB5.]=tb*")));
    }

    /// Any ASCII printable string shorter than 32 bytes should be parsed
    /// correctly.
    function testParseStringLiteralShortASCII(string memory str) external {
        vm.assume(bytes(str).length < 0x20);
        conformValidPrintableStringContent(str);

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

    /// Valid ASCII printable strings 32 bytes or longer should error.
    function testParseStringLiteralLongASCII(string memory str) external {
        vm.assume(bytes(str).length >= 0x20);
        conformValidPrintableStringContent(str);

        vm.expectRevert(abi.encodeWithSelector(StringTooLong.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) =
            this.externalParse(bytes(string.concat("_: \"", str, "\";")));
        (bytecode, constants);
    }

    /// Invalid chars beyond the 31 byte valid range will not be parsed. Instead
    /// a `StringTooLong` error will be thrown.
    function testParseStringLiteralInvalidCharAfter(string memory strA, string memory strB) external {
        vm.assume(bytes(strA).length >= 0x20);
        conformValidPrintableStringContent(strA);
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
        conformValidPrintableStringContent(str);
        badIndex = bound(badIndex, 0, (bytes(str).length > 0x1F ? 0x1F : bytes(str).length) - 1);

        uint256 char = uint256(uint8(bytes(str)[badIndex]));
        uint256 seed = 0;
        while (1 << char & ~CMASK_STRING_LITERAL_TAIL == 0 || char == uint8(bytes1("\""))) {
            assembly ("memory-safe") {
                mstore(0, char)
                mstore(0x20, seed)
                seed := keccak256(0, 0x40)
                char := byte(0, seed)
            }
        }
        bytes(str)[badIndex] = bytes1(uint8(char));

        vm.expectRevert(abi.encodeWithSelector(UnclosedStringLiteral.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) =
            this.externalParse(bytes(string.concat("_: \"", str, "\";")));
        (bytecode, constants);
    }
}
