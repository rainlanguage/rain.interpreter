// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity ^0.8.18;

import {Operand} from "rain.interpreter.interface/interface/IInterpreterV3.sol";
import {
    IInterpreterExternV3,
    ExternDispatch,
    EncodedExternDispatch
} from "rain.interpreter.interface/interface/IInterpreterExternV3.sol";

/// @title LibExtern
/// Defines and implements an encoding and decoding scheme for the data that
/// controls the behaviour of externs.
library LibExtern {
    /// Converts an opcode and operand pair into a single 32-byte word.
    /// The encoding scheme is:
    /// - bits [0,16): the operand
    /// - bits [16,32): the opcode
    /// IMPORTANT: The encoding process does not check that either the opcode or
    /// operand fit within 16 bits. This is the responsibility of the caller.
    function encodeExternDispatch(uint256 opcode, Operand operand) internal pure returns (ExternDispatch) {
        return ExternDispatch.wrap(opcode << 0x10 | Operand.unwrap(operand));
    }

    /// Inverse of `encodeExternDispatch`.
    function decodeExternDispatch(ExternDispatch dispatch) internal pure returns (uint256, Operand) {
        return (ExternDispatch.unwrap(dispatch) >> 0x10, Operand.wrap(uint16(ExternDispatch.unwrap(dispatch))));
    }

    /// Encodes an extern address and dispatch pair into a single 32-byte word.
    /// This is the full data required to actually call an extern contract.
    /// The encoding scheme is:
    /// - bits [0,160): the address of the extern contract
    /// - bits [160,176): the dispatch operand
    /// - bits [176,192): the dispatch opcode
    /// Note that the high bits are implied by a correctly encoded
    /// `ExternDispatch`. Use `encodeExternDispatch` to ensure this.
    /// IMPORTANT: The encoding process does not check that any of the values
    /// fit within their respective bit ranges. This is the responsibility of
    /// the caller.
    function encodeExternCall(IInterpreterExternV3 extern, ExternDispatch dispatch)
        internal
        pure
        returns (EncodedExternDispatch)
    {
        return EncodedExternDispatch.wrap(uint256(uint160(address(extern))) | ExternDispatch.unwrap(dispatch) << 160);
    }

    /// Inverse of `encodeExternCall`.
    function decodeExternCall(EncodedExternDispatch dispatch)
        internal
        pure
        returns (IInterpreterExternV3, ExternDispatch)
    {
        return (
            IInterpreterExternV3(address(uint160(EncodedExternDispatch.unwrap(dispatch)))),
            ExternDispatch.wrap(EncodedExternDispatch.unwrap(dispatch) >> 160)
        );
    }
}
