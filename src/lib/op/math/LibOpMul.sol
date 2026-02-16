// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";
import {LibDecimalFloatImplementation} from "rain.math.float/lib/implementation/LibDecimalFloatImplementation.sol";

/// @title LibOpMul
/// Opcode to multiply N decimal floating point values.
library LibOpMul {
    using LibDecimalFloat for Float;

    /// `mul` integrity check. Requires at least 2 inputs and produces 1 output.
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
        (int256 signedCoefficient, int256 exponent) = a.unpack();
        (int256 signedCoefficientB, int256 exponentB) = b.unpack();
        (signedCoefficient, exponent) =
            LibDecimalFloatImplementation.mul(signedCoefficient, exponent, signedCoefficientB, exponentB);

        {
            uint256 inputs = uint256(OperandV2.unwrap(operand) >> 0x10) & 0x0F;
            uint256 i = 2;
            while (i < inputs) {
                assembly ("memory-safe") {
                    b := mload(stackTop)
                    stackTop := add(stackTop, 0x20)
                }
                (signedCoefficientB, exponentB) = b.unpack();
                (signedCoefficient, exponent) =
                    LibDecimalFloatImplementation.mul(signedCoefficient, exponent, signedCoefficientB, exponentB);
                unchecked {
                    i++;
                }
            }
        }

        //slither-disable-next-line unused-return
        (a,) = LibDecimalFloat.packLossy(signedCoefficient, exponent);
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
            Float acc = Float.wrap(StackItem.unwrap(inputs[0]));
            (int256 signedCoefficient, int256 exponent) = acc.unpack();
            for (uint256 i = 1; i < inputs.length; i++) {
                Float b = Float.wrap(StackItem.unwrap(inputs[i]));
                (int256 signedCoefficientB, int256 exponentB) = b.unpack();
                (signedCoefficient, exponent) =
                    LibDecimalFloatImplementation.mul(signedCoefficient, exponent, signedCoefficientB, exponentB);
            }

            bool lossless;
            (acc, lossless) = LibDecimalFloat.packLossy(signedCoefficient, exponent);
            (lossless);

            outputs = new StackItem[](1);
            outputs[0] = StackItem.wrap(Float.unwrap(acc));

            return outputs;
        }
    }
}
