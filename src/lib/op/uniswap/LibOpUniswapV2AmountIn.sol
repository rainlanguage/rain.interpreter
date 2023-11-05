// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {Operand} from "../../../interface/unstable/IInterpreterV2.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {LibUniswapV2} from "../../uniswap/LibUniswapV2.sol";

/// @title LibOpUniswapV2AmountIn
/// @notice Opcode to calculate the amount in for a Uniswap V2 pair.
library LibOpUniswapV2AmountIn {
    function integrity(IntegrityCheckStateNP memory, Operand operand) internal pure returns (uint256, uint256) {
        unchecked {
            // Outputs is 1 if we don't want the timestamp (operand 0) or 2 if we
            // do (operand 1).
            uint256 outputs = 1 + (Operand.unwrap(operand) & 1);
            return (4, outputs);
        }
    }

    function run(InterpreterStateNP memory, Operand operand, Pointer stackTop) internal view returns (Pointer) {
        uint256 factory;
        uint256 amountOut;
        uint256 tokenIn;
        uint256 tokenOut;
        assembly ("memory-safe") {
            factory := mload(stackTop)
            amountOut := mload(add(stackTop, 0x20))
            tokenIn := mload(add(stackTop, 0x40))
            tokenOut := mload(add(stackTop, 0x60))
            stackTop := add(stackTop, add(0x40, mul(0x20, iszero(and(operand, 1)))))
        }
        (uint256 amountIn, uint256 reserveTimestamp) = LibUniswapV2.getAmountInByTokenWithTime(
            address(uint160(factory)), address(uint160(tokenIn)), address(uint160(tokenOut)), amountOut
        );

        assembly ("memory-safe") {
            mstore(stackTop, amountIn)
            if and(operand, 1) { mstore(add(stackTop, 0x20), reserveTimestamp) }
        }
        return stackTop;
    }

    function referenceFn(InterpreterStateNP memory, Operand operand, uint256[] memory inputs)
        internal
        view
        returns (uint256[] memory outputs)
    {
        uint256 factory = inputs[0];
        uint256 amountOut = inputs[1];
        uint256 tokenIn = inputs[2];
        uint256 tokenOut = inputs[3];
        (uint256 amountIn, uint256 reserveTimestamp) = LibUniswapV2.getAmountInByTokenWithTime(
            address(uint160(factory)), address(uint160(tokenIn)), address(uint160(tokenOut)), amountOut
        );
        outputs = new uint256[](1 + (Operand.unwrap(operand) & 1));
        outputs[0] = amountIn;
        if (Operand.unwrap(operand) & 1 == 1) outputs[1] = reserveTimestamp;
    }
}
