// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "sol.lib.memory/LibPointer.sol";
import "sol.lib.memory/LibMemCpy.sol";
import "sol.lib.memory/LibBytes.sol";

import "../state/LibInterpreterState.sol";
import "../compile/LibCompile.sol";

library LibInterpreterStateDataContract {
    using LibBytes for bytes;

    function serializeSize(bytes[] memory sources, uint256[] memory constants) internal pure returns (uint256 size) {
        assembly ("memory-safe") {
            let sourcesLength := mload(sources)
            size := mul(0x20, add(sourcesLength, add(2, mload(constants))))

            for {
                let cursor := add(sources, 0x20)
                let end := add(cursor, mul(sourcesLength, 0x20))
            } lt(cursor, end) { cursor := add(cursor, 0x20) } { size := add(size, mload(mload(cursor))) }
        }
    }

    /// Efficiently serializes enough information to build `InterpreterState`
    /// without memory allocation or copying of data during deserialization.
    ///
    /// This is achieved by mutating data in place for both serialization and
    /// deserialization so it is much more gas efficient than abi encode/decode
    /// but is NOT SAFE to use any of the inputs after the serialization.
    ///
    /// Notably the index based opcodes in the `sources` will be compiled and
    /// replaced by function pointer based opcodes in place.
    ///
    /// @param cursor Pointer to memory to start the serialization.
    /// @param sources As per `IExpressionDeployerV1`.
    /// @param constants As per `IExpressionDeployerV1`.
    /// @param stackLength Stack length calculated by `IExpressionDeployerV1`
    /// that will be used to allocate memory for the stack upon deserialization.
    /// @param opcodeFunctionPointers As per `IInterpreterV1.functionPointers`,
    /// bytes to be compiled into the final `InterpreterState.compiledSources`.
    function unsafeSerialize(
        Pointer cursor,
        bytes[] memory sources,
        uint256[] memory constants,
        uint256 stackLength,
        bytes memory opcodeFunctionPointers
    ) internal pure {
        assembly ("memory-safe") {
            // Copy stack length.
            // Then constants length.
            mstore(cursor, stackLength)
            cursor := add(cursor, 0x20)

            // Copy constants with length.
            for {
                let constantsCursor := constants
                let constantsEnd := add(constants, add(0x20, mul(0x20, mload(constants))))
            } lt(constantsCursor, constantsEnd) {
                cursor := add(cursor, 0x20)
                constantsCursor := add(constantsCursor, 0x20)
            } { mstore(cursor, mload(constantsCursor)) }
        }
        // Last the sources.
        unchecked {
            uint256 sourcesCursor;
            uint256 sourcesEnd;
            assembly ("memory-safe") {
                sourcesCursor := add(sources, 0x20)
                sourcesEnd := add(sourcesCursor, mul(0x20, mload(sources)))
            }
            for (; sourcesCursor < sourcesEnd; sourcesCursor += 0x20) {
                bytes memory source;
                uint256 length;
                Pointer sourceData;
                assembly ("memory-safe") {
                    source := mload(sourcesCursor)
                    length := mload(source)
                    sourceData := add(0x20, source)

                    mstore(cursor, length)
                    cursor := add(cursor, 0x20)
                }
                LibCompile.unsafeCompile(source, opcodeFunctionPointers);
                LibMemCpy.unsafeCopyBytesTo(sourceData, cursor, length);
                assembly ("memory-safe") {
                    cursor := add(cursor, length)
                }
            }
        }
    }

    /// Return trip from `serialize` but targets an `InterpreterState` NOT a
    /// `ExpressionConfig`. Allows serialized bytes to be written directly into
    /// contract code on the other side of an expression address, then loaded
    /// directly into an eval-able memory layout. The only allocation required
    /// is to initialise the stack for eval, there is no copying in memory from
    /// the serialized data as the deserialization merely calculates Solidity
    /// compatible pointers to positions in the raw serialized data. This is much
    /// more gas efficient than an equivalent abi.decode call which would involve
    /// more processing, copying and allocating.
    ///
    /// Note that per-eval data such as namespace and context is NOT initialised
    /// by the deserialization process and so will need to be handled by the
    /// interpreter as part of `eval`.
    ///
    /// @param serialized Bytes previously serialized by
    /// `LibInterpreterState.serialize`.
    /// @return An eval-able interpreter state with initialized stack.
    function unsafeDeserialize(bytes memory serialized) internal pure returns (InterpreterState memory) {
        unchecked {
            InterpreterState memory state;

            // Context will probably be overridden by the caller according to the
            // context scratch that we deserialize so best to just set it empty
            // here.
            state.context = new uint256[][](0);

            Pointer cursor;
            Pointer end;
            assembly ("memory-safe") {
                cursor := add(serialized, 0x20)
                end := add(cursor, mload(serialized))
            }

            // Read the stack length and build a stack.
            Pointer stackBottom;
            assembly ("memory-safe") {
                let stackLength := mload(cursor)
                cursor := add(cursor, 0x20)

                // We don't need to zero the stack because the interpreter
                // assumes values above the stack top are dirty anyway.
                let stack := mload(0x40)
                mstore(stack, stackLength)
                stackBottom := add(stack, 0x20)
                mstore(0x40, add(stackBottom, mul(stackLength, 0x20)))
            }
            state.stackBottom = stackBottom;

            // Reference the constants array and move cursor past it.
            Pointer constantsBottom;
            assembly ("memory-safe") {
                let constantsLength := mload(cursor)
                constantsBottom := add(cursor, 0x20)
                cursor := add(constantsBottom, mul(constantsLength, 0x20))
            }
            state.constantsBottom = constantsBottom;

            // Rebuild the sources array.
            bytes[] memory compiledSources;
            assembly ("memory-safe") {
                compiledSources := mload(0x40)
                let length := 0
                let compiledSourcesCursor := add(compiledSources, 0x20)
                for {} lt(cursor, end) {
                    cursor := add(cursor, add(0x20, mload(cursor)))
                    compiledSourcesCursor := add(compiledSourcesCursor, 0x20)
                } {
                    mstore(compiledSourcesCursor, cursor)
                    length := add(length, 1)
                }
                mstore(compiledSources, length)
                mstore(0x40, compiledSourcesCursor)
            }
            state.compiledSources = compiledSources;

            return state;
        }
    }
}
