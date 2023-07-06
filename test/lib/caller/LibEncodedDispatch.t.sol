// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

import "forge-std/Test.sol";
import "src/lib/caller/LibEncodedDispatch.sol";

contract LibEncodedDispatchTest is Test {
    function testRoundTrip(address expression, SourceIndex sourceIndex, uint16 maxOutputs) public {
        (address expressionDecoded, SourceIndex sourceIndexDecoded, uint16 maxOutputsDecoded) =
            LibEncodedDispatch.decode(LibEncodedDispatch.encode(expression, sourceIndex, maxOutputs));
        assertEq(expression, expressionDecoded);
        assertEq(SourceIndex.unwrap(sourceIndex), SourceIndex.unwrap(sourceIndexDecoded));
        assertEq(maxOutputs, maxOutputsDecoded);
    }
}
