// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity ^0.8.18;

import {ParseStackUnderflow} from "../../error/ErrParse.sol";

type ParseStackTracker is uint256;

library LibParseStackTracker {
    using LibParseStackTracker for ParseStackTracker;

    /// Pushing inputs requires special handling as the inputs need to be tallied
    /// separately and in addition to the regular stack pushes.
    function pushInputs(ParseStackTracker tracker, uint256 n) internal pure returns (ParseStackTracker) {
        unchecked {
            tracker = tracker.push(n);
            uint256 inputs = (ParseStackTracker.unwrap(tracker) >> 8) & 0xFF;
            inputs += n;
            return ParseStackTracker.wrap((ParseStackTracker.unwrap(tracker) & ~uint256(0xFF00)) | (inputs << 8));
        }
    }

    function push(ParseStackTracker tracker, uint256 n) internal pure returns (ParseStackTracker) {
        unchecked {
            uint256 current = ParseStackTracker.unwrap(tracker) & 0xFF;
            uint256 inputs = (ParseStackTracker.unwrap(tracker) >> 8) & 0xFF;
            uint256 max = ParseStackTracker.unwrap(tracker) >> 0x10;
            current += n;
            if (current > max) {
                max = current;
            }
            return ParseStackTracker.wrap(current | (inputs << 8) | (max << 0x10));
        }
    }

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
