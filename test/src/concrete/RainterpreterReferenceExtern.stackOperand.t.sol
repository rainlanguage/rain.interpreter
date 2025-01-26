// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {RainterpreterReferenceExtern} from "src/concrete/extern/RainterpreterReferenceExtern.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

contract RainterpreterReferenceExternStackOperandTest is OpTest {
    using Strings for address;
    using Strings for uint256;

    function testRainterpreterReferenceExternStackOperandSingle(uint256 value) external {
        value = bound(value, 0, type(uint16).max);
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();

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
