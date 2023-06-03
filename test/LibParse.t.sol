// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/LibParse.sol";

contract LibParseTest is Test {
    function testParseEmpty() external pure {
        // bytes memory char  = ";";
        // assembly {
        //     // let x := shl(and(mload(add(char, 1)), 0xFF), 1)
        //     let x := or(or(0x100000000000, 0x0400000000000000), 0x0800000000000000)
        //     let y := mload(x)
        // }
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(":;");
    }
}
