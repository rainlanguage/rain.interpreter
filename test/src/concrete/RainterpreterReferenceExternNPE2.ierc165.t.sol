// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {IInterpreterExternV3} from "rain.interpreter.interface/interface/IInterpreterExternV3.sol";
import {ISubParserV3} from "rain.interpreter.interface/interface/unstable/ISubParserV3.sol";
import {RainterpreterReferenceExternNPE2} from "src/concrete/extern/RainterpreterReferenceExternNPE2.sol";
import {IDescribedByMetaV1} from "rain.metadata/interface/unstable/IDescribedByMetaV1.sol";

contract RainterpreterReferenceExternNPE2IERC165Test is Test {
    /// Test that ERC165 is implemented for the reference extern contract.
    function testRainterpreterReferenceExternNPE2IERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterExternV3).interfaceId);
        vm.assume(badInterfaceId != type(ISubParserV3).interfaceId);
        vm.assume(badInterfaceId != type(IDescribedByMetaV1).interfaceId);

        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();
        assertTrue(extern.supportsInterface(type(IERC165).interfaceId));
        assertTrue(extern.supportsInterface(type(IInterpreterExternV3).interfaceId));
        assertTrue(extern.supportsInterface(type(ISubParserV3).interfaceId));
        assertTrue(extern.supportsInterface(type(IDescribedByMetaV1).interfaceId));
        assertFalse(extern.supportsInterface(badInterfaceId));
    }
}
