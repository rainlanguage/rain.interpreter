// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibParseInterstitial} from "src/lib/parse/LibParseInterstitial.sol";
import {MalformedCommentStart} from "src/error/ErrParse.sol";

/// @title LibParseInterstitialTest
/// Tests for LibParseInterstitial.
contract LibParseInterstitialTest is Test {
    using LibParseInterstitial for ParseState;
    using LibBytes for bytes;

    /// "//" is not a valid comment start sequence ("/*" is required), so
    /// skipComment must revert with MalformedCommentStart.
    function testMalformedCommentStart() external {
        bytes memory data = bytes("// not a comment */");

        vm.expectRevert(abi.encodeWithSelector(MalformedCommentStart.selector, 0));
        this.externalSkipComment(data);
    }

    /// External wrapper that constructs ParseState internally so memory
    /// pointers remain valid across the external call boundary.
    function externalSkipComment(bytes memory data) external pure returns (uint256) {
        ParseState memory state = LibParseState.newState(data, "", "", "");
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        return state.skipComment(cursor, Pointer.unwrap(data.endDataPointer()));
    }
}
