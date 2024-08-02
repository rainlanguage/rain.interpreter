// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {RainterpreterNPE2} from "src/concrete/RainterpreterNPE2.sol";
import {IInterpreterV4} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

contract RainterpreterNPE2IERC165Test is Test {
    /// Test that ERC165 is implemented for all interfaces.
    function testRainterpreterNPE2IERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterV4).interfaceId);

        RainterpreterNPE2 interpreter = new RainterpreterNPE2();
        assertTrue(interpreter.supportsInterface(type(IERC165).interfaceId));
        assertTrue(interpreter.supportsInterface(type(IInterpreterV4).interfaceId));

        assertFalse(interpreter.supportsInterface(badInterfaceId));
    }
}
