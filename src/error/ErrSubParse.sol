// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572
contract ErrSubParse {}

/// @dev When a subparser is not compatible with the main parser it MUST error
/// on `subParse` calls rather than simply return false.
error IncompatibleSubParser();

/// @dev Thrown when a subparser is asked to build an extern dispatch when the
/// constants height is outside the range a single byte can represent.
error ExternDispatchConstantsHeightOverflow(uint256 constantsHeight);
