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
import {IMetaBoardV1} from "rain.metadata/interface/IMetaBoardV1.sol";

/// @title Deploy
/// This is intended to be run on every commit by CI to a testnet such as mumbai,
/// then cross chain deployed to whatever mainnet is required, by users.
contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYMENT_KEY");
        bytes memory constructionMeta = vm.readFileBinary("meta/RainterpreterExpressionDeployerNPE2.rain.meta");
        IMetaBoardV1 metaboard = IMetaBoardV1(vm.envAddress("DEPLOYMENT_META_BOARD"));

        vm.startBroadcast(deployerPrivateKey);

        RainterpreterParserNPE2 parser = new RainterpreterParserNPE2();
        vm.writeFile("deployments/latest/RainterpreterParserNPE2", vm.toString(address(parser)));

        RainterpreterStoreNPE2 store = new RainterpreterStoreNPE2();
        vm.writeFile("deployments/latest/RainterpreterStoreNPE2", vm.toString(address(store)));

        RainterpreterNPE2 interpreter = new RainterpreterNPE2();
        vm.writeFile("deployments/latest/RainterpreterNPE2", vm.toString(address(interpreter)));

        RainterpreterExpressionDeployerNPE2 deployer = new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfig(
                address(interpreter), address(store), address(parser), constructionMeta
            )
        );
        metaboard.emitMeta(uint256(uint160(address(deployer))), constructionMeta);
        vm.writeFile("deployments/latest/RainterpreterExpressionDeployerNPE2", vm.toString(address(deployer)));

        vm.stopBroadcast();
    }
}
