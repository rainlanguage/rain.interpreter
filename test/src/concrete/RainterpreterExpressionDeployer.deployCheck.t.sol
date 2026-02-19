// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {RainterpreterExpressionDeployer} from "src/concrete/RainterpreterExpressionDeployer.sol";
import {RainterpreterStore} from "src/concrete/RainterpreterStore.sol";
import {RainterpreterParser} from "src/concrete/RainterpreterParser.sol";
import {Rainterpreter} from "src/concrete/Rainterpreter.sol";

/// @title RainterpreterExpressionDeployerDeployCheckTest
/// @notice Test that the RainterpreterExpressionDeployer deploy check reverts if the
/// passed config does not match expectations.
contract RainterpreterExpressionDeployerDeployCheckTest is Test {
    /// Test the deployer can deploy if everything is valid.
    function testRainterpreterExpressionDeployerDeployNoEIP1820() external {
        new RainterpreterExpressionDeployer();
    }
}
