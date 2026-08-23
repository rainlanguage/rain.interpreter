// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {RainDeployVerifyChain} from "rain-deploy-0.1.7/src/abstract/RainDeployVerifyChain.sol";
import {RainlangDeploySuites} from "../../../src/abstract/RainlangDeploySuites.sol";

/// @title RainlangDeployChainTest
/// @notice Binds this repo's declaration to `RainDeployVerifyChain`: every
/// RELEASED suite is live, with the code it froze, on every supported network.
///
/// Candidates are deliberately out of scope — a candidate is meant to be ahead
/// of the chain, and this repo has cut no release under the frozen-record
/// lifecycle yet, so the derivation list is empty and this early-returns
/// without touching an RPC. It gets a subject the moment `src/generated/<tag>/`
/// holds its first release.
contract RainlangDeployChainTest is RainlangDeploySuites, RainDeployVerifyChain {}
