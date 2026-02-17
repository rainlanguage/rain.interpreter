// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {RainterpreterStore} from "src/concrete/RainterpreterStore.sol";
import {IInterpreterStoreV3} from "rain.interpreter.interface/interface/IInterpreterStoreV3.sol";

contract RainterpreterStoreIERC165Test is Test {
    /// Store should introspect support for `IERC165` and `IInterpreterStoreV3`.
    /// It should not support any other interface.
    function testRainterpreterStoreIERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterStoreV3).interfaceId);

        RainterpreterStore store = new RainterpreterStore();
        assertTrue(store.supportsInterface(type(IERC165).interfaceId));
        assertTrue(store.supportsInterface(type(IInterpreterStoreV3).interfaceId));

        assertFalse(store.supportsInterface(badInterfaceId));
    }
}
