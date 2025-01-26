// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {
    RainterpreterExpressionDeployerNPE2,
    RainterpreterExpressionDeployerNPE2ConstructionConfigV2
} from "src/concrete/RainterpreterExpressionDeployerNPE2.sol";
import {RainterpreterStore} from "src/concrete/RainterpreterStore.sol";
import {RainterpreterParserNPE2} from "src/concrete/RainterpreterParserNPE2.sol";
import {Rainterpreter} from "src/concrete/Rainterpreter.sol";

/// @title RainterpreterExpressionDeployerNPE2DeployCheckTest
/// Test that the RainterpreterExpressionDeployerNPE2 deploy check reverts if the
/// passed config does not match expectations.
contract RainterpreterExpressionDeployerNPE2DeployCheckTest is Test {
    /// Test the deployer can deploy if everything is valid.
    function testRainterpreterExpressionDeployerDeployNoEIP1820() external {
        new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfigV2(
                address(new Rainterpreter()),
                address(new RainterpreterStore()),
                address(new RainterpreterParserNPE2())
            )
        );
    }
}
