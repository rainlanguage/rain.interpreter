// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

/// @title LibOpIntIncNP
/// @notice Opcode to increment every integer in a list.
/// Currently this is only really useful for testing the extern contract.
library LibOpIntIncNP {
    /// int-inc
    /// Increment an integer.
    function runExtern(Operand, uint256[] memory inputs) internal pure returns (uint256[] memory) {
        for (uint256 i = 0; i < inputs.length; i++) {
            ++inputs[i];
        }
        return inputs;
    }

    function integrityExtern(Operand, uint256 inputs, uint256) internal pure returns (uint256, uint256) {
        return (inputs, inputs);
    }
}