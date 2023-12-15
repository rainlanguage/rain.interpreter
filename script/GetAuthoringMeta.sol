// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Script} from "forge-std/Script.sol";
import {LibAllStandardOpsNP} from "../src/lib/op/LibAllStandardOpsNP.sol";

/// @title Native Parser Authoring Meta
/// @notice A script that returns the AuthoringMeta raw abi encoded bytes
/// directly from the lib. This is intended to be packed with ExpressionDeployerNP
/// ABI, deflated, cbor encoded and then passed to ExpressionDeployerNP constructor
/// when deploying.
contract GetAuthoringMeta is Script {
    function run() external {
        vm.writeFileBinary("meta/AuthoringMeta.rain.meta", LibAllStandardOpsNP.authoringMeta());
    }
}
