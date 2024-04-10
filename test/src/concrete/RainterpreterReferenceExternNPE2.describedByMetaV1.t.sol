// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {RainterpreterReferenceExternNPE2} from "src/concrete/extern/RainterpreterReferenceExternNPE2.sol";

contract RainterpreterReferenceExternNPE2DescribedByMetaV1 is Test {
    function testRainterpreterReferenceExternNPE2DescribedByMetaV1Happy() external {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();
        bytes memory describedByMeta = vm.readFileBinary("meta/RainterpreterReferenceExternNPE2.rain.meta");

        assertEq(keccak256(describedByMeta), extern.describedByMetaV1());
    }
}
