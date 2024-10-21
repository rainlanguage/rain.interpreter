// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
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
