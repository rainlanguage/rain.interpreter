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

/// @title LibOpERC20Allowance
/// @notice Opcode for getting the current erc20 allowance of an account.
library LibOpERC20Allowance {
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // Always 3 inputs, the token, the owner and the spender.
        // Always 1 output, the allowance.
        return (3, 1);
    }

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
            IERC20(address(uint160(token))).allowance(address(uint160(owner)), address(uint160(spender)));

        // This can fail as `decimals` is an OPTIONAL part of the ERC20 standard.
        uint8 tokenDecimals = IERC20Metadata(address(uint160(token))).decimals();

        (Float tokenAllowanceFloat, bool lossless) =
            LibDecimalFloat.fromFixedDecimalLossyPacked(tokenAllowance, tokenDecimals);
        (lossless);

        assembly ("memory-safe") {
            mstore(stackTop, tokenAllowanceFloat)
        }
        return stackTop;
    }

    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        view
        returns (StackItem[] memory)
    {
        bytes32 token = StackItem.unwrap(inputs[0]);
        bytes32 owner = StackItem.unwrap(inputs[1]);
        bytes32 spender = StackItem.unwrap(inputs[2]);

        uint8 tokenDecimals = IERC20Metadata(address(bytes20(token))).decimals();
        uint256 tokenAllowance =
            IERC20(address(bytes20(token))).allowance(address(bytes20(owner)), address(bytes20(spender)));
        (Float tokenAllowanceFloat, bool lossless) =
            LibDecimalFloat.fromFixedDecimalLossyPacked(tokenAllowance, tokenDecimals);
        (lossless);

        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(Float.unwrap(tokenAllowanceFloat));
        return outputs;
    }
}
