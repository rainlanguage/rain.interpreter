// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Script.sol";
import "src/concrete/RainterpreterStore.sol";

/// @title DeployRainterpreterStore
/// @notice A script that deploys a DeployRainterpreterStore. This is intended to
/// be run on every commit by CI to a testnet such as mumbai, then cross chain
/// deployed to whatever mainnet is required, by users.
contract DeployRainterpreterStore is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYMENT_KEY");

        vm.startBroadcast(deployerPrivateKey);
        RainterpreterStore store = new RainterpreterStore();
        (store);
        vm.stopBroadcast();
    }
}
