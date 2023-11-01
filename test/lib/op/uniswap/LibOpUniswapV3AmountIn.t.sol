// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {IQuoterV2} from "v3-periphery/interfaces/IQuoterV2.sol";
import {IUniswapV3Pool} from "v3-core/contracts/interfaces/IUniswapV3Pool.sol";

uint256 constant FORK_BLOCK_NUMBER = 18475369;

contract LibOpUniswapV3AmountInTest is OpTest {
    function selectFork() internal {
        uint256 fork = vm.createFork(vm.envString("MAINNET_RPC"));
        vm.selectFork(fork);
        vm.rollFork(FORK_BLOCK_NUMBER);
    }

    function testLibOpUniswapV3AmountIn() public {
        selectFork();

        IQuoterV2 quoter = IQuoterV2(address(0x61fFE014bA17989E743c5F6cB21bF9697530B21e));
        address dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        address pool = 0x5777d92f208679DB4b9778590Fa3CAB3aC9e2168;
        uint24 fee = IUniswapV3Pool(pool).fee();

        (uint256 amountIn, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate) =
            quoter.quoteExactOutputSingle(IQuoterV2.QuoteExactOutputSingleParams(dai, usdc, 1e18, fee, 0));
    }
}
