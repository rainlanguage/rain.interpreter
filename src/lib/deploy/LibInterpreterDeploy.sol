// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {Vm} from "forge-std/Vm.sol";

import {
    BYTECODE_HASH as PARSER_HASH,
    DEPLOYED_ADDRESS as PARSER_ADDR,
    RUNTIME_CODE as PARSER_RUNTIME_CODE
} from "../../generated/RainterpreterParser.pointers.sol";
import {
    BYTECODE_HASH as STORE_HASH,
    DEPLOYED_ADDRESS as STORE_ADDR,
    RUNTIME_CODE as STORE_RUNTIME_CODE
} from "../../generated/RainterpreterStore.pointers.sol";
import {
    BYTECODE_HASH as INTERPRETER_HASH,
    DEPLOYED_ADDRESS as INTERPRETER_ADDR,
    RUNTIME_CODE as INTERPRETER_RUNTIME_CODE
} from "../../generated/Rainterpreter.pointers.sol";
import {
    BYTECODE_HASH as EXPRESSION_DEPLOYER_HASH,
    DEPLOYED_ADDRESS as EXPRESSION_DEPLOYER_ADDR,
    RUNTIME_CODE as EXPRESSION_DEPLOYER_RUNTIME_CODE
} from "../../generated/RainterpreterExpressionDeployer.pointers.sol";
import {
    BYTECODE_HASH as DISPAIR_REGISTRY_HASH,
    DEPLOYED_ADDRESS as DISPAIR_REGISTRY_ADDR,
    RUNTIME_CODE as DISPAIR_REGISTRY_RUNTIME_CODE
} from "../../generated/RainterpreterDISPaiRegistry.pointers.sol";

/// @title LibInterpreterDeploy
/// @notice A library containing the deployed address and code hash of the Interpreter
/// contracts when deployed with the rain standard zoltu deployer. This allows
/// idempotent deployments against precommitted addresses and hashes that can be
/// easily verified automatically in tests and scripts rather than relying on
/// registries or manual verification.
library LibInterpreterDeploy {
    /// The address of the `RainterpreterParser` contract when deployed with the
    /// rain standard zoltu deployer.
    address constant PARSER_DEPLOYED_ADDRESS = PARSER_ADDR;

    /// The code hash of the `RainterpreterParser` contract when deployed with
    /// the rain standard zoltu deployer. This can be used to verify that the
    /// deployed contract has the expected bytecode, which provides stronger
    /// guarantees than just checking the address.
    bytes32 constant PARSER_DEPLOYED_CODEHASH = PARSER_HASH;

    /// The address of the `RainterpreterStore` contract when deployed with the
    /// rain standard zoltu deployer.
    address constant STORE_DEPLOYED_ADDRESS = STORE_ADDR;

    /// The code hash of the `RainterpreterStore` contract when deployed with
    /// the rain standard zoltu deployer. This can be used to verify that the
    /// deployed contract has the expected bytecode, which provides stronger
    /// guarantees than just checking the address.
    bytes32 constant STORE_DEPLOYED_CODEHASH = STORE_HASH;

    /// The address of the `Rainterpreter` contract when deployed with the rain
    /// standard zoltu deployer.
    address constant INTERPRETER_DEPLOYED_ADDRESS = INTERPRETER_ADDR;

    /// The code hash of the `Rainterpreter` contract when deployed with the rain
    /// standard zoltu deployer. This can be used to verify that the deployed
    /// contract has the expected bytecode, which provides stronger guarantees
    /// than just checking the address.
    bytes32 constant INTERPRETER_DEPLOYED_CODEHASH = INTERPRETER_HASH;

    /// The address of the `RainterpreterExpressionDeployer` contract when
    /// deployed with the rain standard zoltu deployer.
    address constant EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS = EXPRESSION_DEPLOYER_ADDR;

    /// The code hash of the `RainterpreterExpressionDeployer` contract when
    /// deployed with the rain standard zoltu deployer. This can be used to
    /// verify that the deployed contract has the expected bytecode, which
    /// provides stronger guarantees than just checking the address.
    bytes32 constant EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH = EXPRESSION_DEPLOYER_HASH;

    /// The address of the `RainterpreterDISPaiRegistry` contract when deployed
    /// with the rain standard zoltu deployer.
    address constant DISPAIR_REGISTRY_DEPLOYED_ADDRESS = DISPAIR_REGISTRY_ADDR;

    /// The code hash of the `RainterpreterDISPaiRegistry` contract when
    /// deployed with the rain standard zoltu deployer. This can be used to
    /// verify that the deployed contract has the expected bytecode, which
    /// provides stronger guarantees than just checking the address.
    bytes32 constant DISPAIR_REGISTRY_DEPLOYED_CODEHASH = DISPAIR_REGISTRY_HASH;

    /// @notice Etches the runtime bytecode of the parser, store, interpreter,
    /// expression deployer, and DISPair registry at their expected
    /// deterministic addresses. Skips any contract whose codehash already
    /// matches.
    /// @param vm The Forge `Vm` cheatcode interface.
    function etchDISPaiR(Vm vm) internal {
        if (PARSER_DEPLOYED_CODEHASH != PARSER_DEPLOYED_ADDRESS.codehash) {
            vm.etch(PARSER_DEPLOYED_ADDRESS, PARSER_RUNTIME_CODE);
        }
        if (STORE_DEPLOYED_CODEHASH != STORE_DEPLOYED_ADDRESS.codehash) {
            vm.etch(STORE_DEPLOYED_ADDRESS, STORE_RUNTIME_CODE);
        }
        if (INTERPRETER_DEPLOYED_CODEHASH != INTERPRETER_DEPLOYED_ADDRESS.codehash) {
            vm.etch(INTERPRETER_DEPLOYED_ADDRESS, INTERPRETER_RUNTIME_CODE);
        }
        if (EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH != EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS.codehash) {
            vm.etch(EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS, EXPRESSION_DEPLOYER_RUNTIME_CODE);
        }
        if (DISPAIR_REGISTRY_DEPLOYED_CODEHASH != DISPAIR_REGISTRY_DEPLOYED_ADDRESS.codehash) {
            vm.etch(DISPAIR_REGISTRY_DEPLOYED_ADDRESS, DISPAIR_REGISTRY_RUNTIME_CODE);
        }
    }
}
