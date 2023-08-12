// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "rain.solmem/lib/LibMemCpy.sol";
import "rain.solmem/lib/LibUint256Array.sol";
import "rain.solmem/lib/LibPointer.sol";

import "./RainterpreterExpressionDeployerDeploymentTest.sol";
import "../../../src/lib/state/LibInterpreterStateNP.sol";

abstract contract OpTest is RainterpreterExpressionDeployerDeploymentTest {
    using LibInterpreterStateNP for InterpreterStateNP;
    using LibUint256Array for uint256[];
    using LibPointer for Pointer;

    function calcPrePost(uint256 seed) internal pure returns (uint256 pre, uint256 post) {
        pre = uint256(keccak256(abi.encodePacked(seed)));
        post = uint256(keccak256(abi.encodePacked(pre)));
    }

    function opReferenceCheck(
        InterpreterStateNP memory state,
        uint256 seed,
        Operand operand,
        function(Operand, uint256[] memory) view returns (uint256[] memory) referenceFn,
        function(IntegrityCheckStateNP memory, Operand) pure returns (uint256, uint256) integrityFn,
        function(InterpreterStateNP memory, Operand, Pointer) view returns (Pointer) runFn,
        uint256[] memory inputs
    ) internal {
        uint256[] memory expectedOutputs;

        Pointer stackTop;
        Pointer expectedStackTopAfter;
        Pointer prePointer;
        Pointer postPointer;

        {
            uint256 calcInputs;
            uint256 calcOutputs;
            {
                IntegrityCheckStateNP memory integrityState = LibIntegrityCheckNP.newState("", 0, 0);
                (calcInputs, calcOutputs) = integrityFn(integrityState, operand);
                assertEq(calcInputs, inputs.length, "inputs length");
                assertEq(calcInputs, Operand.unwrap(operand) >> 0x10, "operand inputs");

                // Make a copy of the inputs so that the reference function can't
                // modify what the real function sees.
                uint256[] memory inputsClone = new uint256[](inputs.length);
                LibMemCpy.unsafeCopyWordsTo(inputs.dataPointer(), inputsClone.dataPointer(), inputs.length);
                expectedOutputs = referenceFn(operand, inputsClone);
                assertEq(expectedOutputs.length, calcOutputs, "expected outputs length");
            }

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
            LibMemCpy.unsafeCopyWordsTo(inputs.dataPointer(), stackTop, inputs.length);
        }

        {
            // Pure reference functions don't modify the state.
            bytes32 stateFingerprintBefore = state.fingerprint();
            {
                (uint256 pre, uint256 post) = calcPrePost(seed);
                prePointer.unsafeWriteWord(pre);
                postPointer.unsafeWriteWord(post);
            }
            Pointer stackTopAfter = runFn(state, operand, stackTop);
            bytes32 stateFingerprintAfter = state.fingerprint();

            assertEq(stateFingerprintBefore, stateFingerprintAfter, "state fingerprint");
            assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(expectedStackTopAfter), "stack top after");
        }

        // Compare against reference values.
        {
            (uint256 pre, uint256 post) = calcPrePost(seed);
            assertEq(pre, prePointer.unsafeReadWord(), "pre");
            for (uint256 i = 0; i < expectedOutputs.length; i++) {
                console2.log("expectedOutputs[i]", expectedOutputs[i]);
                assertEq(expectedOutputs[i], expectedStackTopAfter.unsafeReadWord(), "value");
                expectedStackTopAfter = expectedStackTopAfter.unsafeAddWord();
            }
            assertEq(post, postPointer.unsafeReadWord(), "post");
        }
    }
}
