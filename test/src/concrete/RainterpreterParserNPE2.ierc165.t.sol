// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {RainterpreterParserNPE2} from "src/concrete/RainterpreterParserNPE2.sol";
import {IParserPragmaV1} from "rain.interpreter.interface/interface/IParserPragmaV1.sol";
import {IParserV2} from "rain.interpreter.interface/interface/IParserV2.sol";

contract RainterpreterParserNPE2IERC165Test is Test {
    /// Test that ERC165 is implemented for all interfaces.
    function testRainterpreterParserNPE2IERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IParserV2).interfaceId);
        vm.assume(badInterfaceId != type(IParserPragmaV1).interfaceId);

        RainterpreterParserNPE2 parser = new RainterpreterParserNPE2();
        assertTrue(parser.supportsInterface(type(IERC165).interfaceId));
        assertTrue(parser.supportsInterface(type(IParserV2).interfaceId));
        assertTrue(parser.supportsInterface(type(IParserPragmaV1).interfaceId));

        assertFalse(parser.supportsInterface(badInterfaceId));
    }
}
