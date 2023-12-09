// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {LibBytecode} from "src/lib/bytecode/LibBytecode.sol";
import {LibParse} from "src/lib/parse/LibParse.sol";
import {LibMetaFixture} from "test/util/lib/parse/LibMetaFixture.sol";
import {IntOrAString, LibIntOrAString} from "rain.intorastring/src/lib/LibIntOrAString.sol";
import {CMASK_STRING_LITERAL_TAIL} from "src/lib/parse/LibParseCMask.sol";

/// @title LibParseLiteralStringTest
contract LibParseLiteralStringTest is Test {
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

    /// Any ASCII string shorter than 32 bytes should be parsed correctly.
    function testParseStringLiteralShortASCII(string memory str) external {
        vm.assume(bytes(str).length < 0x20);
        uint256 seed = 0;
        // Make the string ascii only.
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

        console2.log("str", str, bytes(str).length);

        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(
            bytes(string.concat("_: \"", str, "\";")),
            LibMetaFixture.parseMeta()
        );
    }
}
