// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {Operand} from "src/interface/IInterpreterV1.sol";
import {LibOpEncodeBitsNP, TruncatedEncoding, ZeroLengthEncoding} from "src/lib/op/bitwise/LibOpEncodeBitsNP.sol";

contract LibOpEncodeBitsNPTest is OpTest {
    /// Directly test the integrity logic of LibOpEncodeBitsNP. All possible
    /// operands result in the same number of inputs and outputs, (2, 1).
    /// However, lengths can overflow and error so we bound the operand to avoid
    /// that here.
    function testOpEncodeBitsNPIntegrity(IntegrityCheckStateNP memory state, uint8 start8Bit, uint8 length8Bit)
        external
    {
        uint256 start = bound(uint256(start8Bit), 0, type(uint8).max - 1);
        uint256 length = bound(uint256(length8Bit), 1, type(uint8).max - start);
        Operand operand = Operand.wrap(2 << 0x10 | (uint256(start) << 8) | uint256(length));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpEncodeBitsNP.integrity(state, operand);
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpEncodeBitsNP. This tests the
    /// error when the length overflows.
    function testOpEncodeBitsNPIntegrityFail(IntegrityCheckStateNP memory state, uint8 start8Bit, uint8 length8Bit)
        external
    {
        // if start is [0,1] then length cannot overflow.
        uint256 start = bound(uint256(start8Bit), 2, type(uint8).max);
        uint256 length = bound(uint256(length8Bit), uint256(type(uint8).max) - start + 2, uint256(type(uint8).max));
        Operand operand = Operand.wrap(2 << 0x10 | (uint256(start) << 8) | uint256(length));
        vm.expectRevert(abi.encodeWithSelector(TruncatedEncoding.selector, start, length));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpEncodeBitsNP.integrity(state, operand);
        (calcInputs, calcOutputs);
    }

    /// Directly test the integrity logic of LibOpEncodeBitsNP. This tests the
    /// error when the length is zero.
    function testOpEncodeBitsNPIntegrityFailZeroLength(IntegrityCheckStateNP memory state, uint8 start) external {
        Operand operand = Operand.wrap(2 << 0x10 | (uint256(start) << 8) | 0);
        vm.expectRevert(abi.encodeWithSelector(ZeroLengthEncoding.selector));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpEncodeBitsNP.integrity(state, operand);
        (calcInputs, calcOutputs);
    }
}
