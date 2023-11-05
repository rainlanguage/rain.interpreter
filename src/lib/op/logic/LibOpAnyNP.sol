// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Operand} from "../../../interface/unstable/IInterpreterV2.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";

/// @title LibOpAnyNP
/// @notice Opcode to return the first nonzero item on the stack up to the inputs
/// limit.
library LibOpAnyNP {
    function integrity(IntegrityCheckStateNP memory, Operand operand) internal pure returns (uint256, uint256) {
        // There must be at least one input.
        uint256 inputs = Operand.unwrap(operand) >> 0x10;
        inputs = inputs > 0 ? inputs : 1;
        return (inputs, 1);
    }

    /// ANY
    /// ANY is the first nonzero item, else 0.
    function run(InterpreterStateNP memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            let length := mul(shr(0x10, operand), 0x20)
            let cursor := stackTop
            stackTop := sub(add(stackTop, length), 0x20)
            for { let end := add(cursor, length) } lt(cursor, end) { cursor := add(cursor, 0x20) } {
                let item := mload(cursor)
                if gt(item, 0) {
                    mstore(stackTop, item)
                    break
                }
            }
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of ANY for testing.
    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        // Zero length inputs is not supported so this 0 will always be written
        // over.
        uint256 value = 0;
        for (uint256 i = 0; i < inputs.length; i++) {
            value = inputs[i];
            if (value != 0) {
                break;
            }
        }
        outputs = new uint256[](1);
        outputs[0] = value;
    }
}
