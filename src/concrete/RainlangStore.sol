// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {BaseRainlangStore} from "../abstract/BaseRainlangStore.sol";

// Exported for convenience.
//forge-lint: disable-next-line(unused-import)
import {BYTECODE_HASH as STORE_BYTECODE_HASH} from "../generated/RainlangStorePointers.sol";

/// @title RainlangStore
/// @notice The deployed `BaseRainlangStore`, which binds nothing: the store has
/// no generated tables.
contract RainlangStore is BaseRainlangStore {}
