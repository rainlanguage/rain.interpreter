// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";
import "test/util/lib/etch/LibEtch.sol";

import "src/concrete/RainterpreterStore.sol";
import "src/concrete/RainterpreterNP.sol";
import "src/concrete/RainterpreterExpressionDeployerNP.sol";

/// @title RainterpreterExpressionDeployerDeploymentTest
/// Tests that the RainterpreterExpressionDeployer meta is correct. Also tests
/// basic functionality of the `IParserV1` interface implementation.
abstract contract RainterpreterExpressionDeployerDeploymentTest is Test {
    RainterpreterStore internal immutable iStore;
    RainterpreterNP internal immutable iInterpreter;
    RainterpreterExpressionDeployerNP internal immutable iDeployer;

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

        bytes memory authoringMeta = LibAllStandardOpsNP.authoringMeta();
        console2.log("current authoring meta hash:");
        console2.logBytes32(keccak256(authoringMeta));

        vm.etch(address(IERC1820_REGISTRY), REVERT_BYTECODE);
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
            authoringMeta
        ));
    }
}
