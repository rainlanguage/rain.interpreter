// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {LibInterpreterDeploy} from "../lib/deploy/LibInterpreterDeploy.sol";
import {IDISPaiRegistry} from "../interface/IDISPaiRegistry.sol";
import {ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

/// @title RainterpreterDISPaiRegistry
/// @notice DISPaiR registry contract that exposes the deterministic Zoltu deploy
/// addresses of the four core interpreter components: Deployer, Interpreter,
/// Store, and Parser. Deployed via the same Zoltu pattern so that external
/// tooling can discover all component addresses from a single known registry
/// address.
contract RainterpreterDISPaiRegistry is IDISPaiRegistry, ERC165 {
    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IDISPaiRegistry).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IDISPaiRegistry
    function expressionDeployerAddress() external pure override returns (address) {
        return LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS;
    }

    /// @inheritdoc IDISPaiRegistry
    function interpreterAddress() external pure override returns (address) {
        return LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS;
    }

    /// @inheritdoc IDISPaiRegistry
    function storeAddress() external pure override returns (address) {
        return LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS;
    }

    /// @inheritdoc IDISPaiRegistry
    function parserAddress() external pure override returns (address) {
        return LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS;
    }
}
