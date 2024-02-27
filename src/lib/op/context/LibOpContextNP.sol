// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {Operand} from "rain.interpreter.interface/interface/unstable/IInterpreterV2.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";

library LibOpContextNP {
    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        // Context doesn't have any inputs. The operand defines the reads.
        // Unfortunately we don't know the shape of the context that we will
        // receive at runtime, so we can't check the reads at integrity time.
        return (0, 1);
    }

    function run(InterpreterStateNP memory state, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 i = Operand.unwrap(operand) & 0xFF;
        uint256 j = (Operand.unwrap(operand) >> 8) & 0xFF;
        // We want these indexes to be checked at runtime for OOB accesses
        // because we don't know the shape of the context at compile time.
        // Solidity handles that for us as long as we don't invoke yul for the
        // reads.
        if (Pointer.unwrap(stackTop) < 0x20) {
            revert("stack underflow");
        }
        uint256 v = state.context[i][j];
        assembly ("memory-safe") {
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, v)
        }
        return stackTop;
    }

    function referenceFn(InterpreterStateNP memory state, Operand operand, uint256[] memory)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        uint256 i = Operand.unwrap(operand) & 0xFF;
        uint256 j = (Operand.unwrap(operand) >> 8) & 0xFF;
        // We want these indexes to be checked at runtime for OOB accesses
        // because we don't know the shape of the context at compile time.
        // Solidity handles that for us as long as we don't invoke yul for the
        // reads.
        uint256 v = state.context[i][j];
        outputs = new uint256[](1);
        outputs[0] = v;
        return outputs;
    }
}
