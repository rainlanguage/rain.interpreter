// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {RainterpreterReferenceExternNPE2} from "src/concrete/extern/RainterpreterReferenceExternNPE2.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {UnknownWord} from "src/error/ErrParse.sol";

contract RainterpreterReferenceExternNPE2UnknownWordTest is OpTest {
    using Strings for address;

    function testRainterpreterReferenceExternNPE2UnknownWord() external {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();

        checkUnhappyParse(
            bytes(string.concat("using-words-from ", address(extern).toHexString(), " _: not-a-word();")),
            abi.encodeWithSelector(UnknownWord.selector, "not-a-word")
        );
    }
}
