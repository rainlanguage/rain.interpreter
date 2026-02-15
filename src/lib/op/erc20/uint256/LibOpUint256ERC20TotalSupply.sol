// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckState} from "../../../integrity/LibIntegrityCheck.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {InterpreterState} from "../../../state/LibInterpreterState.sol";

/// @title LibOpUint256ERC20TotalSupply
/// @notice Opcode for ERC20 `totalSupply`.
library LibOpUint256ERC20TotalSupply {
    /// `uint256-erc20-total-supply` integrity check. Requires 1 input and produces 1 output.
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // Always 1 input, the contract.
        // Always 1 output, the total supply.
        return (1, 1);
    }

    /// `uint256-erc20-total-supply` opcode. Calls `totalSupply` on the token and returns the raw uint256 value.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
        uint256 account;
        assembly ("memory-safe") {
            account := mload(stackTop)
        }
        // It is the rainlang author's responsibility to ensure that account is
        // a valid address.
        // forge-lint: disable-next-line(unsafe-typecast)
        uint256 totalSupply = IERC20(address(uint160(account))).totalSupply();
        assembly ("memory-safe") {
            mstore(stackTop, totalSupply)
        }
        return stackTop;
    }

    /// Reference implementation of `uint256-erc20-total-supply` for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        view
        returns (StackItem[] memory)
    {
        address account = address(uint160(uint256(StackItem.unwrap(inputs[0]))));
        uint256 totalSupply = IERC20(account).totalSupply();
        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(bytes32(totalSupply));
        return outputs;
    }
}
