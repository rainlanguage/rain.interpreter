// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";
import "rain.solmem/lib/LibBytes.sol";
import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibUint256Array.sol";

import "src/lib/state/deprecated/LibInterpreterStateDataContract.sol";

import "test/lib/compile/LibCompileSlow.sol";
import "./LibInterpreterStateDataContractSlow.sol";

/// @title LibInterpreterStateDataContractTest
/// @notice Exercises the data contract implementation of the interpreter state.
/// It should be possible to round trip serialize and deserialize an interpreter
/// state through an onchain data contract.
contract LibInterpreterStateDataContractTest is Test {
    using LibBytes for bytes;
    using LibPointer for Pointer;
    using LibUint256Array for Pointer;

    function testSerializeSize(bytes[] memory sources, uint256[] memory constants, uint256 stackLength) public {
        assertEq(
            LibInterpreterStateDataContractSlow.serializeSizeSlow(sources, constants, stackLength),
            LibInterpreterStateDataContract.serializeSize(sources, constants)
        );
    }

    /// Exercises BOTH serialize and deserialize by round tripping inputs through
    /// fast and slow implementations.
    function compareSerialize(
        bytes[] memory sources,
        uint256[] memory constants,
        uint8 stackLength,
        bytes memory opcodeFunctionPointers
    ) internal {
        for (uint256 i = 0; i < sources.length; ++i) {
            LibCompileSlow.convertToOps(sources[i], opcodeFunctionPointers);
        }

        uint256 serializeSize = LibInterpreterStateDataContract.serializeSize(sources, constants);

        bytes memory serialized = new bytes(serializeSize);
        bytes memory serializedSlow = new bytes(serializeSize);

        bytes[] memory sourcesCopy = new bytes[](sources.length);
        bytes[] memory sourcesCompiled = new bytes[](sources.length);
        for (uint256 i = 0; i < sources.length; ++i) {
            bytes memory sourceCopy = new bytes(sources[i].length);
            LibMemCpy.unsafeCopyBytesTo(sources[i].dataPointer(), sourceCopy.dataPointer(), sources[i].length);
            sourcesCopy[i] = sourceCopy;

            bytes memory sourceCompiled = new bytes(sources[i].length);
            LibMemCpy.unsafeCopyBytesTo(sources[i].dataPointer(), sourceCompiled.dataPointer(), sources[i].length);
            LibCompile.unsafeCompile(sourceCompiled, opcodeFunctionPointers);
            sourcesCompiled[i] = sourceCompiled;
        }
        LibInterpreterStateDataContract.unsafeSerialize(
            serialized.dataPointer(), sourcesCopy, constants, stackLength, opcodeFunctionPointers
        );
        LibInterpreterStateDataContractSlow.serializeSlow(
            serializedSlow.dataPointer(), sources, constants, stackLength, opcodeFunctionPointers
        );

        assertEq(serialized, serializedSlow);

        InterpreterState memory deserialized = LibInterpreterStateDataContract.unsafeDeserialize(serialized);
        InterpreterState memory deserializedSlow = LibInterpreterStateDataContractSlow.deserializeSlow(serializedSlow);

        uint256[] memory deserializedStack = deserialized.stackBottom.unsafeSubWord().unsafeAsUint256Array();
        uint256[] memory deserializedStackSlow = deserializedSlow.stackBottom.unsafeSubWord().unsafeAsUint256Array();

        assertEq(deserializedStack, deserializedStackSlow);
        assertEq(deserializedStack, new uint256[](stackLength));

        uint256[] memory deserializedConstants = deserialized.constantsBottom.unsafeSubWord().unsafeAsUint256Array();
        uint256[] memory deserializedConstantsSlow =
            deserializedSlow.constantsBottom.unsafeSubWord().unsafeAsUint256Array();

        assertEq(deserializedConstants, deserializedConstantsSlow);
        assertEq(deserializedConstants, constants);

        assertEq(MemoryKV.unwrap(deserialized.stateKV), MemoryKV.unwrap(deserializedSlow.stateKV));

        assertEq(
            FullyQualifiedNamespace.unwrap(deserialized.namespace),
            FullyQualifiedNamespace.unwrap(deserializedSlow.namespace)
        );
        assertEq(0, FullyQualifiedNamespace.unwrap(deserialized.namespace));

        assertEq(address(deserialized.store), address(deserializedSlow.store));
        assertEq(address(0), address(deserialized.store));

        assertEq(deserialized.context.length, deserializedSlow.context.length);
        for (uint256 i = 0; i < deserialized.context.length; ++i) {
            assertEq(deserialized.context[i], deserializedSlow.context[i]);
        }
        assertEq(0, deserialized.context.length);

        assertEq(deserialized.compiledSources.length, deserializedSlow.compiledSources.length);
        for (uint256 i = 0; i < deserialized.compiledSources.length; ++i) {
            assertEq(deserialized.compiledSources[i], deserializedSlow.compiledSources[i]);
        }

        assertEq(sources.length, sourcesCompiled.length);
        assertEq(deserialized.compiledSources.length, sourcesCompiled.length);
        for (uint256 i = 0; i < sourcesCompiled.length; ++i) {
            assertEq(deserialized.compiledSources[i], sourcesCompiled[i]);
        }
    }

    function testSerializeEmpty() public {
        compareSerialize(new bytes[](0), new uint256[](0), 0, hex"000000010002");
    }

    function testSerializeGasEmpty0() public pure {
        bytes[] memory sources = new bytes[](0);
        uint256[] memory constants = new uint256[](0);
        bytes memory serialized = new bytes(LibInterpreterStateDataContract.serializeSize(sources, constants));
        LibInterpreterStateDataContract.unsafeSerialize(
            serialized.dataPointer(), sources, constants, 0, hex"000000010002"
        );
    }

    function testSerializeGas0() public pure {
        bytes[] memory sources = new bytes[](10);
        uint256[] memory constants = new uint256[](10);
        bytes memory serialized = new bytes(LibInterpreterStateDataContract.serializeSize(sources, constants));
        LibInterpreterStateDataContract.unsafeSerialize(
            serialized.dataPointer(), sources, constants, 0, hex"000000010002"
        );
    }

    function testSerializeGasSlowEmpty0() public pure {
        bytes[] memory sources = new bytes[](0);
        uint256[] memory constants = new uint256[](0);
        bytes memory serialized = new bytes(LibInterpreterStateDataContract.serializeSize(sources, constants));
        LibInterpreterStateDataContractSlow.serializeSlow(
            serialized.dataPointer(), sources, constants, 0, hex"000000010002"
        );
    }

    function testSerializeGasSlow0() public pure {
        bytes[] memory sources = new bytes[](10);
        uint256[] memory constants = new uint256[](10);
        bytes memory serialized = new bytes(LibInterpreterStateDataContract.serializeSize(sources, constants));
        LibInterpreterStateDataContractSlow.serializeSlow(
            serialized.dataPointer(), sources, constants, 0, hex"000000010002"
        );
    }

    function testSerialize(
        bytes[] memory sources,
        uint256[] memory constants,
        uint8 stackLength,
        bytes memory opcodeFunctionPointers
    ) public {
        vm.assume(opcodeFunctionPointers.length > 0);
        vm.assume(opcodeFunctionPointers.length <= type(uint8).max);
        for (uint256 i = 0; i < sources.length; ++i) {
            vm.assume(sources[i].length % 2 == 0);
        }
        vm.assume(opcodeFunctionPointers.length % 2 == 0);

        compareSerialize(sources, constants, stackLength, opcodeFunctionPointers);
    }
}
