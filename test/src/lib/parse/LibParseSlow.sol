// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity ^0.8.18;

library LibParseSlow {
    function parseWordSlow(bytes memory data, uint256 mask) internal pure returns (uint256) {
        if (data.length > 1) {
            for (uint256 i = 1; i < data.length; i++) {
                if ((1 << uint256(uint8(data[i]))) & mask == 0) {
                    return i;
                }
            }
        }
        return data.length;
    }

    function isMaskSlow(uint256 cursor, uint256 end, uint256 mask) internal pure returns (uint256) {
        if (cursor < end) {
            uint256 wordAtCursor;
            assembly ("memory-safe") {
                wordAtCursor := mload(cursor)
            }
            return (1 << uint256(wordAtCursor >> 0xF8)) & mask > 0 ? 1 : 0;
        } else {
            return 0;
        }
    }
}
