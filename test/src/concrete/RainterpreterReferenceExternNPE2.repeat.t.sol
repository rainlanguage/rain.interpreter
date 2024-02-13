// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/abstract/OpTest.sol";
import {RainterpreterReferenceExternNPE2} from "src/concrete/extern/RainterpreterReferenceExternNPE2.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

contract RainterpreterReferenceExternNPE2RepeatTest is OpTest {
    using Strings for address;

    function testRainterpreterReferenceExternNPE2RepeatHappy() external {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();
        string memory baseStr = string.concat("using-words-from ", address(extern).toHexString(), " ");

        uint256[] memory expectedStack = new uint256[](1);
        expectedStack[0] = 999;

        checkHappy(
            bytes(string.concat(baseStr, "nineninenine: [ref-extern-repeat-9 abc];")), expectedStack, "repeat 9 abc"
        );

        expectedStack[0] = 88;
        checkHappy(bytes(string.concat(baseStr, "eighteight: [ref-extern-repeat-8 zz];")), expectedStack, "repeat 8 zz");
    }
}
