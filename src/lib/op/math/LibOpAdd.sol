// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";

import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpAdd
/// @notice Opcode to add N numbers. Errors on overflow.
library LibOpAdd {
    function integrity(IntegrityCheckState memory, OperandV2 operand) internal pure returns (uint256, uint256) {
        // There must be at least two inputs.
        uint256 inputs = uint256((OperandV2.unwrap(operand) >> 0x10) & bytes32(uint256(0x0F)));
        inputs = inputs > 1 ? inputs : 2;
        return (inputs, 1);
    }

    /// float add
    function run(InterpreterState memory, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
        Float a;
        Float b;
        assembly ("memory-safe") {
            a := mload(stackTop)
            b := mload(add(stackTop, 0x20))
            stackTop := add(stackTop, 0x40)
        }
        a = LibDecimalFloat.add(a, b);

        {
            uint256 inputs = uint256((OperandV2.unwrap(operand) >> 0x10) & bytes32(uint256(0x0F)));
            uint256 i = 2;
            while (i < inputs) {
                assembly ("memory-safe") {
                    b := mload(stackTop)
                    stackTop := add(stackTop, 0x20)
                }
                a = LibDecimalFloat.add(a, b);
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

    /// Gas intensive reference implementation of addition for testing.
    function referenceFn(InterpreterState memory, OperandV2, bytes32[] memory inputs)
        internal
        pure
        returns (bytes32[] memory outputs)
    {
        // Unchecked so that when we assert that an overflow error is thrown, we
        // see the revert from the real function and not the reference function.
        unchecked {
            Float acc = Float.wrap(inputs[0]);
            for (uint256 i = 1; i < inputs.length; i++) {
                acc = LibDecimalFloat.add(acc, Float.wrap(inputs[i]));
            }
            outputs = new bytes32[](1);
            outputs[0] = Float.unwrap(acc);
        }
    }
}
