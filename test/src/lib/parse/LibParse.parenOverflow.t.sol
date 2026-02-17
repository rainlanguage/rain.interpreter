// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {
    RainterpreterExpressionDeployerDeploymentTest
} from "test/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";
import {ParenOverflow} from "src/error/ErrParse.sol";

/// @title LibParseParenOverflowTest
/// Tests for paren overflow in LibParse.
contract LibParseParenOverflowTest is RainterpreterExpressionDeployerDeploymentTest {
    /// Nesting parens beyond 20 levels must revert with ParenOverflow.
    /// Each paren group uses 3 bytes; 62 usable bytes / 3 = 20 levels max.
    function testParenOverflow() external {
        // Build 21 levels of nesting: "int-add(int-add(int-add(...(1 2)...)))"
        // Each level wraps the inner expression in "int-add(" ... " 1)".
        bytes memory inner = bytes("1 2");
        for (uint256 i = 0; i < 21; i++) {
            inner = bytes.concat(bytes("int-add("), inner, bytes(" 1)"));
        }
        bytes memory rainlang = bytes.concat(bytes("_: "), inner, bytes(";"));

        vm.expectRevert(abi.encodeWithSelector(ParenOverflow.selector));
        I_PARSER.unsafeParse(rainlang);
    }
}
