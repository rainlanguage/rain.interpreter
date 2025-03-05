// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpEveryNP
/// @notice Opcode to return the last item out of N items if they are all true,
/// else 0.
library LibOpEveryNP {
    function integrity(IntegrityCheckState memory, OperandV2 operand) internal pure returns (uint256, uint256) {
        // There must be at least one input.
        uint256 inputs = uint256((OperandV2.unwrap(operand) >> 0x10) & bytes32(uint256(0x0F)));
        inputs = inputs > 0 ? inputs : 1;
        return (inputs, 1);
    }

    /// EVERY is the last nonzero item, else 0.
    function run(InterpreterState memory, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            let length := mul(and(shr(0x10, operand), 0x0F), 0x20)
            let cursor := stackTop
            stackTop := sub(add(stackTop, length), 0x20)
            for { let end := add(cursor, length) } lt(cursor, end) { cursor := add(cursor, 0x20) } {
                let item := mload(cursor)
                if iszero(item) {
                    mstore(stackTop, item)
                    break
                }
            }
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of EVERY for testing.
    function referenceFn(InterpreterState memory, OperandV2, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        // Zero length inputs is not supported so this 0 will always be written
        // over.
        uint256 value = 0;
        for (uint256 i = 0; i < inputs.length; i++) {
            value = inputs[i];
            if (value == 0) {
                break;
            }
        }
        outputs = new uint256[](1);
        outputs[0] = value;
    }
}
