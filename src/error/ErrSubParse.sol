// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

/// @dev When a subparser is not compatible with the main parser it MUST error
/// on `subParse` calls rather than simply return false.
error IncompatibleSubParser();
