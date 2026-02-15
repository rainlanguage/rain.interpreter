// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {BaseRainterpreterExtern} from "src/abstract/BaseRainterpreterExtern.sol";
import {ExternDispatchV2} from "rain.interpreter.interface/interface/IInterpreterExternV4.sol";
import {ExternOpcodeOutOfRange} from "src/error/ErrExtern.sol";

/// @dev Extern with exactly 2 opcode and integrity pointers.
contract TwoOpExtern is BaseRainterpreterExtern {
    function opcodeFunctionPointers() internal pure override returns (bytes memory) {
        return hex"00010002";
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

/// @title BaseRainterpreterExternIntegrityOpcodeRangeTest
/// Tests that externIntegrity reverts for out-of-range opcodes.
contract BaseRainterpreterExternIntegrityOpcodeRangeTest is Test {
    /// Any opcode >= fsCount must revert with ExternOpcodeOutOfRange.
    function testExternIntegrityRevertsOpcodeOutOfRange(uint16 opcode, uint16 operand) external {
        // TwoOpExtern has 2 pointers, so valid opcodes are 0 and 1.
        vm.assume(opcode >= 2);
        TwoOpExtern extern = new TwoOpExtern();

        // Encode opcode into bits 16-31 and operand into bits 0-15 of the
        // dispatch bytes32.
        bytes32 dispatch = bytes32(uint256(opcode)) << 0x10 | bytes32(uint256(operand));

        vm.expectRevert(abi.encodeWithSelector(ExternOpcodeOutOfRange.selector, uint256(opcode), 2));
        extern.externIntegrity(ExternDispatchV2.wrap(dispatch), 0, 0);
    }
}
