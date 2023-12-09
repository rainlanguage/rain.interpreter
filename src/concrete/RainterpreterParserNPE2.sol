// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {IERC165, ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {LibParse} from "../lib/parse/LibParse.sol";
import {IParserV1} from "../interface/IParserV1.sol";

bytes32 constant PARSER_BYTECODE_HASH = bytes32(0x019f9a3746b23ee6fe748e84130426f8a870bcfa93cb0ae742d0c47700214623);

bytes constant PARSE_META =
    hex"02498808220a2013000c08021320c51020c10908004040400494201934224b0086280000000000000000000000000000000000000000000000080000000000000000402300f779410d00ee1ce71b0034b7b535009da6ea02200c848908105226f609107827fe0110d556492d001274f717008783b30a2015fe8228402279c32e00b3469f2900e149b12b002e1b22310044b7793710ad62f7062096308500108cdb942740ab5e491d009a2df011009741001e00aeb1550300f54c162500146dc00c00b48633360044bf332000bac651140085c0c3330026583d0720a6dee51f003f2f431600c4b7661800c85a9a3910561eec2f00c2def92200721d5d2a002bd7880b20d7d8610f00ac9dd91a107da12e0500797e1e32007c8fab0e0013dd511c00843337210095f3ee2c00ce0635240006c95d1200b5795d26308372211000fafb87191051da9a1300bef3b2150066f6c230004a27d2040075cf343400985d0238103cf36e";

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
