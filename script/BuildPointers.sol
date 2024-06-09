// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {RainterpreterNPE2} from "src/concrete/RainterpreterNPE2.sol";
import {RainterpreterStoreNPE2} from "src/concrete/RainterpreterStoreNPE2.sol";
import {IInterpreterV2} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {RainterpreterParserNPE2, PARSE_META_BUILD_DEPTH} from "src/concrete/RainterpreterParserNPE2.sol";
import {
    RainterpreterExpressionDeployerNPE2,
    RainterpreterExpressionDeployerNPE2ConstructionConfigV2
} from "src/concrete/RainterpreterExpressionDeployerNPE2.sol";
import {
    RainterpreterReferenceExternNPE2,
    LibRainterpreterReferenceExternNPE2,
    EXTERN_PARSE_META_BUILD_DEPTH
} from "src/concrete/extern/RainterpreterReferenceExternNPE2.sol";
import {LibAllStandardOpsNP, AuthoringMetaV2} from "src/lib/op/LibAllStandardOpsNP.sol";
import {LibCodeGen} from "rain.sol.codegen/lib/LibCodeGen.sol";
import {LibFs} from "rain.sol.codegen/lib/LibFs.sol";

contract BuildPointers is Script {
    function buildRainterpreterNPE2Pointers() internal {
        RainterpreterNPE2 interpreter = new RainterpreterNPE2();

        LibFs.buildFileForContract(
            vm,
            address(interpreter),
            "RainterpreterNPE2",
            LibCodeGen.opcodeFunctionPointersConstantString(vm, interpreter)
        );
    }

    function buildRainterpreterStoreNPE2Pointers() internal {
        RainterpreterStoreNPE2 store = new RainterpreterStoreNPE2();

        LibFs.buildFileForContract(vm, address(store), "RainterpreterStoreNPE2", "");
    }

    function buildRainterpreterParserNPE2Pointers() internal {
        RainterpreterParserNPE2 parser = new RainterpreterParserNPE2();

        LibFs.buildFileForContract(
            vm,
            address(parser),
            "RainterpreterParserNPE2",
            string.concat(
                LibCodeGen.parseMetaConstantString(vm, LibAllStandardOpsNP.authoringMetaV2(), PARSE_META_BUILD_DEPTH),
                LibCodeGen.operandHandlerFunctionPointersConstantString(vm, parser),
                LibCodeGen.literalParserFunctionPointersConstantString(vm, parser)
            )
        );
    }

    function buildRainterpreterExpressionDeployerNPE2Pointers() internal {
        RainterpreterNPE2 interpreter = new RainterpreterNPE2();
        RainterpreterStoreNPE2 store = new RainterpreterStoreNPE2();
        RainterpreterParserNPE2 parser = new RainterpreterParserNPE2();

        RainterpreterExpressionDeployerNPE2 deployer = new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfigV2(
                address(interpreter), address(store), address(parser)
            )
        );

        string memory name = "RainterpreterExpressionDeployerNPE2";

        LibFs.buildFileForContract(
            vm,
            address(deployer),
            name,
            string.concat(
                LibCodeGen.describedByMetaHashConstantString(vm, name),
                LibCodeGen.integrityFunctionPointersConstantString(vm, deployer)
            )
        );
    }

    function buildRainterpreterReferenceExternNPE2Pointers() internal {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();

        string memory name = "RainterpreterReferenceExternNPE2";

        LibFs.buildFileForContract(
            vm,
            address(extern),
            "RainterpreterReferenceExternNPE2",
            string.concat(
                LibCodeGen.describedByMetaHashConstantString(vm, name),
                LibCodeGen.parseMetaConstantString(
                    vm, LibRainterpreterReferenceExternNPE2.authoringMetaV2(), EXTERN_PARSE_META_BUILD_DEPTH
                ),
                LibCodeGen.subParserWordParsersConstantString(vm, extern),
                LibCodeGen.operandHandlerFunctionPointersConstantString(vm, extern),
                LibCodeGen.literalParserFunctionPointersConstantString(vm, extern),
                LibCodeGen.integrityFunctionPointersConstantString(vm, extern),
                LibCodeGen.opcodeFunctionPointersConstantString(vm, extern)
            )
        );
    }

    function run() external {
        buildRainterpreterNPE2Pointers();
        buildRainterpreterStoreNPE2Pointers();
        buildRainterpreterParserNPE2Pointers();
        buildRainterpreterExpressionDeployerNPE2Pointers();
        buildRainterpreterReferenceExternNPE2Pointers();
    }
}
