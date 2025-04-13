// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2, StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {PackedFloat, LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpEqualTo
/// @notice Opcode to return 1 if the first item on the stack is equal to
/// the second item on the stack, else 0. Equality is defined as decimal float
/// equality, so 1.0 == 1 etc.
library LibOpEqualTo {
    using LibDecimalFloat for Float;

    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        return (2, 1);
    }

    /// Float equality
    /// Float equality is 1 if the first item is equal to the second item,
    /// else 0. Equality is defined as decimal float equality.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        PackedFloat a;
        PackedFloat b;

        assembly ("memory-safe") {
            a := mload(stackTop)
            stackTop := add(stackTop, 0x20)
            b := mload(stackTop)
        }

        (int256 signedCoefficientA, int256 exponentA) = LibDecimalFloat.unpack(a);
        (int256 signedCoefficientB, int256 exponentB) = LibDecimalFloat.unpack(b);

        bool areEqual = LibDecimalFloat.eq(signedCoefficientA, exponentA, signedCoefficientB, exponentB);

        assembly ("memory-safe") {
            mstore(stackTop, areEqual)
        }

        return stackTop;
    }

    /// Gas intensive reference implementation of float equal for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory outputs)
    {
        PackedFloat a = PackedFloat.wrap(StackItem.unwrap(inputs[0]));
        PackedFloat b = PackedFloat.wrap(StackItem.unwrap(inputs[1]));

        Float memory floatA = LibDecimalFloat.unpackMem(a);
        Float memory floatB = LibDecimalFloat.unpackMem(b);

        outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(bytes32(uint256(floatA.eq(floatB) ? 1 : 0)));
    }
}
