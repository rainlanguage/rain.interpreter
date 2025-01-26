// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {RainterpreterReferenceExtern} from "src/concrete/extern/RainterpreterReferenceExtern.sol";

contract RainterpreterReferenceExternContextSenderTest is OpTest {
    using Strings for address;

    function testRainterpreterReferenceExterNPE2ContextSenderHappy() external {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();

        uint256[] memory expectedStack = new uint256[](1);
        expectedStack[0] = uint256(uint160(msg.sender));

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ", address(extern).toHexString(), " sender: ref-extern-context-sender();"
                )
            ),
            expectedStack,
            "sender"
        );
    }
}
