// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IMetaV1} from "rain.metadata/interface/IMetaV1.sol";
import {LibMeta} from "rain.metadata/lib/LibMeta.sol";
import {LibDeployerDiscoverable} from "rain.interpreter.interface/lib/caller/LibDeployerDiscoverable.sol";

/// Construction config for `DeployerDiscoverableMetaV3`.
/// @param deployer Deployer the calling contract will be discoverable under.
/// @param meta MetaV1 data to emit before touching the deployer.
struct DeployerDiscoverableMetaV3ConstructionConfig {
    address deployer;
    bytes meta;
}

/// @title DeployerDiscoverableMetaV3
/// @notice Upon construction, checks metadata against a known hash, emits it
/// then touches the deployer (deploy an empty expression). This allows indexers
/// to discover the metadata of the `DeployerDiscoverableMetaV3` contract by
/// indexing the deployer. In this way the deployer acts as a pseudo-registry by
/// virtue of it being a natural hub for interactions with calling contracts.
abstract contract DeployerDiscoverableMetaV3 is IMetaV1 {
    constructor(bytes32 metaHash, DeployerDiscoverableMetaV3ConstructionConfig memory config) {
        LibMeta.checkMetaHashedV1(metaHash, config.meta);
        emit MetaV1(msg.sender, uint256(uint160(address(this))), config.meta);
        LibDeployerDiscoverable.touchDeployerV3(config.deployer);
    }
}
