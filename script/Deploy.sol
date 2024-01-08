// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Script} from "forge-std/Script.sol";
import {RainterpreterStoreNPE2} from "../src/concrete/RainterpreterStoreNPE2.sol";
import {RainterpreterNPE2} from "../src/concrete/RainterpreterNPE2.sol";
import {RainterpreterParserNPE2} from "../src/concrete/RainterpreterParserNPE2.sol";
import {
    RainterpreterExpressionDeployerNPE2,
    RainterpreterExpressionDeployerNPE2ConstructionConfig
} from "../src/concrete/RainterpreterExpressionDeployerNPE2.sol";

/// @title Deploy
/// This is intended to be run on every commit by CI to a testnet such as mumbai,
/// then cross chain deployed to whatever mainnet is required, by users.
contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYMENT_KEY");
        bytes memory constructionMeta = vm.readFileBinary("meta/RainterpreterExpressionDeployerNPE2.rain.meta");

        vm.startBroadcast(deployerPrivateKey);
        RainterpreterNPE2 interpreter = new RainterpreterNPE2();
        RainterpreterStoreNPE2 store = new RainterpreterStoreNPE2();
        RainterpreterParserNPE2 parser = new RainterpreterParserNPE2();
        RainterpreterExpressionDeployerNPE2 deployer = new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfig(
                address(interpreter), address(store), address(parser), constructionMeta
            )
        );
        (deployer);
        vm.stopBroadcast();
    }
}
