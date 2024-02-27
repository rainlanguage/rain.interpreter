// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {Operand} from "rain.interpreter.interface/interface/unstable/IInterpreterV2.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";

/// @title LibOpERC20TotalSupplyNP
/// @notice Opcode for ERC20 `totalSupply`.
library LibOpERC20TotalSupplyNP {
    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        // Always 1 input, the contract.
        // Always 1 output, the total supply.
        return (1, 1);
    }

    function run(InterpreterStateNP memory, Operand, Pointer stackTop) internal view returns (Pointer) {
        uint256 account;
        assembly {
            account := mload(stackTop)
        }
        uint256 totalSupply = IERC20(address(uint160(account))).totalSupply();
        assembly {
            mstore(stackTop, totalSupply)
        }
        return stackTop;
    }

    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs)
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
