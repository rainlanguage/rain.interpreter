// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Script.sol";
import "src/concrete/RainterpreterStore.sol";
import "src/concrete/RainterpreterNP.sol";
import "src/concrete/RainterpreterExpressionDeployerNP.sol";

/// @title DeployDISPair
/// @notice A script that deploys a DeployDISPair.
/// This is intended to be run on every commit by CI to a testnet such as mumbai,
/// then cross chain deployed to whatever mainnet is required, by users.
contract DeployDISPair is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYMENT_KEY");

        vm.startBroadcast(deployerPrivateKey);
        RainterpreterNP interpreter = new RainterpreterNP();
        RainterpreterStore store = new RainterpreterStore();
        RainterpreterExpressionDeployerNP deployer = new RainterpreterExpressionDeployerNP(RainterpreterExpressionDeployerConstructionConfig(
            address(interpreter),
            address(store),
            LibAllStandardOpsNP.authoringMeta()
        ));
        vm.stopBroadcast();
    }
}
