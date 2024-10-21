// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity ^0.8.18;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV3.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {FIXED_POINT_ONE} from "rain.math.fixedpoint/lib/FixedPointDecimalConstants.sol";

/// @title LibOpChainIdNP
/// Implementation of the EVM `CHAINID` opcode as a standard Rainlang opcode.
library LibOpChainIdNP {
    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        return (0, 1);
    }

    function run(InterpreterStateNP memory, Operand, Pointer stackTop) internal view returns (Pointer) {
        uint256 decimalOne = FIXED_POINT_ONE;
        assembly ("memory-safe") {
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, mul(chainid(), decimalOne))
        }
        return stackTop;
    }

    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory)
        internal
        view
        returns (uint256[] memory)
    {
        uint256[] memory outputs = new uint256[](1);
        outputs[0] = block.chainid * FIXED_POINT_ONE;
        return outputs;
    }
}
