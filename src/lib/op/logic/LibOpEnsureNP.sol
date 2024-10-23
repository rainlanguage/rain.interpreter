// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity ^0.8.18;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV3.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {LibIntOrAString, IntOrAString} from "rain.intorastring/lib/LibIntOrAString.sol";

/// @title LibOpEnsureNP
/// @notice Opcode to revert if the condition is zero.
library LibOpEnsureNP {
    using LibIntOrAString for IntOrAString;

    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        // There must be exactly 2 inputs.
        return (2, 0);
    }

    /// `ensure`
    /// If the condition is zero, the expression will revert with the given
    /// string.
    /// All conditions are eagerly evaluated and there are no outputs.
    function run(InterpreterStateNP memory, Operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 condition;
        IntOrAString reason;
        assembly ("memory-safe") {
            condition := mload(stackTop)
            reason := mload(add(stackTop, 0x20))
            stackTop := add(stackTop, 0x40)
        }

        require(condition > 0, reason.toString());
        return stackTop;
    }

    /// Gas intensive reference implementation of `ensure` for testing.
    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        require(inputs[0] > 0, IntOrAString.wrap(inputs[1]).toString());
        outputs = new uint256[](0);
    }
}
