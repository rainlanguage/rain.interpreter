// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {RainDeployVerifySnapshot} from "rain-deploy-0.1.7/src/abstract/RainDeployVerifySnapshot.sol";
import {RainlangDeploySuites} from "../../../src/abstract/RainlangDeploySuites.sol";

/// @title RainlangDeploySnapshotTest
/// @notice Binds this repo's declaration to `RainDeployVerifySnapshot`: every
/// deploy-pin assertion over the rainlang suites that needs no network — each
/// snapshot internally consistent, every candidate still matching current
/// source, and every file in the frozen record declared by a released suite.
///
/// Separate from `RainlangDeployChainTest` because nothing here forks, so an
/// unreachable RPC cannot make any of it red.
contract RainlangDeploySnapshotTest is RainlangDeploySuites, RainDeployVerifySnapshot {}
