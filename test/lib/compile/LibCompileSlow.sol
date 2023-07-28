// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

library LibCompileSlow {
    function convertToOps(bytes memory source, bytes memory pointers) internal pure {
        unchecked {
            require(pointers.length % 2 == 0);
            for (uint256 i = 0; i < source.length; i += 4) {
                uint256 opcodeByte = uint8(source[i + 1]);
                uint8 opcode = uint8(uint256(opcodeByte % (pointers.length / 2)));
                source[i + 1] = bytes1(opcode);
            }
        }
    }

    function compileSlow(bytes memory source, bytes memory pointers) internal pure {
        for (uint256 i = 0; i < source.length; i += 4) {
            // second byte is the opcode.
            uint256 opcode = uint8(source[i + 1]) * 2;
            source[i] = pointers[opcode];
            source[i + 1] = pointers[opcode + 1];
        }
    }
}
