// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

struct IntegrityCheckStateNP {
    uint256 stackIndex;
    uint256 readHighwater;
    uint256 constantsLength;
}

library LibIntegrityCheckNP {
    using LibIntegrityCheckNP for IntegrityCheckStateNP;

    function newState(bytes memory bytecode) internal pure returns (IntegrityCheckStateNP memory) {
        return IntegrityCheckStateNP(0, 0, 0);
    }
}
