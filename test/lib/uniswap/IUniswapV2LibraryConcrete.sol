// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

interface IUniswapV2LibraryConcrete {
    function sortTokens(address tokenA, address tokenB) external pure returns (address token0, address token1);

    function pairFor(address factory, address tokenA, address tokenB) external pure returns (address pair);

    function getReserves(address factory, address tokenA, address tokenB) external view returns (uint256 reserveA, uint256 reserveB);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);

    function getAmountsOut(address factory, uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(address factory, uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}