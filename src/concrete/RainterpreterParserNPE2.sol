// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {IERC165, ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {LibParse} from "../lib/parse/LibParse.sol";
import {IParserV1} from "../interface/IParserV1.sol";

bytes32 constant PARSER_BYTECODE_HASH = bytes32(0xde02760d93dec05e1553b1a54de69bdd1c64ffcef6ebb20a4a6109df2ec5732c);

bytes constant PARSE_META =
    hex"017a080114205002002c00848000416d2042008ed20000000464021001001004e8110a007c002d28002d2b341b001a21c91a004cb6051400d9d29616004abb9c0110addc6812003d955420001bfdef23007d4cd81c30fb30cd0e0060ca202700a4141c07009dee3e1e40349ac22400558f3d13000220b61500ba9a911700a6ced42e10a955a21d402ce6e10010c470af2a009f3d741f00494def220017715c090045b05a2d10ae8adc26003493031800f4d5982b00ae2be00420f74b9a0c008800380d0096ac190320456e6421008a324c052063d1bc08006e3d3a2c00e6a9900200f2bd181110ef0a8229002e7f58190012180a06203cde9c0f00bf79181010d998ae0b00bcdfd8250044e506";

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
