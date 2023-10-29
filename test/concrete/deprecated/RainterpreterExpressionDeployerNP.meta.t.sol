// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {RainterpreterExpressionDeployerNPDeploymentTest} from
    "test/util/abstract/RainterpreterExpressionDeployerNPDeploymentTest.sol";
import {AUTHORING_META_HASH} from "src/concrete/RainterpreterExpressionDeployerNP.sol";

/// @title RainterpreterExpressionDeployerNPMetaTest
/// Tests that the RainterpreterExpressionDeployerNP meta is correct. Also tests
/// basic functionality of the `IParserV1` interface implementation, except
/// parsing which is tested more extensively elsewhere.
contract RainterpreterExpressionDeployerNPMetaTest is RainterpreterExpressionDeployerNPDeploymentTest {
    /// Test that the expected construction meta hash can be read from the
    /// deployer.
    function testRainterpreterExpressionDeployerNPAuthoringMetaHash() external {
        bytes32 actualAuthoringMetaHash = iDeployer.authoringMetaHash();
        assertEq(actualAuthoringMetaHash, AUTHORING_META_HASH);
    }
}
