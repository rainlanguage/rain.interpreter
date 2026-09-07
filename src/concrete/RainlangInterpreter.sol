// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {BaseRainlangInterpreter} from "../abstract/BaseRainlangInterpreter.sol";
import {

    // Exported for convenience.
    //forge-lint: disable-next-line(unused-import)
    BYTECODE_HASH as INTERPRETER_BYTECODE_HASH,
    OPCODE_FUNCTION_POINTERS
} from "../generated/RainlangInterpreterPointers.sol";

/// @title RainlangInterpreter
/// @notice `BaseRainlangInterpreter` bound to its generated opcode function
/// pointer table.
contract RainlangInterpreter is BaseRainlangInterpreter {
    /// @inheritdoc BaseRainlangInterpreter
    function opcodeFunctionPointers() internal view virtual override returns (bytes memory) {
        return OPCODE_FUNCTION_POINTERS;
    }
}
