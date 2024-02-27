// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {LibInterpreterStateNP, InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {LibAllStandardOpsNP} from "src/lib/op/LibAllStandardOpsNP.sol";
import {LibEvalNP} from "src/lib/eval/LibEvalNP.sol";
import {MemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";
import {
    IInterpreterStoreV2,
    FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/unstable/IInterpreterStoreV2.sol";

contract LibEvalNPFBoundsTest is Test {
    /// Due to the mod of indexes to function pointers the indexes wrap at the
    /// length of the function pointers. Test that the length of the fn pointers
    /// + 1 is the constant op.
    function testEvalNPFBoundsModConstant(uint256 c) public {
        bytes memory fs = LibAllStandardOpsNP.opcodeFunctionPointers();

        bytes memory bytecode =
        // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 37 op
            hex"25"
            // 37 stack allocation
            hex"25"
            // 0 input
            hex"00"
            // 37 output
            hex"25"
            // 0: constant 0
            hex"01000000"
            // 1: constant 0
            hex"01000000"
            // 2: constant 0
            hex"01000000"
            // 3: constant 0
            hex"01000000"
            // 4: constant 0
            hex"01000000"
            // 5: constant 0
            hex"01000000"
            // 6: constant 0
            hex"01000000"
            // 7: constant 0
            hex"01000000"
            // 8: constant 0
            hex"01000000"
            // 9: constant 0
            hex"01000000"
            // 10: constant 0
            hex"01000000"
            // 11: constant 0
            hex"01000000"
            // 12: constant 0
            hex"01000000"
            // 13: constant 0
            hex"01000000"
            // 14: constant 0
            hex"01000000"
            // 15: constant 0
            hex"01000000"
            // 16: constant 0
            hex"01000000"
            // 17: constant 0
            hex"01000000"
            // 18: constant 0
            hex"01000000"
            // 19: constant 0
            hex"01000000"
            // 20: constant 0
            hex"01000000"
            // 21: constant 0
            hex"01000000"
            // 22: constant 0
            hex"01000000"
            // 23: constant 0
            hex"01000000"
            // 24: constant 0
            hex"01000000"
            // 25: constant 0
            hex"01000000"
            // 26: constant 0
            hex"01000000"
            // 27: constant 0
            hex"01000000"
            // 28: constant 0
            hex"01000000"
            // 29: constant 0
            hex"01000000"
            // 30: constant 0
            hex"01000000"
            // 31: constant 0
            hex"01000000"
            // 32: constant 0
            hex"01000000"
            // 33: constant 0
            hex"01000000"
            // 34: constant 0
            hex"01000000"
            // 35: constant 0
            hex"01000000"
            // 36: constant 0
            hex"01000000";

        uint256 expectedLength = 37;

        uint256[][] memory stacks = new uint256[][](1);
        stacks[0] = new uint256[](expectedLength);
        uint256[] memory constants = new uint256[](1);
        constants[0] = c;
        uint256[][] memory context = new uint256[][](0);
        InterpreterStateNP memory state = InterpreterStateNP(
            LibInterpreterStateNP.stackBottoms(stacks),
            constants,
            0,
            MemoryKV.wrap(0),
            FullyQualifiedNamespace.wrap(0),
            IInterpreterStoreV2(address(0)),
            context,
            bytecode,
            fs
        );

        (uint256[] memory outputs, uint256[] memory kvs) = LibEvalNP.eval2(state, new uint256[](0), type(uint256).max);
        assertEq(outputs.length, expectedLength);
        for (uint256 i = 0; i < outputs.length; i++) {
            assertEq(outputs[i], c);
        }
        assertEq(kvs.length, 0);

        // Replace the constant byte with constant from the next octave.
        for (uint256 i = 7; i < bytecode.length; i += 4) {
            bytecode[i] = bytes1(uint8(uint8(fs.length / 2) + 1));
        }

        (outputs, kvs) = LibEvalNP.eval2(state, new uint256[](0), type(uint256).max);
        assertEq(outputs.length, expectedLength);
        for (uint256 i = 0; i < outputs.length; i++) {
            assertEq(outputs[i], c);
        }
        assertEq(kvs.length, 0);
    }
}
