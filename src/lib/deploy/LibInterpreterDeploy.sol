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
    address constant PARSER_DEPLOYED_ADDRESS = address(0xE771CB7A2C0cC34ab68Eb7f5f7973ccBDf4f18E7);

    /// The code hash of the `RainterpreterParser` contract when deployed with
    /// the rain standard zoltu deployer. This can be used to verify that the
    /// deployed contract has the expected bytecode, which provides stronger
    /// guarantees than just checking the address.
    bytes32 constant PARSER_DEPLOYED_CODEHASH =
        bytes32(0x0a82033aa519f6cfc574ff2fd37340285f1bf5e432eec61b047dab78f453d615);

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
    address constant EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS = address(0xa7067aa8834DE74eDa4061999929Ae02adcDDe64);

    /// The code hash of the `RainterpreterExpressionDeployer` contract when
    /// deployed with the rain standard zoltu deployer. This can be used to
    /// verify that the deployed contract has the expected bytecode, which
    /// provides stronger guarantees than just checking the address.
    bytes32 constant EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH =
        bytes32(0xf9e6af09d0671611f8be055870c97c3a7c4c598329e2d617158e194b0484893e);

    /// The address of the `RainterpreterDISPaiRegistry` contract when deployed
    /// with the rain standard zoltu deployer.
    address constant DISPAIR_REGISTRY_DEPLOYED_ADDRESS = address(0xb0C5ec55F355e8FaB78D4c82437D0dF2f4688a67);

    /// The code hash of the `RainterpreterDISPaiRegistry` contract when
    /// deployed with the rain standard zoltu deployer. This can be used to
    /// verify that the deployed contract has the expected bytecode, which
    /// provides stronger guarantees than just checking the address.
    bytes32 constant DISPAIR_REGISTRY_DEPLOYED_CODEHASH =
        bytes32(0x79edc50d772f7f1c1105742f21a20089bea85ad001fe7f156ef3ac0b3e7a1191);
}
