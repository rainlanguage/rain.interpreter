// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

interface IOpcodeToolingV1 {
    function buildOpcodeFunctionPointers() external view returns (bytes memory);
}
