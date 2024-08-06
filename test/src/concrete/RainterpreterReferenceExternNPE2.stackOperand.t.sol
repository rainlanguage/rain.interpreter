// SPDX-License-Identifier: CAL
pragma solidity =0.8.26;

import {OpTest} from "test/abstract/OpTest.sol";
import {RainterpreterReferenceExternNPE2} from "src/concrete/extern/RainterpreterReferenceExternNPE2.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

contract RainterpreterReferenceExternNPE2StackOperandTest is OpTest {
    using Strings for address;
    using Strings for uint256;

    function testRainterpreterReferenceExternNPE2StackOperandSingle(uint256 value) external {
        value = bound(value, 0, type(uint16).max);
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();

        uint256[] memory expectedStack = new uint256[](1);
        expectedStack[0] = value;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(extern).toHexString(),
                    " _: ref-extern-stack-operand<",
                    value.toString(),
                    ">();"
                )
            ),
            expectedStack,
            "stack operand"
        );
    }
}
