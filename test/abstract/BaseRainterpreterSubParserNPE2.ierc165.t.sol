// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {ISubParserV1} from "src/interface/unstable/ISubParserV1.sol";
import {BaseRainterpreterSubParserNPE2} from "src/abstract/BaseRainterpreterSubParserNPE2.sol";

/// @dev We need a contract that is deployable in order to test the abstract
/// base contract.
contract ChildRainterpreterSubParserNPE2 is BaseRainterpreterSubParserNPE2 {}

/// @title BaseRainterpreterSubParserNPE2Test
/// Test suite for BaseRainterpreterSubParserNPE2.
contract BaseRainterpreterSubParserNPE2Test is Test {
    /// Test that ERC165 and IInterpreterExternV3 are supported interfaces as
    /// per ERC165.
    function testRainterpreterSubParserNPE2IERC165(uint32 badInterfaceIdUint) external {
        // https://github.com/foundry-rs/foundry/issues/6115
        bytes4 badInterfaceId = bytes4(badInterfaceIdUint);

        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(ISubParserV1).interfaceId);

        ChildRainterpreterSubParserNPE2 extern = new ChildRainterpreterSubParserNPE2();
        assertTrue(extern.supportsInterface(type(IERC165).interfaceId));
        assertTrue(extern.supportsInterface(type(ISubParserV1).interfaceId));
        assertFalse(extern.supportsInterface(badInterfaceId));
    }
}
