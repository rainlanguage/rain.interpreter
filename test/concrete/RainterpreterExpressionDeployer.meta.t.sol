// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {RainterpreterExpressionDeployerNPDeploymentTest} from
    "test/util/abstract/deprecated/RainterpreterExpressionDeployerNPDeploymentTest.sol";
import {AUTHORING_META_HASH} from "src/concrete/deprecated/RainterpreterExpressionDeployerNP.sol";

/// @title RainterpreterExpressionDeployerMetaTest
/// Tests that the RainterpreterExpressionDeployer meta is correct. Also tests
/// basic functionality of the `IParserV1` interface implementation.
contract RainterpreterExpressionDeployerMetaTest is RainterpreterExpressionDeployerNPDeploymentTest {
    /// Test that the expected construction meta hash can be read from the
    /// deployer.
    function testRainterpreterExpressionDeployerAuthoringMetaHash() external {
        bytes32 actualAuthoringMetaHash = iDeployer.authoringMetaHash();
        assertEq(actualAuthoringMetaHash, AUTHORING_META_HASH);
    }
}
