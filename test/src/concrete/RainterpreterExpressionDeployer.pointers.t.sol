// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {
    RainterpreterExpressionDeployer,
    INTEGRITY_FUNCTION_POINTERS
} from "src/concrete/RainterpreterExpressionDeployer.sol";

contract RainterpreterExpressionDeployerPointersTest is Test {
    function testIntegrityFunctionPointers() external {
        RainterpreterExpressionDeployer deployer = new RainterpreterExpressionDeployer();
        bytes memory expected = deployer.buildIntegrityFunctionPointers();
        bytes memory actual = INTEGRITY_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }
}
