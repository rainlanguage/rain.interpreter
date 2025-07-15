// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

/// @title LibOpERC20TotalSupply
/// @notice Opcode for ERC20 `totalSupply`.
library LibOpERC20TotalSupply {
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // Always 1 input, the contract.
        // Always 1 output, the total supply.
        return (1, 1);
    }

    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
        uint256 token;
        assembly ("memory-safe") {
            token := mload(stackTop)
        }
        uint256 totalSupply = IERC20(address(uint160(token))).totalSupply();

        // This can fail as `decimals` is an OPTIONAL part of the ERC20 standard.
        uint8 tokenDecimals = IERC20Metadata(address(uint160(token))).decimals();

        Float totalSupplyFloat = LibDecimalFloat.fromFixedDecimalLosslessPacked(totalSupply, tokenDecimals);

        assembly ("memory-safe") {
            mstore(stackTop, totalSupplyFloat)
        }
        return stackTop;
    }

    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        view
        returns (StackItem[] memory)
    {
        address account = address(uint160(uint256(StackItem.unwrap(inputs[0]))));
        uint256 totalSupply = IERC20(account).totalSupply();

        uint8 tokenDecimals = IERC20Metadata(address(uint160(account))).decimals();
        Float totalSupplyFloat = LibDecimalFloat.fromFixedDecimalLosslessPacked(totalSupply, tokenDecimals);

        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(Float.unwrap(totalSupplyFloat));
        return outputs;
    }
}
