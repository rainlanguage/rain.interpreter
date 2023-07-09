// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../IInterpreterV1.sol";

interface IParserV1 {
    function parse(bytes memory data) external pure returns (bytes[] memory, uint256[] memory);
}
