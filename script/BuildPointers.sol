// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {Rainterpreter} from "src/concrete/Rainterpreter.sol";
import {RainterpreterStore} from "src/concrete/RainterpreterStore.sol";
import {RainterpreterParser, PARSE_META_BUILD_DEPTH} from "src/concrete/RainterpreterParser.sol";
import {RainterpreterExpressionDeployer} from "src/concrete/RainterpreterExpressionDeployer.sol";
import {
    RainterpreterReferenceExtern,
    LibRainterpreterReferenceExtern,
    EXTERN_PARSE_META_BUILD_DEPTH
} from "src/concrete/extern/RainterpreterReferenceExtern.sol";
import {LibAllStandardOps} from "src/lib/op/LibAllStandardOps.sol";
import {LibCodeGen} from "rain.sol.codegen/lib/LibCodeGen.sol";
import {LibGenParseMeta} from "rain.interpreter.interface/lib/codegen/LibGenParseMeta.sol";
import {LibFs} from "rain.sol.codegen/lib/LibFs.sol";

/// @title BuildPointers
/// @notice Forge script that generates Solidity source files containing
/// precomputed constant values (bytecode hashes, function pointer tables,
/// parse meta) for each concrete contract. Run via `forge script` during the
/// build step. Each `build*` function deploys the contract in a local EVM,
/// extracts its runtime pointers, and writes a `.pointers.sol` file into
/// `src/generated/`.
contract BuildPointers is Script {
    /// Builds the Rainterpreter opcode function pointer table.
    function buildRainterpreterPointers() internal {
        Rainterpreter interpreter = new Rainterpreter();

        LibFs.buildFileForContract(
            vm, address(interpreter), "Rainterpreter", LibCodeGen.opcodeFunctionPointersConstantString(vm, interpreter)
        );
    }

    /// Builds the RainterpreterStore pointer file (no additional constants).
    function buildRainterpreterStorePointers() internal {
        RainterpreterStore store = new RainterpreterStore();

        LibFs.buildFileForContract(vm, address(store), "RainterpreterStore", "");
    }

    /// Builds the RainterpreterParser pointer file including the parse meta
    /// (generated from `authoringMetaV2`), operand handler pointers, and
    /// literal parser pointers.
    function buildRainterpreterParserPointers() internal {
        RainterpreterParser parser = new RainterpreterParser();

        LibFs.buildFileForContract(
            vm,
            address(parser),
            "RainterpreterParser",
            string.concat(
                LibGenParseMeta.parseMetaConstantString(
                    vm, LibAllStandardOps.authoringMetaV2(), PARSE_META_BUILD_DEPTH
                ),
                LibCodeGen.operandHandlerFunctionPointersConstantString(vm, parser),
                LibCodeGen.literalParserFunctionPointersConstantString(vm, parser)
            )
        );
    }

    /// Builds the RainterpreterExpressionDeployer pointer file including
    /// the described-by meta hash and integrity function pointers.
    function buildRainterpreterExpressionDeployerPointers() internal {
        RainterpreterExpressionDeployer deployer = new RainterpreterExpressionDeployer();

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

    /// Builds the RainterpreterReferenceExtern pointer file including
    /// described-by meta hash, parse meta, sub-parser word parsers, operand
    /// handlers, literal parsers, integrity pointers, and opcode pointers.
    function buildRainterpreterReferenceExternPointers() internal {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();

        string memory name = "RainterpreterReferenceExtern";

        LibFs.buildFileForContract(
            vm,
            address(extern),
            name,
            string.concat(
                string.concat(
                    LibCodeGen.describedByMetaHashConstantString(vm, name),
                    LibGenParseMeta.parseMetaConstantString(
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

    /// Entry point. Builds all pointer files.
    function run() external {
        buildRainterpreterPointers();
        buildRainterpreterStorePointers();
        buildRainterpreterParserPointers();
        buildRainterpreterExpressionDeployerPointers();
        buildRainterpreterReferenceExternPointers();
    }
}
