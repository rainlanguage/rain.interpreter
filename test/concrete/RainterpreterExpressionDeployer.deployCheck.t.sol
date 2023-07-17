// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "../../lib/forge-std/src/Test.sol";

import "../../src/interface/IInterpreterV1.sol";
import "../../src/concrete/RainterpreterExpressionDeployerNP.sol";

import "../util/lib/etch/LibEtch.sol";

/// @title RainterpreterExpressionDeployerDeployCheckTest
/// Test that the RainterpreterExpressionDeployer deploy check reverts if the
/// passed config does not match expectations.
contract RainterpreterExpressionDeployerDeployCheckTest is Test {
    /// Test that the deployer won't deploy if function pointers are incorrect.
    function testRainterpreterExpressionDeployerDeployInvalidFunctionPointers(
        RainterpreterExpressionDeployerConstructionConfig memory config,
        bytes memory functionPointers
    ) external {
        vm.assume(keccak256(functionPointers) != keccak256(OPCODE_FUNCTION_POINTERS));

        assumeNoPrecompiles(address(uint160(config.interpreter)));
        assumeNoPrecompiles(address(uint160(config.store)));
        vm.etch(address(uint160(config.interpreter)), REVERT_BYTECODE);
        vm.mockCall(
            address(uint160(config.interpreter)),
            abi.encodeWithSelector(IInterpreterV1.functionPointers.selector),
            functionPointers
        );

        vm.expectRevert(abi.encodeWithSelector(UnexpectedPointers.selector, functionPointers));
        new RainterpreterExpressionDeployerNP(config);
    }
}
