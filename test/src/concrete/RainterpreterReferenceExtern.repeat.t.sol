// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {
    RainterpreterReferenceExtern,
    StackItem,
    InvalidRepeatCount
} from "src/concrete/extern/RainterpreterReferenceExtern.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

contract RainterpreterReferenceExternRepeatTest is OpTest {
    using Strings for address;

    function testRainterpreterReferenceExternRepeatHappy() external {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();
        string memory baseStr = string.concat("using-words-from ", address(extern).toHexString(), " ");

        StackItem[] memory expectedStack = new StackItem[](1);
        expectedStack[0] = StackItem.wrap(bytes32(uint256(999)));

        checkHappy(
            bytes(string.concat(baseStr, "nineninenine: [ref-extern-repeat-9 abc];")), expectedStack, "repeat 9 abc"
        );

        expectedStack[0] = StackItem.wrap(bytes32(uint256(88)));
        checkHappy(bytes(string.concat(baseStr, "eighteight: [ref-extern-repeat-8 zz];")), expectedStack, "repeat 8 zz");
    }

    /// Negative repeat count must revert.
    function testRainterpreterReferenceExternRepeatNegative() external {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();
        string memory baseStr = string.concat("using-words-from ", address(extern).toHexString(), " ");

        vm.expectRevert();
        bytes memory bytecode = I_DEPLOYER.parse2(bytes(string.concat(baseStr, "_: [ref-extern-repeat--1 abc];")));
        (bytecode);
    }

    /// Non-integer repeat count (e.g. 1.5) must revert.
    function testRainterpreterReferenceExternRepeatNonInteger() external {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();
        string memory baseStr = string.concat("using-words-from ", address(extern).toHexString(), " ");

        vm.expectRevert();
        bytes memory bytecode = I_DEPLOYER.parse2(bytes(string.concat(baseStr, "_: [ref-extern-repeat-1.5 abc];")));
        (bytecode);
    }

    /// Repeat count > 9 must revert.
    function testRainterpreterReferenceExternRepeatTooLarge() external {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();
        string memory baseStr = string.concat("using-words-from ", address(extern).toHexString(), " ");

        vm.expectRevert();
        bytes memory bytecode = I_DEPLOYER.parse2(bytes(string.concat(baseStr, "_: [ref-extern-repeat-10 abc];")));
        (bytecode);
    }
}
