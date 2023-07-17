// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "../../lib/forge-std/src/Test.sol";
import "../util/lib/etch/LibEtch.sol";
import "../util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";

import "../../src/concrete/RainterpreterStore.sol";
import "../../src/concrete/RainterpreterNP.sol";
import "../../src/concrete/RainterpreterExpressionDeployerNP.sol";

/// @title RainterpreterExpressionDeployerMetaTest
/// Tests that the RainterpreterExpressionDeployer meta is correct. Also tests
/// basic functionality of the `IParserV1` interface implementation.
contract RainterpreterExpressionDeployerMetaTest is RainterpreterExpressionDeployerDeploymentTest {
    /// Test that the authoring meta hash is correct.
    function testRainterpreterExpressionDeployerAuthoringMetaHash() external {
        bytes memory authoringMeta = LibRainterpreterExpressionDeployerNPMeta.authoringMeta();
        bytes32 expectedHash = keccak256(authoringMeta);
        bytes32 actualHash = iDeployer.authoringMetaHash();
        assertEq(actualHash, expectedHash);
    }

    /// Test that the parse meta is correct.
    function testRainterpreterExpressionDeployerParseMeta() external {
        bytes memory parseMeta = iDeployer.parseMeta();
        bytes memory expectedParseMeta = LibRainterpreterExpressionDeployerNPMeta.buildParseMetaFromAuthoringMeta(
            LibRainterpreterExpressionDeployerNPMeta.authoringMeta()
        );
        assertEq(parseMeta, expectedParseMeta);
    }
}
