// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {IERC165, ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {LibParse} from "../lib/parse/LibParse.sol";
import {IParserV1} from "../interface/IParserV1.sol";

bytes32 constant PARSER_BYTECODE_HASH = bytes32(0xe1a894f5142cb769fd8648f39e34c167ddf978129dae05d551d1fea8263dede1);

bytes constant PARSE_META =
    hex"027d00684901a81690080001680a428200012000e04214921123004402000104498000000000000000000000200000000000000000000000000000000000000000000017004c42622c00479d440c006aa9392600f090c024002c65b11400ca0415030038245128007884592340ff9df634104c6c730200ea676008102aa23513004d56372e0061a8d8151005a76520004ae9ac0b00d5a68e2b0099dc041b003f22701c008007340e00d4a5b30d009bd3ec04008483ae1f0089e7e6213094028319009677b91200a92c3a0110d4fa8825006ab6aa0a200cae02062085d59f1100b9d1b133107595b616104070aa2a0015d98a1d0040ab0f0f00686f5c1800928cca2900cdcdd12d00fa56360710f14a3009201ec71b2240dca42d1a00792a602f0059461f31007b8cf21e0053f8d1300033bccc2700494f2c052091b7eb3210122a4d00102ddffc1000beccb0";

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
