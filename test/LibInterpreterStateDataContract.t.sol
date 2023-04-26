// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "sol.lib.memory/LibBytes.sol";

import "./LibInterpreterStateDataContractSlow.sol";
import "../src/LibInterpreterStateDataContract.sol";

contract LibInterpreterStateDataContractTest is Test {
    using LibBytes for bytes;

    function convertToOps(bytes memory source, uint8 max) internal pure {
        unchecked {
            for (uint256 i = 0; i < source.length; i += 2) {
                source[i] = bytes1(uint8(source[i]) % max);
            }
        }
    }

    function testSerializeSize(bytes[] memory sources, uint256[] memory constants, uint256 stackLength) public {
        assertEq(
            LibInterpreterStateDataContractSlow.serializeSizeSlow(sources, constants, stackLength),
            LibInterpreterStateDataContract.serializeSize(sources, constants)
        );
    }

    function compareSerialize(
        bytes[] memory sources,
        uint256[] memory constants,
        uint8 stackLength,
        bytes memory opcodeFunctionPointers
    ) internal {
        uint256 serializeSize = LibInterpreterStateDataContract.serializeSize(sources, constants);

        bytes memory serialized = new bytes(serializeSize);
        bytes memory serializedSlow = new bytes(serializeSize);

        bytes[] memory sourcesCopy = new bytes[](sources.length);
        for (uint256 i = 0; i < sources.length; i++) {
            bytes memory sourceCopy = new bytes(sources[i].length);
            LibMemCpy.unsafeCopyBytesTo(sources[i].dataPointer(), sourceCopy.dataPointer(), sources[i].length);
            sourcesCopy[i] = sourceCopy;
        }
        LibInterpreterStateDataContract.unsafeSerialize(
            serialized.dataPointer(), sourcesCopy, constants, stackLength, opcodeFunctionPointers
        );
        LibInterpreterStateDataContractSlow.serializeSlow(
            serializedSlow.dataPointer(), sources, constants, stackLength, opcodeFunctionPointers
        );

        assertEq(serialized, serializedSlow);
    }

    function testSerializeEmpty() public {
        compareSerialize(new bytes[](0), new uint256[](0), 0, hex"000000010002");
    }

    function testSerializeGasEmpty0() public {
        bytes[] memory sources = new bytes[](0);
        uint256[] memory constants = new uint256[](0);
        bytes memory serialized = new bytes(LibInterpreterStateDataContract.serializeSize(sources, constants));
        LibInterpreterStateDataContract.unsafeSerialize(
            serialized.dataPointer(),
            sources,
            constants,
            0,
            hex"000000010002"
        );
    }

    function testSerializeGas0() public {
        bytes[] memory sources = new bytes[](10);
        uint256[] memory constants = new uint256[](10);
        bytes memory serialized = new bytes(LibInterpreterStateDataContract.serializeSize(sources, constants));
        LibInterpreterStateDataContract.unsafeSerialize(
            serialized.dataPointer(),
            sources,
            constants,
            0,
            hex"000000010002"
        );
    }

    function testSerializeGasSlowEmpty0() public {
        bytes[] memory sources = new bytes[](0);
        uint256[] memory constants = new uint256[](0);
        bytes memory serialized = new bytes(LibInterpreterStateDataContract.serializeSize(sources, constants));
        LibInterpreterStateDataContractSlow.serializeSlow(
            serialized.dataPointer(),
            sources,
            constants,
            0,
            hex"000000010002"
        );
    }

    function testSerializeGasSlow0() public {
        bytes[] memory sources = new bytes[](10);
        uint256[] memory constants = new uint256[](10);
        bytes memory serialized = new bytes(LibInterpreterStateDataContract.serializeSize(sources, constants));
        LibInterpreterStateDataContractSlow.serializeSlow(
            serialized.dataPointer(),
            sources,
            constants,
            0,
            hex"000000010002"
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
        vm.assume(sources.length < 5);
        vm.assume(constants.length < 10);
        for (uint256 i = 0; i < sources.length; i++) {
            vm.assume(sources[i].length % 2 == 0);
            vm.assume(sources[i].length < 50);
            convertToOps(sources[i], uint8(opcodeFunctionPointers.length));
        }

        compareSerialize(sources, constants, stackLength, opcodeFunctionPointers);
    }
}
