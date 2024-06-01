// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {ParseState} from "./LibParseState.sol";

bytes32 constant MAGIC_NUMBER_RAIN_PARSE_ERROR_V1 = keccak256("rain.interpreter.error.parse.0") << 0x10;

library LibParseError {
    function parseErrorOffset(ParseState memory state, uint256 cursor) internal pure returns (uint256 offset) {
        bytes memory data = state.data;
        bytes32 magicNumber = MAGIC_NUMBER_RAIN_PARSE_ERROR_V1;
        assembly ("memory-safe") {
            offset := or(magicNumber, sub(cursor, add(data, 0x20)))
        }
    }
}
