// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

library LibCompileSlow {
    function convertToOps(bytes memory source, bytes memory pointers) internal pure {
        unchecked {
            require(pointers.length % 2 == 0);
            for (uint256 i = 0; i < source.length; i += 4) {
                uint256 high = uint8(source[i]);
                uint256 low = uint8(source[i + 1]);
                uint256 opcode = (high << 8 | low) % (pointers.length / 2);
                source[i] = bytes1(uint8(opcode >> 8));
                source[i + 1] = bytes1(uint8(opcode & 0xFFFF));
            }
        }
    }

    function compileSlow(bytes memory source, bytes memory pointers) internal pure {
        for (uint256 i = 0; i < source.length; i += 4) {
            uint256 high = uint8(source[i]);
            uint256 low = uint8(source[i + 1]);
            uint256 opcode = ((high << 8) | low) * 2;
            source[i] = pointers[opcode];
            source[i + 1] = pointers[opcode + 1];
        }
    }
}
