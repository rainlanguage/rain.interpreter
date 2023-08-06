// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

struct IntegrityCheckStateNP {
    uint256 stackIndex;
    uint256 stackMaxIndex;
    uint256 readHighwater;
    uint256 constantsLength;
    uint256 opIndex;
    bytes bytecode;
}

library LibIntegrityCheckNP {
    using LibIntegrityCheckNP for IntegrityCheckStateNP;

    function newState(bytes memory bytecode, uint256 stackIndex, uint256 constantsLength)
        internal
        pure
        returns (IntegrityCheckStateNP memory)
    {
        return IntegrityCheckStateNP(
            // stackIndex
            stackIndex,
            // stackMaxIndex
            stackIndex,
            // highwater (source inputs are always immutable)
            stackIndex,
            // constantsLength
            constantsLength,
            // opIndex
            0,
            // bytecode
            bytecode
        );
    }
}
