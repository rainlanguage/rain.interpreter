// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {Operand} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {TruncatedBitwiseEncoding, ZeroLengthBitwiseEncoding} from "src/error/ErrBitwise.sol";
import {LibOpEncodeBitsNP} from "src/lib/op/bitwise/LibOpEncodeBitsNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpEncodeBitsNPTest is OpTest {
    /// Directly test the integrity logic of LibOpEncodeBitsNP. All possible
    /// operands result in the same number of inputs and outputs, (2, 1).
    /// However, lengths can overflow and error so we bound the operand to avoid
    /// that here.
    function testOpEncodeBitsNPIntegrity(IntegrityCheckStateNP memory state, uint8 start8Bit, uint8 length8Bit)
        external
    {
        uint256 start = uint256(start8Bit);
        uint256 length = bound(uint256(length8Bit), 1, type(uint8).max - start + 1);
        Operand operand = LibOperand.build(2, 1, uint16((uint256(length) << 8) | uint256(start)));
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
        Operand operand = LibOperand.build(2, 1, uint16((uint256(length) << 8) | uint256(start)));
        vm.expectRevert(abi.encodeWithSelector(TruncatedBitwiseEncoding.selector, start, length));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpEncodeBitsNP.integrity(state, operand);
        (calcInputs, calcOutputs);
    }

    /// Directly test the integrity logic of LibOpEncodeBitsNP. This tests the
    /// error when the length is zero.
    function testOpEncodeBitsNPIntegrityFailZeroLength(IntegrityCheckStateNP memory state, uint8 start) external {
        Operand operand = LibOperand.build(2, 1, uint16(0 << 8 | uint256(start)));
        vm.expectRevert(abi.encodeWithSelector(ZeroLengthBitwiseEncoding.selector));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpEncodeBitsNP.integrity(state, operand);
        (calcInputs, calcOutputs);
    }

    /// Directly test the runtime logic of LibOpEncodeBitsNP. This tests that the
    /// opcode correctly pushes the encoded bits onto the stack.
    function testOpEncodeBitsNPRun(uint256 source, uint256 target, uint8 start8Bit, uint8 length8Bit) external {
        uint256 start = uint256(start8Bit);
        uint256 length = bound(uint256(length8Bit), 1, type(uint8).max - start + 1);
        Operand operand = LibOperand.build(2, 1, uint16((uint256(length) << 8) | uint256(start)));
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = source;
        inputs[1] = target;
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        opReferenceCheck(
            state, operand, LibOpEncodeBitsNP.referenceFn, LibOpEncodeBitsNP.integrity, LibOpEncodeBitsNP.run, inputs
        );
    }

    /// Test the eval of encoding bits parsed from a string.
    function testOpEncodeBitsNPEvalHappy() external {
        checkHappy("_:bitwise-encode<0 1>(0 0);", 0, "0 0");
        checkHappy("_:bitwise-encode<0 1>(0 1e-18);", 0, "0 1");
        checkHappy("_:bitwise-encode<0 1>(1e-18 0);", 1, "1 0");
        checkHappy("_:bitwise-encode<0 1>(1e-18 1e-18);", 1, "1 1");
        checkHappy("_:bitwise-encode<0 1>(0 2e-18);", 2, "0 2");
        checkHappy("_:bitwise-encode<0 1>(1e-18 2e-18);", 3, "1 2");
        checkHappy("_:bitwise-encode<0 1>(uint256-max-value() 0);", 1, "uint256-max-value 0");
        checkHappy("_:bitwise-encode<0 1>(uint256-max-value() 1e-18);", 1, "uint256-max-value 1");
        checkHappy("_:bitwise-encode<0 1>(uint256-max-value() 2e-18);", 3, "uint256-max-value 2");
        checkHappy("_:bitwise-encode<0 1>(uint256-max-value() 3e-18);", 3, "uint256-max-value 3");
        checkHappy("_:bitwise-encode<0 2>(uint256-max-value() 0);", 3, "uint256-max-value 0 0 2");
        checkHappy("_:bitwise-encode<1 1>(uint256-max-value() 0);", 2, "uint256-max-value 1 1 1");
        checkHappy("_:bitwise-encode<1 1>(uint256-max-value() 1e-18);", 3, "uint256-max-value 1 1 1");
        checkHappy("_:bitwise-encode<1 1>(uint256-max-value() 2e-18);", 2, "uint256-max-value 2 1 1");
        checkHappy("_:bitwise-encode<0xFF 1>(uint256-max-value() 0);", 1 << 255, "uint256-max-value 2 0xFF 1");
        checkHappy(
            "_:bitwise-encode<0 0xFF>(uint256-max-value() 0);", type(uint256).max >> 1, "uint256-max-value 2 0xFF 1"
        );
    }

    /// Check bad inputs.
    function testOpEncodeBitsNPEvalZeroInputs() external {
        checkBadInputs("_:bitwise-encode<0 1>();", 0, 2, 0);
    }

    function testOpEncodeBitsNPEvalOneInput() external {
        checkBadInputs("_:bitwise-encode<0 1>(0);", 1, 2, 1);
    }

    function testOpEncodeBitsNPEvalThreeInputs() external {
        checkBadInputs("_:bitwise-encode<0 1>(0 0 0);", 3, 2, 3);
    }

    function testOpEncodeBitsNPEvalZeroOutputs() external {
        checkBadOutputs(":bitwise-encode<0 1>(0 0);", 2, 1, 0);
    }

    function testOpEncodeBitsNPEvalTwoOutputs() external {
        checkBadOutputs("_ _:bitwise-encode<0 1>(0 0);", 2, 1, 2);
    }
}
