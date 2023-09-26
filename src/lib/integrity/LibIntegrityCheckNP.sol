// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import "../../interface/IInterpreterV1.sol";
import "../../lib/bytecode/LibBytecode.sol";

/// @dev There are more entrypoints defined by the minimum stack outputs than
/// there are provided sources. This means the calling contract WILL attempt to
/// eval a dangling reference to a non-existent source at some point, so this
/// MUST REVERT.
error EntrypointMissing(uint256 expectedEntrypoints, uint256 actualEntrypoints);

/// Thrown when some entrypoint has non-zero inputs. This is not allowed as
/// only internal dispatches can have source level inputs.
error EntrypointNonZeroInput(uint256 entrypointIndex, uint256 inputsLength);

/// Thrown when some entrypoint has less outputs than the minimum required.
error EntrypointMinOutputs(uint256 entrypointIndex, uint256 outputsLength, uint256 minOutputs);

/// The bytecode and integrity function disagree on number of inputs.
error BadOpInputsLength(uint256 opIndex, uint256 calculatedInputs, uint256 bytecodeInputs);

/// The stack underflowed during integrity check.
error StackUnderflow(uint256 opIndex, uint256 stackIndex, uint256 calculatedInputs);

/// The stack underflowed the highwater during integrity check.
error StackUnderflowHighwater(uint256 opIndex, uint256 stackIndex, uint256 stackHighwater);

/// The bytecode stack allocation does not match the allocation calculated by
/// the integrity check.
error StackAllocationMismatch(uint256 stackMaxIndex, uint256 bytecodeAllocation);

/// The final stack index does not match the bytecode outputs.
error StackOutputsMismatch(uint256 stackIndex, uint256 bytecodeOutputs);

struct IntegrityCheckStateNP {
    uint256 stackIndex;
    uint256 stackMaxIndex;
    uint256 readHighwater;
    uint256 constantsLength;
    uint256 opIndex;
    bytes bytecode;
}

library LibIntegrityCheckNP {
    using LibIntegrityCheckNP for IntegrityCheckStateNP;

    function newState(bytes memory bytecode, uint256 stackIndex, uint256 constantsLength)
        internal
        pure
        returns (IntegrityCheckStateNP memory)
    {
        return IntegrityCheckStateNP(
            // stackIndex
            stackIndex,
            // stackMaxIndex
            stackIndex,
            // highwater (source inputs are always immutable)
            stackIndex,
            // constantsLength
            constantsLength,
            // opIndex
            0,
            // bytecode
            bytecode
        );
    }

    // The cyclomatic complexity here comes from all the `if` checks for each
    // integrity check. While the scanner isn't wrong, if we broke the checks
    // out into functions it would be a mostly superficial reduction in
    // complexity, and would make the code harder to read, as well as cost gas.
    //slither-disable-next-line cyclomatic-complexity
    function integrityCheck(
        bytes memory fPointers,
        bytes memory bytecode,
        uint256[] memory constants,
        uint256[] memory minOutputs
    ) internal view {
        unchecked {
            uint256 sourceCount = LibBytecode.sourceCount(bytecode);

            // Ensure that we are not missing any entrypoints expected by the calling
            // contract.
            if (minOutputs.length > sourceCount) {
                revert EntrypointMissing(minOutputs.length, sourceCount);
            }

            uint256 fPointersStart;
            assembly {
                fPointersStart := add(fPointers, 0x20)
            }

            // Ensure that the bytecode has no out of bounds pointers BEFORE we
            // start attempting to iterate over opcodes. This ensures the
            // integrity of the source count, relative offset pointers,
            // ops count per source, and that there is no garbage bytes at the
            // end or between these things. Basically everything structural about
            // the bytecode is confirmed here.
            LibBytecode.checkNoOOBPointers(bytecode);

            // Run the integrity check over each source. This needs to ensure
            // the integrity of each source's inputs, outputs, and stack
            // allocation, as well as the integrity of the bytecode itself on
            // a per-opcode basis, according to each opcode's implementation.
            for (uint256 i = 0; i < sourceCount; i++) {
                (uint256 inputsLength, uint256 outputsLength) = LibBytecode.sourceInputsOutputsLength(bytecode, i);

                // This is an entrypoint so has additional restrictions.
                if (i < minOutputs.length) {
                    if (inputsLength != 0) {
                        revert EntrypointNonZeroInput(i, inputsLength);
                    }

                    if (outputsLength < minOutputs[i]) {
                        revert EntrypointMinOutputs(i, outputsLength, minOutputs[i]);
                    }
                }

                IntegrityCheckStateNP memory state =
                    LibIntegrityCheckNP.newState(bytecode, inputsLength, constants.length);

                // Have low 4 bytes of cursor overlap the first op, skipping the
                // prefix.
                uint256 cursor = Pointer.unwrap(LibBytecode.sourcePointer(bytecode, i)) - 0x18;
                uint256 end = cursor + LibBytecode.sourceOpsCount(bytecode, i) * 4;

                while (cursor < end) {
                    Operand operand;
                    uint256 bytecodeOpInputs;
                    function(IntegrityCheckStateNP memory, Operand)
                    view
                    returns (uint256, uint256) f;
                    assembly ("memory-safe") {
                        let word := mload(cursor)
                        f := shr(0xf0, mload(add(fPointersStart, mul(byte(28, word), 2))))
                        // 3 bytes mask.
                        operand := and(word, 0xFFFFFF)
                        bytecodeOpInputs := byte(29, word)
                    }
                    (uint256 calcOpInputs, uint256 calcOpOutputs) = f(state, operand);
                    if (calcOpInputs != bytecodeOpInputs) {
                        revert BadOpInputsLength(state.opIndex, calcOpInputs, bytecodeOpInputs);
                    }

                    if (calcOpInputs > state.stackIndex) {
                        revert StackUnderflow(state.opIndex, state.stackIndex, calcOpInputs);
                    }
                    state.stackIndex -= calcOpInputs;

                    // The stack index can't move below the highwater.
                    if (state.stackIndex < state.readHighwater) {
                        revert StackUnderflowHighwater(state.opIndex, state.stackIndex, state.readHighwater);
                    }

                    // Let's assume that sane opcode implementations don't
                    // overflow uint256 due to their outputs.
                    state.stackIndex += calcOpOutputs;

                    // Ensure the max stack index is updated if needed.
                    if (state.stackIndex > state.stackMaxIndex) {
                        state.stackMaxIndex = state.stackIndex;
                    }

                    // If there are multiple outputs the highwater MUST move.
                    if (calcOpOutputs > 1) {
                        state.readHighwater = state.stackIndex;
                    }

                    state.opIndex++;
                    cursor += 4;
                }

                // The final stack max index MUST match the bytecode allocation.
                if (state.stackMaxIndex != LibBytecode.sourceStackAllocation(bytecode, i)) {
                    revert StackAllocationMismatch(state.stackMaxIndex, LibBytecode.sourceStackAllocation(bytecode, i));
                }

                // The final stack index MUST match the bytecode source outputs.
                if (state.stackIndex != outputsLength) {
                    revert StackOutputsMismatch(state.stackIndex, outputsLength);
                }
            }
        }
    }
}
