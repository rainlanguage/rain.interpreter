// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {LibInterpreterStateNP, STACK_TRACER} from "src/lib/state/LibInterpreterStateNP.sol";
import {Test} from "forge-std/Test.sol";

contract LibInterpreterStateNPStackTraceTest is Test {
    using LibUint256Array for uint256[];

    function testStackTraceCall(uint256 sourceIndex, uint256[] memory inputs) external {
        uint256 lengthBefore = inputs.length;
        vm.expectCall(STACK_TRACER, abi.encodePacked(bytes4(uint32(sourceIndex)), inputs), 1);
        LibInterpreterStateNP.stackTrace(sourceIndex, inputs.dataPointer(), inputs.endPointer());
        // Check we didn't corrupt the inputs length while mutating memory.
        assertEq(inputs.length, lengthBefore);
    }
}
