// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Operand} from "../../../../interface/unstable/IInterpreterV2.sol";
import {LibSubParse} from "../../../parse/LibSubParse.sol";
import {IInterpreterExternV3} from "../../../../interface/unstable/IInterpreterExternV3.sol";

uint256 constant CONTEXT_CALLER_CONTEXT_COLUMN = 1;
uint256 constant CONTEXT_CALLER_CONTEXT_ROW_RAINLEN = 0;

/// @title LibExternOpContextRainlenNPE2
/// This op is a simple reference to the length of the rainlang bytes. It is
/// used to demonstrate how to implement context references.
library LibExternOpContextRainlenNPE2 {
    /// The sub parser for the extern increment opcode. It has no special logic
    /// so uses the default sub parser from `LibSubParse`.
    //slither-disable-next-line dead-code
    function subParser(uint256, uint256, Operand) internal pure returns (bool, bytes memory, uint256[] memory) {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserContext(CONTEXT_CALLER_CONTEXT_COLUMN, CONTEXT_CALLER_CONTEXT_ROW_RAINLEN);
    }
}
