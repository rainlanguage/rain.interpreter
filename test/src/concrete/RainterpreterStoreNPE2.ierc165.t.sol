// SPDX-License-Identifier: CAL
pragma solidity =0.8.26;

import {Test} from "forge-std/Test.sol";

import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {RainterpreterStoreNPE2} from "src/concrete/RainterpreterStoreNPE2.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";

contract RainterpreterStoreNPE2IERC165Test is Test {
    /// Test that ERC165 is implemented for all interfaces.
    function testRainterpreterStoreNPE2IERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterStoreV2).interfaceId);

        RainterpreterStoreNPE2 store = new RainterpreterStoreNPE2();
        assertTrue(store.supportsInterface(type(IERC165).interfaceId));
        assertTrue(store.supportsInterface(type(IInterpreterStoreV2).interfaceId));

        assertFalse(store.supportsInterface(badInterfaceId));
    }
}
