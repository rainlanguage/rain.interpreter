// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";

/// @title LibOpCallNPTest
/// @notice Test the LibOpCallNP library that includes the "call" word.
contract LibOpCallNPTest is OpTest {
    /// Directly test the integrity logic of LibOpCallNP.

    /// Test the eval of some call that has order dependent inputs and outputs
    /// so we can sanity check the stacks.
    function testOpCallNPRunOrdering() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iDeployer.parse("a b: call<1 2>(10 5); ten five:, a b: int-div(ten five) 9;");
        // The second source is for internal calls only, it is not an entrypoint.
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 2;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            new uint256[][](0)
        );

        assertEq(stack.length, 2, "stack length");
        assertEq(stack[0], 2, "stack[0]");
        assertEq(stack[1], 9, "stack[1]");
        assertEq(kvs.length, 0, "kvs length");
    }
}
