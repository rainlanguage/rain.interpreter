// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckState} from "../../../integrity/LibIntegrityCheck.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {InterpreterState} from "../../../state/LibInterpreterState.sol";

/// @title LibOpUint256ERC20Allowance
/// @notice Opcode for getting the current erc20 allowance of an account.
library LibOpUint256ERC20Allowance {
    /// `uint256-erc20-allowance` integrity check. Requires 3 inputs and produces 1 output.
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // Always 3 inputs, the token, the owner and the spender.
        // Always 1 output, the allowance.
        return (3, 1);
    }

    /// `uint256-erc20-allowance` opcode. Calls `allowance` on the token and returns the raw uint256 allowance.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
        uint256 token;
        uint256 owner;
        uint256 spender;
        assembly ("memory-safe") {
            token := mload(stackTop)
            owner := mload(add(stackTop, 0x20))
            stackTop := add(stackTop, 0x40)
            spender := mload(stackTop)
        }
        uint256 tokenAllowance =
        // It is the rainlang author's responsibility to ensure that token,
        // owner and spender are valid addresses.
        //forge-lint: disable-next-line(unsafe-typecast)
        IERC20(address(uint160(token))).allowance(address(uint160(owner)), address(uint160(spender)));
        assembly ("memory-safe") {
            mstore(stackTop, tokenAllowance)
        }
        return stackTop;
    }

    /// Reference implementation of `uint256-erc20-allowance` for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        view
        returns (StackItem[] memory)
    {
        address token = address(uint160(uint256(StackItem.unwrap(inputs[0]))));
        address owner = address(uint160(uint256(StackItem.unwrap(inputs[1]))));
        address spender = address(uint160(uint256(StackItem.unwrap(inputs[2]))));
        uint256 tokenAllowance = IERC20(token).allowance(owner, spender);
        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(bytes32(tokenAllowance));
        return outputs;
    }
}
