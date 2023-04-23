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
            for (uint256 i = 0; i < source.length; i++) {
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

    function testSerialize(
        bytes[] memory sources,
        uint256[] memory constants,
        uint256 stackLength,
        bytes memory opcodeFunctionPointers
    ) public {
        unchecked {
            vm.assume(opcodeFunctionPointers.length > 0);
            vm.assume(opcodeFunctionPointers.length <= type(uint8).max);
            for (uint256 i = 0; i < sources.length; i++) {
                convertToOps(sources[i], uint8(opcodeFunctionPointers.length));
            }

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
    }
}
