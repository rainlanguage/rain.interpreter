// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

// import "forge-std/Test.sol";
// import "test/util/lib/etch/LibEtch.sol";
import {RainterpreterExpressionDeployerDeploymentTest} from
    "test/util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";
// import "test/util/lib/constants/ExpressionDeployerNPConstants.sol";
import {LibAllStandardOpsNP} from "src/lib/op/LibAllStandardOpsNP.sol";

// import "src/concrete/RainterpreterStore.sol";
// import "src/concrete/RainterpreterNP.sol";
import {AuthoringMetaHashMismatch, CONSTRUCTION_META_HASH} from "src/concrete/RainterpreterExpressionDeployerNP.sol";

/// @title RainterpreterExpressionDeployerMetaTest
/// Tests that the RainterpreterExpressionDeployer meta is correct. Also tests
/// basic functionality of the `IParserV1` interface implementation.
contract RainterpreterExpressionDeployerMetaTest is RainterpreterExpressionDeployerDeploymentTest {
    /// Test that the authoring meta hash is correct.
    function testRainterpreterExpressionDeployerAuthoringMetaHash() external {
        bytes32 expectedHash = keccak256(LibAllStandardOpsNP.authoringMeta());
        bytes32 actualHash = iDeployer.authoringMetaHash();
        assertEq(actualHash, expectedHash);
    }

    /// Test that the deployer agrees with itself for a build and view.
    function testRainterpreterExpressionDeployerBuildAndParse() external {
        bytes memory authoringMeta = LibAllStandardOpsNP.authoringMeta();
        bytes memory builtParseMeta = iDeployer.buildParseMeta(authoringMeta);
        bytes memory parseMeta = iDeployer.parseMeta();
        assertEq(keccak256(builtParseMeta), keccak256(parseMeta));
    }

    /// Test that invalid authoring meta reverts the parse meta builder.
    function testRainterpreterExpressionDeployerBuildParseMetaReverts(bytes memory authoringMeta) external {
        bytes32 expectedHash = iDeployer.authoringMetaHash();
        bytes32 actualHash = keccak256(authoringMeta);
        vm.assume(actualHash != expectedHash);
        vm.expectRevert(abi.encodeWithSelector(AuthoringMetaHashMismatch.selector, expectedHash, actualHash));
        iDeployer.buildParseMeta(authoringMeta);
    }

    /// Test that the expected construction meta hash can be read from the
    /// deployer.
    function testRainterpreterExpressionDeployerConstructionMetaHash() external {
        bytes32 actualConstructionMetaHash = iDeployer.expectedConstructionMetaHash();
        assertEq(actualConstructionMetaHash, CONSTRUCTION_META_HASH);
    }
}
