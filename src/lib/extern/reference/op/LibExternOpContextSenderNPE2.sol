// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Operand} from "../../../../interface/unstable/IInterpreterV2.sol";
import {LibSubParse} from "../../../parse/LibSubParse.sol";
import {IInterpreterExternV3} from "../../../../interface/unstable/IInterpreterExternV3.sol";
import {CONTEXT_BASE_COLUMN, CONTEXT_BASE_ROW_SENDER} from "../../../caller/LibContext.sol";

/// @title LibExternOpContextSenderNPE2
/// This op is a simple reference to the sender of the transaction that called
/// the interpreter. It is used to demonstrate how to implement context
/// references.
library LibExternOpContextSenderNPE2 {
    /// The sub parser for the extern increment opcode. It has no special logic
    /// so uses the default sub parser from `LibSubParse`.
    //slither-disable-next-line dead-code
    function subParser(uint256, uint256, Operand) internal pure returns (bool, bytes memory, uint256[] memory) {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserContext(CONTEXT_BASE_COLUMN, CONTEXT_BASE_ROW_SENDER);
    }
}
