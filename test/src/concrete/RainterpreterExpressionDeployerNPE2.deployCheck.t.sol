// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {INVALID_BYTECODE} from "test/lib/etch/LibEtch.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from "test/lib/constants/ExpressionDeployerNPConstants.sol";
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
import {RainterpreterParserNPE2} from "src/concrete/RainterpreterParserNPE2.sol";
import {RainterpreterNPE2, OPCODE_FUNCTION_POINTERS} from "src/concrete/RainterpreterNPE2.sol";

/// @title RainterpreterExpressionDeployerNPE2DeployCheckTest
/// Test that the RainterpreterExpressionDeployerNPE2 deploy check reverts if the
/// passed config does not match expectations.
contract RainterpreterExpressionDeployerNPE2DeployCheckTest is Test {
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
        bytes memory constructionMeta = vm.readFileBinary(EXPRESSION_DEPLOYER_NP_META_PATH);
        new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfig(
                address(new RainterpreterNPE2()),
                address(new RainterpreterStoreNPE2()),
                address(new RainterpreterParserNPE2()),
                constructionMeta
            )
        );
    }

    /// Test the deployer can deploy to a chain that does not support EIP-1820.
    function testRainterpreterExpressionDeployerDeployNoEIP1820() external {
        bytes memory constructionMeta = vm.readFileBinary(EXPRESSION_DEPLOYER_NP_META_PATH);
        new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfig(
                address(new RainterpreterNPE2()),
                address(new RainterpreterStoreNPE2()),
                address(new RainterpreterParserNPE2()),
                constructionMeta
            )
        );
    }

    /// If everything is invalid the construction meta hash should be the error
    /// as this makes it easier to implement tooling that needs to access the
    /// meta hash but may not have access to the dependencies.
    function testRainterpreterExpressionDeployerDeployInvalidEverything() external {
        bytes memory badConstructionMeta = hex"DEADBEEF";
        vm.expectRevert(
            abi.encodeWithSelector(
                UnexpectedConstructionMetaHash.selector, CONSTRUCTION_META_HASH, keccak256(badConstructionMeta)
            )
        );
        new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfig(
                address(0), address(0), address(0), badConstructionMeta
            )
        );
    }
}
