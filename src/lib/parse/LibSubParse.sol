// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {LibParseState, ParseState} from "./LibParseState.sol";
import {OPCODE_UNKNOWN, OPCODE_EXTERN, Operand} from "../../interface/unstable/IInterpreterV2.sol";
import {LibBytecode, Pointer} from "../bytecode/LibBytecode.sol";
import {ISubParserV1, COMPATIBLITY_V0} from "../../interface/unstable/ISubParserV1.sol";
import {BadSubParserResult, UnknownWord} from "../../error/ErrParse.sol";
import {LibExtern, EncodedExternDispatch} from "../extern/LibExtern.sol";
import {IInterpreterExternV3} from "../../interface/unstable/IInterpreterExternV3.sol";

library LibSubParse {
    using LibParseState for ParseState;

    function subParserExtern(uint256 constantsHeight, uint256 inputsByte, Operand operand, uint256 opcodeIndex)
        internal
        view
        returns (bool, bytes memory, uint256[] memory)
    {
        // Build an extern call that dials back into the current contract at eval
        // time with the current opcode index.
        bytes memory bytecode = new bytes(4);
        uint256 opIndex = OPCODE_EXTERN;
        assembly ("memory-safe") {
            // Main opcode is extern, to call back into current contract.
            mstore8(add(bytecode, 0x20), opIndex)
            // Use the io byte as is for inputs.
            mstore8(add(bytecode, 0x21), inputsByte)
            // The outputs are the same as inputs for inc.
            mstore8(add(bytecode, 0x22), inputsByte)
            // The extern dispatch is the index to the new constant that we will
            // add to the constants array.
            mstore8(add(bytecode, 0x23), constantsHeight)
        }

        uint256 externDispatch = EncodedExternDispatch.unwrap(
            LibExtern.encodeExternCall(
                IInterpreterExternV3(address(this)), LibExtern.encodeExternDispatch(opcodeIndex, operand)
            )
        );

        uint256[] memory constants;
        assembly ("memory-safe") {
            constants := mload(0x40)
            mstore(0x40, add(constants, 0x40))
            mstore(constants, 1)
            mstore(add(constants, 0x20), externDispatch)
        }

        return (true, bytecode, constants);
    }

    function subParseSlice(ParseState memory state, uint256 cursor, uint256 end) internal pure {
        unchecked {
            for (; cursor < end; cursor += 4) {
                uint256 memoryAtCursor;
                assembly ("memory-safe") {
                    memoryAtCursor := mload(cursor)
                }
                if (memoryAtCursor >> 0xf8 == OPCODE_UNKNOWN) {
                    uint256 deref = state.subParsers;
                    while (deref != 0) {
                        ISubParserV1 subParser = ISubParserV1(address(uint160(deref)));
                        assembly ("memory-safe") {
                            deref := mload(shr(0xf0, deref))
                        }

                        // Subparse data is a fixed length header that provides the
                        // subparser some minimal additional contextual information
                        // then the rest of the data is the original string that the
                        // main parser could not understand.
                        // The header is:
                        // - 2 bytes: The current constant builder height. MAY be
                        //   used by the subparser to calculate indexes for the
                        //   constants it pushes.
                        // - 1 byte: The IO byte from the unknown op. MAY be used
                        //   by the subparser to calculate the IO byte for the op
                        //   it builds.
                        bytes memory data;
                        // The operand of the unknown opcode directly points at the
                        // data that we need to subparse.
                        assembly ("memory-safe") {
                            data := and(shr(0xe0, memoryAtCursor), 0xFFFF)
                        }
                        // We just need to fill in the header.
                        {
                            uint256 constantsBuilder = state.constantsBuilder;
                            assembly ("memory-safe") {
                                let header :=
                                    shl(
                                        0xe8,
                                        or(
                                            // IO byte is the second byte of the unknown op.
                                            byte(1, memoryAtCursor),
                                            // Constants builder height is the low 16 bits.
                                            shl(8, and(constantsBuilder, 0xFFFF))
                                        )
                                    )

                                let headerPtr := add(data, 0x20)
                                mstore(headerPtr, or(header, and(mload(headerPtr), not(shl(0xe8, 0xFFFFFF)))))
                            }
                        }

                        (bool success, bytes memory subBytecode, uint256[] memory subConstants) =
                            subParser.subParse(COMPATIBLITY_V0, data);
                        if (success) {
                            // The sub bytecode must be exactly 4 bytes to
                            // represent an op.
                            if (subBytecode.length != 4) {
                                revert BadSubParserResult(subBytecode);
                            }

                            {
                                // Copy the sub bytecode over the unknown op.
                                uint256 mask = 0xFFFFFFFF << 0xe0;
                                assembly ("memory-safe") {
                                    mstore(
                                        cursor,
                                        or(and(memoryAtCursor, not(mask)), and(mload(add(subBytecode, 0x20)), mask))
                                    )
                                }
                            }

                            for (uint256 i; i < subConstants.length; ++i) {
                                // Use 0 as a fingerprint as the literal
                                // deduping logic is irrelevant to
                                // subparsing. This is safe as long as
                                // nothing that wants to dedupe could collide
                                // with a 0 fingerprint.
                                state.pushConstantValue(0, subConstants[i]);
                            }

                            // Stop looping over sub parsers now.
                            break;
                        }
                    }
                }

                // If the op was not replaced, then we need to error because we have
                // no idea what it is.
                assembly ("memory-safe") {
                    memoryAtCursor := mload(cursor)
                }
                if (memoryAtCursor >> 0xf8 == OPCODE_UNKNOWN) {
                    revert UnknownWord();
                }
            }
        }
    }

    function subParse(ParseState memory state, bytes memory bytecode)
        internal
        pure
        returns (bytes memory, uint256[] memory)
    {
        unchecked {
            uint256 sourceCount = LibBytecode.sourceCount(bytecode);
            for (uint256 sourceIndex; sourceIndex < sourceCount; ++sourceIndex) {
                // Start cursor at the pointer to the source.
                uint256 cursor = Pointer.unwrap(LibBytecode.sourcePointer(bytecode, sourceIndex)) + 4;
                uint256 end = cursor + (LibBytecode.sourceOpsCount(bytecode, sourceIndex) * 4);
                subParseSlice(state, cursor, end);
            }
            return (bytecode, state.buildConstants());
        }
    }

    function consumeInputData(bytes memory data, bytes memory meta, uint256 literalParsers, uint256 operandParsers)
        internal
        pure
        returns (uint256 constantsHeight, uint256 ioByte, ParseState memory state)
    {
        assembly ("memory-safe") {
            // Pull the header out into EVM stack items.
            constantsHeight := and(mload(add(data, 2)), 0xFFFF)
            ioByte := and(mload(add(data, 3)), 0xFF)

            // Mutate the data to no longer have a header.
            let newLength := sub(mload(data), 3)
            data := add(data, 3)
            mstore(data, newLength)
        }
        state = LibParseState.newState(data, meta, literalParsers);
        state.operandParsers = operandParsers;
    }
}
