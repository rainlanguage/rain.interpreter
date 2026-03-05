// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {Rainterpreter} from "src/concrete/Rainterpreter.sol";
import {RainterpreterStore} from "src/concrete/RainterpreterStore.sol";
import {RainterpreterParser, PARSE_META_BUILD_DEPTH} from "src/concrete/RainterpreterParser.sol";
import {RainterpreterExpressionDeployer} from "src/concrete/RainterpreterExpressionDeployer.sol";
import {RainterpreterDISPaiRegistry} from "src/concrete/RainterpreterDISPaiRegistry.sol";
import {
    RainterpreterReferenceExtern,
    LibRainterpreterReferenceExtern,
    EXTERN_PARSE_META_BUILD_DEPTH
} from "src/concrete/extern/RainterpreterReferenceExtern.sol";
import {LibAllStandardOps} from "src/lib/op/LibAllStandardOps.sol";
import {LibCodeGen} from "rain.sol.codegen/lib/LibCodeGen.sol";
import {LibGenParseMeta} from "rain.interpreter.interface/lib/codegen/LibGenParseMeta.sol";
import {LibFs} from "rain.sol.codegen/lib/LibFs.sol";
import {LibRainDeploy} from "rain.deploy/lib/LibRainDeploy.sol";

/// @title BuildPointers
/// @notice Forge script that generates Solidity source files containing
/// precomputed constant values (bytecode hashes, function pointer tables,
/// parse meta, deterministic deploy addresses) for each concrete contract.
/// Run via `forge script` during the build step. Each `build*` function
/// deploys the contract via the Zoltu factory in a local EVM, extracts its
/// runtime pointers, and writes a `.pointers.sol` file into `src/generated/`.
contract BuildPointers is Script {
    /// Generates a Solidity address constant declaration string.
    /// @param addr The address value.
    /// @return A string containing the Solidity code for the address constant.
    function addressConstantString(address addr) internal view returns (string memory) {
        return string.concat(
            "\n",
            "/// @dev The deterministic deploy address of the contract when deployed via\n",
            "/// the Zoltu factory.\n",
            "address constant DEPLOYED_ADDRESS = address(",
            vm.toString(addr),
            ");\n"
        );
    }

    /// Builds the Rainterpreter opcode function pointer table.
    function buildRainterpreterPointers() internal {
        address deployed = LibRainDeploy.deployZoltu(type(Rainterpreter).creationCode);
        Rainterpreter interpreter = Rainterpreter(deployed);

        LibFs.buildFileForContract(
            vm,
            deployed,
            "Rainterpreter",
            string.concat(
                addressConstantString(deployed),
                LibCodeGen.bytesConstantString(
                    vm,
                    "/// @dev The creation bytecode of the contract.",
                    "CREATION_CODE",
                    type(Rainterpreter).creationCode
                ),
                LibCodeGen.opcodeFunctionPointersConstantString(vm, interpreter)
            )
        );
    }

    /// Builds the RainterpreterStore pointer file.
    function buildRainterpreterStorePointers() internal {
        address deployed = LibRainDeploy.deployZoltu(type(RainterpreterStore).creationCode);

        LibFs.buildFileForContract(
            vm,
            deployed,
            "RainterpreterStore",
            string.concat(
                addressConstantString(deployed),
                LibCodeGen.bytesConstantString(
                    vm,
                    "/// @dev The creation bytecode of the contract.",
                    "CREATION_CODE",
                    type(RainterpreterStore).creationCode
                )
            )
        );
    }

    /// Builds the RainterpreterParser pointer file including the parse meta
    /// (generated from `authoringMetaV2`), operand handler pointers, and
    /// literal parser pointers.
    function buildRainterpreterParserPointers() internal {
        address deployed = LibRainDeploy.deployZoltu(type(RainterpreterParser).creationCode);
        RainterpreterParser parser = RainterpreterParser(deployed);

        LibFs.buildFileForContract(
            vm,
            deployed,
            "RainterpreterParser",
            string.concat(
                addressConstantString(deployed),
                LibCodeGen.bytesConstantString(
                    vm,
                    "/// @dev The creation bytecode of the contract.",
                    "CREATION_CODE",
                    type(RainterpreterParser).creationCode
                ),
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
        address deployed = LibRainDeploy.deployZoltu(type(RainterpreterExpressionDeployer).creationCode);
        RainterpreterExpressionDeployer deployer = RainterpreterExpressionDeployer(deployed);

        string memory name = "RainterpreterExpressionDeployer";

        LibFs.buildFileForContract(
            vm,
            deployed,
            name,
            string.concat(
                addressConstantString(deployed),
                LibCodeGen.bytesConstantString(
                    vm,
                    "/// @dev The creation bytecode of the contract.",
                    "CREATION_CODE",
                    type(RainterpreterExpressionDeployer).creationCode
                ),
                LibCodeGen.describedByMetaHashConstantString(vm, name),
                LibCodeGen.integrityFunctionPointersConstantString(vm, deployer)
            )
        );
    }

    /// Builds the RainterpreterReferenceExtern pointer file including
    /// described-by meta hash, parse meta, sub-parser word parsers, operand
    /// handlers, literal parsers, integrity pointers, and opcode pointers.
    function buildRainterpreterReferenceExternPointers() internal {
        address deployed = LibRainDeploy.deployZoltu(type(RainterpreterReferenceExtern).creationCode);
        RainterpreterReferenceExtern extern = RainterpreterReferenceExtern(deployed);

        string memory name = "RainterpreterReferenceExtern";

        LibFs.buildFileForContract(
            vm,
            deployed,
            name,
            string.concat(
                string.concat(
                    addressConstantString(deployed),
                    LibCodeGen.bytesConstantString(
                        vm,
                        "/// @dev The creation bytecode of the contract.",
                        "CREATION_CODE",
                        type(RainterpreterReferenceExtern).creationCode
                    ),
                    LibCodeGen.describedByMetaHashConstantString(vm, name),
                    LibGenParseMeta.parseMetaConstantString(
                        vm, LibRainterpreterReferenceExtern.authoringMetaV2(), EXTERN_PARSE_META_BUILD_DEPTH
                    ),
                    LibCodeGen.subParserWordParsersConstantString(vm, extern),
                    LibCodeGen.operandHandlerFunctionPointersConstantString(vm, extern),
                    LibCodeGen.literalParserFunctionPointersConstantString(vm, extern)
                ),
                string.concat(
                    LibCodeGen.integrityFunctionPointersConstantString(vm, extern),
                    LibCodeGen.opcodeFunctionPointersConstantString(vm, extern)
                )
            )
        );
    }

    /// Builds the RainterpreterDISPaiRegistry pointer file.
    function buildRainterpreterDISPaiRegistryPointers() internal {
        address deployed = LibRainDeploy.deployZoltu(type(RainterpreterDISPaiRegistry).creationCode);

        LibFs.buildFileForContract(
            vm,
            deployed,
            "RainterpreterDISPaiRegistry",
            string.concat(
                addressConstantString(deployed),
                LibCodeGen.bytesConstantString(
                    vm,
                    "/// @dev The creation bytecode of the contract.",
                    "CREATION_CODE",
                    type(RainterpreterDISPaiRegistry).creationCode
                )
            )
        );
    }

    /// Entry point. Etches the Zoltu factory and builds all pointer files.
    function run() external {
        LibRainDeploy.etchZoltuFactory(vm);

        buildRainterpreterPointers();
        buildRainterpreterStorePointers();
        buildRainterpreterParserPointers();
        buildRainterpreterExpressionDeployerPointers();
        buildRainterpreterReferenceExternPointers();
        buildRainterpreterDISPaiRegistryPointers();
    }
}
