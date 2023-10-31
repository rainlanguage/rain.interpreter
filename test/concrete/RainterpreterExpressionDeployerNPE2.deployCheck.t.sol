// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {INVALID_BYTECODE} from "test/util/lib/etch/LibEtch.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from "test/util/lib/constants/ExpressionDeployerNPConstants.sol";
import {IERC1820Registry} from "openzeppelin-contracts/contracts/utils/introspection/IERC1820Registry.sol";
import {IERC1820_REGISTRY} from "rain.erc1820/lib/LibIERC1820.sol";
import {IInterpreterV2} from "src/interface/unstable/IInterpreterV2.sol";

import {
    RainterpreterExpressionDeployerNPE2,
    RainterpreterExpressionDeployerNPE2ConstructionConfig,
    CONSTRUCTION_META_HASH,
    UnexpectedConstructionMetaHash,
    UnexpectedPointers
} from "src/concrete/RainterpreterExpressionDeployerNPE2.sol";
import {RainterpreterStoreNPE2} from "src/concrete/RainterpreterStoreNPE2.sol";
import {RainterpreterNPE2, OPCODE_FUNCTION_POINTERS} from "src/concrete/RainterpreterNPE2.sol";

/// @title RainterpreterExpressionDeployerNPE2DeployCheckTest
/// Test that the RainterpreterExpressionDeployerNPE2 deploy check reverts if the
/// passed config does not match expectations.
contract RainterpreterExpressionDeployerNPE2DeployCheckTest is Test {
    /// Test that the deployer won't deploy if function pointers are incorrect.
    function testRainterpreterExpressionDeployerNPE2DeployInvalidFunctionPointers(
        RainterpreterExpressionDeployerNPE2ConstructionConfig memory config,
        bytes memory functionPointers
    ) external {
        vm.assume(keccak256(functionPointers) != keccak256(OPCODE_FUNCTION_POINTERS));

        assumeNotPrecompile(address(uint160(config.interpreter)));
        assumeNotPrecompile(address(uint160(config.store)));
        vm.etch(address(uint160(config.interpreter)), INVALID_BYTECODE);
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
        vm.etch(address(IERC1820_REGISTRY), INVALID_BYTECODE);
        vm.mockCall(
            address(IERC1820_REGISTRY),
            abi.encodeWithSelector(IERC1820Registry.interfaceHash.selector),
            abi.encode(bytes32(uint256(0)))
        );
        vm.expectCall(address(IERC1820_REGISTRY), abi.encodeWithSelector(IERC1820Registry.interfaceHash.selector), 1);
        vm.mockCall(
            address(IERC1820_REGISTRY), abi.encodeWithSelector(IERC1820Registry.setInterfaceImplementer.selector), ""
        );
        vm.expectCall(
            address(IERC1820_REGISTRY), abi.encodeWithSelector(IERC1820Registry.setInterfaceImplementer.selector), 1
        );
        bytes memory authoringMeta = vm.readFileBinary(EXPRESSION_DEPLOYER_NP_META_PATH);
        new RainterpreterExpressionDeployerNP(RainterpreterExpressionDeployerConstructionConfig(
            address(new RainterpreterNP()),
            address(new RainterpreterStore()),
            authoringMeta
        ));
    }

    /// Test the deployer can deploy to a chain that does not support EIP-1820.
    function testRainterpreterExpressionDeployerDeployNoEIP1820() external {
        bytes memory authoringMeta = vm.readFileBinary(EXPRESSION_DEPLOYER_NP_META_PATH);
        new RainterpreterExpressionDeployerNP(RainterpreterExpressionDeployerConstructionConfig(
            address(new RainterpreterNP()),
            address(new RainterpreterStore()),
            authoringMeta
        ));
    }

    /// If everything is invalid the construction meta hash should be the error
    /// as this makes it easier to implement tooling that needs to access the
    /// meta hash but may not have access to the dependencies.
    function testRainterpreterExpressionDeployerDeployInvalidEverything() external {
        bytes memory badAuthoringMeta = hex"DEADBEEF";
        vm.expectRevert(
            abi.encodeWithSelector(
                UnexpectedConstructionMetaHash.selector, CONSTRUCTION_META_HASH, keccak256(badAuthoringMeta)
            )
        );
        new RainterpreterExpressionDeployerNP(RainterpreterExpressionDeployerConstructionConfig(
            address(0),
            address(0),
            badAuthoringMeta
        ));
    }
}
