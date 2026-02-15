// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572
contract ErrDeploy {}

/// Thrown when the `DEPLOYMENT_SUITE` env var does not match any known suite
/// selector.
/// @param suite The unrecognised suite selector hash.
error UnknownDeploymentSuite(bytes32 suite);
