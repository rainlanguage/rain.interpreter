// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {RainlangExpressionDeployer, DESCRIBED_BY_META_HASH} from "../../../src/concrete/RainlangExpressionDeployer.sol";

contract RainlangExpressionDeployerMetaTest is Test {
    /// The deployed concrete describes itself by the generated meta hash.
    function testRainlangExpressionDeployerExpectedConstructionMetaHash() external {
        RainlangExpressionDeployer deployer = new RainlangExpressionDeployer();
        assertEq(deployer.describedByMetaV1(), DESCRIBED_BY_META_HASH);
    }
}
