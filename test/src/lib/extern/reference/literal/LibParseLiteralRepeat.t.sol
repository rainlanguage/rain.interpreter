// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {
    LibParseLiteralRepeat,
    RepeatDispatchNotDigit
} from "src/lib/extern/reference/literal/LibParseLiteralRepeat.sol";

contract LibParseLiteralRepeatTest is Test {
    /// External wrapper for parseRepeat so that expectRevert can catch
    /// the revert at a deeper call depth.
    function externalParseRepeat(uint256 dispatchValue, uint256 cursor, uint256 end) external pure returns (uint256) {
        return LibParseLiteralRepeat.parseRepeat(dispatchValue, cursor, end);
    }

    /// Dispatch values 0-9 must not revert.
    function testParseRepeatValidDigits() external pure {
        uint256 cursor = 0;
        uint256 end = 3;
        for (uint256 i = 0; i <= 9; i++) {
            LibParseLiteralRepeat.parseRepeat(i, cursor, end);
        }
    }

    /// Dispatch value 10 must revert.
    function testParseRepeatInvalidDispatch() external {
        vm.expectRevert(abi.encodeWithSelector(RepeatDispatchNotDigit.selector, uint256(10)));
        this.externalParseRepeat(10, 0, 3);
    }

    /// Any dispatch value > 9 must revert.
    function testParseRepeatInvalidDispatchFuzz(uint256 dispatchValue) external {
        vm.assume(dispatchValue > 9);
        vm.expectRevert(abi.encodeWithSelector(RepeatDispatchNotDigit.selector, dispatchValue));
        this.externalParseRepeat(dispatchValue, 0, 3);
    }
}
