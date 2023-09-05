// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/op/LibAllStandardOpsNP.sol";
import "src/lib/eval/LibEvalNP.sol";

contract LibEvalFBoundsTest is Test {
    /// Due to the mod of indexes to function pointers the indexes wrap at the
    /// length of the function pointers. Test that the length of the fn pointers
    /// + 1 is the constant op.
    function testEvalFBoundsModConstant(uint256 c) public {
        bytes memory fs = LibAllStandardOpsNP.opcodeFunctionPointers();

        bytes memory bytecode =
        // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 op
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 input
            hex"00"
            // 1 output
            hex"01"
            // constant 0
            hex"01000000";

        uint256[][] memory stacks = new uint256[][](1);
        stacks[0] = new uint256[](1);
        uint256[] memory constants = new uint256[](1);
        constants[0] = c;
        uint256[][] memory context = new uint256[][](0);
        InterpreterStateNP memory state = InterpreterStateNP(
            LibInterpreterStateNP.stackBottoms(stacks),
            constants,
            0,
            MemoryKV.wrap(0),
            FullyQualifiedNamespace.wrap(0),
            IInterpreterStoreV1(address(0)),
            context,
            bytecode,
            fs
        );

        (uint256[] memory outputs, uint256[] memory kvs) = LibEvalNP.evalNP(state, new uint256[](0), type(uint256).max);
        assertEq(outputs.length, 1);
        assertEq(outputs[0], c);
        assertEq(kvs.length, 0);

        // Replace the constant byte with constant from the next octave.
        bytecode[7] = bytes1(uint8(uint8(fs.length / 2) + 1));

        (outputs, kvs) = LibEvalNP.evalNP(state, new uint256[](0), type(uint256).max);
        assertEq(outputs.length, 1);
        assertEq(outputs[0], c);
        assertEq(kvs.length, 0);
    }
}
