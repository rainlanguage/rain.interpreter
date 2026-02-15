// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {IInterpreterExternV4} from "rain.interpreter.interface/interface/IInterpreterExternV4.sol";
import {ISubParserV4} from "rain.interpreter.interface/interface/ISubParserV4.sol";
import {RainterpreterReferenceExtern} from "src/concrete/extern/RainterpreterReferenceExtern.sol";
import {IDescribedByMetaV1} from "rain.metadata/interface/IDescribedByMetaV1.sol";
import {ISubParserToolingV1} from "rain.sol.codegen/interface/ISubParserToolingV1.sol";
import {IParserToolingV1} from "rain.sol.codegen/interface/IParserToolingV1.sol";
import {IIntegrityToolingV1} from "rain.sol.codegen/interface/IIntegrityToolingV1.sol";
import {IOpcodeToolingV1} from "rain.sol.codegen/interface/IOpcodeToolingV1.sol";

contract RainterpreterReferenceExternIERC165Test is Test {
    /// Test that ERC165 is implemented for the reference extern contract.
    function testRainterpreterReferenceExternIERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterExternV4).interfaceId);
        vm.assume(badInterfaceId != type(ISubParserV4).interfaceId);
        vm.assume(badInterfaceId != type(IDescribedByMetaV1).interfaceId);
        vm.assume(badInterfaceId != type(IParserToolingV1).interfaceId);
        vm.assume(badInterfaceId != type(ISubParserToolingV1).interfaceId);
        vm.assume(badInterfaceId != type(IIntegrityToolingV1).interfaceId);
        vm.assume(badInterfaceId != type(IOpcodeToolingV1).interfaceId);

        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();
        assertTrue(extern.supportsInterface(type(IERC165).interfaceId));
        assertTrue(extern.supportsInterface(type(IInterpreterExternV4).interfaceId));
        assertTrue(extern.supportsInterface(type(ISubParserV4).interfaceId));
        assertTrue(extern.supportsInterface(type(IDescribedByMetaV1).interfaceId));
        assertTrue(extern.supportsInterface(type(IParserToolingV1).interfaceId));
        assertTrue(extern.supportsInterface(type(ISubParserToolingV1).interfaceId));
        assertTrue(extern.supportsInterface(type(IIntegrityToolingV1).interfaceId));
        assertTrue(extern.supportsInterface(type(IOpcodeToolingV1).interfaceId));
        assertFalse(extern.supportsInterface(badInterfaceId));
    }
}
