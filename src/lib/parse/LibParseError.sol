// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {ParseState} from "./LibParseState.sol";

library LibParseError {
    function parseErrorOffset(ParseState memory state, uint256 cursor) internal pure returns (uint256 offset) {
        bytes memory data = state.data;
        assembly ("memory-safe") {
            offset := sub(cursor, add(data, 0x20))
        }
    }
}
