// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {LibInterpreterStateNP, InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {LibOpE} from "src/lib/op/math/LibOpE.sol";
import {LibOperand, Operand} from "test/lib/operand/LibOperand.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {IInterpreterV2} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV2.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {FullyQualifiedNamespace} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {LibEncodedDispatch} from "rain.interpreter.interface/lib/caller/LibEncodedDispatch.sol";
import {SourceIndexV2} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {FIXED_POINT_E} from "rain.math.fixedpoint/lib/FixedPointDecimalConstants.sol";

/// @title LibOpETest
contract LibOpETest is OpTest {
    /// Directly test the integrity logic of LibOpE.
    function testOpEIntegrity(IntegrityCheckStateNP memory state, uint8 inputs, uint8 outputs, uint16 operandData)
        external
    {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpE.integrity(state, LibOperand.build(inputs, outputs, operandData));

        assertEq(calcInputs, 0);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpE. This tests that the
    /// opcode correctly pushes the mathematical constant e onto the stack.
    function testOpERun(uint16 operandData) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        Operand operand = LibOperand.build(0, 1, operandData);
        uint256[] memory inputs = new uint256[](0);
        opReferenceCheck(state, operand, LibOpE.referenceFn, LibOpE.integrity, LibOpE.run, inputs);
    }

    /// Test the eval of a mathematical constant e opcode parsed from a string.
    function testOpEEval() external {
        bytes memory bytecode = iDeployer.parse2("_: e();");

        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 1);
        assertEq(stack[0], FIXED_POINT_E);
        assertEq(kvs.length, 0);
    }

    function testOpEEvalOneInput() external {
        checkBadInputs("_: e(0x00);", 1, 0, 1);
    }

    function testOpEEvalZeroOutputs() external {
        checkBadOutputs(": e();", 0, 1, 0);
    }

    function testOpEEvalTwoOutputs() external {
        checkBadOutputs("_ _: e();", 0, 1, 2);
    }
}
