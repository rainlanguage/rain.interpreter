// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {
    RainterpreterExpressionDeployerDeploymentTest
} from "test/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";
import {OpcodeIOOverflow} from "src/error/ErrParse.sol";

/// @title LibParseStateOpcodeIOOverflowTest
/// Tests for OpcodeIOOverflow in endLine.
contract LibParseStateOpcodeIOOverflowTest is RainterpreterExpressionDeployerDeploymentTest {
    /// A word with 16 paren-enclosed inputs overflows the 4-bit ioByte
    /// input nybble (max 15), triggering OpcodeIOOverflow.
    function testOpcodeIOOverflowInputs() external {
        // int-add with 16 inputs: int-add(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)
        bytes memory rainlang = bytes("_: int-add(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1);");

        vm.expectRevert(abi.encodeWithSelector(OpcodeIOOverflow.selector, 43));
        I_PARSER.unsafeParse(rainlang);
    }
}
