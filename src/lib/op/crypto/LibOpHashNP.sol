// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../../state/LibInterpreterStateNP.sol";
import "../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpHashNP
/// Implementation of keccak256 hashing as a standard Rainlang opcode.
library LibOpHashNP {
    function integrity(IntegrityCheckStateNP memory, Operand operand) internal pure returns (uint256, uint256) {
        // Any number of inputs are valid.
        // 0 inputs will be the hash of empty (0 length) bytes.
        uint256 inputs = Operand.unwrap(operand) >> 0x10;
        return (inputs, 1);
    }

    function run(InterpreterStateNP memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            let length := mul(shr(0x10, operand), 0x20)
            let value := keccak256(stackTop, length)
            stackTop := sub(add(stackTop, length), 0x20)
            mstore(stackTop, value)
        }
        return stackTop;
    }

    function referenceFn(Operand, uint256[] memory inputs) internal pure returns (uint256[] memory outputs) {
        outputs = new uint256[](1);
        outputs[0] = uint256(keccak256(abi.encodePacked(inputs)));
    }
}
