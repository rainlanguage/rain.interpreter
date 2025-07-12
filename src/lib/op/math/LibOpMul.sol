// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {LibDecimalFloatImplementation} from "rain.math.float/lib/implementation/LibDecimalFloatImplementation.sol";

/// @title LibOpMul
/// @notice Opcode to mul N 18 floating point values.
library LibOpMul {
    function integrity(IntegrityCheckState memory, OperandV2 operand) internal pure returns (uint256, uint256) {
        // There must be at least two inputs.
        uint256 inputs = uint256(OperandV2.unwrap(operand) >> 0x10) & 0x0F;
        inputs = inputs > 1 ? inputs : 2;
        return (inputs, 1);
    }

    /// mul
    function run(InterpreterState memory, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
        Float a;
        Float b;
        assembly ("memory-safe") {
            a := mload(stackTop)
            b := mload(add(stackTop, 0x20))
            stackTop := add(stackTop, 0x40)
        }
        a = LibDecimalFloat.mul(a, b);

        {
            uint256 inputs = uint256(OperandV2.unwrap(operand) >> 0x10) & 0x0F;
            uint256 i = 2;
            while (i < inputs) {
                assembly ("memory-safe") {
                    b := mload(stackTop)
                    stackTop := add(stackTop, 0x20)
                }
                a = LibDecimalFloat.mul(a, b);
                unchecked {
                    i++;
                }
            }
        }
        assembly ("memory-safe") {
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, a)
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of multiplication for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory outputs)
    {
        // Unchecked so that when we assert that an overflow error is thrown, we
        // see the revert from the real function and not the reference function.
        unchecked {
            Float a;
            uint256 overflows = 0;
            (int256 signedCoefficientA, int256 exponentA) =
                LibDecimalFloat.unpack(Float.wrap(StackItem.unwrap(inputs[0])));
            if (int32(exponentA) != exponentA) {
                overflows++;
            }
            for (uint256 i = 1; i < inputs.length; i++) {
                (int256 signedCoefficientB, int256 exponentB) =
                    LibDecimalFloat.unpack(Float.wrap(StackItem.unwrap(inputs[i])));
                if (int32(exponentB) != exponentB) {
                    overflows++;
                    break;
                }

                (signedCoefficientA, exponentA) =
                    LibDecimalFloatImplementation.mul(signedCoefficientA, exponentA, signedCoefficientB, exponentB);

                if (int32(exponentA) != exponentA) {
                    overflows++;
                    break;
                }
            }
            outputs = new StackItem[](1);

            if (overflows > 0) {
                a = Float.wrap(keccak256(abi.encodePacked("overflow sentinel")));
            } else {
                a = LibDecimalFloat.packLossless(signedCoefficientA, exponentA);
            }

            outputs[0] = StackItem.wrap(Float.unwrap(a));

            return outputs;
        }
    }
}
