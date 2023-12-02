// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {IERC165, ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {LibParse} from "../lib/parse/LibParse.sol";
import {IParserV1} from "../interface/IParserV1.sol";

bytes32 constant PARSER_BYTECODE_HASH = bytes32(0x00fa9080851a348b9184ac91d3949f4d5e36e8bf83f76a9b9bacdc20411d00d9);

bytes constant PARSE_META =
    hex"027d00684901a81690080001680a428200012000e04314921123004402000104498000000000000000000000200000000000000000000000000000000000000000000018004c42622d00479d440d006aa9392700f090c025002c65b11500ca0415030038245129007884592440ff9df635104c6c730200ea676008102aa23514004d56372f0061a8d8161005a76521004ae9ac0b00d5a68e2c0099dc041c003f22700c00f1ac931d008007340f00d4a5b30e009bd3ec04008483ae200089e7e622309402831a009677b91300a92c3a0110d4fa8826006ab6aa0a200cae02062085d59f1200b9d1b134107595b617104070aa2b0015d98a1e0040ab0f1000686f5c1900928cca2a00cdcdd12e00fa56360710f14a3009201ec71b2340dca42d1b00792a60300059461f32007b8cf21f0053f8d1310033bccc2800494f2c052091b7eb3310122a4d00102ddffc1100beccb0";

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
