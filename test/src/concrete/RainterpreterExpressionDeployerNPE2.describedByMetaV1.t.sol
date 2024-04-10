// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {
    RainterpreterExpressionDeployerNPE2,
    RainterpreterExpressionDeployerNPE2ConstructionConfig
} from "src/concrete/RainterpreterExpressionDeployerNPE2.sol";
import {RainterpreterNPE2} from "src/concrete/RainterpreterNPE2.sol";
import {RainterpreterStoreNPE2} from "src/concrete/RainterpreterStoreNPE2.sol";
import {RainterpreterParserNPE2} from "src/concrete/RainterpreterParserNPE2.sol";

contract RainterpreterExpressionDeployerNPE2DescribedByMetaV1Test is Test {
    function testRainterpreterExpressionDeployerNPE2DescribedByMetaV1Happy() external {
        bytes memory describedByMeta = vm.readFileBinary("meta/RainterpreterExpressionDeployerNPE2.rain.meta");
        RainterpreterExpressionDeployerNPE2 deployer = new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfig(
                address(new RainterpreterNPE2()),
                address(new RainterpreterStoreNPE2()),
                address(new RainterpreterParserNPE2()),
                describedByMeta
            )
        );

        assertEq(keccak256(describedByMeta), deployer.describedByMetaV1());
        assertEq(deployer.describedByMetaV1(), deployer.expectedConstructionMetaHash());
    }
}
