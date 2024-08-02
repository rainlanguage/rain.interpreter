// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {IERC1820_REGISTRY, IERC1820Registry} from "rain.erc1820/lib/LibIERC1820.sol";
import {Test, console2, stdError} from "forge-std/Test.sol";

import {INVALID_BYTECODE} from "../lib/etch/LibEtch.sol";
import {LibParseMeta} from "rain.interpreter.interface/lib/parse/LibParseMeta.sol";
import {AuthoringMetaV2} from "rain.interpreter.interface/interface/IParserV2.sol";
import {RainterpreterStoreNPE2, STORE_BYTECODE_HASH} from "src/concrete/RainterpreterStoreNPE2.sol";
import {
    RainterpreterParserNPE2,
    PARSE_META,
    PARSE_META_BUILD_DEPTH,
    PARSER_BYTECODE_HASH
} from "src/concrete/RainterpreterParserNPE2.sol";
import {
    RainterpreterNPE2, OPCODE_FUNCTION_POINTERS, INTERPRETER_BYTECODE_HASH
} from "src/concrete/RainterpreterNPE2.sol";
import {
    DESCRIBED_BY_META_HASH,
    INTEGRITY_FUNCTION_POINTERS,
    RainterpreterExpressionDeployerNPE2ConstructionConfigV2,
    RainterpreterExpressionDeployerNPE2
} from "../../src/concrete/RainterpreterExpressionDeployerNPE2.sol";
import {LibAllStandardOpsNP} from "src/lib/op/LibAllStandardOpsNP.sol";
import {LibGenParseMeta} from "rain.sol.codegen/lib/LibGenParseMeta.sol";

/// @title RainterpreterExpressionDeployerNPD2DeploymentTest
/// Tests that the RainterpreterExpressionDeployerNPE2 meta is correct. Also
/// tests basic functionality of the `IParserV1View` interface implementation.
abstract contract RainterpreterExpressionDeployerNPE2DeploymentTest is Test {
    //solhint-disable-next-line private-vars-leading-underscore
    RainterpreterExpressionDeployerNPE2 internal immutable iDeployer;
    //solhint-disable-next-line private-vars-leading-underscore
    RainterpreterNPE2 internal immutable iInterpreter;
    //solhint-disable-next-line private-vars-leading-underscore
    RainterpreterStoreNPE2 internal immutable iStore;
    //solhint-disable-next-line private-vars-leading-underscore
    RainterpreterParserNPE2 internal immutable iParser;

    function beforeOpTestConstructor() internal virtual {}

    constructor() {
        beforeOpTestConstructor();

        iInterpreter = new RainterpreterNPE2();
        iStore = new RainterpreterStoreNPE2();
        iParser = new RainterpreterParserNPE2();

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
        assembly ("memory-safe") {
            i9rHash := extcodehash(interpreter)
        }
        if (i9rHash != INTERPRETER_BYTECODE_HASH) {
            console2.log("current i9r bytecode hash:");
            console2.logBytes32(i9rHash);
            revert("unexpected interpreter bytecode hash");
        }

        bytes32 storeHash;
        address store = address(iStore);
        assembly ("memory-safe") {
            storeHash := extcodehash(store)
        }
        if (storeHash != STORE_BYTECODE_HASH) {
            console2.log("current store bytecode hash:");
            console2.logBytes32(storeHash);
            revert("unexpected store bytecode hash");
        }

        bytes32 parserHash;
        address parser = address(iParser);
        assembly ("memory-safe") {
            parserHash := extcodehash(parser)
        }
        if (parserHash != PARSER_BYTECODE_HASH) {
            console2.log("current parser bytecode hash:");
            console2.logBytes32(parserHash);
            revert("unexpected parser bytecode hash");
        }

        AuthoringMetaV2[] memory authoringMeta = abi.decode(LibAllStandardOpsNP.authoringMetaV2(), (AuthoringMetaV2[]));
        bytes memory parseMeta = LibGenParseMeta.buildParseMetaV2(authoringMeta, PARSE_META_BUILD_DEPTH);
        if (keccak256(parseMeta) != keccak256(PARSE_META)) {
            console2.log("current parse meta:");
            console2.logBytes(parseMeta);
            revert("unexpected parse meta");
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
        iDeployer = new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfigV2(
                address(iInterpreter), address(iStore), address(iParser)
            )
        );

        // Sanity check the deployer's integrity function pointers.
        bytes memory integrityFunctionPointers = iDeployer.buildIntegrityFunctionPointers();
        if (keccak256(integrityFunctionPointers) != keccak256(INTEGRITY_FUNCTION_POINTERS)) {
            console2.log("current deployer integrity function pointers:");
            console2.logBytes(integrityFunctionPointers);
            revert("unexpected deployer integrity function pointers");
        }
    }
}
