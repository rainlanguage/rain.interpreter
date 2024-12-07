// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {
    RainterpreterExpressionDeployerNPE2,
    RainterpreterExpressionDeployerNPE2ConstructionConfigV2
} from "src/concrete/RainterpreterExpressionDeployerNPE2.sol";
import {RainterpreterNPE2} from "src/concrete/RainterpreterNPE2.sol";
import {RainterpreterStoreNPE2} from "src/concrete/RainterpreterStoreNPE2.sol";
import {RainterpreterParserNPE2} from "src/concrete/RainterpreterParserNPE2.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from "src/lib/constants/ExpressionDeployerNPConstants.sol";

contract RainterpreterExpressionDeployerNPE2DescribedByMetaV1Test is Test {
    function testRainterpreterExpressionDeployerNPE2DescribedByMetaV1Happy() external {
        bytes memory describedByMeta = vm.readFileBinary(EXPRESSION_DEPLOYER_NP_META_PATH);
        RainterpreterExpressionDeployerNPE2 deployer = new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfigV2(
                address(new RainterpreterNPE2()),
                address(new RainterpreterStoreNPE2()),
                address(new RainterpreterParserNPE2())
            )
        );

        assertEq(keccak256(describedByMeta), deployer.describedByMetaV1());
    }
}
