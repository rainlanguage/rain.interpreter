// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

import "src/lib/LibEvaluable.sol";

library LibEvaluableSlow {
    function hashSlow(Evaluable memory evaluable) internal pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                uint256(uint160(address(evaluable.interpreter))),
                uint256(uint160(address(evaluable.store))),
                uint256(uint160(evaluable.expression))
            )
        );
    }
}
