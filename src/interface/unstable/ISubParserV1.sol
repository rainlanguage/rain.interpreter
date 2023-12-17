// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";

interface ISubParserV1 is IERC165 {
    function subParse(bytes32 compatibility, bytes calldata data)
        external
        pure
        returns (bool success, bytes calldata bytecode, uint256[] calldata constants);
}
