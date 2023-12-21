// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {
    RainterpreterReferenceExternNPE2,
    OPCODE_FUNCTION_POINTERS,
    INTEGRITY_FUNCTION_POINTERS
} from "src/concrete/RainterpreterReferenceExternNPE2.sol";
import {
    ExternDispatch,
    EncodedExternDispatch,
    IInterpreterExternV3
} from "src/interface/unstable/IInterpreterExternV3.sol";
import {Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {LibExtern} from "src/lib/extern/LibExtern.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

contract RainterpreterReferenceExternNPE2IntIncTest is OpTest {
    using Strings for address;

    function testRainterpreterReferenceExternNPE2IntIncHappy() external {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();

        uint256 intIncOpcode = 0;

        ExternDispatch externDispatch = LibExtern.encodeExternDispatch(intIncOpcode, Operand.wrap(0));
        EncodedExternDispatch encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);

        assertEq(
            EncodedExternDispatch.unwrap(encodedExternDispatch),
            0x000000000000000000000000c7183455a4c133ae270771860664b6b7ec320bb1
        );

        uint256[] memory expectedStack = new uint256[](3);
        expectedStack[0] = 4;
        expectedStack[1] = 3;
        expectedStack[2] = EncodedExternDispatch.unwrap(encodedExternDispatch);

        checkHappy(
            // Need the constant in the constant array to be indexable in the operand.
            "_: 0x000000000000000000000000c7183455a4c133ae270771860664b6b7ec320bb1,"
            // Operand is the constant index of the dispatch.
            "three four: extern<0 2>(2 3);",
            expectedStack,
            "inc 2 3 = 3 4"
        );
    }

    function testRainterpreterReferenceExternNPE2IntIncHappySugared() external {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();

        uint256[] memory expectedStack = new uint256[](2);
        expectedStack[0] = 4;
        expectedStack[1] = 3;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ", address(extern).toHexString(), " three four: reference-extern-inc(2 3);"
                )
            ),
            expectedStack,
            "sugared inc 2 3 = 3 4"
        );
    }
}
