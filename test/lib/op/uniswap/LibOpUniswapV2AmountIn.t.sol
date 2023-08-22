// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "src/lib/uniswap/LibUniswapV2.sol";
import "test/util/abstract/OpTest.sol";

contract LibOpUniswapV2AmountInTest is OpTest {
    /// Directly test the integrity logic of LibOpUniswapV2AmountIn. The inputs
    /// are always 4 but the outputs depend on the low bit of the operand.
    function testIntegrity(IntegrityCheckStateNP memory state, Operand operand) public {
        // The low bit of the operand determines whether we want the timestamp
        // or not.
        uint256 outputs = 1 + (Operand.unwrap(operand) & 1);

        (uint256 calcInputs, uint256 calcOutputs) = LibOpUniswapV2AmountIn.integrity(state, operand);

        assertEq(calcInputs, 4, "inputs");
        assertEq(calcOutputs, outputs, "outputs");
    }

    /// Directly test the runtime logic of LibOpUniswapV2AmountIn.
    function testOpUniswapV2AmountInRun(
        address factory,
        uint256 amountOut,
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
        amountOut = bound(amountOut, 1, (reserveOut < reserveIn ? reserveOut : reserveIn) - 1);

        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        uint256[] memory inputs = new uint256[](4);
        inputs[0] = uint256(uint160(factory));
        inputs[1] = amountOut;
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
            LibOpUniswapV2AmountIn.referenceFn,
            LibOpUniswapV2AmountIn.integrity,
            LibOpUniswapV2AmountIn.run,
            inputs
        );
    }
}
