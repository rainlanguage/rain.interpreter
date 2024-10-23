// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity ^0.8.25;

import {Operand} from "rain.interpreter.interface/interface/IInterpreterV3.sol";
import {LibSubParse} from "../../../parse/LibSubParse.sol";
import {IInterpreterExternV3} from "rain.interpreter.interface/interface/IInterpreterExternV3.sol";

/// @dev Opcode index of the extern increment opcode. Needs to be manually kept
/// in sync with the extern opcode function pointers. Definitely write tests for
/// this to ensure a mismatch doesn't happen silently.
uint256 constant OP_INDEX_INCREMENT = 0;

/// @title LibExternOpIntIncNPE2
/// This op is a simple increment of every input by 1. It is used to demonstrate
/// handling both multiple inputs and outputs in extern dispatching logic.
library LibExternOpIntIncNPE2 {
    /// Running the extern increments every input by 1. By allowing many inputs
    /// we can test multi input/output logic is implemented correctly for
    /// externs.
    //slither-disable-next-line dead-code
    function run(Operand, uint256[] memory inputs) internal pure returns (uint256[] memory) {
        for (uint256 i = 0; i < inputs.length; i++) {
            ++inputs[i];
        }
        return inputs;
    }

    /// The integrity check for the extern increment opcode. The inputs and
    /// outputs are the same always.
    //slither-disable-next-line dead-code
    function integrity(Operand, uint256 inputs, uint256) internal pure returns (uint256, uint256) {
        return (inputs, inputs);
    }

    /// The sub parser for the extern increment opcode. It has no special logic
    /// so uses the default sub parser from `LibSubParse`.
    //slither-disable-next-line dead-code
    function subParser(uint256 constantsHeight, uint256 ioByte, Operand operand)
        internal
        view
        returns (bool, bytes memory, uint256[] memory)
    {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserExtern(
            IInterpreterExternV3(address(this)), constantsHeight, ioByte, operand, OP_INDEX_INCREMENT
        );
    }
}
