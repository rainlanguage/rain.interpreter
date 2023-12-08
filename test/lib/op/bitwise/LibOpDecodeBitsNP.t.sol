// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {TruncatedBitwiseEncoding, ZeroLengthBitwiseEncoding} from "src/error/ErrBitwise.sol";
import {LibOpDecodeBitsNP} from "src/lib/op/bitwise/LibOpDecodeBitsNP.sol";

contract LibOpDecodeBitsNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecodeBitsNP. All possible
    /// operands result in the same number of inputs and outputs, (2, 1).
    /// However, lengths can overflow and error so we bound the operand to avoid
    /// that here.
    function testOpDecodeBitsNPIntegrity(IntegrityCheckStateNP memory state, uint8 start8Bit, uint8 length8Bit)
        external
    {
        uint256 start = bound(uint256(start8Bit), 0, type(uint8).max);
        uint256 length = bound(uint256(length8Bit), 1, type(uint8).max - start + 1);
        Operand operand = Operand.wrap(2 << 0x10 | (uint256(length) << 8) | uint256(start));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecodeBitsNP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpDecodeBitsNP. This tests the
    /// error when the length overflows.
    function testOpDecodeBitsNPIntegrityFail(IntegrityCheckStateNP memory state, uint8 start8Bit, uint8 length8Bit)
        external
    {
        // if start is [0,1] then length cannot overflow.
        uint256 start = bound(uint256(start8Bit), 2, type(uint8).max);
        uint256 length = bound(uint256(length8Bit), uint256(type(uint8).max) - start + 2, uint256(type(uint8).max));
        Operand operand = Operand.wrap(2 << 0x10 | (uint256(length) << 8) | uint256(start));
        vm.expectRevert(abi.encodeWithSelector(TruncatedBitwiseEncoding.selector, start, length));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecodeBitsNP.integrity(state, operand);
        (calcInputs, calcOutputs);
    }

    /// Directly test the integrity logic of LibOpDecodeBitsNP. This tests the
    /// error when the length is zero.
    function testOpDecodeBitsNPIntegrityFailZeroLength(IntegrityCheckStateNP memory state, uint8 start) external {
        Operand operand = Operand.wrap(2 << 0x10 | 0 << 8 | uint256(start));
        vm.expectRevert(abi.encodeWithSelector(ZeroLengthBitwiseEncoding.selector));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecodeBitsNP.integrity(state, operand);
        (calcInputs, calcOutputs);
    }

    /// Directly test the runtime logic of LibOpDecodeBitsNP. This tests that the
    /// opcode correctly pushes the decoded bits onto the stack.
    function testOpDecodeBitsNPRun(uint256 value, uint8 start8Bit, uint8 length8Bit) external {
        uint256 start = uint256(start8Bit);
        uint256 length = bound(uint256(length8Bit), 1, type(uint8).max - start + 1);
        Operand operand = Operand.wrap(1 << 0x10 | (uint256(length) << 8) | uint256(start));
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = value;
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        opReferenceCheck(
            state, operand, LibOpDecodeBitsNP.referenceFn, LibOpDecodeBitsNP.integrity, LibOpDecodeBitsNP.run, inputs
        );
    }

    /// Test the eval of decoding bits parsed from a string.
    function testOpDecodeBitsNPEvalHappy() external {
        checkHappy("_:bitwise-decode<0 1>(0);", 0, "0 1 0");
        checkHappy("_:bitwise-decode<0 1>(1);", 1, "0 1 1");
        checkHappy("_:bitwise-decode<0 1>(2);", 0, "0 1 2");
        checkHappy("_:bitwise-decode<0 1>(3);", 1, "0 1 3");
        checkHappy("_:bitwise-decode<0 1>(4);", 0, "0 1 4");
        checkHappy("_:bitwise-decode<0 1>(5);", 1, "0 1 5");
        checkHappy("_:bitwise-decode<0 1>(6);", 0, "0 1 6");
        checkHappy("_:bitwise-decode<0 1>(7);", 1, "0 1 7");
        checkHappy("_:bitwise-decode<0 2>(0);", 0, "0 2 0");
        checkHappy("_:bitwise-decode<0 2>(1);", 1, "0 2 1");
        checkHappy("_:bitwise-decode<0 2>(2);", 2, "0 2 2");
        checkHappy("_:bitwise-decode<0 2>(3);", 3, "0 2 3");
        checkHappy("_:bitwise-decode<0 2>(4);", 0, "0 2 4");
        checkHappy("_:bitwise-decode<0 2>(max-int-value());", 3, "0 2 max-int-value");
        checkHappy("_:bitwise-decode<0 0xFF>(max-int-value());", type(uint256).max >> 1, "0 0xFF max-int-value");
        checkHappy("_:bitwise-decode<0xFF 1>(max-int-value());", 1, "0xFF 1 max-int-value");
        checkHappy("_:bitwise-decode<1 0xFF>(max-int-value());", type(uint256).max >> 1, "1 0xFF max-int-value");
        checkHappy("_:bitwise-decode<20 2>(max-int-value());", 3, "20 2 max-int-value");
    }

    /// Check bad inputs.
    function testOpDecodeBitsNPEvalBadInputs() external {
        checkBadInputs("_:bitwise-decode<0 1>();", 0, 1, 0);
        checkBadInputs("_:bitwise-decode<0 1>(0 0);", 2, 1, 2);
    }
}
