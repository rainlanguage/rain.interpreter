// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {LibOpIntAddNP} from "src/lib/op/math/int/LibOpIntAddNP.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";

contract LibOpIntAddNPExternTest is Test {
    /// Check the integrity of the extern call matches the intern call.
    function testOpIntAddNPIntegrityHappy(
        IntegrityCheckStateNP memory state,
        Operand externOperand,
        uint256 inputs,
        uint256 outputs
    ) external {
        inputs = bound(inputs, 0, 0xFF);
        outputs = bound(outputs, 0, 0xFF);

        (uint256 externCalcInputs, uint256 externCalcOutputs) =
            LibOpIntAddNP.integrityExtern(externOperand, inputs, outputs);

        Operand internOperand = Operand.wrap(inputs << 0x10);
        (uint256 internCalcInputs, uint256 internCalcOutputs) = LibOpIntAddNP.integrity(state, internOperand);

        assertEq(externCalcInputs, internCalcInputs);
        assertEq(externCalcOutputs, internCalcOutputs);
    }

    /// Check the extern call matches the intern call.
    function testOpIntAddNPExternHappy(InterpreterStateNP memory state, Operand operand, uint256[] memory inputs)
        external
    {
        vm.assume(inputs.length > 0);
        vm.assume(inputs.length <= type(uint8).max);
        uint256 boundAcc = 0;
        for (uint256 i = 0; i < inputs.length; i++) {
            inputs[i] = bound(inputs[i], 0, type(uint256).max - boundAcc);
            boundAcc += inputs[i];
        }

        uint256[] memory expectedOutputs = LibOpIntAddNP.referenceFn(state, operand, inputs);
        uint256[] memory actualOutputs = LibOpIntAddNP.runExtern(operand, inputs);

        assertEq(actualOutputs.length, expectedOutputs.length);
        for (uint256 i = 0; i < actualOutputs.length; i++) {
            assertEq(actualOutputs[i], expectedOutputs[i]);
        }
    }
}
