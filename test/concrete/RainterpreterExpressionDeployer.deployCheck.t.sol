// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";
import "test/util/lib/etch/LibEtch.sol";

import "src/interface/IInterpreterV1.sol";

import "src/concrete/RainterpreterExpressionDeployerNP.sol";
import "src/concrete/RainterpreterStore.sol";
import "src/concrete/RainterpreterNP.sol";

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

        assumeNotPrecompile(address(uint160(config.interpreter)));
        assumeNotPrecompile(address(uint160(config.store)));
        vm.etch(address(uint160(config.interpreter)), REVERT_BYTECODE);
        vm.mockCall(
            address(uint160(config.interpreter)),
            abi.encodeWithSelector(IInterpreterV1.functionPointers.selector),
            functionPointers
        );

        vm.expectRevert(abi.encodeWithSelector(UnexpectedPointers.selector, functionPointers));
        new RainterpreterExpressionDeployerNP(config);
    }

    /// Test the deployer can deploy if everything is valid.
    function testRainterpreterExpressionDeployerDeployValidFunctionPointers() external {
        vm.etch(address(IERC1820_REGISTRY), REVERT_BYTECODE);
        vm.mockCall(
            address(IERC1820_REGISTRY),
            abi.encodeWithSelector(IERC1820Registry.interfaceHash.selector),
            abi.encode(bytes32(uint256(0)))
        );
        vm.mockCall(
            address(IERC1820_REGISTRY), abi.encodeWithSelector(IERC1820Registry.setInterfaceImplementer.selector), ""
        );
        bytes memory authoringMeta = LibAllStandardOpsNP.authoringMeta();
        new RainterpreterExpressionDeployerNP(RainterpreterExpressionDeployerConstructionConfig(
            address(new RainterpreterNP()),
            address(new RainterpreterStore()),
            authoringMeta
        ));
    }
}
