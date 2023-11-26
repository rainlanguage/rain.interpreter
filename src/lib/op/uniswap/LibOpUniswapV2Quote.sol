// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {Operand} from "../../../interface/unstable/IInterpreterV2.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {LibUniswapV2} from "../../uniswap/LibUniswapV2.sol";

/// @title LibOpUniswapV2Quote
/// @notice Opcode to calculate the quote for a Uniswap V2 pair.
library LibOpUniswapV2Quote {
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
        uint256 amountA;
        uint256 tokenA;
        uint256 tokenB;
        uint256 withTime;
        assembly ("memory-safe") {
            factory := mload(stackTop)
            amountA := mload(add(stackTop, 0x20))
            tokenA := mload(add(stackTop, 0x40))
            tokenB := mload(add(stackTop, 0x60))
            withTime := and(operand, 1)
            stackTop := add(stackTop, add(0x40, mul(0x20, iszero(withTime))))
        }
        (uint256 amountB, uint256 reserveTimestamp) = LibUniswapV2.getQuoteWithTime(
            address(uint160(factory)), address(uint160(tokenA)), address(uint160(tokenB)), amountA
        );

        assembly ("memory-safe") {
            mstore(stackTop, amountB)
            if withTime { mstore(add(stackTop, 0x20), reserveTimestamp) }
        }
        return stackTop;
    }

    function referenceFn(InterpreterStateNP memory, Operand operand, uint256[] memory inputs)
        internal
        view
        returns (uint256[] memory outputs)
    {
        uint256 factory = inputs[0];
        uint256 amountA = inputs[1];
        uint256 tokenA = inputs[2];
        uint256 tokenB = inputs[3];
        (uint256 amountB, uint256 reserveTimestamp) = LibUniswapV2.getQuoteWithTime(
            address(uint160(factory)), address(uint160(tokenA)), address(uint160(tokenB)), amountA
        );
        outputs = new uint256[](1 + (Operand.unwrap(operand) & 1));
        outputs[0] = amountB;
        if (Operand.unwrap(operand) & 1 == 1) {
            outputs[1] = reserveTimestamp;
        }
    }
}
