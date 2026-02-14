// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test, console2} from "forge-std/Test.sol";

import {AuthoringMetaV2} from "rain.interpreter.interface/interface/IParserV2.sol";
import {RainterpreterStore, STORE_BYTECODE_HASH} from "../../src/concrete/RainterpreterStore.sol";
import {
    RainterpreterParser,
    PARSE_META,
    PARSE_META_BUILD_DEPTH,
    PARSER_BYTECODE_HASH
} from "../../src/concrete/RainterpreterParser.sol";
import {Rainterpreter, INTERPRETER_BYTECODE_HASH} from "../../src/concrete/Rainterpreter.sol";
import {
    INTEGRITY_FUNCTION_POINTERS,
    RainterpreterExpressionDeployer
} from "../../src/concrete/RainterpreterExpressionDeployer.sol";
import {LibAllStandardOps} from "../../src/lib/op/LibAllStandardOps.sol";
import {LibGenParseMeta} from "rain.interpreter.interface/lib/codegen/LibGenParseMeta.sol";
import {LibRainDeploy} from "rain.deploy/lib/LibRainDeploy.sol";
import {LibInterpreterDeploy} from "../../src/lib/deploy/LibInterpreterDeploy.sol";

/// @title RainterpreterExpressionDeployerNPD2DeploymentTest
/// Tests that the RainterpreterExpressionDeployer meta is correct. Also
/// tests basic functionality of the `IParserV1View` interface implementation.
abstract contract RainterpreterExpressionDeployerDeploymentTest is Test {
    //solhint-disable-next-line private-vars-leading-underscore
    RainterpreterExpressionDeployer internal immutable I_DEPLOYER;
    //solhint-disable-next-line private-vars-leading-underscore
    Rainterpreter internal immutable I_INTERPRETER;
    //solhint-disable-next-line private-vars-leading-underscore
    RainterpreterStore internal immutable I_STORE;
    //solhint-disable-next-line private-vars-leading-underscore
    RainterpreterParser internal immutable I_PARSER;

    function beforeOpTestConstructor() internal virtual {}

    constructor() {
        beforeOpTestConstructor();

        vm.etch(LibRainDeploy.ZOLTU_FACTORY, hex"60003681823780368234f58015156014578182fd5b80825250506014600cf3");

        if (LibInterpreterDeploy.PARSER_DEPLOYED_CODEHASH != LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS.codehash) {
            console2.log("Deploying Parser");
            LibRainDeploy.deployZoltu(type(RainterpreterParser).creationCode);
        }
        if (
            LibInterpreterDeploy.INTERPRETER_DEPLOYED_CODEHASH
                != LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS.codehash
        ) {
            console2.log("Deploying Interpreter");
            LibRainDeploy.deployZoltu(type(Rainterpreter).creationCode);
        }
        if (LibInterpreterDeploy.STORE_DEPLOYED_CODEHASH != LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS.codehash) {
            console2.log("Deploying Store");
            LibRainDeploy.deployZoltu(type(RainterpreterStore).creationCode);
        }

        I_PARSER = RainterpreterParser(LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS);
        I_INTERPRETER = Rainterpreter(LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS);
        I_STORE = RainterpreterStore(LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS);

        assertEq(
            address(I_INTERPRETER),
            LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS,
            "unexpected interpreter deployed address"
        );
        assertEq(address(I_STORE), LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS, "unexpected store deployed address");
        assertEq(address(I_PARSER), LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS, "unexpected parser deployed address");

        bytes32 storeHash;
        address store = address(I_STORE);
        assembly ("memory-safe") {
            storeHash := extcodehash(store)
        }
        if (storeHash != STORE_BYTECODE_HASH) {
            console2.log("current store bytecode hash:");
            console2.logBytes32(storeHash);
            revert("unexpected store bytecode hash");
        }

        bytes32 parserHash;
        address parser = address(I_PARSER);
        assembly ("memory-safe") {
            parserHash := extcodehash(parser)
        }
        if (parserHash != PARSER_BYTECODE_HASH) {
            console2.log("current parser bytecode hash:");
            console2.logBytes32(parserHash);
            revert("unexpected parser bytecode hash");
        }

        AuthoringMetaV2[] memory authoringMeta = abi.decode(LibAllStandardOps.authoringMetaV2(), (AuthoringMetaV2[]));
        bytes memory parseMeta = LibGenParseMeta.buildParseMetaV2(authoringMeta, PARSE_META_BUILD_DEPTH);
        if (keccak256(parseMeta) != keccak256(PARSE_META)) {
            console2.log("current parse meta:");
            console2.logBytes(parseMeta);
            revert("unexpected parse meta");
        }

        // I_DEPLOYER = new RainterpreterExpressionDeployer();
        if (
            LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH
                != LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS.codehash
        ) {
            console2.log("Deploying Expression Deployer");
            I_DEPLOYER = RainterpreterExpressionDeployer(
                LibRainDeploy.deployZoltu(type(RainterpreterExpressionDeployer).creationCode)
            );
        }

        // Sanity check the deployer's integrity function pointers.
        bytes memory integrityFunctionPointers = I_DEPLOYER.buildIntegrityFunctionPointers();
        if (keccak256(integrityFunctionPointers) != keccak256(INTEGRITY_FUNCTION_POINTERS)) {
            console2.log("current deployer integrity function pointers:");
            console2.logBytes(integrityFunctionPointers);
            revert("unexpected deployer integrity function pointers");
        }
    }
}
