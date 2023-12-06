// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {LibOpIntIncNP} from "src/lib/op/math/int/LibOpIntIncNP.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";

contract LibOpIntIncNPExternTest is Test {
    /// Check the integrity of the extern call matches the intern call.
    function testOpIntincNPIntegrityHappy(Operand externOperand, uint256 inputs, uint256 outputs) external {
        inputs = bound(inputs, 0, 0xFF);
        outputs = bound(outputs, 0, 0xFF);

        (uint256 externCalcInputs, uint256 externCalcOutputs) =
            LibOpIntIncNP.integrityExtern(externOperand, inputs, outputs);

        assertEq(externCalcInputs, inputs);
        assertEq(externCalcOutputs, inputs);
    }
}
