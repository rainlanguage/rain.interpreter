// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {SourceIndexV2, EncodedDispatch} from "../../interface/unstable/IInterpreterV2.sol";

/// @title LibEncodedDispatch
/// @notice Establishes and implements a convention for encoding an interpreter
/// dispatch. Handles encoding of several things required for efficient dispatch.
library LibEncodedDispatch {
    /// Builds an `EncodedDispatch` from its constituent parts.
    /// @param expression The onchain address of the expression to run.
    /// @param sourceIndex The index of the source to run within the expression
    /// as an entrypoint.
    /// @param maxOutputs The maximum outputs the caller can meaningfully use.
    /// If the interpreter returns a larger stack than this it is merely wasting
    /// gas across the external call boundary.
    /// @return The encoded dispatch.
    function encode2(address expression, SourceIndexV2 sourceIndex, uint256 maxOutputs)
        internal
        pure
        returns (EncodedDispatch)
    {
        // Both source index and max outputs are expected to be compile time
        // constants, or at least significantly less than type(uint16).max.
        // Generally a real world implementation would hit gas limits long before
        // either of these values overflowed. Rather than add the gas of
        // conditionals and errors to check for overflow, we simply truncate the
        // values to uint16.
        return EncodedDispatch.wrap(
            (uint256(uint160(expression)) << 0x20) | (uint256(uint16(SourceIndexV2.unwrap(sourceIndex))) << 0x10)
                | uint256(uint16(maxOutputs))
        );
    }

    function decode2(EncodedDispatch dispatch) internal pure returns (address, SourceIndexV2, uint256) {
        return (
            address(uint160(EncodedDispatch.unwrap(dispatch) >> 0x20)),
            SourceIndexV2.wrap(uint256(uint16(EncodedDispatch.unwrap(dispatch) >> 0x10))),
            uint256(uint16(EncodedDispatch.unwrap(dispatch)))
        );
    }
}
