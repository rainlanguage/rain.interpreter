// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

bytes32 constant COMPATIBLITY_V2 = keccak256("2023.12.28 Rainlang ISubParserV2");

interface ISubParserV2 {
    function subParseLiteral(bytes32 compatibility, bytes calldata data)
        external
        pure
        returns (bool success, uint256 value);

    function subParseWord(bytes32 compatibility, bytes calldata data)
        external
        pure
        returns (bool success, bytes memory bytecode, uint256[] memory constants);
}
