// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {RainterpreterNPE2} from "src/concrete/RainterpreterNPE2.sol";
import {IInterpreterV2} from "rain.interpreter.interface/interface/deprecated/IInterpreterV2.sol";
import {IInterpreterV3} from "rain.interpreter.interface/interface/IInterpreterV3.sol";

contract RainterpreterNPE2IERC165Test is Test {
    /// Test that ERC165 is implemented for all interfaces.
    function testRainterpreterNPE2IERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterV3).interfaceId);

        RainterpreterNPE2 interpreter = new RainterpreterNPE2();
        assertTrue(interpreter.supportsInterface(type(IERC165).interfaceId));
        assertTrue(interpreter.supportsInterface(type(IInterpreterV3).interfaceId));

        assertFalse(interpreter.supportsInterface(badInterfaceId));
    }
}
