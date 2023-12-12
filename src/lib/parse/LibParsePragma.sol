// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {ParseState} from "./LibParseState.sol";

library LibParsePragma {
    function parsePragma(ParseState memory, uint256 cursor, uint256) internal pure returns (uint256) {
        return cursor;
    }
}
