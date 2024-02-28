// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {IInterpreterExternV3} from "rain.interpreter.interface/interface/IInterpreterExternV3.sol";
import {ISubParserV2} from "rain.interpreter.interface/interface/ISubParserV2.sol";
import {RainterpreterReferenceExternNPE2} from "src/concrete/extern/RainterpreterReferenceExternNPE2.sol";

contract RainterpreterReferenceExternNPE2IERC165Test is Test {
    /// Test that ERC165 is implemented for the reference extern contract.
    /// Need to check both `IInterpreterExternV3` and `IParserV1`.
    function testRainterpreterReferenceExternNPE2IERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterExternV3).interfaceId);
        vm.assume(badInterfaceId != type(ISubParserV2).interfaceId);

        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();
        assertTrue(extern.supportsInterface(type(IERC165).interfaceId));
        assertTrue(extern.supportsInterface(type(IInterpreterExternV3).interfaceId));
        assertTrue(extern.supportsInterface(type(ISubParserV2).interfaceId));
        assertFalse(extern.supportsInterface(badInterfaceId));
    }
}
