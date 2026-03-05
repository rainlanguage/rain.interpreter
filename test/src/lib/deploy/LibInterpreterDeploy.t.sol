// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {LibRainDeploy} from "rain.deploy/lib/LibRainDeploy.sol";
import {LibInterpreterDeploy} from "src/lib/deploy/LibInterpreterDeploy.sol";
import {RainterpreterParser} from "src/concrete/RainterpreterParser.sol";
import {RainterpreterStore} from "src/concrete/RainterpreterStore.sol";
import {Rainterpreter} from "src/concrete/Rainterpreter.sol";
import {RainterpreterExpressionDeployer} from "src/concrete/RainterpreterExpressionDeployer.sol";
import {RainterpreterDISPaiRegistry} from "src/concrete/RainterpreterDISPaiRegistry.sol";
import {LibExtrospectBytecode} from "rain.extrospection/lib/LibExtrospectBytecode.sol";
import {LibExtrospectMetamorphic} from "rain.extrospection/lib/LibExtrospectMetamorphic.sol";
import {RainterpreterReferenceExtern} from "src/concrete/extern/RainterpreterReferenceExtern.sol";
import {CREATION_CODE as PARSER_CREATION_CODE} from "src/generated/RainterpreterParser.pointers.sol";
import {CREATION_CODE as STORE_CREATION_CODE} from "src/generated/RainterpreterStore.pointers.sol";
import {CREATION_CODE as INTERPRETER_CREATION_CODE} from "src/generated/Rainterpreter.pointers.sol";
import {
    CREATION_CODE as EXPRESSION_DEPLOYER_CREATION_CODE
} from "src/generated/RainterpreterExpressionDeployer.pointers.sol";
import {CREATION_CODE as DISPAIR_REGISTRY_CREATION_CODE} from "src/generated/RainterpreterDISPaiRegistry.pointers.sol";
import {CREATION_CODE as REFERENCE_EXTERN_CREATION_CODE} from "src/generated/RainterpreterReferenceExtern.pointers.sol";

contract LibInterpreterDeployTest is Test {
    function testDeployAddressParser() external {
        vm.createSelectFork(vm.envString("CI_FORK_ETH_RPC_URL"));

        console2.logBytes(LibRainDeploy.ZOLTU_FACTORY.code);

        address deployedAddress = LibRainDeploy.deployZoltu(type(RainterpreterParser).creationCode);

        assertEq(deployedAddress, LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS);
        assertTrue(address(deployedAddress).code.length > 0, "Deployed address has no code");

        assertEq(address(deployedAddress).codehash, LibInterpreterDeploy.PARSER_DEPLOYED_CODEHASH);
    }

    function testExpectedCodeHashParser() external {
        RainterpreterParser parser = new RainterpreterParser();

        assertEq(address(parser).codehash, LibInterpreterDeploy.PARSER_DEPLOYED_CODEHASH);
    }

    function testDeployAddressStore() external {
        vm.createSelectFork(vm.envString("CI_FORK_ETH_RPC_URL"));

        address deployedAddress = LibRainDeploy.deployZoltu(type(RainterpreterStore).creationCode);

        assertEq(deployedAddress, LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS);
        assertTrue(address(deployedAddress).code.length > 0, "Deployed address has no code");

        assertEq(address(deployedAddress).codehash, LibInterpreterDeploy.STORE_DEPLOYED_CODEHASH);
    }

    function testExpectedCodeHashStore() external {
        RainterpreterStore store = new RainterpreterStore();

        assertEq(address(store).codehash, LibInterpreterDeploy.STORE_DEPLOYED_CODEHASH);
    }

    function testDeployAddressInterpreter() external {
        vm.createSelectFork(vm.envString("CI_FORK_ETH_RPC_URL"));

        address deployedAddress = LibRainDeploy.deployZoltu(type(Rainterpreter).creationCode);

        assertEq(deployedAddress, LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS);
        assertTrue(address(deployedAddress).code.length > 0, "Deployed address has no code");

        assertEq(address(deployedAddress).codehash, LibInterpreterDeploy.INTERPRETER_DEPLOYED_CODEHASH);
    }

    function testExpectedCodeHashInterpreter() external {
        Rainterpreter interpreter = new Rainterpreter();

        assertEq(address(interpreter).codehash, LibInterpreterDeploy.INTERPRETER_DEPLOYED_CODEHASH);
    }

    function testDeployAddressExpressionDeployer() external {
        vm.createSelectFork(vm.envString("CI_FORK_ETH_RPC_URL"));

        address deployedAddress = LibRainDeploy.deployZoltu(type(RainterpreterExpressionDeployer).creationCode);

        console2.log("Deployed address:", deployedAddress);

        assertEq(deployedAddress, LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS);
        assertTrue(address(deployedAddress).code.length > 0, "Deployed address has no code");

        assertEq(address(deployedAddress).codehash, LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH);
    }

    function testExpectedCodeHashExpressionDeployer() external {
        RainterpreterExpressionDeployer expressionDeployer = new RainterpreterExpressionDeployer();

        assertEq(address(expressionDeployer).codehash, LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH);
    }

    function testDeployAddressDISPaiRegistry() external {
        vm.createSelectFork(vm.envString("CI_FORK_ETH_RPC_URL"));

        address deployedAddress = LibRainDeploy.deployZoltu(type(RainterpreterDISPaiRegistry).creationCode);

        assertEq(deployedAddress, LibInterpreterDeploy.DISPAIR_REGISTRY_DEPLOYED_ADDRESS);
        assertTrue(address(deployedAddress).code.length > 0, "Deployed address has no code");

        assertEq(address(deployedAddress).codehash, LibInterpreterDeploy.DISPAIR_REGISTRY_DEPLOYED_CODEHASH);
    }

    function testExpectedCodeHashDISPaiRegistry() external {
        RainterpreterDISPaiRegistry registry = new RainterpreterDISPaiRegistry();

        assertEq(address(registry).codehash, LibInterpreterDeploy.DISPAIR_REGISTRY_DEPLOYED_CODEHASH);
    }

    /// Parser bytecode MUST NOT contain Solidity CBOR metadata.
    function testNoCborMetadataParser() external {
        RainterpreterParser parser = new RainterpreterParser();
        assertFalse(
            LibExtrospectBytecode.tryTrimSolidityCBORMetadata(address(parser).code),
            "Parser bytecode contains CBOR metadata"
        );
    }

    /// Store bytecode MUST NOT contain Solidity CBOR metadata.
    function testNoCborMetadataStore() external {
        RainterpreterStore store = new RainterpreterStore();
        assertFalse(
            LibExtrospectBytecode.tryTrimSolidityCBORMetadata(address(store).code),
            "Store bytecode contains CBOR metadata"
        );
    }

    /// Interpreter bytecode MUST NOT contain Solidity CBOR metadata.
    function testNoCborMetadataInterpreter() external {
        Rainterpreter interpreter = new Rainterpreter();
        assertFalse(
            LibExtrospectBytecode.tryTrimSolidityCBORMetadata(address(interpreter).code),
            "Interpreter bytecode contains CBOR metadata"
        );
    }

    /// ExpressionDeployer bytecode MUST NOT contain Solidity CBOR metadata.
    function testNoCborMetadataExpressionDeployer() external {
        RainterpreterExpressionDeployer expressionDeployer = new RainterpreterExpressionDeployer();
        assertFalse(
            LibExtrospectBytecode.tryTrimSolidityCBORMetadata(address(expressionDeployer).code),
            "ExpressionDeployer bytecode contains CBOR metadata"
        );
    }

    /// DISPaiRegistry bytecode MUST NOT contain Solidity CBOR metadata.
    function testNoCborMetadataDISPaiRegistry() external {
        RainterpreterDISPaiRegistry registry = new RainterpreterDISPaiRegistry();
        assertFalse(
            LibExtrospectBytecode.tryTrimSolidityCBORMetadata(address(registry).code),
            "DISPaiRegistry bytecode contains CBOR metadata"
        );
    }

    /// Parser bytecode MUST NOT contain reachable metamorphic risk opcodes.
    function testNotMetamorphicParser() external {
        RainterpreterParser parser = new RainterpreterParser();
        LibExtrospectMetamorphic.checkNotMetamorphic(address(parser).code);
    }

    /// Store bytecode MUST NOT contain reachable metamorphic risk opcodes.
    function testNotMetamorphicStore() external {
        RainterpreterStore store = new RainterpreterStore();
        LibExtrospectMetamorphic.checkNotMetamorphic(address(store).code);
    }

    /// Interpreter bytecode MUST NOT contain reachable metamorphic risk opcodes.
    function testNotMetamorphicInterpreter() external {
        Rainterpreter interpreter = new Rainterpreter();
        LibExtrospectMetamorphic.checkNotMetamorphic(address(interpreter).code);
    }

    /// ExpressionDeployer bytecode MUST NOT contain reachable metamorphic risk
    /// opcodes.
    function testNotMetamorphicExpressionDeployer() external {
        RainterpreterExpressionDeployer expressionDeployer = new RainterpreterExpressionDeployer();
        LibExtrospectMetamorphic.checkNotMetamorphic(address(expressionDeployer).code);
    }

    /// DISPaiRegistry bytecode MUST NOT contain reachable metamorphic risk
    /// opcodes.
    function testNotMetamorphicDISPaiRegistry() external {
        RainterpreterDISPaiRegistry registry = new RainterpreterDISPaiRegistry();
        LibExtrospectMetamorphic.checkNotMetamorphic(address(registry).code);
    }

    /// The precompiled creation code constant for the parser MUST match the
    /// compiler's creation code.
    function testCreationCodeParser() external pure {
        assertEq(keccak256(PARSER_CREATION_CODE), keccak256(type(RainterpreterParser).creationCode));
    }

    /// The precompiled creation code constant for the store MUST match the
    /// compiler's creation code.
    function testCreationCodeStore() external pure {
        assertEq(keccak256(STORE_CREATION_CODE), keccak256(type(RainterpreterStore).creationCode));
    }

    /// The precompiled creation code constant for the interpreter MUST match
    /// the compiler's creation code.
    function testCreationCodeInterpreter() external pure {
        assertEq(keccak256(INTERPRETER_CREATION_CODE), keccak256(type(Rainterpreter).creationCode));
    }

    /// The precompiled creation code constant for the expression deployer MUST
    /// match the compiler's creation code.
    function testCreationCodeExpressionDeployer() external pure {
        assertEq(
            keccak256(EXPRESSION_DEPLOYER_CREATION_CODE), keccak256(type(RainterpreterExpressionDeployer).creationCode)
        );
    }

    /// The precompiled creation code constant for the DISPaiRegistry MUST
    /// match the compiler's creation code.
    function testCreationCodeDISPaiRegistry() external pure {
        assertEq(keccak256(DISPAIR_REGISTRY_CREATION_CODE), keccak256(type(RainterpreterDISPaiRegistry).creationCode));
    }

    /// The precompiled creation code constant for the reference extern MUST
    /// match the compiler's creation code.
    function testCreationCodeReferenceExtern() external pure {
        assertEq(keccak256(REFERENCE_EXTERN_CREATION_CODE), keccak256(type(RainterpreterReferenceExtern).creationCode));
    }
}
