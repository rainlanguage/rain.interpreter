// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {
    RainterpreterExpressionDeployerNPE2,
    RainterpreterExpressionDeployerNPE2ConstructionConfigV2
} from "src/concrete/RainterpreterExpressionDeployerNPE2.sol";
import {Rainterpreter} from "src/concrete/Rainterpreter.sol";
import {RainterpreterStore} from "src/concrete/RainterpreterStore.sol";
import {RainterpreterParserNPE2} from "src/concrete/RainterpreterParserNPE2.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from "src/lib/constants/ExpressionDeployerNPConstants.sol";

contract RainterpreterExpressionDeployerNPE2DescribedByMetaV1Test is Test {
    function testRainterpreterExpressionDeployerNPE2DescribedByMetaV1Happy() external {
        bytes memory describedByMeta = vm.readFileBinary(EXPRESSION_DEPLOYER_NP_META_PATH);
        RainterpreterExpressionDeployerNPE2 deployer = new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfigV2(
                address(new Rainterpreter()),
                address(new RainterpreterStore()),
                address(new RainterpreterParserNPE2())
            )
        );

        assertEq(keccak256(describedByMeta), deployer.describedByMetaV1());
    }
}
