// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from "test/lib/constants/ExpressionDeployerNPConstants.sol";
import {
    RainterpreterExpressionDeployerNPE2,
    RainterpreterExpressionDeployerNPE2ConstructionConfigV2
} from "src/concrete/RainterpreterExpressionDeployerNPE2.sol";
import {RainterpreterStoreNPE2} from "src/concrete/RainterpreterStoreNPE2.sol";
import {RainterpreterParserNPE2} from "src/concrete/RainterpreterParserNPE2.sol";
import {RainterpreterNPE2} from "src/concrete/RainterpreterNPE2.sol";
import {LibDataContract} from "rain.datacontract/lib/LibDataContract.sol";

contract RainterpreterExpressionDeployerNPE2Parse2Test is Test {
    function testRainterpreterExpressionDeployerParse2Equivalent() external {
        RainterpreterParserNPE2 parser = new RainterpreterParserNPE2();
        RainterpreterExpressionDeployerNPE2 deployer = new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfigV2(
                address(new RainterpreterNPE2()), address(new RainterpreterStoreNPE2()), address(parser)
            )
        );

        bytes memory rainlangString = "a b c: 1 2 3, _: int-add(a b c);";

        (bytes memory bytecodeV1, uint256[] memory constantsV1) = parser.parse(rainlangString);
        (,, address expression,) = deployer.deployExpression2(bytecodeV1, constantsV1);

        bytes memory bytecodeV2 = deployer.parse2(rainlangString);

        assertEq(LibDataContract.read(expression), bytecodeV2);
    }
}
