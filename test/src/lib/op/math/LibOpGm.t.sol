// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest, IntegrityCheckState, OperandV2, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpGm} from "src/lib/op/math/LibOpGm.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

contract LibOpGmTest is OpTest {
    function beforeOpTestConstructor() internal virtual override {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
    }

    /// Directly test the integrity logic of LibOpGm.
    /// Inputs are always 2, outputs are always 1.
    function testOpGmIntegrity(IntegrityCheckState memory state, OperandV2 operand) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpGm.integrity(state, operand);
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpGm.
    function testOpGmRun(
        int224 signedCoefficientA,
        int32 exponentA,
        int224 signedCoefficientB,
        int32 exponentB,
        uint16 operandData
    ) public view {
        signedCoefficientA = int224(bound(signedCoefficientA, 0, 10000));
        exponentA = int32(bound(exponentA, -10, 5));
        signedCoefficientB = int224(bound(signedCoefficientB, 0, 10000));
        exponentB = int32(bound(exponentB, -10, 5));

        InterpreterState memory state = opTestDefaultInterpreterState();

        Float a = LibDecimalFloat.packLossless(signedCoefficientA, exponentA);
        Float b = LibDecimalFloat.packLossless(signedCoefficientB, exponentB);

        OperandV2 operand = LibOperand.build(2, 1, operandData);
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] = StackItem.wrap(Float.unwrap(a));
        inputs[1] = StackItem.wrap(Float.unwrap(b));

        opReferenceCheck(state, operand, LibOpGm.referenceFn, LibOpGm.integrity, LibOpGm.run, inputs);
    }

    /// Test the eval of `gm`.
    function testOpGmEval() external view {
        checkHappy("_: gm(0 0);", 0, "0 0");
        checkHappy("_: gm(0 1);", 0, "0 1");
        checkHappy("_: gm(1 0);", 0, "1 0");
        checkHappy("_: gm(1 1);", Float.unwrap(LibDecimalFloat.packLossless(1e3, -3)), "1 1");
        checkHappy("_: gm(1 2);", Float.unwrap(LibDecimalFloat.packLossless(1415, -3)), "1 2");
        checkHappy("_: gm(2 2);", Float.unwrap(LibDecimalFloat.packLossless(2e3, -3)), "2 2");
        checkHappy("_: gm(2 3);", Float.unwrap(LibDecimalFloat.packLossless(2450, -3)), "2 3");
        checkHappy(
            "_: gm(2 4);",
            Float.unwrap(LibDecimalFloat.packLossless(282850000000000000000000000000000000000000, -41)),
            "2 4"
        );
        checkHappy("_: gm(4 0.5);", Float.unwrap(LibDecimalFloat.packLossless(1415, -3)), "4 0.5");
    }

    /// Test the eval of `gm` for bad inputs.
    function testOpGmOneInput() external {
        checkBadInputs("_: gm(1);", 1, 2, 1);
    }

    function testOpGmThreeInputs() external {
        checkBadInputs("_: gm(1 1 1);", 3, 2, 3);
    }

    function testOpGmZeroOutputs() external {
        checkBadOutputs(": gm(1 1);", 2, 1, 0);
    }

    function testOpGmTwoOutputs() external {
        checkBadOutputs("_ _: gm(1 1);", 2, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpGmEvalOperandDisallowed() external {
        checkUnhappyParse("_: gm<0>(1 1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
