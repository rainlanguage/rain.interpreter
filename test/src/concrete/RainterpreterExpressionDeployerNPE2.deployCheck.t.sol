// SPDX-License-Identifier: CAL
pragma solidity =0.8.26;

import {Test} from "forge-std/Test.sol";

import {
    RainterpreterExpressionDeployerNPE2,
    RainterpreterExpressionDeployerNPE2ConstructionConfigV2
} from "src/concrete/RainterpreterExpressionDeployerNPE2.sol";
import {RainterpreterStoreNPE2} from "src/concrete/RainterpreterStoreNPE2.sol";
import {RainterpreterParserNPE2} from "src/concrete/RainterpreterParserNPE2.sol";
import {RainterpreterNPE2} from "src/concrete/RainterpreterNPE2.sol";

/// @title RainterpreterExpressionDeployerNPE2DeployCheckTest
/// Test that the RainterpreterExpressionDeployerNPE2 deploy check reverts if the
/// passed config does not match expectations.
contract RainterpreterExpressionDeployerNPE2DeployCheckTest is Test {
    /// Test the deployer can deploy if everything is valid.
    function testRainterpreterExpressionDeployerDeployNoEIP1820() external {
        new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfigV2(
                address(new RainterpreterNPE2()),
                address(new RainterpreterStoreNPE2()),
                address(new RainterpreterParserNPE2())
            )
        );
    }
}
