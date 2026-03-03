// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

/// @title LibInterpreterDeploy
/// @notice A library containing the deployed address and code hash of the Interpreter
/// contracts when deployed with the rain standard zoltu deployer. This allows
/// idempotent deployments against precommitted addresses and hashes that can be
/// easily verified automatically in tests and scripts rather than relying on
/// registries or manual verification.
library LibInterpreterDeploy {
    /// The address of the `RainterpreterParser` contract when deployed with the
    /// rain standard zoltu deployer.
    address constant PARSER_DEPLOYED_ADDRESS = address(0x744d1fFF170FC824EcEDb4E220819682095dFE83);

    /// The code hash of the `RainterpreterParser` contract when deployed with
    /// the rain standard zoltu deployer. This can be used to verify that the
    /// deployed contract has the expected bytecode, which provides stronger
    /// guarantees than just checking the address.
    bytes32 constant PARSER_DEPLOYED_CODEHASH =
        bytes32(0xcca04b4215c721df539f9a2525ea402fd5fc6905f4a0fee036a6e979b905ca18);

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
    address constant INTERPRETER_DEPLOYED_ADDRESS = address(0xe758FACfeb8E02bfed2d8C53B731D687DDD88A68);

    /// The code hash of the `Rainterpreter` contract when deployed with the rain
    /// standard zoltu deployer. This can be used to verify that the deployed
    /// contract has the expected bytecode, which provides stronger guarantees
    /// than just checking the address.
    bytes32 constant INTERPRETER_DEPLOYED_CODEHASH =
        bytes32(0x66a2e1c7c62ac40c6dc3c281364370e8fd18e2cce1a2819dc38b01880cbce0fa);

    /// The address of the `RainterpreterExpressionDeployer` contract when
    /// deployed with the rain standard zoltu deployer.
    address constant EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS = address(0x3Dcbe436dC61dd38635bB32aFc8C9487F6EFa5b6);

    /// The code hash of the `RainterpreterExpressionDeployer` contract when
    /// deployed with the rain standard zoltu deployer. This can be used to
    /// verify that the deployed contract has the expected bytecode, which
    /// provides stronger guarantees than just checking the address.
    bytes32 constant EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH =
        bytes32(0x58937b2f2590a07a3c3f93b766fd9dc1890de7a85239282e9a0928068d329b6c);

    /// The address of the `RainterpreterDISPaiRegistry` contract when deployed
    /// with the rain standard zoltu deployer.
    address constant DISPAIR_REGISTRY_DEPLOYED_ADDRESS = address(0x877e3e8D0860235f4F4F771a3E71B076f47b23Ac);

    /// The code hash of the `RainterpreterDISPaiRegistry` contract when
    /// deployed with the rain standard zoltu deployer. This can be used to
    /// verify that the deployed contract has the expected bytecode, which
    /// provides stronger guarantees than just checking the address.
    bytes32 constant DISPAIR_REGISTRY_DEPLOYED_CODEHASH =
        bytes32(0xaa0a08b32797ce90d646ca05dcc64b53b0bb34ba7b15834619a51b567294470f);
}
