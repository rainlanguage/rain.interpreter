// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {Rainterpreter} from "src/concrete/Rainterpreter.sol";
import {RainterpreterStore} from "src/concrete/RainterpreterStore.sol";
import {RainterpreterParserNPE2, PARSE_META_BUILD_DEPTH} from "src/concrete/RainterpreterParserNPE2.sol";
import {
    RainterpreterExpressionDeployer,
    RainterpreterExpressionDeployerConstructionConfigV2
} from "src/concrete/RainterpreterExpressionDeployer.sol";
import {
    RainterpreterReferenceExtern,
    LibRainterpreterReferenceExtern,
    EXTERN_PARSE_META_BUILD_DEPTH
} from "src/concrete/extern/RainterpreterReferenceExtern.sol";
import {LibAllStandardOpsNP, AuthoringMetaV2} from "src/lib/op/LibAllStandardOpsNP.sol";
import {LibCodeGen} from "rain.sol.codegen/lib/LibCodeGen.sol";
import {LibFs} from "rain.sol.codegen/lib/LibFs.sol";

contract BuildPointers is Script {
    function buildRainterpreterPointers() internal {
        Rainterpreter interpreter = new Rainterpreter();

        LibFs.buildFileForContract(
            vm, address(interpreter), "Rainterpreter", LibCodeGen.opcodeFunctionPointersConstantString(vm, interpreter)
        );
    }

    function buildRainterpreterStorePointers() internal {
        RainterpreterStore store = new RainterpreterStore();

        LibFs.buildFileForContract(vm, address(store), "RainterpreterStore", "");
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

    function buildRainterpreterExpressionDeployerPointers() internal {
        Rainterpreter interpreter = new Rainterpreter();
        RainterpreterStore store = new RainterpreterStore();
        RainterpreterParserNPE2 parser = new RainterpreterParserNPE2();

        RainterpreterExpressionDeployer deployer = new RainterpreterExpressionDeployer(
            RainterpreterExpressionDeployerConstructionConfigV2(address(interpreter), address(store), address(parser))
        );

        string memory name = "RainterpreterExpressionDeployer";

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

    function buildRainterpreterReferenceExternPointers() internal {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();

        string memory name = "RainterpreterReferenceExtern";

        LibFs.buildFileForContract(
            vm,
            address(extern),
            "RainterpreterReferenceExtern",
            string.concat(
                string.concat(
                    LibCodeGen.describedByMetaHashConstantString(vm, name),
                    LibCodeGen.parseMetaConstantString(
                        vm, LibRainterpreterReferenceExtern.authoringMetaV2(), EXTERN_PARSE_META_BUILD_DEPTH
                    ),
                    LibCodeGen.subParserWordParsersConstantString(vm, extern),
                    LibCodeGen.operandHandlerFunctionPointersConstantString(vm, extern),
                    LibCodeGen.literalParserFunctionPointersConstantString(vm, extern),
                    LibCodeGen.integrityFunctionPointersConstantString(vm, extern)
                ),
                LibCodeGen.opcodeFunctionPointersConstantString(vm, extern)
            )
        );
    }

    function run() external {
        buildRainterpreterPointers();
        buildRainterpreterStorePointers();
        buildRainterpreterParserNPE2Pointers();
        buildRainterpreterExpressionDeployerPointers();
        buildRainterpreterReferenceExternPointers();
    }
}
