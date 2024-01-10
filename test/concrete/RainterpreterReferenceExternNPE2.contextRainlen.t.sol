// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {RainterpreterReferenceExternNPE2} from "src/concrete/extern/RainterpreterReferenceExternNPE2.sol";

contract RainterpreterReferenceExternNPE2ContextRainlenTest is OpTest {
    using Strings for address;

    function testRainterpreterReferenceExterNPE2ContextRainlenHappy() external {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();

        bytes memory rainlang = bytes(
            string.concat("using-words-from ", address(extern).toHexString(), " rainlen: ref-extern-context-rainlen();")
        );

        uint256[] memory expectedStack = new uint256[](1);
        expectedStack[0] = rainlang.length;

        checkHappy(rainlang, expectedStack, "rainlen");
    }
}
