// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {IERC165, ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {LibParse} from "../lib/parse/LibParse.sol";
import {IParserV1} from "../interface/IParserV1.sol";

bytes32 constant PARSER_BYTECODE_HASH = bytes32(0x633e5d12bafcc0e93fd5f1c8e586e141a8047d3465d1c5dd8d5f864a3f94e7a7);

bytes constant PARSE_META =
    hex"027d00684901a81690080801680a428200012000e04314921123004402000104498000000000000000000000200000000000000000000000000000000000000000000019004c42622e00479d440e006aa9392800f090c026002c65b11600ca041503003824512a007884592540ff9df636104c6c730200ea676008102aa23515004d5637300061a8d8171005a76522004ae9ac0b00d5a68e2d0099dc041d003f22700d00f1ac931e008007341000d4a5b30f009bd3ec04008483ae210089e7e623309402831b009677b91400a92c3a0110d4fa8827006ab6aa0a200cae02062085d59f1300b9d1b135107595b618104070aa2c0015d98a1f0040ab0f0c005fb3681100686f5c1a00928cca2b00cdcdd12f00fa56360710f14a3009201ec71b2440dca42d1c00792a60310059461f33007b8cf2200053f8d1320033bccc2900494f2c052091b7eb3410122a4d00102ddffc1200beccb0";

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
