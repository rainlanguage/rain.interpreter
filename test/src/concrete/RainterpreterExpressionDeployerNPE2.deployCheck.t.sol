// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {INVALID_BYTECODE} from "test/lib/etch/LibEtch.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from "test/lib/constants/ExpressionDeployerNPConstants.sol";
import {IERC1820Registry} from "openzeppelin-contracts/contracts/utils/introspection/IERC1820Registry.sol";
import {IERC1820_REGISTRY} from "rain.erc1820/lib/LibIERC1820.sol";
import {IInterpreterV2} from "rain.interpreter.interface/interface/IInterpreterV2.sol";

import {
    RainterpreterExpressionDeployerNPE2,
    RainterpreterExpressionDeployerNPE2ConstructionConfigV2,
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
        new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfigV2(
                address(new RainterpreterNPE2()),
                address(new RainterpreterStoreNPE2()),
                address(new RainterpreterParserNPE2())
            )
        );
    }

    /// Test the deployer can deploy to a chain that does not support EIP-1820.
    function testRainterpreterExpressionDeployerDeployNoEIP1820() external {
        new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfigV2(
                address(new RainterpreterNPE2()),
                address(new RainterpreterStoreNPE2()),
                address(new RainterpreterParserNPE2())
            )
        );
    }
}
