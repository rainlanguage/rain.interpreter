// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

interface IParserToolingV1 {
    function buildOperandHandlerFunctionPointers() external pure returns (bytes memory);

    function buildLiteralParserFunctionPointers() external pure returns (bytes memory);
}
