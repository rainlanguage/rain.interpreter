// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Operand} from "../../../../interface/unstable/IInterpreterV2.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterStateNP} from "../../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpIntAddNP
/// @notice Opcode to add N integers. Errors on overflow.
library LibOpIntAddNP {
    function integrity(IntegrityCheckStateNP memory, Operand operand) internal pure returns (uint256, uint256) {
        // There must be at least two inputs.
        uint256 inputs = Operand.unwrap(operand) >> 0x10;
        inputs = inputs > 1 ? inputs : 2;
        return (inputs, 1);
    }

    /// int-add
    /// Addition with implied overflow checks from the Solidity 0.8.x compiler.
    function run(InterpreterStateNP memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 a;
        uint256 b;
        assembly ("memory-safe") {
            a := mload(stackTop)
            b := mload(add(stackTop, 0x20))
            stackTop := add(stackTop, 0x40)
        }
        a += b;

        {
            uint256 inputs = Operand.unwrap(operand) >> 0x10;
            uint256 i = 2;
            while (i < inputs) {
                assembly ("memory-safe") {
                    b := mload(stackTop)
                    stackTop := add(stackTop, 0x20)
                }
                a += b;
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

    function integrityExtern(Operand, uint256 inputs, uint256) internal pure returns (uint256, uint256) {
        inputs = inputs > 1 ? inputs : 2;
        return (inputs, 1);
    }

    function runExtern(Operand, uint256[] memory inputs) internal pure returns (uint256[] memory) {
        uint256 acc = inputs[0];
        for (uint256 i = 1; i < inputs.length; i++) {
            acc += inputs[i];
        }
        uint256[] memory outputs = new uint256[](1);
        outputs[0] = acc;
        return outputs;
    }

    /// Gas intensive reference implementation of addition for testing.
    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        // Unchecked so that when we assert that an overflow error is thrown, we
        // see the revert from the real function and not the reference function.
        unchecked {
            uint256 acc = inputs[0];
            for (uint256 i = 1; i < inputs.length; i++) {
                acc += inputs[i];
            }
            outputs = new uint256[](1);
            outputs[0] = acc;
        }
    }
}
