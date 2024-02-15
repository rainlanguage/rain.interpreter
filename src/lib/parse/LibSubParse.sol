// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {LibParseState, ParseState} from "./LibParseState.sol";
import {
    OPCODE_UNKNOWN,
    OPCODE_EXTERN,
    OPCODE_CONSTANT,
    OPCODE_CONTEXT,
    Operand
} from "../../interface/unstable/IInterpreterV2.sol";
import {LibBytecode, Pointer} from "../bytecode/LibBytecode.sol";
import {ISubParserV2, COMPATIBLITY_V3} from "../../interface/unstable/ISubParserV2.sol";
import {BadSubParserResult, UnknownWord, UnsupportedLiteralType} from "../../error/ErrParse.sol";
import {LibExtern, EncodedExternDispatch} from "../extern/LibExtern.sol";
import {IInterpreterExternV3} from "../../interface/unstable/IInterpreterExternV3.sol";
import {ExternDispatchConstantsHeightOverflow} from "../../error/ErrSubParse.sol";
import {LibMemCpy} from "rain.solmem/lib/LibMemCpy.sol";
import {LibParseError} from "./LibParseError.sol";

library LibSubParse {
    using LibParseState for ParseState;
    using LibParseError for ParseState;

    /// Sub parse a word into a context grid position.
    function subParserContext(uint256 column, uint256 row)
        internal
        pure
        returns (bool, bytes memory, uint256[] memory)
    {
        bytes memory bytecode;
        uint256 opIndex = OPCODE_CONTEXT;
        assembly ("memory-safe") {
            // Allocate the bytecode.
            // This is an UNALIGNED allocation.
            bytecode := mload(0x40)
            mstore(0x40, add(bytecode, 0x24))

            // The caller is responsible for ensuring the column and row are
            // within `uint8`.
            mstore8(add(bytecode, 0x23), column)
            mstore8(add(bytecode, 0x22), row)

            // 0 inputs 1 output.
            mstore8(add(bytecode, 0x21), 0x10)

            mstore8(add(bytecode, 0x20), opIndex)

            // Write the length of the bytes.
            mstore(bytecode, 4)
        }

        uint256[] memory constants;
        assembly ("memory-safe") {
            constants := mload(0x40)
            mstore(0x40, add(constants, 0x20))
            mstore(constants, 0)
        }

        return (true, bytecode, constants);
    }

    /// Sub parse a value into the bytecode that will run on the interpreter to
    /// push the given value onto the stack, using the constant opcode at eval.
    function subParserConstant(uint256 constantsHeight, uint256 value)
        internal
        pure
        returns (bool, bytes memory, uint256[] memory)
    {
        // Build a constant opcode that the interpreter will run itself.
        bytes memory bytecode;
        uint256 opIndex = OPCODE_CONSTANT;
        assembly ("memory-safe") {
            // Allocate the bytecode.
            // This is an UNALIGNED allocation.
            bytecode := mload(0x40)
            mstore(0x40, add(bytecode, 0x24))

            // It's most efficient to store the constants height first, as it
            // is in theory multibyte (although it's not expected to be).
            // This also has the effect of zeroing out the inputs, which is what
            // we want, as long as the main parser respects the constants height
            // never being more than 2 bytes.
            mstore(add(bytecode, 4), constantsHeight)

            // 0 inputs 1 output.
            mstore8(add(bytecode, 0x21), 0x10)

            // Main opcode is constant.
            mstore8(add(bytecode, 0x20), opIndex)

            // Write the length of the bytes.
            mstore(bytecode, 4)
        }

        uint256[] memory constants;
        assembly ("memory-safe") {
            constants := mload(0x40)
            mstore(0x40, add(constants, 0x40))
            mstore(constants, 1)
            mstore(add(constants, 0x20), value)
        }

        return (true, bytecode, constants);
    }

    /// Sub parse a known extern opcode index into the bytecode that will run
    /// on the interpreter to call the given extern contract. This requires the
    /// parsing has already matched a word to the extern opcode index, so it
    /// implies the parse meta has been traversed and the parse index has been
    /// mapped to an extern opcode index somehow.
    function subParserExtern(
        IInterpreterExternV3 extern,
        uint256 constantsHeight,
        uint256 ioByte,
        Operand operand,
        uint256 opcodeIndex
    ) internal pure returns (bool, bytes memory, uint256[] memory) {
        // The constants height is an error check because the main parser can
        // provide two bytes for it. Everything else is expected to be more
        // directly controlled by the subparser itself.
        if (constantsHeight > 0xFFFF) {
            revert ExternDispatchConstantsHeightOverflow(constantsHeight);
        }
        // Build an extern call that dials back into the current contract at eval
        // time with the current opcode index.
        bytes memory bytecode;
        uint256 opIndex = OPCODE_EXTERN;
        assembly ("memory-safe") {
            // Allocate the bytecode.
            // This is an UNALIGNED allocation.
            bytecode := mload(0x40)
            mstore(0x40, add(bytecode, 0x24))
            mstore(add(bytecode, 4), constantsHeight)
            // The IO byte is inputs merged with outputs.
            mstore8(add(bytecode, 0x21), ioByte)
            // Main opcode is extern, to call back into current contract.
            mstore8(add(bytecode, 0x20), opIndex)
            // The bytes length is 4.
            mstore(bytecode, 4)
        }

        uint256 externDispatch = EncodedExternDispatch.unwrap(
            LibExtern.encodeExternCall(extern, LibExtern.encodeExternDispatch(opcodeIndex, operand))
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

    function subParseWordSlice(ParseState memory state, uint256 cursor, uint256 end) internal pure {
        unchecked {
            for (; cursor < end; cursor += 4) {
                uint256 memoryAtCursor;
                assembly ("memory-safe") {
                    memoryAtCursor := mload(cursor)
                }
                if (memoryAtCursor >> 0xf8 == OPCODE_UNKNOWN) {
                    uint256 deref = state.subParsers;
                    while (deref != 0) {
                        ISubParserV2 subParser = ISubParserV2(address(uint160(deref)));
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
                            subParser.subParseWord(COMPATIBLITY_V3, data);
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
                                state.pushConstantValue(subConstants[i]);
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

    function subParseWords(ParseState memory state, bytes memory bytecode)
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
                subParseWordSlice(state, cursor, end);
            }
            return (bytecode, state.buildConstants());
        }
    }

    function subParseLiteral(
        ParseState memory state,
        uint256 dispatchStart,
        uint256 dispatchEnd,
        uint256 bodyStart,
        uint256 bodyEnd
    ) internal pure returns (uint256) {
        unchecked {
            // Build the data for the subparser.
            bytes memory data;
            {
                uint256 copyPointer;
                uint256 dispatchLength = dispatchEnd - dispatchStart;
                uint256 bodyLength = bodyEnd - bodyStart;
                {
                    uint256 dataLength = 2 + dispatchLength + bodyLength;
                    assembly ("memory-safe") {
                        data := mload(0x40)
                        mstore(0x40, add(data, add(dataLength, 0x20)))
                        mstore(add(data, 2), dispatchLength)
                        mstore(data, dataLength)
                        copyPointer := add(data, 0x22)
                    }
                }
                LibMemCpy.unsafeCopyBytesTo(Pointer.wrap(dispatchStart), Pointer.wrap(copyPointer), dispatchLength);
                LibMemCpy.unsafeCopyBytesTo(
                    Pointer.wrap(bodyStart), Pointer.wrap(copyPointer + dispatchLength), bodyLength
                );
            }

            uint256 deref = state.subParsers;
            while (deref != 0) {
                ISubParserV2 subParser = ISubParserV2(address(uint160(deref)));
                assembly ("memory-safe") {
                    deref := mload(shr(0xf0, deref))
                }

                (bool success, uint256 value) = subParser.subParseLiteral(COMPATIBLITY_V3, data);
                if (success) {
                    return value;
                }
            }

            revert UnsupportedLiteralType(state.parseErrorOffset(dispatchStart));
        }
    }

    function consumeSubParseWordInputData(bytes memory data, bytes memory meta, bytes memory operandHandlers)
        internal
        pure
        returns (uint256 constantsHeight, uint256 ioByte, ParseState memory state)
    {
        uint256[] memory operandValues;
        assembly ("memory-safe") {
            // Pull the header out into EVM stack items.
            constantsHeight := and(mload(add(data, 2)), 0xFFFF)
            ioByte := and(mload(add(data, 3)), 0xFF)

            // Mutate the data to no longer have a header.
            let newLength := and(mload(add(data, 5)), 0xFFFF)
            data := add(data, 5)
            mstore(data, newLength)
            operandValues := add(data, add(newLength, 0x20))
        }
        // Literal parsers are empty for the sub parser as the main parser should
        // be handling all literals in operands. The sub parser handles literal
        // parsing as a dedicated interface seperately.
        state = LibParseState.newState(data, meta, operandHandlers, "");
        state.operandValues = operandValues;
    }

    function consumeSubParseLiteralInputData(bytes memory data)
        internal
        pure
        returns (uint256 dispatchStart, uint256 bodyStart, uint256 bodyEnd)
    {
        assembly ("memory-safe") {
            let dispatchLength := and(mload(add(data, 2)), 0xFFFF)
            dispatchStart := add(data, 0x22)
            bodyStart := add(dispatchStart, dispatchLength)
            bodyEnd := add(data, add(0x20, mload(data)))
        }
    }
}
