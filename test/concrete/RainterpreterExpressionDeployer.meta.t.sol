// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {RainterpreterExpressionDeployerDeploymentTest} from
    "test/util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";
import {AUTHORING_META_HASH} from "src/concrete/RainterpreterExpressionDeployerNP.sol";

/// @title RainterpreterExpressionDeployerMetaTest
/// Tests that the RainterpreterExpressionDeployer meta is correct. Also tests
/// basic functionality of the `IParserV1` interface implementation.
contract RainterpreterExpressionDeployerMetaTest is RainterpreterExpressionDeployerDeploymentTest {
    /// Test that the expected construction meta hash can be read from the
    /// deployer.
    function testRainterpreterExpressionDeployerAuthoringMetaHash() external {
        bytes32 actualAuthoringMetaHash = iDeployer.authoringMetaHash();
        assertEq(actualAuthoringMetaHash, AUTHORING_META_HASH);
    }
}
