// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {BaseRainterpreterExtern} from "src/abstract/BaseRainterpreterExtern.sol";
import {ExternPointersMismatch} from "src/error/ErrExtern.sol";

/// @dev Extern with 2 opcode pointers but 1 integrity pointer.
contract MismatchedExternMoreOpcodes is BaseRainterpreterExtern {
    function opcodeFunctionPointers() internal pure override returns (bytes memory) {
        return hex"00010002";
    }

    function integrityFunctionPointers() internal pure override returns (bytes memory) {
        return hex"0001";
    }

    function buildIntegrityFunctionPointers() external pure returns (bytes memory) {
        return integrityFunctionPointers();
    }

    function buildOpcodeFunctionPointers() external pure returns (bytes memory) {
        return opcodeFunctionPointers();
    }
}

/// @dev Extern with 1 opcode pointer but 2 integrity pointers.
contract MismatchedExternMoreIntegrity is BaseRainterpreterExtern {
    function opcodeFunctionPointers() internal pure override returns (bytes memory) {
        return hex"0001";
    }

    function integrityFunctionPointers() internal pure override returns (bytes memory) {
        return hex"00010002";
    }

    function buildIntegrityFunctionPointers() external pure returns (bytes memory) {
        return integrityFunctionPointers();
    }

    function buildOpcodeFunctionPointers() external pure returns (bytes memory) {
        return opcodeFunctionPointers();
    }
}

/// @title BaseRainterpreterExternConstructionTest
/// Tests construction invariants for BaseRainterpreterExtern.
contract BaseRainterpreterExternConstructionTest is Test {
    /// Construction reverts when opcode pointers outnumber integrity pointers.
    function testExternConstructorRevertsMoreOpcodes() external {
        vm.expectRevert(abi.encodeWithSelector(ExternPointersMismatch.selector, 4, 2));
        new MismatchedExternMoreOpcodes();
    }

    /// Construction reverts when integrity pointers outnumber opcode pointers.
    function testExternConstructorRevertsMoreIntegrity() external {
        vm.expectRevert(abi.encodeWithSelector(ExternPointersMismatch.selector, 2, 4));
        new MismatchedExternMoreIntegrity();
    }
}
