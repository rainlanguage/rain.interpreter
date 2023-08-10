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

    function opReferenceCheck(
        InterpreterStateNP memory state,
        uint256 seed,
        function(uint256[] memory) pure returns (uint256) referenceFn,
        function(IntegrityCheckStateNP memory, Operand) pure returns (uint256, uint256) integrityFn,
        function(InterpreterStateNP memory, Operand, Pointer) pure returns (Pointer) runFn,
        uint256[] memory inputs
    ) internal {
        Pointer stackTop;
        Pointer expectedStackTopAfter;
        Pointer prePointer;
        Pointer postPointer;
        uint256 pre;
        uint256 post;
        {
            pre = uint256(keccak256(abi.encodePacked(seed)));
            post = uint256(keccak256(abi.encodePacked(pre)));
            Operand operand = Operand.wrap(uint256(inputs.length) << 0x10);

            IntegrityCheckStateNP memory integrityState = LibIntegrityCheckNP.newState("", 0, 0);
            (uint256 calcInputs, uint256 calcOutputs) = integrityFn(integrityState, operand);
            assertEq(calcInputs, inputs.length, "inputs length");
            assertEq(calcOutputs, 1, "outputs length");

            assembly ("memory-safe") {
                let headroom := 0x20
                if gt(calcOutputs, calcInputs) { headroom := add(headroom, mul(sub(calcOutputs, calcInputs), 0x20)) }
                postPointer := mload(0x40)
                mstore(postPointer, post)
                stackTop := add(postPointer, headroom)
                // Write the pre after the integrity check's inputs.
                prePointer := add(stackTop, mul(calcInputs, 0x20))
                mstore(prePointer, pre)
                expectedStackTopAfter := sub(add(stackTop, mul(calcInputs, 0x20)), mul(calcOutputs, 0x20))
                mstore(0x40, add(prePointer, 0x20))
            }

            LibMemCpy.unsafeCopyWordsTo(inputs.dataPointer(), stackTop, inputs.length);
        }

        {
            // Pure reference functions don't modify the state.
            bytes32 stateFingerprintBefore = state.fingerprint();
            Pointer stackTopAfter = runFn(state, Operand.wrap(inputs.length << 0x10), stackTop);
            bytes32 stateFingerprintAfter = state.fingerprint();

            assertEq(stateFingerprintBefore, stateFingerprintAfter, "state fingerprint");
            assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(expectedStackTopAfter), "stack top after");
        }

        // Compare against reference values.
        {
            uint256 expectedValue = referenceFn(inputs);
            assertEq(pre, prePointer.unsafeReadWord(), "pre");
            assertEq(expectedValue, expectedStackTopAfter.unsafeReadWord(), "value");
            assertEq(post, postPointer.unsafeReadWord(), "post");
        }
    }
}
