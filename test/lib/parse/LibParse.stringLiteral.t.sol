// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibBytecode} from "src/lib/bytecode/LibBytecode.sol";
import {LibParse} from "src/lib/parse/LibParse.sol";
import {LibMetaFixture} from "test/util/lib/parse/LibMetaFixture.sol";
import {IntOrAString, LibIntOrAString} from "rain.intorastring/src/lib/LibIntOrAString.sol";

contract LibParseStringLiteralTest is Test {
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
}
