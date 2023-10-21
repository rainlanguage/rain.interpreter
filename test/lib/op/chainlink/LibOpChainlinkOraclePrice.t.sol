// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibWillOverflow} from "rain.math.fixedpoint/lib/LibWillOverflow.sol";

import "src/interface/IInterpreterV1.sol";
import "src/lib/op/chainlink/LibOpChainlinkOraclePrice.sol";
import {AggregatorV3Interface} from "rain.chainlink/interface/AggregatorV3Interface.sol";

/// @title LibOpChainlinkOraclePriceTest
/// Test the runtime and integrity time logic of LibOpChainlinkOraclePrice.
contract LibOpChainlinkOraclePriceTest is Test {
    /// `f` is a thin wrapper around `LibChainlink.price`. Test that it returns
    /// the same value. This test only covers the happy path where the underlying
    /// Chainlink call succeeds.
    /// If forge supports mocking and expecting reverts at the same time we can
    /// also test the unhappy path.
    /// https://github.com/foundry-rs/foundry/issues/5359
    function testOpChainlinkOraclePriceF(
        uint256 currentTimestamp,
        uint256 feed,
        uint256 staleAfter,
        uint256 scalingFlags,
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound,
        uint8 decimals
    ) external {
        vm.warp(currentTimestamp);
        answer = bound(answer, 1, type(int256).max);
        vm.assume(!LibWillOverflow.scale18WillOverflow(uint256(answer), decimals, scalingFlags));
        updatedAt = bound(updatedAt, 0, currentTimestamp);
        staleAfter = bound(staleAfter, currentTimestamp - updatedAt, type(uint256).max);
        uint256 price =
            LibChainlink.roundDataToPrice(currentTimestamp, staleAfter, scalingFlags, answer, updatedAt, decimals);
        Operand operand = Operand.wrap(scalingFlags & type(uint16).max);

        vm.assume(address(uint160(feed)) != address(this));
        assumeNotPrecompile(address(uint160(feed)));
        vm.etch(address(uint160(feed)), hex"00");
        vm.mockCall(
            address(uint160(feed)),
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(roundId, answer, startedAt, updatedAt, answeredInRound)
        );
        vm.mockCall(
            address(uint160(feed)),
            abi.encodeWithSelector(AggregatorV3Interface.decimals.selector),
            abi.encode(decimals)
        );

        assertEq(LibOpChainlinkOraclePrice.f(operand, feed, staleAfter), price);
    }
}
