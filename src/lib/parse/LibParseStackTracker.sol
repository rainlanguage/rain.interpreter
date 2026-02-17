// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {ParseStackUnderflow, ParseStackOverflow} from "../../error/ErrParse.sol";

type ParseStackTracker is uint256;

library LibParseStackTracker {
    using LibParseStackTracker for ParseStackTracker;

    /// Pushing inputs requires special handling as the inputs need to be tallied
    /// separately and in addition to the regular stack pushes.
    /// @param tracker The current stack tracker state.
    /// @param n The number of inputs to push.
    /// @return The updated stack tracker.
    function pushInputs(ParseStackTracker tracker, uint256 n) internal pure returns (ParseStackTracker) {
        unchecked {
            tracker = tracker.push(n);
            uint256 inputs = (ParseStackTracker.unwrap(tracker) >> 8) & 0xFF;
            inputs += n;
            if (inputs > 0xFF) {
                revert ParseStackOverflow();
            }
            return ParseStackTracker.wrap((ParseStackTracker.unwrap(tracker) & ~uint256(0xFF00)) | (inputs << 8));
        }
    }

    /// Pushes n items onto the tracked stack, updating the current height
    /// and the high watermark if the new height exceeds it.
    /// @param tracker The current stack tracker state.
    /// @param n The number of items to push.
    /// @return The updated stack tracker.
    function push(ParseStackTracker tracker, uint256 n) internal pure returns (ParseStackTracker) {
        unchecked {
            uint256 current = ParseStackTracker.unwrap(tracker) & 0xFF;
            uint256 inputs = (ParseStackTracker.unwrap(tracker) >> 8) & 0xFF;
            uint256 max = ParseStackTracker.unwrap(tracker) >> 0x10;
            current += n;
            if (current > 0xFF) {
                revert ParseStackOverflow();
            }
            if (current > max) {
                max = current;
            }
            return ParseStackTracker.wrap(current | (inputs << 8) | (max << 0x10));
        }
    }

    /// Pops n items from the tracked stack. Reverts with
    /// `ParseStackUnderflow` if the current stack height is less than n.
    /// @param tracker The current stack tracker state.
    /// @param n The number of items to pop.
    /// @return The updated stack tracker.
    function pop(ParseStackTracker tracker, uint256 n) internal pure returns (ParseStackTracker) {
        unchecked {
            uint256 current = ParseStackTracker.unwrap(tracker) & 0xFF;
            if (current < n) {
                revert ParseStackUnderflow();
            }
            return ParseStackTracker.wrap(ParseStackTracker.unwrap(tracker) - n);
        }
    }
}
