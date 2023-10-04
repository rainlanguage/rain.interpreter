// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test, console2, stdError} from "forge-std/Test.sol";
import {INVALID_BYTECODE} from "../lib/etch/LibEtch.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from "../lib/constants/ExpressionDeployerNPConstants.sol";
import {IERC1820_REGISTRY, IERC1820Registry} from "rain.erc1820/lib/LibIERC1820.sol";

import {RainterpreterStore} from "../../../src/concrete/RainterpreterStore.sol";
import {
    RainterpreterNP,
    OPCODE_FUNCTION_POINTERS,
    INTERPRETER_BYTECODE_HASH
} from "../../../src/concrete/RainterpreterNP.sol";
import {
    AUTHORING_META_HASH,
    STORE_BYTECODE_HASH,
    CONSTRUCTION_META_HASH,
    INTEGRITY_FUNCTION_POINTERS,
    RainterpreterExpressionDeployerConstructionConfig
} from "../../../src/concrete/RainterpreterExpressionDeployerNP.sol";
import {RainterpreterExpressionDeployerNP} from "../../../src/concrete/RainterpreterExpressionDeployerNP.sol";
import {LibAllStandardOpsNP} from "../../../src/lib/op/LibAllStandardOpsNP.sol";
import {LibEncodedDispatch} from "../../../src/lib/caller/LibEncodedDispatch.sol";

/// @title RainterpreterExpressionDeployerDeploymentTest
/// Tests that the RainterpreterExpressionDeployer meta is correct. Also tests
/// basic functionality of the `IParserV1` interface implementation.
abstract contract RainterpreterExpressionDeployerDeploymentTest is Test {
    //solhint-disable-next-line private-vars-leading-underscore
    RainterpreterStore internal immutable iStore;
    //solhint-disable-next-line private-vars-leading-underscore
    RainterpreterNP internal immutable iInterpreter;
    //solhint-disable-next-line private-vars-leading-underscore
    RainterpreterExpressionDeployerNP internal immutable iDeployer;

    constructor() {
        iStore = new RainterpreterStore();
        iInterpreter = new RainterpreterNP();

        // Sanity check the interpreter's opcode function pointers.
        bytes memory opcodeFunctionPointers = iInterpreter.functionPointers();
        if (keccak256(opcodeFunctionPointers) != keccak256(OPCODE_FUNCTION_POINTERS)) {
            console2.log("current interpreter opcode function pointers:");
            console2.logBytes(opcodeFunctionPointers);
            revert("unexpected interpreter opcode function pointers");
        }

        // Sanity check the interpreter's bytecode hash.
        bytes32 i9rHash;
        address interpreter = address(iInterpreter);
        assembly {
            i9rHash := extcodehash(interpreter)
        }
        if (i9rHash != INTERPRETER_BYTECODE_HASH) {
            console2.log("current i9r bytecode hash:");
            console2.logBytes32(i9rHash);
            revert("unexpected interpreter bytecode hash");
        }

        bytes32 storeHash;
        address store = address(iStore);
        assembly {
            storeHash := extcodehash(store)
        }
        if (storeHash != STORE_BYTECODE_HASH) {
            console2.log("current store bytecode hash:");
            console2.logBytes32(storeHash);
            revert("unexpected store bytecode hash");
        }

        bytes memory constructionMeta = vm.readFileBinary(EXPRESSION_DEPLOYER_NP_META_PATH);
        bytes32 constructionMetaHash = keccak256(constructionMeta);
        if (constructionMetaHash != CONSTRUCTION_META_HASH) {
            console2.log("current construction meta hash:");
            console2.logBytes32(constructionMetaHash);
            revert("unexpected construction meta hash");
        }

        vm.etch(address(IERC1820_REGISTRY), INVALID_BYTECODE);
        vm.mockCall(
            address(IERC1820_REGISTRY),
            abi.encodeWithSelector(IERC1820Registry.interfaceHash.selector),
            abi.encode(bytes32(uint256(0)))
        );
        vm.mockCall(
            address(IERC1820_REGISTRY), abi.encodeWithSelector(IERC1820Registry.setInterfaceImplementer.selector), ""
        );
        iDeployer = new RainterpreterExpressionDeployerNP(RainterpreterExpressionDeployerConstructionConfig(
            address(iInterpreter),
            address(iStore),
            constructionMeta
        ));

        // Sanity check the deployer's parse meta.
        bytes memory authoringMeta = LibAllStandardOpsNP.authoringMeta();
        bytes32 authoringMetaHash = keccak256(authoringMeta);
        if (authoringMetaHash != AUTHORING_META_HASH) {
            console2.log("current authoring meta hash:");
            console2.logBytes32(authoringMetaHash);
            revert("unexpected authoring meta hash");
        }

        bytes memory parseMeta = iDeployer.parseMeta();
        bytes memory builtParseMeta = iDeployer.buildParseMeta(authoringMeta);
        if (keccak256(parseMeta) != keccak256(builtParseMeta)) {
            console2.log("current deployer parse meta:");
            console2.logBytes(builtParseMeta);
            revert("unexpected deployer parse meta");
        }

        // Sanity check the deployer's integrity function pointers.
        bytes memory integrityFunctionPointers = iDeployer.integrityFunctionPointers();
        if (keccak256(integrityFunctionPointers) != keccak256(INTEGRITY_FUNCTION_POINTERS)) {
            console2.log("current deployer integrity function pointers:");
            console2.logBytes(integrityFunctionPointers);
            revert("unexpected deployer integrity function pointers");
        }
    }
}
