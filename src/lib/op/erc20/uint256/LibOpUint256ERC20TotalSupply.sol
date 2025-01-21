// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckStateNP} from "../../../integrity/LibIntegrityCheckNP.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterStateNP} from "../../../state/LibInterpreterStateNP.sol";

/// @title LibOpUint256ERC20TotalSupply
/// @notice Opcode for ERC20 `totalSupply`.
library LibOpUint256ERC20TotalSupply {
    function integrity(IntegrityCheckStateNP memory, OperandV2) internal pure returns (uint256, uint256) {
        // Always 1 input, the contract.
        // Always 1 output, the total supply.
        return (1, 1);
    }

    function run(InterpreterStateNP memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
        uint256 account;
        assembly ("memory-safe") {
            account := mload(stackTop)
        }
        uint256 totalSupply = IERC20(address(uint160(account))).totalSupply();
        assembly ("memory-safe") {
            mstore(stackTop, totalSupply)
        }
        return stackTop;
    }

    function referenceFn(InterpreterStateNP memory, OperandV2, uint256[] memory inputs)
        internal
        view
        returns (uint256[] memory)
    {
        uint256 account = inputs[0];
        uint256 totalSupply = IERC20(address(uint160(account))).totalSupply();
        uint256[] memory outputs = new uint256[](1);
        outputs[0] = totalSupply;
        return outputs;
    }
}
