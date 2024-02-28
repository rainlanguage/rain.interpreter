// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {IInterpreterExternV3} from "rain.interpreter.interface/interface/IInterpreterExternV3.sol";
import {BaseRainterpreterExternNPE2} from "src/abstract/BaseRainterpreterExternNPE2.sol";

/// @dev We need a contract that is deployable in order to test the abstract
/// base contract.
contract ChildRainterpreterExternNPE2 is BaseRainterpreterExternNPE2 {}

/// @title BaseRainterpreterExternNPE2Test
/// Test suite for BaseRainterpreterExternNPE2.
contract BaseRainterpreterExternNPE2IERC165Test is Test {
    /// Test that ERC165 and IInterpreterExternV3 are supported interfaces as
    /// per ERC165.
    function testRainterpreterExternNPE2IERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterExternV3).interfaceId);

        ChildRainterpreterExternNPE2 extern = new ChildRainterpreterExternNPE2();
        assertTrue(extern.supportsInterface(type(IERC165).interfaceId));
        assertTrue(extern.supportsInterface(type(IInterpreterExternV3).interfaceId));
        assertFalse(extern.supportsInterface(badInterfaceId));
    }
}
