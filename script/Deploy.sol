// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {RainterpreterStore} from "../src/concrete/RainterpreterStore.sol";
import {Rainterpreter} from "../src/concrete/Rainterpreter.sol";
import {RainterpreterParser} from "../src/concrete/RainterpreterParser.sol";

// import {
//     RainterpreterExpressionDeployer,
//     RainterpreterExpressionDeployerConstructionConfigV2
// } from "../src/concrete/RainterpreterExpressionDeployer.sol";
// import {IMetaBoardV1_2} from "rain.metadata/interface/unstable/IMetaBoardV1_2.sol";
// import {LibDescribedByMeta} from "rain.metadata/lib/LibDescribedByMeta.sol";

/// @title Deploy
contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYMENT_KEY");

        LibRainDeploy.deployAndBroadcastToSupportedNetworks(
            vm,
            LibRainDeploy.supportedNetworks(),
            deployerPrivateKey,
            type(RainterpreterParser).creationCode,
            "",
            LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS,
            LibInterpreterDeploy.PARSER_DEPLOYED_CODEHASH,
            new address[](0)
        );

        // bytes memory constructionMeta = vm.readFileBinary("meta/RainterpreterExpressionDeployer.rain.meta");
        // IMetaBoardV1_2 metaboard = IMetaBoardV1_2(vm.envAddress("DEPLOY_METABOARD_ADDRESS"));

        // vm.startBroadcast(deployerPrivateKey);

        // RainterpreterParser parser = new RainterpreterParser();
        // //forge-lint: disable-next-line(unsafe-cheatcode)
        // vm.writeFile("deployments/latest/RainterpreterParser", vm.toString(address(parser)));

        // RainterpreterStore store = new RainterpreterStore();
        // //forge-lint: disable-next-line(unsafe-cheatcode)
        // vm.writeFile("deployments/latest/RainterpreterStore", vm.toString(address(store)));

        // Rainterpreter interpreter = new Rainterpreter();
        // //forge-lint: disable-next-line(unsafe-cheatcode)
        // vm.writeFile("deployments/latest/Rainterpreter", vm.toString(address(interpreter)));

        // RainterpreterExpressionDeployer deployer = new RainterpreterExpressionDeployer(
        //     RainterpreterExpressionDeployerConstructionConfigV2(address(interpreter), address(store), address(parser))
        // );
        // LibDescribedByMeta.emitForDescribedAddress(metaboard, deployer, constructionMeta);

        // //forge-lint: disable-next-line(unsafe-cheatcode)
        // vm.writeFile("deployments/latest/RainterpreterExpressionDeployer", vm.toString(address(deployer)));

        // vm.stopBroadcast();
    }
}
