// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {LibChainlink} from "rain.chainlink/lib/LibChainlink.sol";

import "../../../interface/IInterpreterV1.sol";

/// @title LibOpChainlinkOraclePrice
/// An opcode which pushes the current price of a Chainlink oracle to the stack.
library LibOpChainlinkOraclePrice {
    /// Thin wrapper around `LibChainlink.price`.
    /// Casts arguments to the types expected by `LibChainlink.price` without
    /// checking their validity. `LibChainlink.price` will revert if the
    /// arguments are clearly invalid, or there is a detectable issue with the
    /// upstream Chainlink oracle (such as negative price or stale data).
    /// @param operand The scaling flags.
    /// @param feed The address of the Chainlink oracle.
    /// @param staleAfter The number of seconds after which the price is stale.
    /// This is compared against the `updatedAt` field of the Chainlink oracle
    /// and the current timestamp, so functions as a max age on price data.
    function f(Operand operand, uint256 feed, uint256 staleAfter) internal view returns (uint256) {
        return LibChainlink.price(address(uint160(feed)), staleAfter, Operand.unwrap(operand));
    }
}
