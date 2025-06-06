// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {LibSubParse} from "../../../parse/LibSubParse.sol";
import {IInterpreterExternV4} from "rain.interpreter.interface/interface/unstable/IInterpreterExternV4.sol";
import {
    CONTEXT_BASE_COLUMN,
    CONTEXT_BASE_ROW_CALLING_CONTRACT
} from "rain.interpreter.interface/lib/caller/LibContext.sol";

/// @title LibExternOpContextCallingContract
/// This op is a simple reference to the contract that called the interpreter.
/// It is used to demonstrate how to implement context references.
library LibExternOpContextCallingContract {
    /// The sub parser for the extern increment opcode. It has no special logic
    /// so uses the default sub parser from `LibSubParse`.
    //slither-disable-next-line dead-code
    function subParser(uint256, uint256, OperandV2) internal pure returns (bool, bytes memory, bytes32[] memory) {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserContext(CONTEXT_BASE_COLUMN, CONTEXT_BASE_ROW_CALLING_CONTRACT);
    }
}
