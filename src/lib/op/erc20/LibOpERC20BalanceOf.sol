// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

/// @title LibOpERC20BalanceOf
/// @notice Opcode for getting the current erc20 balance of an account.
library LibOpERC20BalanceOf {
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // Always 2 inputs, the token and the account.
        // Always 1 output, the balance.
        return (2, 1);
    }

    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
        uint256 token;
        uint256 account;
        assembly ("memory-safe") {
            token := mload(stackTop)
            stackTop := add(stackTop, 0x20)
            account := mload(stackTop)
        }
        uint256 tokenBalance = IERC20(address(uint160(token))).balanceOf(address(uint160(account)));

        // This can fail as `decimals` is an OPTIONAL part of the ERC20 standard.
        uint8 tokenDecimals = IERC20Metadata(address(uint160(token))).decimals();

        Float tokenBalanceFloat = LibDecimalFloat.fromFixedDecimalLosslessPacked(tokenBalance, tokenDecimals);

        assembly ("memory-safe") {
            mstore(stackTop, tokenBalanceFloat)
        }
        return stackTop;
    }

    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        view
        returns (StackItem[] memory)
    {
        address token = address(uint160(uint256(StackItem.unwrap(inputs[0]))));
        address account = address(uint160(uint256(StackItem.unwrap(inputs[1]))));

        uint256 tokenBalance = IERC20(token).balanceOf(account);

        uint8 tokenDecimals = IERC20Metadata(token).decimals();
        Float tokenBalanceFloat = LibDecimalFloat.fromFixedDecimalLosslessPacked(tokenBalance, tokenDecimals);

        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(Float.unwrap(tokenBalanceFloat));
        return outputs;
    }
}
