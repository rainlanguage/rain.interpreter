// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {console2} from "forge-std/console2.sol";

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {ParseLiteralTest} from "test/util/abstract/ParseLiteralTest.sol";
import {LibParseLiteral} from "src/lib/parse/LibParseLiteral.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {InvalidAddressLength} from "src/error/ErrParse.sol";

/// @title LibParseLiteralBoundLiteralHexAddressTest
/// Tests parsing bound literal hex address values.
contract LibParseLiteralBoundLiteralHexAddressTest is ParseLiteralTest {
    using LibParseLiteral for ParseState;
    using LibBytes for bytes;

    function externalBoundLiteralHexAddress(string calldata value)
        external
        pure
        returns (uint256, uint256, uint256, uint256, uint256)
    {
        ParseState memory state = LibParseState.newState(bytes(value), "");

        uint256 outerStart = Pointer.unwrap(bytes(value).dataPointer());
        uint256 end = outerStart + bytes(value).length;
        (
            function(ParseState memory, uint256, uint256) pure returns (uint256) parserFn,
            uint256 innerStart,
            uint256 innerEnd,
            uint256 outerEnd
        ) = state.boundLiteralHexAddress(outerStart, end);
        uint256 parser;
        assembly {
            parser := parserFn
        }
        return (parser, outerStart, innerStart, innerEnd, outerEnd);
    }

    // Every address should parse.
    function testParseLiteralBoundLiteralHexAddressHappy(address value) external {
        string memory hexAddress = Strings.toHexString(value);

        ParseState memory state = LibParseState.newState(bytes(hexAddress), "");

        uint256 outerStart = Pointer.unwrap(bytes(hexAddress).dataPointer());
        uint256 end = outerStart + bytes(hexAddress).length;
        (
            function(ParseState memory, uint256, uint256) pure returns (uint256) parser,
            uint256 innerStart,
            uint256 innerEnd,
            uint256 outerEnd
        ) = state.boundLiteralHexAddress(outerStart, end);

        uint256 hexParser;
        function (ParseState memory, uint256, uint256) pure returns (uint256) parseLiteralHex =
            LibParseLiteral.parseLiteralHex;
        assembly ("memory-safe") {
            hexParser := parseLiteralHex
        }
        uint256 actualParser;
        assembly {
            actualParser := parser
        }
        assertEq(actualParser, hexParser);

        // 0x
        assertEq(innerStart - outerStart, 2);
        // 0x + 40 chars = 2 byte address
        assertEq(innerEnd - outerStart, 42);
        // outer end is same as inner end
        assertEq(outerEnd, innerEnd);
    }

    // Things that aren't addresses should not parse.
    function testParseLiteralBoundLiteralHexAddressSad(string calldata garbage) external {
        vm.assume(bytes(garbage).length > 0);
        vm.assume(bytes(garbage).length != 40);

        string memory value = string.concat("0x", garbage);
        console2.log(value);
        console2.logBytes(bytes(garbage));
        console2.logBytes(bytes(value));

        vm.expectRevert(abi.encodeWithSelector(InvalidAddressLength.selector, bytes(value).length));
        (uint256 parser, uint256 outerStart, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            this.externalBoundLiteralHexAddress(value);
        (parser, outerStart, innerStart, innerEnd, outerEnd);
    }
}
