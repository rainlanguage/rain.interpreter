// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {Operand} from "src/interface/IInterpreterV1.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibOpCtPopNP} from "src/lib/op/bitwise/LibOpCtPopNP.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {IInterpreterV1, StateNamespace, SourceIndex} from "src/interface/IInterpreterV1.sol";
import {IInterpreterStoreV1} from "src/interface/IInterpreterStoreV1.sol";
import {SignedContextV1} from "src/interface/IInterpreterCallerV2.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";
import {LibCtPop} from "src/lib/bitwise/LibCtPop.sol";

contract LibOpCtPopNPTest is OpTest {
    /// Directly test the integrity logic of LibOpCtPopNP. All possible operands
    /// result in the same number of inputs and outputs, (1, 1).
    function testOpCtPopNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpCtPopNP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpCtPopNP. This tests that the
    /// opcode correctly pushes the ct pop onto the stack.
    function testOpCtPopNPRun(uint256 x) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = x;
        Operand operand = Operand.wrap(1 << 0x10);
        opReferenceCheck(state, operand, LibOpCtPopNP.referenceFn, LibOpCtPopNP.integrity, LibOpCtPopNP.run, inputs);
    }

    /// Test the eval of a ct pop opcode parsed from a string.
    function testOpCtPopNPEval(uint256 x) external {
        // 0 is just a placeholder that we'll override with `x`.
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: bitwise-count-ones(0);");
        // Override the constant with the value we want to test.
        constants[0] = x;

        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;

        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        assertEq(stack.length, 1);
        assertEq(stack[0], LibCtPop.ctpop(x));
        assertEq(kvs.length, 0);
    }

    /// Test that a bitwise count with bad inputs fails integrity.
    function testOpCtPopNPIntegrityFail() external {
        checkBadInputs("_: bitwise-count-ones();", 0, 1, 0);
        checkBadInputs("_: bitwise-count-ones(0 0);", 2, 1, 2);
    }
}
