// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "sol.metadata/IMetaV1.sol";
import "sol.metadata/LibMeta.sol";
import "./LibDeployerDiscoverable.sol";

/// Construction config for `DeployerDiscoverableMetaV1`.
/// @param deployer Deployer the calling contract will be discoverable under.
/// @param meta MetaV1 data to emit before touching the deployer.
struct DeployerDiscoverableMetaV1ConstructionConfig {
    address deployer;
    bytes meta;
}

/// @title DeployerDiscoverableMetaV1
/// @notice Upon construction, checks metadata against a known hash, emits it
/// then touches the deployer (deploy an empty expression). This allows indexers
/// to discover the metadata of the `DeployerDiscoverableMetaV1` contract by
/// indexing the deployer. In this way the deployer acts as a pseudo-registry by
/// virtue of it being a natural hub for interactions with calling contracts.
abstract contract DeployerDiscoverableMetaV1 is IMetaV1 {
    constructor(bytes32 metaHash, DeployerDiscoverableMetaV1ConstructionConfig memory config) {
        LibMeta.checkMetaHashed(metaHash, config.meta);
        emit MetaV1(msg.sender, uint256(uint160(address(this))), config.meta);
        LibDeployerDiscoverable.touchDeployer(config.deployer);
    }
}
