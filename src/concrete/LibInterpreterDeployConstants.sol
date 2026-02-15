// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {LibInterpreterDeploy} from "../lib/deploy/LibInterpreterDeploy.sol";

/// @dev Exposes LibInterpreterDeploy constants as callable functions so external
/// tooling (Rust test fixtures, scripts) can read deterministic Zoltu addresses
/// without hardcoding them.
contract LibInterpreterDeployConstants {
    function parserAddress() external pure returns (address) {
        return LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS;
    }

    function storeAddress() external pure returns (address) {
        return LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS;
    }

    function interpreterAddress() external pure returns (address) {
        return LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS;
    }
}
