// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

import {IERC5313} from "openzeppelin-contracts/contracts/interfaces/IERC5313.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";

/// @title LibOpERC5313Owner
/// @notice Opcode for ERC5313 `owner`.
library LibOpERC5313Owner {
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // Always 1 input, the contract.
        // Always 1 output, the owner.
        return (1, 1);
    }

    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
        uint256 account;
        assembly ("memory-safe") {
            account := mload(stackTop)
        }
        address owner = IERC5313(address(uint160(account))).owner();
        assembly ("memory-safe") {
            mstore(stackTop, owner)
        }
        return stackTop;
    }

    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        view
        returns (StackItem[] memory)
    {
        bytes32 account = StackItem.unwrap(inputs[0]);
        address owner = IERC5313(address(uint160(uint256(account)))).owner();
        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(bytes32(uint256(uint160(owner))));
        return outputs;
    }
}
