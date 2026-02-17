// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {Rainterpreter} from "src/concrete/Rainterpreter.sol";
import {ZeroFunctionPointers} from "src/error/ErrEval.sol";

contract ZeroFPRainterpreter is Rainterpreter {
    function opcodeFunctionPointers() internal pure override returns (bytes memory) {
        return hex"";
    }
}

contract RainterpreterZeroFunctionPointersTest is Test {
    /// Deploying a Rainterpreter with empty function pointers must revert.
    function testZeroFunctionPointersReverts() external {
        vm.expectRevert(abi.encodeWithSelector(ZeroFunctionPointers.selector));
        new ZeroFPRainterpreter();
    }

    /// The standard Rainterpreter must deploy successfully.
    function testStandardRainterpreterDeploys() external {
        new Rainterpreter();
    }
}
