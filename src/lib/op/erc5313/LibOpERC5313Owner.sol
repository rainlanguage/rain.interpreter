// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {IERC5313} from "openzeppelin-contracts/contracts/interfaces/IERC5313.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";

/// @title LibOpERC5313Owner
/// @notice Opcode for ERC5313 `owner`.
library LibOpERC5313Owner {
    /// `erc5313-owner` integrity check. Requires 1 input and produces 1 output.
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // Always 1 input, the contract.
        // Always 1 output, the owner.
        return (1, 1);
    }

    /// `erc5313-owner` opcode. Calls `owner()` on the given contract address.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
        uint256 account;
        assembly ("memory-safe") {
            account := mload(stackTop)
        }
        // The rainlang author is responsible for ensuring the input is a valid
        // ERC5313 contract address.
        //forge-lint: disable-next-line(unsafe-typecast)
        address owner = IERC5313(address(uint160(account))).owner();
        assembly ("memory-safe") {
            mstore(stackTop, owner)
        }
        return stackTop;
    }

    /// Reference implementation of `erc5313-owner` for testing.
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
