// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {OperandV2} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {LibSubParse} from "../../../parse/LibSubParse.sol";

/// @dev Column index for caller-provided context. Column 0 is the base
/// context (sender, calling contract) built by the interpreter itself.
/// Column 1 is always the caller context passed in by the calling contract.
/// Defined locally rather than in `LibContext.sol` because `LibContext` only
/// covers the base context grid; caller context layout is caller-specific.
uint256 constant CONTEXT_CALLER_CONTEXT_COLUMN = 1;

/// @dev Row index for the Rainlang byte length within the caller context
/// column. This position is specific to the reference extern implementation
/// and is not a universal convention, so it is defined locally.
uint256 constant CONTEXT_CALLER_CONTEXT_ROW_RAINLEN = 0;

/// @title LibExternOpContextRainlen
/// @notice This op is a simple reference to the length of the rainlang bytes. It is
/// used to demonstrate how to implement context references.
library LibExternOpContextRainlen {
    /// The sub parser for the rainlen context opcode. It has no special logic
    /// so uses the default sub parser from `LibSubParse`.
    //slither-disable-next-line dead-code
    function subParser(uint256, uint256, OperandV2) internal pure returns (bool, bytes memory, bytes32[] memory) {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserContext(CONTEXT_CALLER_CONTEXT_COLUMN, CONTEXT_CALLER_CONTEXT_ROW_RAINLEN);
    }
}
