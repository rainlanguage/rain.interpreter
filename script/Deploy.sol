// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {RainterpreterStoreNPE2} from "../src/concrete/RainterpreterStoreNPE2.sol";
import {RainterpreterNPE2} from "../src/concrete/RainterpreterNPE2.sol";
import {RainterpreterParserNPE2} from "../src/concrete/RainterpreterParserNPE2.sol";
import {
    RainterpreterExpressionDeployerNPE2,
    RainterpreterExpressionDeployerNPE2ConstructionConfigV2
} from "../src/concrete/RainterpreterExpressionDeployerNPE2.sol";
import {IMetaBoardV1_2} from "rain.metadata/interface/unstable/IMetaBoardV1_2.sol";
import {LibDescribedByMeta} from "rain.metadata/lib/LibDescribedByMeta.sol";

/// @title Deploy
/// This is intended to be run on every commit by CI to a testnet such as mumbai,
/// then cross chain deployed to whatever mainnet is required, by users.
contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYMENT_KEY");
        bytes memory constructionMeta = vm.readFileBinary("meta/RainterpreterExpressionDeployerNPE2.rain.meta");
        IMetaBoardV1_2 metaboard = IMetaBoardV1_2(vm.envAddress("DEPLOY_METABOARD_ADDRESS"));

        vm.startBroadcast(deployerPrivateKey);

        RainterpreterParserNPE2 parser = new RainterpreterParserNPE2();
        vm.writeFile("deployments/latest/RainterpreterParserNPE2", vm.toString(address(parser)));

        RainterpreterStoreNPE2 store = new RainterpreterStoreNPE2();
        vm.writeFile("deployments/latest/RainterpreterStoreNPE2", vm.toString(address(store)));

        RainterpreterNPE2 interpreter = new RainterpreterNPE2();
        vm.writeFile("deployments/latest/RainterpreterNPE2", vm.toString(address(interpreter)));

        RainterpreterExpressionDeployerNPE2 deployer = new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfigV2(
                address(interpreter), address(store), address(parser)
            )
        );
        LibDescribedByMeta.emitForDescribedAddress(metaboard, deployer, constructionMeta);

        vm.writeFile("deployments/latest/RainterpreterExpressionDeployerNPE2", vm.toString(address(deployer)));

        vm.stopBroadcast();
    }
}
