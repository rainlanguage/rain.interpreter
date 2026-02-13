// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

/// @title LibInterpreterDeploy
/// A library containing the deployed address and code hash of the Interpreter
/// contracts when deployed with the rain standard zoltu deployer. This allows
/// idempotent deployments against precommitted addresses and hashes that can be
/// easily verified automatically in tests and scripts rather than relying on
/// registries or manual verification.
library LibInterpreterDeploy {
    /// The address of the `RainterpreterParser` contract when deployed with the
    /// rain standard zoltu deployer.
    address constant PARSER_DEPLOYED_ADDRESS = address(0x34ACfD304C67a78b8b3b64a1A3ae19b6854Fb5C1);

    /// The code hash of the `RainterpreterParser` contract when deployed with
    /// the rain standard zoltu deployer. This can be used to verify that the
    /// deployed contract has the expected bytecode, which provides stronger
    /// guarantees than just checking the address.
    bytes32 constant PARSER_DEPLOYED_CODEHASH =
        bytes32(0x01366d5f1a57df3c785384934aeb8bb3925918fc76dc2cacceeeee910cb9dd38);

    /// The address of the `RainterpreterStore` contract when deployed with the
    /// rain standard zoltu deployer.
    address constant STORE_DEPLOYED_ADDRESS = address(0x08d847643144D0bC1964b024b2CcCFFB94836f79);

    /// The code hash of the `RainterpreterStore` contract when deployed with
    /// the rain standard zoltu deployer. This can be used to verify that the
    /// deployed contract has the expected bytecode, which provides stronger
    /// guarantees than just checking the address.
    bytes32 constant STORE_DEPLOYED_CODEHASH =
        bytes32(0x0504fb2004eb1cad882a8eb495be50b9f2beacdc99e0b0d6b7d3eb1e32854210);

    /// The address of the `Rainterpreter` contract when deployed with the rain
    /// standard zoltu deployer.
    address constant INTERPRETER_DEPLOYED_ADDRESS = address(0x288F6ef6f56617963B80c6136eB93b3b9839Dfc2);

    /// The code hash of the `Rainterpreter` contract when deployed with the rain
    /// standard zoltu deployer. This can be used to verify that the deployed
    /// contract has the expected bytecode, which provides stronger guarantees
    /// than just checking the address.
    bytes32 constant INTERPRETER_DEPLOYED_CODEHASH =
        bytes32(0x1fbd8edd51e83869024d8f43ca5777828d9573b4bbb719d83988b85f067bc401);

    /// The address of the `ProdRainterpreterExpressionDeployer` contract when
    /// deployed with the rain standard zoltu deployer.
    address constant EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS = address(0x9F44A7E9D6DE4086C6628bA8863f1b36DD748C3D);

    /// The code hash of the `ProdRainterpreterExpressionDeployer` contract when
    /// deployed with the rain standard zoltu deployer. This can be used to
    /// verify that the deployed contract has the expected bytecode, which
    /// provides stronger guarantees than just checking the address.
    bytes32 constant EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH =
        bytes32(0x0574bc9fc95910f86c2b3024798647a01d14f4b75ae4cc853245820b05b041db);
}
