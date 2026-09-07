// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {BaseRainlangStore} from "../../src/abstract/BaseRainlangStore.sol";

/// @title TestRainlangStore
/// @notice `BaseRainlangStore` over the current source. The store binds no
/// tables, so this is the base as-is.
contract TestRainlangStore is BaseRainlangStore {}
