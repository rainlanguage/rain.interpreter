// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {BuildScript} from "rain-deploy-0.1.7/src/abstract/BuildScript.sol";
import {LibRainDeploySnapshot} from "rain-deploy-0.1.7/src/lib/LibRainDeploySnapshot.sol";
import {LibRainDeploy} from "rain-deploy-0.1.7/src/lib/LibRainDeploy.sol";
import {LibCodeGen} from "rain-sol-codegen-0.1.0/src/lib/LibCodeGen.sol";
import {LibFs} from "rain-sol-codegen-0.1.0/src/lib/LibFs.sol";
import {LibGenParseMeta} from "rainlang-interface-0.2.5/src/lib/codegen/LibGenParseMeta.sol";
import {DeployCandidate} from "../src/abstract/RainDeploySuitesBase.sol";
import {RainlangDeploySuites} from "../src/abstract/RainlangDeploySuites.sol";
import {RainlangParser, PARSE_META_BUILD_DEPTH} from "../src/concrete/RainlangParser.sol";
import {RainlangStore} from "../src/concrete/RainlangStore.sol";
import {RainlangInterpreter} from "../src/concrete/RainlangInterpreter.sol";
import {RainlangExpressionDeployer} from "../src/concrete/RainlangExpressionDeployer.sol";
import {
    RainlangReferenceExtern,
    LibRainlangReferenceExtern,
    EXTERN_PARSE_META_BUILD_DEPTH
} from "../src/concrete/extern/RainlangReferenceExtern.sol";
import {LibAllStandardOps} from "../src/lib/op/LibAllStandardOps.sol";

/// One contract's generated snapshot and the released-suites lib emitted from
/// its record.
struct GeneratedContract {
    /// Places the snapshot inside `src/generated/<dir>/` and names the
    /// generated released-suites lib.
    string contractName;
    /// Snapshots are written from its `sourceCreationCode` and
    /// `snapshot.dependencies`; the released lib takes its suite key and
    /// artifact path from its `snapshot`.
    DeployCandidate candidate;
}

/// @title Build
/// @notice Generates the deploy pins for every contract this repo deploys.
/// `generatedContracts()` is the only list, read by every hook below.
///
/// `run()` (what CI regenerates against) rewrites the rolling
/// `src/generated/candidate/` snapshots, the non-deploy codegen beside them
/// and the released-suites libs. `cutRelease()` freezes the candidates into
/// `src/generated/<tag>/` first. Frozen snapshots are append-only historical
/// records, never regenerated here.
///
/// Unlike the org's template deploy repos there are no generated alias libs:
/// `src/lib/deploy/LibInterpreterDeploy.sol` is hand-written over the
/// candidate snapshots because its constant names and its `etchRainlang`
/// helper are a published consumer API.
contract Build is BuildScript, RainlangDeploySuites {
    /// Every contract this repo generates deploy pins for, in deploy order:
    /// the expression deployer and `Rainlang` reach the ones before them at
    /// their deterministic addresses.
    /// @return The generated contracts.
    function generatedContracts() internal pure returns (GeneratedContract[] memory) {
        GeneratedContract[] memory contracts = new GeneratedContract[](5);
        contracts[0] = GeneratedContract({contractName: "RainlangParser", candidate: parserCandidate()});
        contracts[1] = GeneratedContract({contractName: "RainlangStore", candidate: storeCandidate()});
        contracts[2] = GeneratedContract({contractName: "RainlangInterpreter", candidate: interpreterCandidate()});
        contracts[3] =
            GeneratedContract({contractName: "RainlangExpressionDeployer", candidate: expressionDeployerCandidate()});
        contracts[4] = GeneratedContract({contractName: "Rainlang", candidate: rainlangCandidate()});
        return contracts;
    }

    /// @inheritdoc BuildScript
    /// @dev In declaration order — the order the aggregate emits its entries
    /// in.
    function snapshotContractNames() internal pure override returns (string[] memory) {
        GeneratedContract[] memory contracts = generatedContracts();
        string[] memory names = new string[](contracts.length);
        for (uint256 i = 0; i < contracts.length; i++) {
            names[i] = contracts[i].contractName;
        }
        return names;
    }

    /// @inheritdoc BuildScript
    /// @dev Every released-suites lib and the aggregate over them. No alias
    /// libs: `LibInterpreterDeploy` is hand-written.
    function regenerateLibs() internal override {
        GeneratedContract[] memory contracts = generatedContracts();
        for (uint256 i = 0; i < contracts.length; i++) {
            LibRainDeploySnapshot.writeReleasedSuitesLib(
                vm,
                LibRainDeploySnapshot.LIB_DIR,
                recordRoot(),
                contracts[i].contractName,
                contracts[i].candidate.snapshot
            );
        }
        LibRainDeploySnapshot.writeReleasedSuitesAggregate(vm, LibRainDeploySnapshot.LIB_DIR, snapshotContractNames());
    }

    /// @inheritdoc BuildScript
    function regenerateSnapshots() internal override {
        GeneratedContract[] memory contracts = generatedContracts();
        for (uint256 i = 0; i < contracts.length; i++) {
            LibRainDeploySnapshot.writeSnapshot(
                vm,
                LibRainDeploySnapshot.CANDIDATE,
                contracts[i].contractName,
                contracts[i].candidate.sourceCreationCode,
                contracts[i].candidate.snapshot.dependencies
            );
        }
        buildRainlangParserPointers();
        buildRainlangStorePointers();
        buildRainlangInterpreterPointers();
        buildRainlangExpressionDeployerPointers();
        buildRainlangReferenceExternPointers();
    }

    /// The parser's non-deploy codegen: parse meta, operand handler pointers
    /// and literal parser pointers.
    ///
    /// `LibRainDeploySnapshot.writeSnapshot` only ever emits deploy constants,
    /// so everything a contract needs to compile ITSELF lives in its own
    /// generated file — the usual committed-codegen cycle. The name is
    /// distinct from the contract's so the file cannot be taken for a snapshot
    /// of `RainlangParser`, and so it survives
    /// `LibFs.requireNoOrphanedArtifact` beside the candidate record.
    ///
    /// The instance read here is the one the `writeSnapshot` loop in
    /// `regenerateSnapshots` already deployed via the Zoltu factory, reached
    /// again through its deterministic address — deploying twice through the
    /// factory would collide.
    function buildRainlangParserPointers() internal {
        RainlangParser parser = RainlangParser(LibRainDeploy.zoltuAddress(type(RainlangParser).creationCode));

        LibFs.buildFileForContract(
            vm,
            address(parser),
            "RainlangParserPointers",
            string.concat(
                LibGenParseMeta.parseMetaConstantString(
                    vm, LibAllStandardOps.authoringMetaV2(), PARSE_META_BUILD_DEPTH
                ),
                LibCodeGen.operandHandlerFunctionPointersConstantString(vm, parser),
                LibCodeGen.literalParserFunctionPointersConstantString(vm, parser)
            )
        );
    }

    /// The store's only generated constant is the bytecode hash every
    /// generated file carries, which `RainlangStore` itself imports. It has no
    /// word tables, no parse meta and no function pointers, so the file is the
    /// header and nothing else.
    function buildRainlangStorePointers() internal {
        LibFs.buildFileForContract(
            vm, LibRainDeploy.zoltuAddress(type(RainlangStore).creationCode), "RainlangStorePointers", ""
        );
    }

    /// The interpreter's non-deploy codegen: its opcode function pointers.
    function buildRainlangInterpreterPointers() internal {
        RainlangInterpreter interpreter =
            RainlangInterpreter(LibRainDeploy.zoltuAddress(type(RainlangInterpreter).creationCode));

        LibFs.buildFileForContract(
            vm,
            address(interpreter),
            "RainlangInterpreterPointers",
            LibCodeGen.opcodeFunctionPointersConstantString(vm, interpreter)
        );
    }

    /// The expression deployer's non-deploy codegen: its described-by meta
    /// hash and integrity function pointers.
    function buildRainlangExpressionDeployerPointers() internal {
        RainlangExpressionDeployer deployer =
            RainlangExpressionDeployer(LibRainDeploy.zoltuAddress(type(RainlangExpressionDeployer).creationCode));

        LibFs.buildFileForContract(
            vm,
            address(deployer),
            "RainlangExpressionDeployerPointers",
            string.concat(
                LibCodeGen.describedByMetaHashConstantString(vm, "RainlangExpressionDeployer"),
                LibCodeGen.integrityFunctionPointersConstantString(vm, deployer)
            )
        );
    }

    /// The reference extern's codegen: described-by meta hash, parse meta,
    /// sub-parser word parsers, operand handlers, literal parsers, integrity
    /// pointers and opcode pointers.
    ///
    /// `RainlangReferenceExtern` is not a deploy candidate — it is a reference
    /// implementation of the extern and sub-parser interfaces rather than
    /// something this repo ships to a chain — so nothing in
    /// `generatedContracts()` deploys it and this function does, through the
    /// same factory, to read its tables back off the deployed instance.
    function buildRainlangReferenceExternPointers() internal {
        LibRainDeploy.etchZoltuFactory(vm);
        RainlangReferenceExtern extern =
            RainlangReferenceExtern(LibRainDeploy.deployZoltu(type(RainlangReferenceExtern).creationCode));

        LibFs.buildFileForContract(
            vm,
            address(extern),
            "RainlangReferenceExternPointers",
            string.concat(
                string.concat(
                    LibCodeGen.describedByMetaHashConstantString(vm, "RainlangReferenceExtern"),
                    LibGenParseMeta.parseMetaConstantString(
                        vm, LibRainlangReferenceExtern.authoringMetaV2(), EXTERN_PARSE_META_BUILD_DEPTH
                    ),
                    LibCodeGen.subParserWordParsersConstantString(vm, extern)
                ),
                string.concat(
                    LibCodeGen.operandHandlerFunctionPointersConstantString(vm, extern),
                    LibCodeGen.literalParserFunctionPointersConstantString(vm, extern),
                    LibCodeGen.integrityFunctionPointersConstantString(vm, extern),
                    LibCodeGen.opcodeFunctionPointersConstantString(vm, extern)
                )
            )
        );
    }
}
