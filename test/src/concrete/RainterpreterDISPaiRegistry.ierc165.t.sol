// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {RainterpreterDISPaiRegistry} from "src/concrete/RainterpreterDISPaiRegistry.sol";
import {IDISPaiRegistry} from "src/interface/IDISPaiRegistry.sol";

/// @title RainterpreterDISPaiRegistryIERC165Test
/// @notice Test that ERC165 is implemented for the DISPaiR registry.
contract RainterpreterDISPaiRegistryIERC165Test is Test {
    /// Test that ERC165 is implemented for all interfaces.
    function testRainterpreterDISPaiRegistryIERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IDISPaiRegistry).interfaceId);

        RainterpreterDISPaiRegistry registry = new RainterpreterDISPaiRegistry();
        assertTrue(registry.supportsInterface(type(IERC165).interfaceId));
        assertTrue(registry.supportsInterface(type(IDISPaiRegistry).interfaceId));

        assertFalse(registry.supportsInterface(badInterfaceId));
    }
}
