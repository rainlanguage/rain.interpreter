// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "v2-core/interfaces/IUniswapV2Pair.sol";

import "../../integrity/LibIntegrityCheckNP.sol";
import "../../state/LibInterpreterStateNP.sol";

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

    /// Copy of UniswapV2Library.sortTokens for solidity 0.8.x support.
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    /// Copy of UniswapV2Library.pairFor for solidity 0.8.x support.
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        unchecked {
            pair = address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                hex"ff",
                                factory,
                                keccak256(abi.encodePacked(token0, token1)),
                                hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f" // init code hash
                            )
                        )
                    )
                )
            );
        }
    }

    /// UniswapV2Library.sol has a `getReserves` function but it discards the
    /// timestamp that the pair reserves were last updated at. This function
    /// duplicates the logic of `getReserves` but returns the timestamp as well.
    function getReservesWithTime(address factory, address tokenA, address tokenB)
        internal
        view
        returns (uint256 reserveA, uint256 reserveB, uint256 timestamp)
    {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, uint256 blockTimestampLast) =
            IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB, timestamp) =
            tokenA == token0 ? (reserve0, reserve1, blockTimestampLast) : (reserve1, reserve0, blockTimestampLast);
    }

    /// Copy of UniswapV2Library.getAmountIn for solidity 0.8.x support.
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountIn)
    {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;
        amountIn = (numerator / denominator) + 1;
    }

    function getAmountInByTokenWithTime(address factory, address tokenIn, address tokenOut, uint256 amountOut)
        internal
        view
        returns (uint256 amountIn, uint256 timestamp)
    {
        (uint256 reserveIn, uint256 reserveOut, uint256 reserveTimestamp) =
            getReservesWithTime(factory, tokenIn, tokenOut);
        amountIn = getAmountIn(amountOut, reserveIn, reserveOut);
        timestamp = reserveTimestamp;
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
        (uint256 amountIn, uint256 reserveTimestamp) = getAmountInByTokenWithTime(
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
        (uint256 amountIn, uint256 reserveTimestamp) = getAmountInByTokenWithTime(
            address(uint160(factory)), address(uint160(tokenIn)), address(uint160(tokenOut)), amountOut
        );
        outputs = new uint256[](1 + (Operand.unwrap(operand) & 1));
        outputs[0] = amountIn;
        if (Operand.unwrap(operand) & 1 == 1) outputs[1] = reserveTimestamp;
    }
}
