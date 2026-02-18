// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {OperandV2} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";
import {StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";

/// @title LibOpERC20Allowance
/// @notice Opcode for getting the current erc20 allowance of an account.
library LibOpERC20Allowance {
    /// `erc20-allowance` integrity check. Requires 3 inputs and produces 1 output.
    /// @return The number of inputs.
    /// @return The number of outputs.
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // Always 3 inputs, the token, the owner and the spender.
        // Always 1 output, the allowance.
        return (3, 1);
    }

    /// `erc20-allowance` opcode. Calls `allowance` on the token and converts the result to a decimal float using the token's `decimals`.
    /// @param stackTop Pointer to the top of the stack.
    /// @return The new stack top pointer after execution.
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
        // It is the rainlang author's responsibility to ensure that the token,
        // owner and spender are valid addresses.
        uint256 tokenAllowance =
        //forge-lint: disable-next-line(unsafe-typecast)
        IERC20(address(uint160(token))).allowance(address(uint160(owner)), address(uint160(spender)));

        // This can fail as `decimals` is an OPTIONAL part of the ERC20 standard.
        //forge-lint: disable-next-line(unsafe-typecast)
        uint8 tokenDecimals = IERC20Metadata(address(uint160(token))).decimals();

        // Unlike `balanceOf` and `totalSupply`, allowance uses the lossy
        // conversion. Infinite approvals (`type(uint256).max`) are extremely
        // common in ERC20 tokens, and that value cannot be represented
        // losslessly in a decimal float. Using the lossless variant here would
        // revert on any infinite approval, bricking most evaluations that read
        // allowances.
        // Slither doesn't like that we're ignoring the lossless flag but it's
        // currently irrelevant. Perhaps in the future we setup an operand to
        // handle it, but not now.
        //slither-disable-next-line unused-return
        (Float tokenAllowanceFloat,) = LibDecimalFloat.fromFixedDecimalLossyPacked(tokenAllowance, tokenDecimals);

        assembly ("memory-safe") {
            mstore(stackTop, tokenAllowanceFloat)
        }
        return stackTop;
    }

    /// Reference implementation of `erc20-allowance` for testing.
    /// @param inputs The input values from the stack.
    /// @return The output values to push onto the stack.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        view
        returns (StackItem[] memory)
    {
        address token = address(uint160(uint256(StackItem.unwrap(inputs[0]))));
        address owner = address(uint160(uint256(StackItem.unwrap(inputs[1]))));
        address spender = address(uint160(uint256(StackItem.unwrap(inputs[2]))));

        uint8 tokenDecimals = IERC20Metadata(token).decimals();
        uint256 tokenAllowance = IERC20(token).allowance(owner, spender);
        // Same as in the run implementation.
        //slither-disable-next-line unused-return
        (Float tokenAllowanceFloat,) = LibDecimalFloat.fromFixedDecimalLossyPacked(tokenAllowance, tokenDecimals);

        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(Float.unwrap(tokenAllowanceFloat));
        return outputs;
    }
}
