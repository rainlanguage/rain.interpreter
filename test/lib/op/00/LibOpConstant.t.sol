// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";

import "src/lib/caller/LibContext.sol";

/// @title LibOpConstantTest
contract LibOpConstantTest is RainterpreterExpressionDeployerDeploymentTest {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibInterpreterState for InterpreterState;

    /// Test the eval of a constant opcode parsed from a string.
    function testOpConstantEval() external {
        (bytes[] memory sources, uint256[] memory constants) = iDeployer.parse("_ _: max-uint-256() 1001e15;");
        assertEq(sources.length, 1);
        assertEq(sources[0], hex"0004000000010000");
        assertEq(constants.length, 1);
        assertEq(constants[0], 1001e15);

        uint256[] memory minOuputs = new uint256[](1);
        minOuputs[0] = 2;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(sources, constants, minOuputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        assertEq(stack.length, 2);
        assertEq(stack[0], type(uint256).max);
        assertEq(stack[1], 1001e15);
        assertEq(kvs.length, 0);
    }
}
