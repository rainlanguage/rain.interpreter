// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {RainterpreterExpressionDeployerNPE2DeploymentTest} from
    "test/util/abstract/RainterpreterExpressionDeployerNPE2DeploymentTest.sol";
import {AUTHORING_META_HASH} from "src/concrete/RainterpreterExpressionDeployerNPE2.sol";

/// @title RainterpreterExpressionDeployerNPE2MetaTest
/// Tests that the RainterpreterExpressionDeployerNPE2 meta is correct. Also
/// tests basic functionality of the `IParserV1` interface implementation, except
/// parsing which is tested more extensively elsewhere.
contract RainterpreterExpressionDeployerNPE2MetaTest is RainterpreterExpressionDeployerNPE2DeploymentTest {
    /// Test that the expected construction meta hash can be read from the
    /// deployer.
    function testRainterpreterExpressionDeployerNPE2AuthoringMetaHash() external {
        bytes32 actualAuthoringMetaHash = iDeployer.authoringMetaHash();
        assertEq(actualAuthoringMetaHash, AUTHORING_META_HASH);
    }
}
