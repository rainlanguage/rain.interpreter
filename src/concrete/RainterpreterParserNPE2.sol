// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {IERC165, ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {LibParse} from "../lib/parse/LibParse.sol";
import {IParserV1} from "../interface/IParserV1.sol";

bytes32 constant PARSER_BYTECODE_HASH = bytes32(0x91a823ea861f185af3e0d05d2e172ea3711eeca2006919b4cfc35934578368e4);

bytes constant PARSE_META =
    hex"018d9000200000c60015020104002282000025814a4250d01010582292c0580008081900fa8a612a0026e97316004484642800cfe9e51100bb4eda29007539f91f403402582f102c74f50d003f313230100fbdb4082044508c0a0069b1c90610b8940802006e046d131026b58c051075309b2200b62fd61e301bab1821009c483b0900bcad332e001c79f3240003ae3d0c004e8a1618007611e00720301671230080ed670e0089c48c1b00c286dd2700a266f917007659e41400cb818a01106dd7c92c005deb9f2b00832fdd0f009264ee0b007979a72d00cc54fe2600cc40dd00102b39ae1c0083926412107e941003203869991a0070f5b81500ad311b100029582a250053c8e32040b318e21d0024ab9f0420b80b95";

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
