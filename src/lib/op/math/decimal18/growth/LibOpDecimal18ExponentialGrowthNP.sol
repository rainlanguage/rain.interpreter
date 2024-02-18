// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {UD60x18, mul, pow} from "prb-math/UD60x18.sol";
import {Operand} from "../../../../../interface/unstable/IInterpreterV2.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterStateNP} from "../../../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpDecimal18ExponentialGrowthNP
/// @notice Exponential growth is a(1 + r)^t where a is the initial value, r is
/// the growth rate, and t is time.
library LibOpDecimal18ExponentialGrowthNP {
    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        // There must be three inputs and one output.
        return (3, 1);
    }

    /// decimal18-exponential-growth
    function run(InterpreterStateNP memory, Operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 a;
        uint256 r;
        uint256 t;
        assembly ("memory-safe") {
            a := mload(stackTop)
            r := mload(add(stackTop, 0x20))
            stackTop := add(stackTop, 0x40)
            t := mload(stackTop)
        }
        a = UD60x18.unwrap(mul(UD60x18.wrap(a), pow(UD60x18.wrap(1e18 + r), UD60x18.wrap(t))));

        assembly ("memory-safe") {
            mstore(stackTop, a)
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of avg for testing.
    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory)
    {
        uint256[] memory outputs = new uint256[](1);
        outputs[0] =
            UD60x18.unwrap(mul(UD60x18.wrap(inputs[0]), pow(UD60x18.wrap(1e18 + inputs[1]), UD60x18.wrap(inputs[2]))));
        return outputs;
    }
}
