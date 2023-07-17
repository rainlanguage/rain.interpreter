// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "../../../lib/forge-std/src/Test.sol";
import "../lib/etch/LibEtch.sol";

import "../../../src/concrete/RainterpreterStore.sol";
import "../../../src/concrete/RainterpreterNP.sol";
import "../../../src/concrete/RainterpreterExpressionDeployerNP.sol";

/// @title RainterpreterExpressionDeployerDeploymentTest
/// Tests that the RainterpreterExpressionDeployer meta is correct. Also tests
/// basic functionality of the `IParserV1` interface implementation.
abstract contract RainterpreterExpressionDeployerDeploymentTest is Test {
    RainterpreterStore immutable iStore;
    RainterpreterNP immutable iInterpreter;
    RainterpreterExpressionDeployerNP immutable iDeployer;

    constructor() {
        iStore = new RainterpreterStore();
        iInterpreter = new RainterpreterNP();

        console2.log("current function pointers:");
        console2.logBytes(iInterpreter.functionPointers());

        console2.log("current i9r bytecode hash:");
        bytes32 i9rHash;
        address interpreter = address(iInterpreter);
        assembly {
            i9rHash := extcodehash(interpreter)
        }
        console2.logBytes32(i9rHash);

        console2.log("current store bytecode hash:");
        bytes32 storeHash;
        address store = address(iStore);
        assembly {
            storeHash := extcodehash(store)
        }
        console2.logBytes32(storeHash);

        bytes memory authoringMeta = LibRainterpreterExpressionDeployerNPMeta.authoringMeta();
        console2.log("current authoring meta hash:");
        console2.logBytes32(keccak256(authoringMeta));

        vm.etch(address(IERC1820_REGISTRY), REVERT_BYTECODE);
        vm.mockCall(address(IERC1820_REGISTRY), "", abi.encode(""));
        iDeployer = new RainterpreterExpressionDeployerNP(RainterpreterExpressionDeployerConstructionConfig(
            address(iInterpreter),
            address(iStore),
            authoringMeta
        ));
    }
}
