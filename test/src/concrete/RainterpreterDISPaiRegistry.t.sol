// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {RainterpreterDISPaiRegistry} from "src/concrete/RainterpreterDISPaiRegistry.sol";
import {LibInterpreterDeploy} from "src/lib/deploy/LibInterpreterDeploy.sol";

contract RainterpreterDISPaiRegistryTest is Test {
    function testExpressionDeployerAddress() external {
        RainterpreterDISPaiRegistry registry = new RainterpreterDISPaiRegistry();
        assertEq(registry.expressionDeployerAddress(), LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS);
        assertTrue(registry.expressionDeployerAddress() != address(0));
    }

    function testInterpreterAddress() external {
        RainterpreterDISPaiRegistry registry = new RainterpreterDISPaiRegistry();
        assertEq(registry.interpreterAddress(), LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS);
        assertTrue(registry.interpreterAddress() != address(0));
    }

    function testStoreAddress() external {
        RainterpreterDISPaiRegistry registry = new RainterpreterDISPaiRegistry();
        assertEq(registry.storeAddress(), LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS);
        assertTrue(registry.storeAddress() != address(0));
    }

    function testParserAddress() external {
        RainterpreterDISPaiRegistry registry = new RainterpreterDISPaiRegistry();
        assertEq(registry.parserAddress(), LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS);
        assertTrue(registry.parserAddress() != address(0));
    }
}
