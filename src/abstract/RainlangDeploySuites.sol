// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {DeployCandidate, DeploySuite, RainDeploySuitesBase} from "./RainDeploySuitesBase.sol";
import {RainlangParser} from "../concrete/RainlangParser.sol";
import {RainlangStore} from "../concrete/RainlangStore.sol";
import {RainlangInterpreter} from "../concrete/RainlangInterpreter.sol";
import {RainlangExpressionDeployer} from "../concrete/RainlangExpressionDeployer.sol";
import {Rainlang} from "../concrete/Rainlang.sol";
import {LibInterpreterDeploy} from "../lib/deploy/LibInterpreterDeploy.sol";
import {LibReleasedSuites} from "../lib/LibReleasedSuites.sol";
import {LibDecimalFloatDeploy} from "rain-math-float-0.1.1/src/lib/deploy/LibDecimalFloatDeploy.sol";
import {LibTOFUTokenDecimals} from "rain-tofu-erc20-decimals-0.1.1/src/lib/LibTOFUTokenDecimals.sol";
import {
    CREATION_CODE as PARSER_CREATION_CODE_CANDIDATE,
    RUNTIME_CODE as PARSER_RUNTIME_CODE_CANDIDATE
} from "../generated/candidate/RainlangParser.sol";
import {
    CREATION_CODE as STORE_CREATION_CODE_CANDIDATE,
    RUNTIME_CODE as STORE_RUNTIME_CODE_CANDIDATE
} from "../generated/candidate/RainlangStore.sol";
import {
    CREATION_CODE as INTERPRETER_CREATION_CODE_CANDIDATE,
    RUNTIME_CODE as INTERPRETER_RUNTIME_CODE_CANDIDATE
} from "../generated/candidate/RainlangInterpreter.sol";
import {
    CREATION_CODE as EXPRESSION_DEPLOYER_CREATION_CODE_CANDIDATE,
    RUNTIME_CODE as EXPRESSION_DEPLOYER_RUNTIME_CODE_CANDIDATE
} from "../generated/candidate/RainlangExpressionDeployer.sol";
import {
    CREATION_CODE as RAINLANG_CREATION_CODE_CANDIDATE,
    RUNTIME_CODE as RAINLANG_RUNTIME_CODE_CANDIDATE
} from "../generated/candidate/Rainlang.sol";

/// @title RainlangDeploySuites
/// @notice Everything this repo deploys, declared ONCE: the five hand-written
/// candidates below, and the released side read from the generated
/// `LibReleasedSuites`, which `script/Build.sol` emits from the frozen record.
///
/// The suite keys are the `Manual sol artifacts` dispatch choices and MUST
/// stay in step with `.github/workflows/manual-sol-artifacts.yaml`.
///
/// `RainlangReferenceExtern` is deliberately absent. It is a reference
/// implementation of the extern/sub-parser interfaces, compiled and codegen'd
/// so its word tables stay honest, but it is not something this repo ships to
/// a chain — it is in none of the deploy script, the dispatch choices or the
/// deploy-pin lib, and declaring it a candidate would make the chain group
/// demand it be live on all seven networks from the first release onwards.
/// Its non-deploy codegen lives in `src/generated/RainlangReferenceExternPointers.sol`.
///
/// It lives in `src/` rather than `test/` because `.soldeerignore` would
/// otherwise be free to drop it, and the deployment process is part of the
/// product.
abstract contract RainlangDeploySuites is RainDeploySuitesBase {
    /// @inheritdoc RainDeploySuitesBase
    function releasedSuites() internal pure override returns (DeploySuite[] memory) {
        return LibReleasedSuites.releasedSuites();
    }

    /// @inheritdoc RainDeploySuitesBase
    function candidateSuites() internal pure override returns (DeployCandidate[] memory) {
        DeployCandidate[] memory candidates = new DeployCandidate[](5);
        candidates[0] = parserCandidate();
        candidates[1] = storeCandidate();
        candidates[2] = interpreterCandidate();
        candidates[3] = expressionDeployerCandidate();
        candidates[4] = rainlangCandidate();
        return candidates;
    }

    /// The decimal float log tables, which every contract here reaches through
    /// `LibDecimalFloat`.
    /// @return The dependency addresses.
    function logTablesOnly() internal pure returns (address[] memory) {
        address[] memory deps = new address[](1);
        deps[0] = LibDecimalFloatDeploy.ZOLTU_DEPLOYED_LOG_TABLES_ADDRESS;
        return deps;
    }

    /// This repo's rolling `RainlangParser` candidate. Each candidate is a
    /// named function rather than an index into `candidateSuites`, because
    /// `script/Build.sol` emits snapshots from these candidates specifically,
    /// and because five full creation codes built in one frame do not fit the
    /// legacy codegen's stack.
    /// @return The candidate.
    function parserCandidate() internal pure returns (DeployCandidate memory) {
        return DeployCandidate({
            snapshot: DeploySuite({
                suite: "parser",
                creationCode: PARSER_CREATION_CODE_CANDIDATE,
                storedDeployedAddress: LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS,
                storedBytecodeHash: LibInterpreterDeploy.PARSER_DEPLOYED_CODEHASH,
                storedRuntimeCode: PARSER_RUNTIME_CODE_CANDIDATE,
                artifactPath: "src/concrete/RainlangParser.sol:RainlangParser",
                dependencies: logTablesOnly()
            }),
            sourceCreationCode: type(RainlangParser).creationCode
        });
    }

    /// This repo's rolling `RainlangStore` candidate.
    /// @return The candidate.
    function storeCandidate() internal pure returns (DeployCandidate memory) {
        return DeployCandidate({
            snapshot: DeploySuite({
                suite: "store",
                creationCode: STORE_CREATION_CODE_CANDIDATE,
                storedDeployedAddress: LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS,
                storedBytecodeHash: LibInterpreterDeploy.STORE_DEPLOYED_CODEHASH,
                storedRuntimeCode: STORE_RUNTIME_CODE_CANDIDATE,
                artifactPath: "src/concrete/RainlangStore.sol:RainlangStore",
                dependencies: logTablesOnly()
            }),
            sourceCreationCode: type(RainlangStore).creationCode
        });
    }

    /// This repo's rolling `RainlangInterpreter` candidate.
    /// @return The candidate.
    function interpreterCandidate() internal pure returns (DeployCandidate memory) {
        address[] memory deps = new address[](2);
        deps[0] = LibDecimalFloatDeploy.ZOLTU_DEPLOYED_LOG_TABLES_ADDRESS;
        deps[1] = address(LibTOFUTokenDecimals.TOFU_DECIMALS_DEPLOYMENT);
        return DeployCandidate({
            snapshot: DeploySuite({
                suite: "interpreter",
                creationCode: INTERPRETER_CREATION_CODE_CANDIDATE,
                storedDeployedAddress: LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS,
                storedBytecodeHash: LibInterpreterDeploy.INTERPRETER_DEPLOYED_CODEHASH,
                storedRuntimeCode: INTERPRETER_RUNTIME_CODE_CANDIDATE,
                artifactPath: "src/concrete/RainlangInterpreter.sol:RainlangInterpreter",
                dependencies: deps
            }),
            sourceCreationCode: type(RainlangInterpreter).creationCode
        });
    }

    /// This repo's rolling `RainlangExpressionDeployer` candidate. It reaches
    /// the parser, store and interpreter at their deterministic addresses, so
    /// all three must already be live on a network before it can be broadcast
    /// there.
    /// @return The candidate.
    function expressionDeployerCandidate() internal pure returns (DeployCandidate memory) {
        address[] memory deps = new address[](5);
        deps[0] = LibDecimalFloatDeploy.ZOLTU_DEPLOYED_LOG_TABLES_ADDRESS;
        deps[1] = address(LibTOFUTokenDecimals.TOFU_DECIMALS_DEPLOYMENT);
        deps[2] = LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS;
        deps[3] = LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS;
        deps[4] = LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS;
        return DeployCandidate({
            snapshot: DeploySuite({
                suite: "expression-deployer",
                creationCode: EXPRESSION_DEPLOYER_CREATION_CODE_CANDIDATE,
                storedDeployedAddress: LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS,
                storedBytecodeHash: LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH,
                storedRuntimeCode: EXPRESSION_DEPLOYER_RUNTIME_CODE_CANDIDATE,
                artifactPath: "src/concrete/RainlangExpressionDeployer.sol:RainlangExpressionDeployer",
                dependencies: deps
            }),
            sourceCreationCode: type(RainlangExpressionDeployer).creationCode
        });
    }

    /// This repo's rolling `Rainlang` candidate — the facade over the other
    /// four, so all four must already be live on a network before it can be
    /// broadcast there.
    /// @return The candidate.
    function rainlangCandidate() internal pure returns (DeployCandidate memory) {
        address[] memory deps = new address[](5);
        deps[0] = address(LibTOFUTokenDecimals.TOFU_DECIMALS_DEPLOYMENT);
        deps[1] = LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS;
        deps[2] = LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS;
        deps[3] = LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS;
        deps[4] = LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS;
        return DeployCandidate({
            snapshot: DeploySuite({
                suite: "rainlang",
                creationCode: RAINLANG_CREATION_CODE_CANDIDATE,
                storedDeployedAddress: LibInterpreterDeploy.RAINLANG_DEPLOYED_ADDRESS,
                storedBytecodeHash: LibInterpreterDeploy.RAINLANG_DEPLOYED_CODEHASH,
                storedRuntimeCode: RAINLANG_RUNTIME_CODE_CANDIDATE,
                artifactPath: "src/concrete/Rainlang.sol:Rainlang",
                dependencies: deps
            }),
            sourceCreationCode: type(Rainlang).creationCode
        });
    }
}
