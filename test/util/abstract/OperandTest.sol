// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "test/util/lib/parse/LibMetaFixture.sol";

abstract contract OperandTest is Test {
    // External version of parse for testing. Expect revert only works properly
    // when called externally.
    function parse(bytes memory rainString) external pure returns (bytes memory bytecode, uint256[] memory constants) {
        return LibParse.parse(rainString, LibMetaFixture.parseMeta());
    }

    function checkParseError(bytes memory rainString, bytes memory err) internal {
        bytes memory bytecode;
        uint256[] memory constants;
        vm.expectRevert(err);
        (bytecode, constants) = this.parse(rainString);
        (bytecode);
        (constants);
    }

    function checkOperandParse(bytes memory rainString, bytes memory operand) internal {
        (bytes memory bytecode, uint256[] memory constants) = this.parse(rainString);
        assertEq(
            bytecode,
            bytes.concat(
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 op
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 output
            hex"01",
            operand)
        );
        assertEq(constants.length, 0);
    }
}
