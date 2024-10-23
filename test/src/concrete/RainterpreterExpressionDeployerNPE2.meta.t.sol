// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity =0.8.25;

import {RainterpreterExpressionDeployerNPE2DeploymentTest} from
    "test/abstract/RainterpreterExpressionDeployerNPE2DeploymentTest.sol";
import {DESCRIBED_BY_META_HASH} from "src/concrete/RainterpreterExpressionDeployerNPE2.sol";

/// @title RainterpreterExpressionDeployerNPE2MetaTest
/// Tests that the RainterpreterExpressionDeployerNPE2 meta is correct. Also
/// tests basic functionality of the `IParserV1View` interface implementation, except
/// parsing which is tested more extensively elsewhere.
contract RainterpreterExpressionDeployerNPE2MetaTest is RainterpreterExpressionDeployerNPE2DeploymentTest {
    /// Test that the expected construction meta hash can be read from the
    /// deployer.
    function testRainterpreterExpressionDeployerNPE2ExpectedConstructionMetaHash() external view {
        bytes32 actualConstructionMetaHash = iDeployer.describedByMetaV1();
        assertEq(actualConstructionMetaHash, DESCRIBED_BY_META_HASH);
    }
}
