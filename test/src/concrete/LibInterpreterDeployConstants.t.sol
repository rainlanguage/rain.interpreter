// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibInterpreterDeployConstants} from "src/concrete/LibInterpreterDeployConstants.sol";
import {LibInterpreterDeploy} from "src/lib/deploy/LibInterpreterDeploy.sol";

contract LibInterpreterDeployConstantsTest is Test {
    function testParserAddress() external {
        LibInterpreterDeployConstants constants = new LibInterpreterDeployConstants();
        assertEq(constants.parserAddress(), LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS);
        assertTrue(constants.parserAddress() != address(0));
    }

    function testStoreAddress() external {
        LibInterpreterDeployConstants constants = new LibInterpreterDeployConstants();
        assertEq(constants.storeAddress(), LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS);
        assertTrue(constants.storeAddress() != address(0));
    }

    function testInterpreterAddress() external {
        LibInterpreterDeployConstants constants = new LibInterpreterDeployConstants();
        assertEq(constants.interpreterAddress(), LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS);
        assertTrue(constants.interpreterAddress() != address(0));
    }
}
