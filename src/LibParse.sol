// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

library LibParse {
    function parse(bytes memory data) internal pure returns (bytes[] memory sources, uint256[] memory constants) {
        assembly ("memory-safe") {
            // Notable excerpts from ASCII as shifted chars
            // 0x20 = space = 0x0100000000
            // 0x2C = , = 0x100000000000
            // 0x3A = : = 0x0400000000000000
            // 0x3B = ; = 0x0800000000000000
            let lhs := 1
            let cursor := add(data, 1)
            let end := add(cursor, mload(data))
            // This is spacebar in ascii, effectively this prefixes every
            // parsed data with some whitespace.
            let prevChar := 0x0100000000
            let char := shl(and(mload(cursor), 0xFF), 1)
            for {} lt(cursor, end) {} {
                prevChar := char
                // Cursor must be incremented by the inner logic.
                char := shl(and(mload(cursor), 0xFF), 1)
                let masked := and(
                    char,
                    // mask for , : ;
                    0x0C00100000000000
                )
                if masked {
                    switch masked
                    // ,
                    case 0x100000000000 {
                        lhs := 1
                        cursor := add(cursor, 1)
                    }
                    // char :
                    case 0x0400000000000000 {
                        lhs := 0
                        cursor := add(cursor, 1)
                    }
                    // char ;
                    case 0x0800000000000000 { cursor := add(cursor, 1) }
                    default { revert(0, 0) }
                }
            }
            if iszero(eq(char, 0x0800000000000000)) {
                revert(0, 0)
            }
        }
    }
}
