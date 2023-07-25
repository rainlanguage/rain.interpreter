// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";

import "src/lib/caller/LibContext.sol";

/// @title LibOpStackTest
/// @notice Test the runtime and integrity time logic of LibOpStack.
contract LibOpStackTest is RainterpreterExpressionDeployerDeploymentTest {
/// Directly test the integrity logic of LibOpStack. The operand always
/// puts a single value on the stack, regardless of the stack length or
}
