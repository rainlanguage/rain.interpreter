// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {
    BaseRainterpreterSubParser,
    SubParserIndexOutOfBounds
} from "src/abstract/BaseRainterpreterSubParser.sol";

/// @dev Sub parser where matchSubParseLiteralDispatch always succeeds with
/// index 1, but subParserLiteralParsers returns only 1 pointer (2 bytes).
/// This triggers SubParserIndexOutOfBounds(1, 1) in subParseLiteral2.
contract MismatchedLiteralSubParser is BaseRainterpreterSubParser {
    function matchSubParseLiteralDispatch(uint256, uint256)
        internal
        pure
        override
        returns (bool, uint256, bytes32)
    {
        return (true, 1, bytes32(0));
    }

    function subParserLiteralParsers() internal pure override returns (bytes memory) {
        // 1 pointer = 2 bytes, so parsersLength = 1. Index 1 is out of range.
        return hex"0001";
    }

    function describedByMetaV1() external pure override returns (bytes32) {
        return bytes32(0);
    }

    function buildLiteralParserFunctionPointers() external pure returns (bytes memory) {
        return "";
    }

    function buildOperandHandlerFunctionPointers() external pure returns (bytes memory) {
        return "";
    }

    function buildSubParserWordParsers() external pure returns (bytes memory) {
        return "";
    }
}

/// @title BaseRainterpreterSubParserLiteralIndexTest
/// Tests that subParseLiteral2 reverts with SubParserIndexOutOfBounds when
/// the literal parser index from dispatch exceeds the literal parsers table.
contract BaseRainterpreterSubParserLiteralIndexTest is Test {
    /// subParseLiteral2 must revert when the dispatch index is out of range.
    function testSubParseLiteral2RevertsIndexOutOfBounds() external {
        MismatchedLiteralSubParser subParser = new MismatchedLiteralSubParser();

        // Minimal data: 2-byte dispatch length + 1 byte dispatch body.
        bytes memory data = bytes.concat(bytes2(uint16(1)), bytes1(0));

        vm.expectRevert(abi.encodeWithSelector(SubParserIndexOutOfBounds.selector, uint256(1), uint256(1)));
        subParser.subParseLiteral2(data);
    }
}
