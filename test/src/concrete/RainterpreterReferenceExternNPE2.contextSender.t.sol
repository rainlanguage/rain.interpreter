// SPDX-License-Identifier: CAL
pragma solidity =0.8.26;

import {OpTest} from "test/abstract/OpTest.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {RainterpreterReferenceExternNPE2} from "src/concrete/extern/RainterpreterReferenceExternNPE2.sol";

contract RainterpreterReferenceExternNPE2ContextSenderTest is OpTest {
    using Strings for address;

    function testRainterpreterReferenceExterNPE2ContextSenderHappy() external {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();

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
