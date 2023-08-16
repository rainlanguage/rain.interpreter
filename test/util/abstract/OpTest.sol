// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "rain.solmem/lib/LibMemCpy.sol";
import "rain.solmem/lib/LibUint256Array.sol";
import "rain.solmem/lib/LibPointer.sol";

import "./RainterpreterExpressionDeployerDeploymentTest.sol";
import "../../../src/lib/state/LibInterpreterStateNP.sol";

uint256 constant PRE = uint256(keccak256(abi.encodePacked("pre")));
uint256 constant POST = uint256(keccak256(abi.encodePacked("post")));

abstract contract OpTest is RainterpreterExpressionDeployerDeploymentTest {
    using LibInterpreterStateNP for InterpreterStateNP;
    using LibUint256Array for uint256[];
    using LibPointer for Pointer;

    struct ReferenceCheckPointers {
        Pointer pre;
        Pointer post;
        Pointer stackTop;
        Pointer expectedStackTopAfter;
    }

    function opReferenceCheck(
        InterpreterStateNP memory state,
        Operand operand,
        function(InterpreterStateNP memory, Operand, uint256[] memory) view returns (uint256[] memory) referenceFn,
        function(IntegrityCheckStateNP memory, Operand) pure returns (uint256, uint256) integrityFn,
        function(InterpreterStateNP memory, Operand, Pointer) view returns (Pointer) runFn,
        uint256[] memory inputs
    ) internal {
        uint256[] memory expectedOutputs;
        ReferenceCheckPointers memory pointers;

        {
            uint256 calcInputs;
            uint256 calcOutputs;
            {
                IntegrityCheckStateNP memory integrityState = LibIntegrityCheckNP.newState("", 0, state.constants.length);
                (calcInputs, calcOutputs) = integrityFn(integrityState, operand);
                assertEq(calcInputs, inputs.length, "inputs length");
                assertEq(calcInputs, Operand.unwrap(operand) >> 0x10, "operand inputs");

                // Make a copy of the inputs so that the reference function can't
                // modify what the real function sees.
                uint256[] memory inputsClone = new uint256[](inputs.length);
                LibMemCpy.unsafeCopyWordsTo(inputs.dataPointer(), inputsClone.dataPointer(), inputs.length);
                expectedOutputs = referenceFn(state, operand, inputsClone);
                assertEq(expectedOutputs.length, calcOutputs, "expected outputs length");
            }

            Pointer prePointer;
            Pointer postPointer;
            Pointer stackTop;
            Pointer expectedStackTopAfter;
            assembly ("memory-safe") {
                let headroom := 0x20
                if gt(calcOutputs, calcInputs) { headroom := add(headroom, mul(sub(calcOutputs, calcInputs), 0x20)) }
                postPointer := mload(0x40)
                stackTop := add(postPointer, headroom)
                // Write the pre after the integrity check's inputs.
                prePointer := add(stackTop, mul(calcInputs, 0x20))
                expectedStackTopAfter := sub(add(stackTop, mul(calcInputs, 0x20)), mul(calcOutputs, 0x20))
                mstore(0x40, add(prePointer, 0x20))
            }
            pointers.pre = prePointer;
            pointers.post = postPointer;
            pointers.stackTop = stackTop;
            pointers.expectedStackTopAfter = expectedStackTopAfter;
            LibMemCpy.unsafeCopyWordsTo(inputs.dataPointer(), pointers.stackTop, inputs.length);
        }

        {
            // Pure reference functions don't modify the state.
            bytes32 stateFingerprintBefore = state.fingerprint();
            {
                pointers.pre.unsafeWriteWord(PRE);
                pointers.post.unsafeWriteWord(POST);
            }
            Pointer stackTopAfter = runFn(state, operand, pointers.stackTop);
            bytes32 stateFingerprintAfter = state.fingerprint();

            assertEq(stateFingerprintBefore, stateFingerprintAfter, "state fingerprint");
            assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(pointers.expectedStackTopAfter), "stack top after");
        }

        // Compare against reference values.
        {
            assertEq(PRE, pointers.pre.unsafeReadWord(), "pre");
            for (uint256 i = 0; i < expectedOutputs.length; i++) {
                console2.log("expectedOutputs[i]", expectedOutputs[i]);
                assertEq(expectedOutputs[i], pointers.expectedStackTopAfter.unsafeReadWord(), "value");
                pointers.expectedStackTopAfter = pointers.expectedStackTopAfter.unsafeAddWord();
            }
            assertEq(POST, pointers.post.unsafeReadWord(), "post");
        }
    }
}
