// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {RainterpreterNPE2, OPCODE_FUNCTION_POINTERS} from "src/concrete/RainterpreterNPE2.sol";

contract RainterpreterNPE2PointersTest is Test {
    function testOpcodeFunctionPointers() external {
        RainterpreterNPE2 interpreter = new RainterpreterNPE2();
        bytes memory expected = interpreter.buildOpcodeFunctionPointers();
        bytes memory actual = OPCODE_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }
}
