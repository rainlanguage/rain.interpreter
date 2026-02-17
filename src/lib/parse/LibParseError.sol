// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {ParseState} from "./LibParseState.sol";

library LibParseError {
    /// Calculates the byte offset of a cursor position relative to the start
    /// of the parse data, for use in error reporting.
    /// @param state The parser state containing the source data reference.
    /// @param cursor The cursor position to calculate the offset for.
    /// @return offset The byte offset from the start of the parse data.
    function parseErrorOffset(ParseState memory state, uint256 cursor) internal pure returns (uint256 offset) {
        bytes memory data = state.data;
        assembly ("memory-safe") {
            offset := sub(cursor, add(data, 0x20))
        }
    }

    /// Reverts with the given error selector and the cursor's byte offset if
    /// the selector is non-zero. A zero selector indicates no error.
    /// @param state The parser state for error offset calculation.
    /// @param cursor The cursor position for the error offset.
    /// @param errorSelector The 4-byte error selector to revert with, or
    /// zero for no error.
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
