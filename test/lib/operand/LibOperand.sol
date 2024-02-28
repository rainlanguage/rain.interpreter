// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Operand} from "rain.interpreter.interface/interface/IInterpreterV2.sol";

library LibOperand {
    function build(uint8 inputs, uint8 outputs, uint16 operandData) internal pure returns (Operand) {
        require(inputs < 0x10, "inputs must be less than 16");
        require(outputs < 0x10, "outputs must be less than 16");
        return Operand.wrap(uint256(outputs) << 0x14 | uint256(inputs) << 0x10 | uint256(operandData));
    }
}
