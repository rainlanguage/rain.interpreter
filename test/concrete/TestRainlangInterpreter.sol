// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {BaseRainlangInterpreter} from "../../src/abstract/BaseRainlangInterpreter.sol";
import {LibAllStandardOps} from "../../src/lib/op/LibAllStandardOps.sol";

/// @title TestRainlangInterpreter
/// @notice `BaseRainlangInterpreter` over the current source: the opcode
/// function pointer table is read from `LibAllStandardOps` at runtime rather
/// than a generated file.
contract TestRainlangInterpreter is BaseRainlangInterpreter {
    /// @inheritdoc BaseRainlangInterpreter
    function opcodeFunctionPointers() internal pure virtual override returns (bytes memory) {
        return LibAllStandardOps.opcodeFunctionPointers();
    }
}
