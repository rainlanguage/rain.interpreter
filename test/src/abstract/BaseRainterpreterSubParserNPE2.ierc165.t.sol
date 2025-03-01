// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {ISubParserV4} from "rain.interpreter.interface/interface/unstable/ISubParserV4.sol";
import {BaseRainterpreterSubParserNPE2} from "src/abstract/BaseRainterpreterSubParserNPE2.sol";
import {IDescribedByMetaV1} from "rain.metadata/interface/IDescribedByMetaV1.sol";

/// @dev We need a contract that is deployable in order to test the abstract
/// base contract.
contract ChildRainterpreterSubParserNPE2 is BaseRainterpreterSubParserNPE2 {
    function describedByMetaV1() external pure override returns (bytes32) {
        return 0;
    }

    function buildLiteralParserFunctionPointers() external pure returns (bytes memory) {
        return new bytes(0);
    }

    function buildOperandHandlerFunctionPointers() external pure returns (bytes memory) {
        return new bytes(0);
    }

    function buildSubParserWordParsers() external pure returns (bytes memory) {
        return new bytes(0);
    }
}

/// @title BaseRainterpreterSubParserNPE2Test
/// Test suite for BaseRainterpreterSubParserNPE2.
contract BaseRainterpreterSubParserNPE2IERC165Test is Test {
    /// Test that ERC165 and ISubParserV3 are supported interfaces as
    /// per ERC165.
    function testRainterpreterSubParserNPE2IERC165(uint32 badInterfaceIdUint) external {
        // https://github.com/foundry-rs/foundry/issues/6115
        bytes4 badInterfaceId = bytes4(badInterfaceIdUint);

        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(ISubParserV4).interfaceId);
        vm.assume(badInterfaceId != type(IDescribedByMetaV1).interfaceId);

        ChildRainterpreterSubParserNPE2 subParser = new ChildRainterpreterSubParserNPE2();
        assertTrue(subParser.supportsInterface(type(IERC165).interfaceId));
        assertTrue(subParser.supportsInterface(type(ISubParserV4).interfaceId));
        assertTrue(subParser.supportsInterface(type(IDescribedByMetaV1).interfaceId));
        assertFalse(subParser.supportsInterface(badInterfaceId));
    }
}
