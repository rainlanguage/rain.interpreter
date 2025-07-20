// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
// // import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {LibOpGreaterThanOrEqualTo} from "src/lib/op/logic/LibOpGreaterThanOrEqualTo.sol";
import {IntegrityCheckState, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheck.sol";
import {
    IInterpreterV4,
    OperandV2,
    SourceIndexV2,
    FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "src/lib/state/LibInterpreterState.sol";
// // import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
// // import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV3.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

contract LibOpGreaterThanOrEqualToTest is OpTest {
    /// Directly test the integrity logic of LibOpGreaterThanOrEqualTo. No matter the
    /// operand inputs, the calc inputs must be 2, and the calc outputs must be
    /// 1.
    function testOpGreaterThanOrEqualToIntegrityHappy(IntegrityCheckState memory state, uint8 inputs) external pure {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpGreaterThanOrEqualTo.integrity(state, OperandV2.wrap(bytes32(uint256(inputs) << 0x10)));

        // The inputs from the operand are ignored. The op is always 2 inputs.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpGreaterThanOrEqualTo.
    function testOpGreaterThanOrEqualToNPRun(StackItem input1, StackItem input2) external view {
        InterpreterState memory state = opTestDefaultInterpreterState();
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] = input1;
        inputs[1] = input2;
        OperandV2 operand = LibOperand.build(uint8(inputs.length), 1, 0);
        opReferenceCheck(
            state,
            operand,
            LibOpGreaterThanOrEqualTo.referenceFn,
            LibOpGreaterThanOrEqualTo.integrity,
            LibOpGreaterThanOrEqualTo.run,
            inputs
        );
    }

    /// Test the eval of greater than or equal to opcode parsed from a string.
    /// Tests 2 inputs. Both inputs are 0.
    function testOpGreaterThanOrEqualToEval2ZeroInputs() external view {
        checkHappy("_: greater-than-or-equal-to(0 0);", bytes32(uint256(1)), "");
    }

    /// Test the eval of greater than or equal to opcode parsed from a string.
    /// Tests 2 inputs. The first input is 0, the second input is 1.
    function testOpGreaterThanOrEqualToEval2InputsFirstZeroSecondOne() external view {
        checkHappy("_: greater-than-or-equal-to(0 1);", 0, "");
    }

    /// Test the eval of greater than or equal to opcode parsed from a string.
    /// Tests 2 inputs. The first input is 1, the second input is 0.
    function testOpGreaterThanOrEqualToEval2InputsFirstOneSecondZero() external view {
        checkHappy("_: greater-than-or-equal-to(1 0);", bytes32(uint256(1)), "");
    }

    /// Test the eval of greater than or equal to opcode parsed from a string.
    /// Tests 2 inputs. Both inputs are 1.
    function testOpGreaterThanOrEqualToEval2InputsBothOne() external view {
        checkHappy("_: greater-than-or-equal-to(1 1);", bytes32(uint256(1)), "");
    }

    /// Test that a greater than or equal to without inputs fails integrity check.
    function testOpGreaterThanOrEqualToEvalFail0Inputs() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
        bytes memory bytecode = iDeployer.parse2("_: greater-than-or-equal-to();");
        (bytecode);
    }

    /// Test that a greater than or equal to with 1 input fails integrity check.
    function testOpGreaterThanOrEqualToEvalFail1Input() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
        bytes memory bytecode = iDeployer.parse2("_: greater-than-or-equal-to(0x00);");
        (bytecode);
    }

    /// Test that a greater than or equal to with 3 inputs fails integrity check.
    function testOpGreaterThanOrEqualToEvalFail3Inputs() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 3, 2, 3));
        bytes memory bytecode = iDeployer.parse2("_: greater-than-or-equal-to(0x00 0x00 0x00);");
        (bytecode);
    }

    function testOpGreaterThanOrEqualToZeroOutputs() external {
        checkBadOutputs(": greater-than-or-equal-to(1 2);", 2, 1, 0);
    }

    function testOpGreaterThanOrEqualToTwoOutputs() external {
        checkBadOutputs("_ _: greater-than-or-equal-to(1 2);", 2, 1, 2);
    }
}
