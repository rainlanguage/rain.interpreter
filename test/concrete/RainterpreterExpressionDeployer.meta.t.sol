// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {RainterpreterExpressionDeployerDeploymentTest} from
    "test/util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";
import {LibAllStandardOpsNP} from "src/lib/op/LibAllStandardOpsNP.sol";
import {
    AuthoringMetaHashMismatch,
    CONSTRUCTION_META_HASH,
    AUTHORING_META_HASH
} from "src/concrete/RainterpreterExpressionDeployerNP.sol";

/// @title RainterpreterExpressionDeployerMetaTest
/// Tests that the RainterpreterExpressionDeployer meta is correct. Also tests
/// basic functionality of the `IParserV1` interface implementation.
contract RainterpreterExpressionDeployerMetaTest is RainterpreterExpressionDeployerDeploymentTest {
    /// Test that the expected construction meta hash can be read from the
    /// deployer.
    function testRainterpreterExpressionDeployerConstructionMetaHash() external {
        bytes32 actualConstructionMetaHash = iDeployer.expectedConstructionMetaHash();
        assertEq(actualConstructionMetaHash, CONSTRUCTION_META_HASH);
    }
}
