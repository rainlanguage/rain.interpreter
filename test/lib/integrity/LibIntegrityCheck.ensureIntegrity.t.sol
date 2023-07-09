// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "src/lib/integrity/LibIntegrityCheck.sol";

/// @title LibIntegrityCheckEnsureIntegrityTest
/// `ensureIntegrity` is the main entry point for the integrity check library as
/// it takes a fresh state, parsed indexes and runs the integrity check for each
/// index-opcode.
contract LibIntegrityCheckEnsureIntegrityTest is Test {}
