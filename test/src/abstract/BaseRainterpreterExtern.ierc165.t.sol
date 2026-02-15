// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {IInterpreterExternV4} from "rain.interpreter.interface/interface/IInterpreterExternV4.sol";
import {BaseRainterpreterExtern} from "src/abstract/BaseRainterpreterExtern.sol";
import {IIntegrityToolingV1} from "rain.sol.codegen/interface/IIntegrityToolingV1.sol";
import {IOpcodeToolingV1} from "rain.sol.codegen/interface/IOpcodeToolingV1.sol";

/// @dev We need a contract that is deployable in order to test the abstract
/// base contract.
contract ChildRainterpreterExtern is BaseRainterpreterExtern {
    function buildIntegrityFunctionPointers() external pure returns (bytes memory) {
        return new bytes(0);
    }

    function buildOpcodeFunctionPointers() external pure returns (bytes memory) {
        return new bytes(0);
    }
}

/// @title BaseRainterpreterExternTest
/// Test suite for BaseRainterpreterExtern.
contract BaseRainterpreterExternIERC165Test is Test {
    /// Test that ERC165 and IInterpreterExternV4 are supported interfaces as
    /// per ERC165.
    function testRainterpreterExternIERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterExternV4).interfaceId);
        vm.assume(badInterfaceId != type(IIntegrityToolingV1).interfaceId);
        vm.assume(badInterfaceId != type(IOpcodeToolingV1).interfaceId);

        ChildRainterpreterExtern extern = new ChildRainterpreterExtern();
        assertTrue(extern.supportsInterface(type(IERC165).interfaceId));
        assertTrue(extern.supportsInterface(type(IInterpreterExternV4).interfaceId));
        assertTrue(extern.supportsInterface(type(IIntegrityToolingV1).interfaceId));
        assertTrue(extern.supportsInterface(type(IOpcodeToolingV1).interfaceId));
        assertFalse(extern.supportsInterface(badInterfaceId));
    }
}
