// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

/// @title IDISPaiRegistry
/// @notice Interface for a DISPaiR (Deployer, Interpreter, Store, Parser)
/// registry that exposes the deterministic deploy addresses of the four core
/// interpreter components.
interface IDISPaiRegistry {
    /// Returns the deterministic deploy address of the expression deployer.
    /// @return The expression deployer address.
    function expressionDeployerAddress() external pure returns (address);

    /// Returns the deterministic deploy address of the interpreter.
    /// @return The interpreter address.
    function interpreterAddress() external pure returns (address);

    /// Returns the deterministic deploy address of the store.
    /// @return The store address.
    function storeAddress() external pure returns (address);

    /// Returns the deterministic deploy address of the parser.
    /// @return The parser address.
    function parserAddress() external pure returns (address);
}
