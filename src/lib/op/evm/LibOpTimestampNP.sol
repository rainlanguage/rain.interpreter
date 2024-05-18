// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {InterpreterStateNP, LibInterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {FIXED_POINT_ONE} from "rain.math.fixedpoint/lib/FixedPointDecimalConstants.sol";

/// @title LibOpTimestampNP
/// Implementation of the EVM `TIMESTAMP` opcode as a standard Rainlang opcode.
library LibOpTimestampNP {
    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        return (0, 1);
    }

    function run(InterpreterStateNP memory, Operand, Pointer stackTop) internal view returns (Pointer) {
        uint256 decimalOne = FIXED_POINT_ONE;
        assembly ("memory-safe") {
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, mul(timestamp(), decimalOne))
        }
        return stackTop;
    }

    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory)
        internal
        view
        returns (uint256[] memory)
    {
        uint256[] memory outputs = new uint256[](1);
        outputs[0] = block.timestamp * FIXED_POINT_ONE;
        return outputs;
    }
}
