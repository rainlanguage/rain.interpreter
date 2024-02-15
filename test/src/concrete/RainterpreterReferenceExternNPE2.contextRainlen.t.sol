// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/abstract/OpTest.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {RainterpreterReferenceExternNPE2} from "src/concrete/extern/RainterpreterReferenceExternNPE2.sol";
import {SignedContextV1} from "src/interface/IInterpreterCallerV2.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";

contract RainterpreterReferenceExternNPE2ContextRainlenTest is OpTest {
    using Strings for address;

    function testRainterpreterReferenceExterNPE2ContextRainlenHappy() external {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();

        bytes memory rainlang = bytes(
            string.concat("using-words-from ", address(extern).toHexString(), " rainlen: ref-extern-context-rainlen();")
        );

        uint256[] memory expectedStack = new uint256[](1);
        expectedStack[0] = rainlang.length;

        uint256[][] memory callerContext = new uint256[][](1);
        callerContext[0] = new uint256[](1);
        callerContext[0][0] = rainlang.length;

        checkHappy(rainlang, LibContext.build(callerContext, new SignedContextV1[](0)), expectedStack, "rainlen");
    }
}
