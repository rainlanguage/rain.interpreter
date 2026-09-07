// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {BaseRainlangParser} from "../abstract/BaseRainlangParser.sol";
import {
    LITERAL_PARSER_FUNCTION_POINTERS,

    // Exported for convenience.
    //forge-lint: disable-next-line(unused-import)
    BYTECODE_HASH as PARSER_BYTECODE_HASH,
    OPERAND_HANDLER_FUNCTION_POINTERS,
    PARSE_META
} from "../generated/RainlangParserPointers.sol";

/// @title RainlangParser
/// @notice `BaseRainlangParser` bound to its generated parse meta and function
/// pointer tables.
contract RainlangParser is BaseRainlangParser {
    /// @inheritdoc BaseRainlangParser
    function parseMeta() internal pure virtual override returns (bytes memory) {
        return PARSE_META;
    }

    /// @inheritdoc BaseRainlangParser
    function operandHandlerFunctionPointers() internal pure virtual override returns (bytes memory) {
        return OPERAND_HANDLER_FUNCTION_POINTERS;
    }

    /// @inheritdoc BaseRainlangParser
    function literalParserFunctionPointers() internal pure virtual override returns (bytes memory) {
        return LITERAL_PARSER_FUNCTION_POINTERS;
    }
}
