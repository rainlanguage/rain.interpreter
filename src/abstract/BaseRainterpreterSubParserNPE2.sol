// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";

import {ISubParserV1, COMPATIBLITY_V0} from "../interface/unstable/ISubParserV1.sol";
import {IncompatibleSubParser} from "../error/ErrSubParse.sol";
import {LibSubParse, ParseState} from "../lib/parse/LibSubParse.sol";
import {CMASK_RHS_WORD_TAIL} from "../lib/parse/LibParseCMask.sol";
import {LibParse, Operand} from "../lib/parse/LibParse.sol";
import {LibParseMeta} from "../lib/parse/LibParseMeta.sol";

bytes constant SUB_PARSER_FUNCTION_POINTERS = hex"";
bytes constant SUB_PARSER_PARSE_META = hex"";

abstract contract BaseRainterpreterSubParserNPE2 is ERC165, ISubParserV1 {
    using LibBytes for bytes;
    using LibParse for ParseState;
    using LibParseMeta for ParseState;

    function subParserFunctionPointers() internal pure returns (bytes memory) {
        return SUB_PARSER_FUNCTION_POINTERS;
    }

    function subParse(bytes32 compatibility, bytes memory data)
        external
        pure
        returns (bool success, bytes memory bytecode, uint256[] memory constants)
    {
        if (compatibility != COMPATIBLITY_V0) {
            revert IncompatibleSubParser();
        }

        (uint256 constantsHeight, uint256 ioByte, ParseState memory state) =
            LibSubParse.consumeInputData(data, SUB_PARSER_PARSE_META);
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        uint256 end = cursor + state.data.length;

        bytes32 word;
        (cursor, word) = LibParse.parseWord(cursor, end, CMASK_RHS_WORD_TAIL);
        (
            bool exists,
            uint256 index,
            function(ParseState memory, uint256, uint256) pure returns (uint256, Operand) operandParser
        ) = state.lookupWord(word);
        if (exists) {
            Operand operand;
            (cursor, operand) = operandParser(state, cursor, end);
            function (uint256, uint256, Operand) internal pure returns (bool, bytes memory, uint256[] memory) subParser;
            bytes memory localSubParserFunctionPointers = subParserFunctionPointers();
            assembly ("memory-safe") {
                subParser := and(mload(add(localSubParserFunctionPointers, mul(add(index, 1), 2))), 0xFFFF)
            }
            return subParser(constantsHeight, ioByte, operand);
        } else {
            return (false, "", new uint256[](0));
        }
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ISubParserV1).interfaceId || super.supportsInterface(interfaceId);
    }
}
