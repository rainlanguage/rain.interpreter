// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibParseStackTracker, ParseStackTracker} from "src/lib/parse/LibParseStackTracker.sol";
import {ParseStackOverflow, ParseStackUnderflow} from "src/error/ErrParse.sol";

contract LibParseStackTrackerTest is Test {
    using LibParseStackTracker for ParseStackTracker;

    function externalPush(uint256 trackerRaw, uint256 n) external pure returns (uint256) {
        return ParseStackTracker.unwrap(ParseStackTracker.wrap(trackerRaw).push(n));
    }

    function externalPop(uint256 trackerRaw, uint256 n) external pure returns (uint256) {
        return ParseStackTracker.unwrap(ParseStackTracker.wrap(trackerRaw).pop(n));
    }

    function externalPushInputs(uint256 trackerRaw, uint256 n) external pure returns (uint256) {
        return ParseStackTracker.unwrap(ParseStackTracker.wrap(trackerRaw).pushInputs(n));
    }

    /// push reverts with ParseStackOverflow when current + n > 0xFF.
    function testPushOverflow(uint8 current, uint8 n) external {
        vm.assume(uint256(current) + uint256(n) > 0xFF);
        vm.expectRevert(abi.encodeWithSelector(ParseStackOverflow.selector));
        this.externalPush(uint256(current), uint256(n));
    }

    /// push succeeds when current + n <= 0xFF.
    function testPushNoOverflow(uint8 current, uint8 n) external view {
        vm.assume(uint256(current) + uint256(n) <= 0xFF);
        uint256 result = this.externalPush(uint256(current), uint256(n));
        uint256 newCurrent = result & 0xFF;
        assertEq(newCurrent, uint256(current) + uint256(n));
    }

    /// pop reverts with ParseStackUnderflow when current < n.
    function testPopUnderflow(uint8 current, uint8 n) external {
        vm.assume(uint256(current) < uint256(n));
        vm.expectRevert(abi.encodeWithSelector(ParseStackUnderflow.selector));
        this.externalPop(uint256(current), uint256(n));
    }

    /// pop succeeds when current >= n.
    function testPopNoUnderflow(uint8 current, uint8 n) external view {
        vm.assume(uint256(current) >= uint256(n));
        uint256 result = this.externalPop(uint256(current), uint256(n));
        uint256 newCurrent = result & 0xFF;
        assertEq(newCurrent, uint256(current) - uint256(n));
    }

    /// pushInputs reverts with ParseStackOverflow when inputs + n > 0xFF.
    function testPushInputsOverflow(uint8 existingInputs, uint8 n) external {
        vm.assume(uint256(existingInputs) + uint256(n) > 0xFF);
        vm.assume(uint256(n) <= 0xFF);
        vm.expectRevert(abi.encodeWithSelector(ParseStackOverflow.selector));
        this.externalPushInputs(uint256(existingInputs) << 8, uint256(n));
    }

    /// pushInputs succeeds and updates both current and inputs.
    function testPushInputsNoOverflow(uint8 existingInputs, uint8 n) external view {
        vm.assume(uint256(existingInputs) + uint256(n) <= 0xFF);
        uint256 result = this.externalPushInputs(uint256(existingInputs) << 8, uint256(n));
        uint256 newCurrent = result & 0xFF;
        uint256 newInputs = (result >> 8) & 0xFF;
        assertEq(newCurrent, uint256(n));
        assertEq(newInputs, uint256(existingInputs) + uint256(n));
    }

    /// push updates high watermark when current + n exceeds previous max.
    function testPushUpdatesHighWatermark(uint8 n) external view {
        vm.assume(n > 0);
        uint256 result = this.externalPush(0, uint256(n));
        uint256 max = result >> 0x10;
        assertEq(max, uint256(n));
    }

    /// push preserves high watermark when current + n does not exceed it.
    function testPushPreservesHighWatermark(uint8 n) external view {
        vm.assume(n > 0);
        uint256 result = this.externalPush(uint256(0xFF) << 0x10, uint256(n));
        uint256 max = result >> 0x10;
        assertEq(max, 0xFF);
    }
}
