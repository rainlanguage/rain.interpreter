// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {IERC165, ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {LibParse} from "../lib/parse/LibParse.sol";
import {IParserV1} from "../interface/IParserV1.sol";

bytes32 constant PARSER_BYTECODE_HASH = bytes32(0x4eba9c393606de8c91c1b7745506ee48361cabdd488a218c976e88f115997510);

bytes constant PARSE_META =
    hex"013e002a2208b2001080a0102400000302920481840880062e1240044004200204001100c332a00a00d8ac552500df95d8070038ef251e008683ce050031dbd003208596c41f00048a5a16008b6c060d00f39c0626006806f922002870ea21002cb51d1d007ed6ee1c40ce75301000ab79f01400862cf02300f82ccc2b102116660f10a5c7372c10d76cb417003e0bda1b40dce01d2700ec21ff1200121cd20010f7a0481500d0147329002655b3042036bc2d01100b23821a3074ca4013006c16580b00afd55a0e1097af9a02006ab30728009ea40f090008512f2a00a2f61c24002b93430c00e043780800cb7812060096888b190069940c20000c6d8d18002584c4";

uint8 constant PARSE_META_BUILD_DEPTH = 2;

contract RainterpreterParserNPE2 is IParserV1, ERC165 {
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IParserV1).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IParserV1
    function parse(bytes memory data) external pure virtual override returns (bytes memory, uint256[] memory) {
        // The return is used by returning it, so this is a false positive.
        //slither-disable-next-line unused-return
        return LibParse.parse(data, parseMeta());
    }

    /// Virtual function to return the parse meta.
    function parseMeta() internal pure virtual returns (bytes memory) {
        return PARSE_META;
    }
}
