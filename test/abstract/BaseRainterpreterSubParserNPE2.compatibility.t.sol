// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {BaseRainterpreterSubParserNPE2, COMPATIBLITY_V2} from "src/abstract/BaseRainterpreterSubParserNPE2.sol";
import {ISubParserV2} from "src/interface/unstable/ISubParserV2.sol";
import {IncompatibleSubParser} from "src/error/ErrSubParse.sol";

/// @dev We need a contract that is deployable in order to test the abstract
/// base contract.
contract ChildRainterpreterSubParserNPE2 is BaseRainterpreterSubParserNPE2 {}

/// @title BaseRainterpreterSubParserNPE2CompatibilityTest
contract BaseRainterpreterSubParserNPE2CompatibilityTest is Test {
    /// Test that any compatibility ID other than the correct one will revert.
    function testRainterpreterSubParserNPE2Compatibility(bytes32 badCompatibility, bytes memory data) external {
        vm.assume(badCompatibility != COMPATIBLITY_V2);

        ChildRainterpreterSubParserNPE2 subParser = new ChildRainterpreterSubParserNPE2();
        vm.expectRevert(abi.encodeWithSelector(IncompatibleSubParser.selector));
        (bool success, bytes memory bytecode, uint256[] memory constants) =
            ISubParserV2(address(subParser)).subParseWord(badCompatibility, data);
        (success, bytecode, constants);
    }
}
