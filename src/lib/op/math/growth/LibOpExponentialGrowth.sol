// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2, StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterState} from "../../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../../integrity/LibIntegrityCheck.sol";
import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

import {console2} from "forge-std/console2.sol";

/// @title LibOpExponentialGrowth
/// @notice Exponential growth is base(1 + rate)^t where base is the initial
/// value, rate is the growth rate, and t is time.
library LibOpExponentialGrowth {
    using LibDecimalFloat for Float;

    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // There must be three inputs and one output.
        return (3, 1);
    }

    /// exponential-growth
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
        Float base;
        Float rate;
        Float t;
        assembly ("memory-safe") {
            base := mload(stackTop)
            rate := mload(add(stackTop, 0x20))
            stackTop := add(stackTop, 0x40)
            t := mload(stackTop)
        }
        console2.log("Exponential Growth:");
        console2.log(LibDecimalFloat.LOG_TABLES_ADDRESS);
        (int256 signedCoefficient, int256 exponent) = LibDecimalFloat.unpack(base);
        console2.log("  Base:");
        console2.logInt(signedCoefficient);
        console2.logInt(exponent);
        (signedCoefficient, exponent) = LibDecimalFloat.unpack(rate);
        console2.log("  Rate:");
        console2.logInt(signedCoefficient);
        console2.logInt(exponent);
        (signedCoefficient, exponent) = LibDecimalFloat.unpack(t);
        console2.log("  Time:");
        console2.logInt(signedCoefficient);
        console2.logInt(exponent);
        console2.log("Calculating...");
        console2.log("add");
        Float add = rate.add(LibDecimalFloat.FLOAT_ONE);
        console2.log("pow");
        (signedCoefficient, exponent) = LibDecimalFloat.unpack(add);
        console2.log("  (1 + r):");
        console2.logInt(signedCoefficient);
        console2.logInt(exponent);
        Float pow = add.pow(t, LibDecimalFloat.LOG_TABLES_ADDRESS);
        console2.log("mul");
        base = base.mul(pow);
        // base = base.mul(rate.add(LibDecimalFloat.FLOAT_ONE).pow(t, LibDecimalFloat.LOG_TABLES_ADDRESS));

        console2.log("done");

        assembly ("memory-safe") {
            mstore(stackTop, base)
        }
        return stackTop;
    }

    /// Gas intensive reference implementation for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        view
        returns (StackItem[] memory)
    {
        Float base = Float.wrap(StackItem.unwrap(inputs[0]));
        Float rate = Float.wrap(StackItem.unwrap(inputs[1]));
        Float t = Float.wrap(StackItem.unwrap(inputs[2]));
        base = base.mul(rate.add(LibDecimalFloat.FLOAT_ONE).pow(t, LibDecimalFloat.LOG_TABLES_ADDRESS));
        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(Float.unwrap(base));
        return outputs;
    }
}
