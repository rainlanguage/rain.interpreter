// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.18;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckStateNP} from "../../../integrity/LibIntegrityCheckNP.sol";
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV3.sol";
import {InterpreterStateNP} from "../../../state/LibInterpreterStateNP.sol";

/// @title LibOpUint256ERC20Allowance
/// @notice Opcode for getting the current erc20 allowance of an account.
library LibOpUint256ERC20Allowance {
    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        // Always 3 inputs, the token, the owner and the spender.
        // Always 1 output, the allowance.
        return (3, 1);
    }

    function run(InterpreterStateNP memory, Operand, Pointer stackTop) internal view returns (Pointer) {
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
        assembly ("memory-safe") {
            mstore(stackTop, tokenAllowance)
        }
        return stackTop;
    }

    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs)
        internal
        view
        returns (uint256[] memory)
    {
        uint256 token = inputs[0];
        uint256 owner = inputs[1];
        uint256 spender = inputs[2];
        uint256 tokenAllowance =
            IERC20(address(uint160(token))).allowance(address(uint160(owner)), address(uint160(spender)));
        uint256[] memory outputs = new uint256[](1);
        outputs[0] = tokenAllowance;
        return outputs;
    }
}
