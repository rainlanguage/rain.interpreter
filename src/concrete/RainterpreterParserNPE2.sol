// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {IERC165, ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {LibParse} from "../lib/parse/LibParse.sol";
import {IParserV1} from "../interface/IParserV1.sol";
import {LibParseState, ParseState} from "../lib/parse/LibParseState.sol";
import {LibParseLiteral} from "../lib/parse/literal/LibParseLiteral.sol";
import {LibAllStandardOpsNP} from "../lib/op/LibAllStandardOpsNP.sol";

bytes32 constant PARSER_BYTECODE_HASH = bytes32(0xa3f5b823b93d247b6e95eaf602604f231f7fb7bf4682a2dd30ce13c777fdefba);

bytes constant PARSE_META =
    hex"02498808220a2013000c08021320c51020c10908004040400494201934224b00862800000000000000000000000000000000000000000000000800000000000000004023f779410dee1ce71b34b7b5359da6ea020c8489085226f6097827fe01d556492d1274f7178783b30a15fe82282279c32eb3469f29e149b12b2e1b223144b77937ad62f706963085008cdb9427ab5e491d9a2df0119741001eaeb15503f54c1625146dc00cb486333644bf3320bac6511485c0c33326583d07a6dee51f3f2f4316c4b76618c85a9a39561eec2fc2def922721d5d2a2bd7880bd7d8610fac9dd91a7da12e05797e1e327c8fab0e13dd511c8433372195f3ee2cce06352406c95d12b5795d2683722110fafb871951da9a13bef3b21566f6c2304a27d20475cf3434985d02383cf36e";

uint8 constant PARSE_META_BUILD_DEPTH = 2;

bytes constant OPERAND_HANDLER_FUNCTION_POINTERS =
    hex"0ef40ef40f89102a102a102a0f890f890ef40ef40f890f89102a102a102a102a102a102a102a102a102a102a102a102a102a0ef40ef4102a102a102a102a102a102a102a102a102a102a102a106f11031103102a102a102a102a102a102a102a102a102a102a102a102a102a102a0ef40ef40ef4";

bytes constant LITERAL_PARSER_FUNCTION_POINTERS = hex"07e60aae0dab";

contract RainterpreterParserNPE2 is IParserV1, ERC165 {
    using LibParse for ParseState;

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IParserV1).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IParserV1
    function parse(bytes memory data) external pure virtual override returns (bytes memory, uint256[] memory) {
        // The return is used by returning it, so this is a false positive.
        //slither-disable-next-line unused-return
        return LibParseState.newState(
            data, parseMeta(), operandHandlerFunctionPointers(), literalParserFunctionPointers()
        ).parse();
    }

    /// Virtual function to return the parse meta.
    function parseMeta() internal pure virtual returns (bytes memory) {
        return PARSE_META;
    }

    /// Virtual function to return the operand handler function pointers.
    function operandHandlerFunctionPointers() internal pure virtual returns (bytes memory) {
        return OPERAND_HANDLER_FUNCTION_POINTERS;
    }

    /// Virtual function to return the literal parser function pointers.
    function literalParserFunctionPointers() internal pure virtual returns (bytes memory) {
        return LITERAL_PARSER_FUNCTION_POINTERS;
    }

    /// External function to build the operand handler function pointers.
    function buildOperandHandlerFunctionPointers() external pure returns (bytes memory) {
        return LibAllStandardOpsNP.operandHandlerFunctionPointers();
    }

    /// External function to build the literal parser function pointers.
    function buildLiteralParserFunctionPointers() external pure returns (bytes memory) {
        return LibAllStandardOpsNP.literalParserFunctionPointers();
    }
}
