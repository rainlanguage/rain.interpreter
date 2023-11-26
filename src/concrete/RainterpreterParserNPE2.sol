// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {IERC165, ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {LibParse} from "../lib/parse/LibParse.sol";
import {IParserV1} from "../interface/IParserV1.sol";

bytes32 constant PARSER_BYTECODE_HASH = bytes32(0x976399c9cbb9cafef6fe021660d784b9e4f3c4806c3b1a0a0cc180360aea46cf);

bytes constant PARSE_META =
    hex"02588021002e004400805a0128004060822400400910000900044d510693108028840000000000000000000800000000000000000000000000000000000000000000001a0049c6a30b001dc5372a00b46c3a15106b5d511600a56d9d27006380a82d006811912b00bf1f411700932038260025b2071e007675860110778874230054ad340d00facaed0920f793d9214098844e0810c51f7f0e00de41320c00b789641d00844b3011001158590520980f12280000857412000142421c002a4b6e24002012363210f3a07e29005fbbfc1f00e281ae25007af188311054e3922240b312972f001ec0421300a0265d020082963a0a205436e6001075eca110002558bb04001fa2212e00a5e8dd0f004329871900e60c070710880be518007d424b203098ad582c0054aa0514107e9c530300e7bf521b002f3f5e0620783df930009232f7";

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
