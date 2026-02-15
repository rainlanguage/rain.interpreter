// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity ^0.8.18;

import {ParseState} from "./LibParseState.sol";

library LibParseError {
    /// Calculates the byte offset of a cursor position relative to the start
    /// of the parse data, for use in error reporting.
    function parseErrorOffset(ParseState memory state, uint256 cursor) internal pure returns (uint256 offset) {
        bytes memory data = state.data;
        assembly ("memory-safe") {
            offset := sub(cursor, add(data, 0x20))
        }
    }

    /// Reverts with the given error selector and the cursor's byte offset if
    /// the selector is non-zero. A zero selector indicates no error.
    function handleErrorSelector(ParseState memory state, uint256 cursor, bytes4 errorSelector) internal pure {
        if (errorSelector != 0) {
            uint256 errorOffset = parseErrorOffset(state, cursor);
            assembly ("memory-safe") {
                mstore(0, errorSelector)
                mstore(4, errorOffset)
                revert(0, 0x24)
            }
        }
    }
}
