// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {ExcessRHSItems} from "src/lib/parse/LibParse.sol";
import {LibOpEnsureNP} from "src/lib/op/logic/LibOpEnsureNP.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {
    IInterpreterV2,
    Operand,
    SourceIndexV2,
    FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/unstable/IInterpreterV2.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {LibIntOrAString, IntOrAString} from "rain.intorastring/src/lib/LibIntOrAString.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpEnsureNPTest is OpTest {
    /// Directly test the integrity logic of LibOpEnsureNP. This tests the
    /// happy path where there is at least one input.
    function testOpEnsureNPIntegrityHappy(
        IntegrityCheckStateNP memory state,
        uint8 inputs,
        uint8 outputs,
        uint16 operandData
    ) external {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpEnsureNP.integrity(state, LibOperand.build(inputs, outputs, operandData));
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 0);
    }

    /// Directly test the integrity logic of LibOpEnsureNP. This tests the
    /// unhappy path where there are no inputs.
    function testOpEnsureNPIntegrityUnhappy(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpEnsureNP.integrity(state, Operand.wrap(0));
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 0);
    }

    /// Directly test the run logic of LibOpEnsureNP.
    function testOpEnsureNPRun(uint256 condition, string memory reason) external {
        vm.assume(bytes(reason).length <= 31);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = condition;
        inputs[1] = IntOrAString.unwrap(LibIntOrAString.fromString(reason));

        Operand operand = LibOperand.build(2, 0, 0);
        if (condition == 0) {
            vm.expectRevert(bytes(reason));
        }
        opReferenceCheck(state, operand, LibOpEnsureNP.referenceFn, LibOpEnsureNP.integrity, LibOpEnsureNP.run, inputs);
    }

    /// Test the eval of `ensure` parsed from a string. Tests zero inputs.
    function testOpEnsureNPEvalZero() external {
        checkBadInputs(":ensure();", 0, 2, 0);
    }

    /// Test the eval of `ensure` parsed from a string. Tests one input.
    function testOpEnsureNPEvalOne() external {
        checkBadInputs(":ensure(1);", 1, 2, 1);
    }

    /// Test the eval of `ensure` parsed from a string. Tests three inputs.
    function testOpEnsureNPEvalThree() external {
        checkBadInputs(":ensure(1 2 3);", 3, 2, 3);
    }

    /// Test the eval of `ensure` parsed from a string. Tests that ensure cannot
    /// be used on the same line as another word as it has non-one outputs.
    /// Tests ensuring with an addition on the same line.
    function testOpEnsureNPEvalBadOutputs() external {
        vm.expectRevert(abi.encodeWithSelector(ExcessRHSItems.selector, 24));
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_:ensure(1) int-add(1 1);");
        (bytecode);
        (constants);
    }

    /// Test the eval of `ensure` parsed from a string. Tests that ensure cannot
    /// be used on the same line as another word as it has non-one outputs.
    /// Tests ensuring with another ensure on the same line.
    function testOpEnsureNPEvalBadOutputs2() external {
        vm.expectRevert(abi.encodeWithSelector(ExcessRHSItems.selector, 20));
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse(":ensure(1) ensure(1);");
        (bytecode);
        (constants);
    }

    /// Test the eval of `ensure` parsed from a string. Tests the happy path
    /// where all inputs are nonzero.
    function testOpEnsureNPEvalHappy() external {
        checkHappy(":ensure(1 \"always 1\"), _:1;", 1, "1");
        checkHappy(":ensure(5 \"always 5\"), _:1;", 1, "5");

        // Empty reason should be fine.
        checkHappy(":ensure(1 \"\"), _:1;", 1, "");
    }

    /// Test the eval of `ensure` parsed from a string. Tests the unhappy path
    /// where the input is 0.
    function testOpEnsureNPEvalUnhappy() external {
        checkUnhappy(":ensure(0 \"foo\"), _:1;", "foo");

        // Empty reason should be fine.
        checkUnhappy(":ensure(0 \"\"), _:1;", "");
    }

    /// Test the eval of `ensure` parsed from a string. Tests the unhappy path
    /// where an operand is provided.
    function testOpEnsureNPEvalUnhappyOperand() external {
        checkUnhappyParse(":ensure<0>(1 \"foo\");", abi.encodeWithSelector(UnexpectedOperand.selector));
    }

    function testOpEnsureNPOneOutput() external {
        checkBadOutputs("_:ensure(1 \"foo\");", 2, 0, 1);
    }
}
