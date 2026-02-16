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
    address constant PARSER_DEPLOYED_ADDRESS = address(0x2D571384605942B257e3Fe3960081833Db031FfC);

    /// The code hash of the `RainterpreterParser` contract when deployed with
    /// the rain standard zoltu deployer. This can be used to verify that the
    /// deployed contract has the expected bytecode, which provides stronger
    /// guarantees than just checking the address.
    bytes32 constant PARSER_DEPLOYED_CODEHASH =
        bytes32(0x822c1d64a2ae067d6392b45a235a3d526dc148695059a98bfaada8af8f3aa3f4);

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
    address constant INTERPRETER_DEPLOYED_ADDRESS = address(0x62dFF77E7DF78aFA6610e2a2089Cd88E16928828);

    /// The code hash of the `Rainterpreter` contract when deployed with the rain
    /// standard zoltu deployer. This can be used to verify that the deployed
    /// contract has the expected bytecode, which provides stronger guarantees
    /// than just checking the address.
    bytes32 constant INTERPRETER_DEPLOYED_CODEHASH =
        bytes32(0x7b37e726148f7506775a802bc811e7684d38e5c58fc1571d47e156ade7e4d877);

    /// The address of the `RainterpreterExpressionDeployer` contract when
    /// deployed with the rain standard zoltu deployer.
    address constant EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS = address(0xFD0C12d1F8D5d0783e715B77469A5C0a08BAd6F5);

    /// The code hash of the `RainterpreterExpressionDeployer` contract when
    /// deployed with the rain standard zoltu deployer. This can be used to
    /// verify that the deployed contract has the expected bytecode, which
    /// provides stronger guarantees than just checking the address.
    bytes32 constant EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH =
        bytes32(0x50e5fb6ddb750f71cf8ed206b92c06834dd4d3703ad023e46c7a41d1507a1059);

    /// The address of the `RainterpreterDISPaiRegistry` contract when deployed
    /// with the rain standard zoltu deployer.
    address constant DISPAIR_REGISTRY_DEPLOYED_ADDRESS = address(0xe7c1EF0DAb8ed6615bA84e802dEBC6629f699822);

    /// The code hash of the `RainterpreterDISPaiRegistry` contract when
    /// deployed with the rain standard zoltu deployer. This can be used to
    /// verify that the deployed contract has the expected bytecode, which
    /// provides stronger guarantees than just checking the address.
    bytes32 constant DISPAIR_REGISTRY_DEPLOYED_CODEHASH =
        bytes32(0xc4a55403ca4cfe85e522f39df6513b89f216a6e13c5f9a0ca09f9284360ec8d9);
}
