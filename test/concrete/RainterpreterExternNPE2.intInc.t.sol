// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {
    RainterpreterExternNPE2,
    OPCODE_FUNCTION_POINTERS,
    INTEGRITY_FUNCTION_POINTERS
} from "src/concrete/RainterpreterExternNPE2.sol";
import {
    ExternDispatch,
    EncodedExternDispatch,
    IInterpreterExternV3
} from "src/interface/unstable/IInterpreterExternV3.sol";
import {Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {LibExtern} from "src/lib/extern/LibExtern.sol";

contract RainterpreterExternNPE2IntIncTest is OpTest {
    function testRainterpreterExternNPE2IntIncHappy() external {
        RainterpreterExternNPE2 extern = new RainterpreterExternNPE2();

        uint256 intIncOpcode = 1;

        ExternDispatch externDispatch = LibExtern.encodeExternDispatch(intIncOpcode, Operand.wrap(0));
        EncodedExternDispatch encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);

        assertEq(
            EncodedExternDispatch.unwrap(encodedExternDispatch),
            0x000000000000000000010000c7183455a4c133ae270771860664b6b7ec320bb1
        );

        uint256[] memory expectedStack = new uint256[](3);
        expectedStack[0] = 4;
        expectedStack[1] = 3;
        expectedStack[2] = EncodedExternDispatch.unwrap(encodedExternDispatch);

        checkHappy(
            // Need the constant in the constant array to be indexable in the operand.
            "_: 0x000000000000000000010000c7183455a4c133ae270771860664b6b7ec320bb1,"
            // Operand is the constant index of the dispatch.
            "three four: extern<0 2>(2 3);",
            expectedStack,
            "add 2 3 = 3 4"
        );
    }
}
