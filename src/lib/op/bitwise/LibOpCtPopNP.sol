// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {Operand} from "src/interface/IInterpreterV1.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {LibCtPop} from "src/lib/bitwise/LibCtPop.sol";
import {LibCtPopSlow} from "test/lib/bitwise/LibCtPopSlow.sol";

library LibOpCtPopNP {
    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        return (1, 1);
    }

    function run(InterpreterStateNP memory, Operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 value;
        assembly ("memory-safe") {
            value := mload(stackTop)
        }
        value = LibCtPop.ctpop(value);
        assembly ("memory-safe") {
            mstore(stackTop, value)
        }
        return stackTop;
    }

    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory)
    {
        uint256[] memory outputs = new uint256[](1);
        outputs[0] = LibCtPopSlow.ctpopSlow(inputs[0]);
        return outputs;
    }
}