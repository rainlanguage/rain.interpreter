// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {IERC165, ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {LibParse} from "../lib/parse/LibParse.sol";
import {IParserV1} from "../interface/IParserV1.sol";

bytes32 constant PARSER_BYTECODE_HASH = bytes32(0xa252b25b58cce5c4c1806357397441d780e4a7330bec03f8b0d1d306a9903975);

bytes constant PARSE_META =
    hex"027d00684901a81690080841680a428200012000e0431492112320440200010449800000000000000000000020000000000000000000000000000000000000000000001a004c42623000479d440f006aa9392a00f090c028002c65b11700ca041503003824512c007884592740ff9df60c0096c4d038104c6c730200ea676008102aa23516004d5637320061a8d8181005a76523004ae9ac0b00d5a68e2f0099dc041e003f22700e00f1ac931f008007341100d4a5b310009bd3ec04008483ae220089e7e625309402831c009677b91500a92c3a0110d4fa8829006ab6aa0a200cae02062085d59f1400b9d1b137107595b619104070aa2e0015d98a200040ab0f2400c5c8660d005fb3681200686f5c1b00928cca2d00cdcdd13100fa56360710f14a3009201ec71b2640dca42d1d00792a60330059461f35007b8cf2210053f8d1340033bccc2b00494f2c052091b7eb3610122a4d00102ddffc1300beccb0";

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
