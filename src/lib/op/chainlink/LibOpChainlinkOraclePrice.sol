// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.chainlink/lib/LibChainlink.sol";

import "../../../interface/IInterpreterV1.sol";

/// @title LibOpChainlinkOraclePrice
/// An opcode which pushes the current price of a Chainlink oracle to the stack.
library LibOpChainlinkOraclePrice {
    function f(
        Operand operand,
        uint256 feed,
        uint256 staleAfter
    ) internal view returns (uint256) {
        return LibChainlink.price(address(uint160(feed)), staleAfter, Operand.unwrap(operand));
    }
}