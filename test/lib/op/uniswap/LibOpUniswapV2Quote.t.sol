// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibUniswapV2} from "rain.uniswapv2/src/lib/LibUniswapV2.sol";
import {OpTest} from "test/util/abstract/OpTest.sol";
import {LibOpUniswapV2Quote} from "src/lib/op/uniswap/LibOpUniswapV2Quote.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {IUniswapV2Factory} from "rain.uniswapv2/src/interface/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "rain.uniswapv2/src/interface/IUniswapV2Pair.sol";
import {UniswapV2IdenticalAddresses, UniswapV2ZeroAddress} from "rain.uniswapv2/src/error/ErrUniswapV2.sol";

contract LibOpUniswapV2QuoteTest is OpTest {
    /// Directly test the integrity logic of LibOpUniswapV2Quote. The inputs
    /// are always 4 but the outputs depend on the low bit of the operand.
    function testIntegrity(IntegrityCheckStateNP memory state, Operand operand) public {
        // The low bit of the operand determines whether we want the timestamp
        // or not.
        uint256 outputs = 1 + (Operand.unwrap(operand) & 1);

        (uint256 calcInputs, uint256 calcOutputs) = LibOpUniswapV2Quote.integrity(state, operand);

        assertEq(calcInputs, 4, "inputs");
        assertEq(calcOutputs, outputs, "outputs");
    }

    /// Directly test the runtime logic of LibOpUniswapV2AmountIn.
    function testOpUniswapV2QuoteRun(
        uint256 amountOut,
        address tokenIn,
        address tokenOut,
        uint256 reserveIn,
        uint256 reserveOut,
        uint32 reserveTimestamp,
        uint16 operandData
    ) public {
        address factory = address(0x0123456789ABCDEF);
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
            vm.expectRevert(abi.encodeWithSelector(UniswapV2IdenticalAddresses.selector));
        } else if (tokenIn == address(0) || tokenOut == address(0)) {
            vm.expectRevert(abi.encodeWithSelector(UniswapV2ZeroAddress.selector));
        } else {
            address expectedPair = LibUniswapV2.pairFor(factory, tokenIn, tokenOut);
            vm.mockCall(
                factory,
                abi.encodeWithSelector(IUniswapV2Factory.getPair.selector, tokenIn, tokenOut),
                abi.encode(expectedPair)
            );
            vm.mockCall(
                expectedPair,
                abi.encodeWithSelector(IUniswapV2Pair.getReserves.selector),
                abi.encode(reserveIn, reserveOut, reserveTimestamp)
            );
        }
        opReferenceCheck(
            state,
            operand,
            LibOpUniswapV2Quote.referenceFn,
            LibOpUniswapV2Quote.integrity,
            LibOpUniswapV2Quote.run,
            inputs
        );
    }

    /// Test the eval of `uniswap-v2-quote` parsed from a string.
    /// Test zero inputs.
    function testOpUniswapV2QuoteZeroInputs() public {
        checkBadInputs("_: uniswap-v2-quote();", 0, 4, 0);
    }

    // /// Test the eval of `uniswap-v2-amount-in` parsed from a string.
    // /// Test that 0 output amount returns 0 input amount.
    // function testOpUniswapV2AmountInZeroOutput(uint256 reserveIn, uint256 reserveOut, uint32 reserveTimestamp) public {
    //     address factory = address(0x1234);
    //     address tokenIn = address(0x2345);
    //     address tokenOut = address(0x3456);
    //     reserveIn = bound(reserveIn, 2, type(uint112).max);
    //     reserveOut = bound(reserveOut, 2, type(uint112).max);
    //     address expectedPair = LibUniswapV2.pairFor(factory, tokenIn, tokenOut);
    //     vm.mockCall(
    //         factory,
    //         abi.encodeWithSelector(IUniswapV2Factory.getPair.selector, tokenIn, tokenOut),
    //         abi.encode(expectedPair)
    //     );
    //     vm.mockCall(
    //         expectedPair,
    //         abi.encodeWithSelector(IUniswapV2Pair.getReserves.selector),
    //         abi.encode(reserveIn, reserveOut, reserveTimestamp)
    //     );
    //     checkHappy("_: uniswap-v2-amount-in(0x1234 0 0x2345 0x3456);", 0, "0x1234 0 0x2345 0x3456");
    // }

    // /// Test the eval of `uniswap-v2-amount-in` parsed from a string.
    // /// Test one input.
    // function testOpUniswapV2AmountInOneInput() public {
    //     checkBadInputs("_: uniswap-v2-amount-in(0);", 1, 4, 1);
    //     checkBadInputs("_: uniswap-v2-amount-in(1);", 1, 4, 1);
    //     checkBadInputs("_: uniswap-v2-amount-in(max-decimal18-value());", 1, 4, 1);
    // }

    // /// Test the eval of `uniswap-v2-amount-in` parsed from a string.
    // /// Test two inputs.
    // function testOpUniswapV2AmountInTwoInputs() public {
    //     checkBadInputs("_: uniswap-v2-amount-in(0 0);", 2, 4, 2);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 1);", 2, 4, 2);
    //     checkBadInputs("_: uniswap-v2-amount-in(1 0);", 2, 4, 2);
    //     checkBadInputs("_: uniswap-v2-amount-in(1 1);", 2, 4, 2);
    //     checkBadInputs("_: uniswap-v2-amount-in(1 max-decimal18-value());", 2, 4, 2);
    //     checkBadInputs("_: uniswap-v2-amount-in(max-decimal18-value() 1);", 2, 4, 2);
    // }

    // /// Test the eval of `uniswap-v2-amount-in` parsed from a string.
    // /// Test three inputs.
    // function testOpUniswapV2AmountInThreeInputs() public {
    //     checkBadInputs("_: uniswap-v2-amount-in(0 0 0);", 3, 4, 3);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 0 1);", 3, 4, 3);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 1 0);", 3, 4, 3);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 1 1);", 3, 4, 3);
    //     checkBadInputs("_: uniswap-v2-amount-in(1 0 0);", 3, 4, 3);
    //     checkBadInputs("_: uniswap-v2-amount-in(1 0 1);", 3, 4, 3);
    //     checkBadInputs("_: uniswap-v2-amount-in(1 1 0);", 3, 4, 3);
    //     checkBadInputs("_: uniswap-v2-amount-in(1 1 1);", 3, 4, 3);
    //     checkBadInputs("_: uniswap-v2-amount-in(1 1 max-decimal18-value());", 3, 4, 3);
    //     checkBadInputs("_: uniswap-v2-amount-in(1 max-decimal18-value() 1);", 3, 4, 3);
    //     checkBadInputs("_: uniswap-v2-amount-in(max-decimal18-value() 1 1);", 3, 4, 3);
    // }

    // /// Test the eval of `uniswap-v2-amount-in` parsed from a string.
    // /// Test five inputs.
    // function testOpUniswapV2AmountInFiveInputs() public {
    //     checkBadInputs("_: uniswap-v2-amount-in(0 0 0 0 0);", 5, 4, 5);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 0 0 0 1);", 5, 4, 5);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 0 0 1 0);", 5, 4, 5);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 0 0 1 1);", 5, 4, 5);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 0 1 0 0);", 5, 4, 5);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 0 1 0 1);", 5, 4, 5);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 0 1 1 0);", 5, 4, 5);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 0 1 1 1);", 5, 4, 5);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 1 0 0 0);", 5, 4, 5);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 1 0 0 1);", 5, 4, 5);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 1 0 1 0);", 5, 4, 5);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 1 0 1 1);", 5, 4, 5);
    //     checkBadInputs("_: uniswap-v2-amount-in(0 1 1 0 0);", 5, 4, 5);
    // }
}
