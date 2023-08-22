// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "v2-core/interfaces/IUniswapV2Pair.sol";

/// UniswapV2Library from uniswap/v2-periphery is compiled with a version of
/// SafeMath that is locked to Solidity 0.6.x which means we can't use it in
/// Solidity 0.8.x. This is a copy of the library with the SafeMath dependency
/// removed, using Solidity's built-in overflow checking.
/// Some minor modifications have been made to the reference functions. These
/// are noted in the comments and/or made explicit by descriptively renaming the
/// functions to differentiate them from the original.
library LibUniswapV2 {
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

    /// Bundles the key library logic together to produce amounts based on tokens
    /// and amounts out rather than needing to handle reserves directly.
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
}