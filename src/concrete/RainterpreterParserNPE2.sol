// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {IERC165, ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {LibParse} from "../lib/parse/LibParse.sol";
import {IParserV1} from "../interface/IParserV1.sol";

bytes32 constant PARSER_BYTECODE_HASH = bytes32(0x84de58b8ef64de117ddec676f089c22295e8267ec2c38e4d4b829f860e105587);

bytes constant PARSE_META =
    hex"023e00aa2208b2001088a0112400000382b20481860980062e1340044044200284000000000001000000000000000000000000000000000000008000000000000000001c00c332a00f00ff2aae1500d8ac553000df95d8110038ef2503005a78ab29008683ce0c0031dbd00a208596c4381029afd92a00048a5a21008b6c061800f39c0631006806f92d002870ea2c002cb51d28007ed6ee2740ce75301b00ab79f002208323531f00862cf004005c7b2b2e00f82ccc36102116661a10a5c7373710d76cb422003e0bda2640dce01d3200ec21ff0720fdef701d00121cd20010f7a04809109c96262000d0147308109e9ec50b2036bc2d01100b238212004029dd253074ca401e006c16581600afd55a0e0039eac0191097af9a05006ab30733009ea40f140008512f3500a2f61c2f002b93431700e043780620ed7c40100096888b240069940c2b000c6d8d23002584c40d00a53c173400655cbd13008857ce";

uint8 constant PARSE_META_BUILD_DEPTH = 2;

contract RainterpreterParserNPE2 is IParserV1, ERC165 {
    /// @inheritdoc ERC165
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
