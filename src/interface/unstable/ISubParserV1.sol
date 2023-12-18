// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

/// @dev This can be anything as long as it is unique and the sub parsers
/// can agree on it.
bytes32 constant COMPATIBLITY_V0 = keccak256("2023.12.17 Rainlang Parser v0");

interface ISubParserV1 {
    function subParse(bytes32 compatibility, bytes calldata data)
        external
        pure
        returns (bool success, bytes calldata bytecode, uint256[] calldata constants);
}
