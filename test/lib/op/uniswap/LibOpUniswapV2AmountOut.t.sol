// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "src/lib/uniswap/LibUniswapV2.sol";
import "test/util/abstract/OpTest.sol";

contract LibOpUniswapV2AmountOutTest is OpTest {
    /// Directly test the integrity logic of LibOpUniswapV2AmountOut. The inputs
    /// are always 4 but the outputs depend on the low bit of the operand.
    function testIntegrity(IntegrityCheckStateNP memory state, Operand operand) public {
        // The low bit of the operand determines whether we want the timestamp
        // or not.
        uint256 outputs = 1 + (Operand.unwrap(operand) & 1);

        (uint256 calcInputs, uint256 calcOutputs) = LibOpUniswapV2AmountOut.integrity(state, operand);

        assertEq(calcInputs, 4, "inputs");
        assertEq(calcOutputs, outputs, "outputs");
    }

    /// Directly test the runtime logic of LibOpUniswapV2AmountOut.
    function testOpUniswapV2AmountOutRun(
        address factory,
        uint256 amountIn,
        address tokenIn,
        address tokenOut,
        uint256 reserveIn,
        uint256 reserveOut,
        uint32 reserveTimestamp,
        uint16 operandData
    ) public {
        // We can't check the error conditions for these while also mocking due
        // to the way the mock works. So we just bound them for this test.
        // Anything outside these bounds is expected to revert in real use.
        reserveIn = bound(reserveIn, 2, type(uint112).max);
        reserveOut = bound(reserveOut, 2, type(uint112).max);
        // Depending on the sort order of the tokens, the reserve amounts may
        // be swapped internally, so "out" may be "in". Simple hack is to just
        // bound the amount to the smaller of the two reserves. This prevents
        // a divide by zero in the library.
        amountIn = bound(amountIn, 1, (reserveOut < reserveIn ? reserveOut : reserveIn) - 1);

        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        uint256[] memory inputs = new uint256[](4);
        inputs[0] = uint256(uint160(factory));
        inputs[1] = amountIn;
        inputs[2] = uint256(uint160(tokenIn));
        inputs[3] = uint256(uint160(tokenOut));
        Operand operand = Operand.wrap((4 << 0x10) | uint256(operandData));

        if (tokenIn == tokenOut) {
            vm.expectRevert("UniswapV2Library: IDENTICAL_ADDRESSES");
        } else if (tokenIn == address(0) || tokenOut == address(0)) {
            vm.expectRevert("UniswapV2Library: ZERO_ADDRESS");
        } else {
            address expectedPair = LibUniswapV2.pairFor(factory, tokenIn, tokenOut);
            vm.mockCall(
                expectedPair,
                abi.encodeWithSelector(IUniswapV2Pair.getReserves.selector),
                abi.encode(reserveIn, reserveOut, reserveTimestamp)
            );
        }
        opReferenceCheck(
            state,
            operand,
            LibOpUniswapV2AmountOut.referenceFn,
            LibOpUniswapV2AmountOut.integrity,
            LibOpUniswapV2AmountOut.run,
            inputs
        );
    }

    /// Test the eval of `uniswap-v2-amount-out` parsed from a string.
    /// Test zero inputs.
    function testOpUniswapV2AmountOutZeroInputs() public {
        checkBadInputs("_: uniswap-v2-amount-out();", 0, 4, 0);
    }

    /// Test the eval of `uniswap-v2-amount-out` parsed from a string.
    /// Test one input.
    function testOpUniswapV2AmountOutOneInput() public {
        checkBadInputs("_: uniswap-v2-amount-out(0);", 1, 4, 1);
        checkBadInputs("_: uniswap-v2-amount-out(1);", 1, 4, 1);
        checkBadInputs("_: uniswap-v2-amount-out(max-decimal18-value());", 1, 4, 1);
    }

    /// Test the eval of `uniswap-v2-amount-out` parsed from a string.
    /// Test two inputs.
    function testOpUniswapV2AmountOutTwoInputs() public {
        checkBadInputs("_: uniswap-v2-amount-out(0 0);", 2, 4, 2);
        checkBadInputs("_: uniswap-v2-amount-out(0 1);", 2, 4, 2);
        checkBadInputs("_: uniswap-v2-amount-out(1 0);", 2, 4, 2);
        checkBadInputs("_: uniswap-v2-amount-out(1 1);", 2, 4, 2);
        checkBadInputs("_: uniswap-v2-amount-out(1 max-decimal18-value());", 2, 4, 2);
        checkBadInputs("_: uniswap-v2-amount-out(max-decimal18-value() 1);", 2, 4, 2);
    }

    /// Test the eval of `uniswap-v2-amount-out` parsed from a string.
    /// Test three inputs.
    function testOpUniswapV2AmountOutThreeInputs() public {
        checkBadInputs("_: uniswap-v2-amount-out(0 0 0);", 3, 4, 3);
        checkBadInputs("_: uniswap-v2-amount-out(0 0 1);", 3, 4, 3);
        checkBadInputs("_: uniswap-v2-amount-out(0 1 0);", 3, 4, 3);
        checkBadInputs("_: uniswap-v2-amount-out(0 1 1);", 3, 4, 3);
        checkBadInputs("_: uniswap-v2-amount-out(1 0 0);", 3, 4, 3);
        checkBadInputs("_: uniswap-v2-amount-out(1 0 1);", 3, 4, 3);
        checkBadInputs("_: uniswap-v2-amount-out(1 1 0);", 3, 4, 3);
        checkBadInputs("_: uniswap-v2-amount-out(1 1 1);", 3, 4, 3);
        checkBadInputs("_: uniswap-v2-amount-out(1 1 max-decimal18-value());", 3, 4, 3);
        checkBadInputs("_: uniswap-v2-amount-out(1 max-decimal18-value() 1);", 3, 4, 3);
        checkBadInputs("_: uniswap-v2-amount-out(max-decimal18-value() 1 1);", 3, 4, 3);
    }

    /// Test the eval of `uniswap-v2-amount-out` parsed from a string.
    /// Test five inputs.
    function testOpUniswapV2AmountOutFiveInputs() public {
        checkBadInputs("_: uniswap-v2-amount-out(0 0 0 0 0);", 5, 4, 5);
        checkBadInputs("_: uniswap-v2-amount-out(0 0 0 0 1);", 5, 4, 5);
        checkBadInputs("_: uniswap-v2-amount-out(0 0 0 1 0);", 5, 4, 5);
        checkBadInputs("_: uniswap-v2-amount-out(0 0 0 1 1);", 5, 4, 5);
        checkBadInputs("_: uniswap-v2-amount-out(0 0 1 0 0);", 5, 4, 5);
        checkBadInputs("_: uniswap-v2-amount-out(0 0 1 0 1);", 5, 4, 5);
        checkBadInputs("_: uniswap-v2-amount-out(0 0 1 1 0);", 5, 4, 5);
        checkBadInputs("_: uniswap-v2-amount-out(0 0 1 1 1);", 5, 4, 5);
        checkBadInputs("_: uniswap-v2-amount-out(0 1 0 0 0);", 5, 4, 5);
        checkBadInputs("_: uniswap-v2-amount-out(0 1 0 0 1);", 5, 4, 5);
        checkBadInputs("_: uniswap-v2-amount-out(0 1 0 1 0);", 5, 4, 5);
        checkBadInputs("_: uniswap-v2-amount-out(0 1 0 1 1);", 5, 4, 5);
        checkBadInputs("_: uniswap-v2-amount-out(0 1 1 0 0);", 5, 4, 5);
    }
}
