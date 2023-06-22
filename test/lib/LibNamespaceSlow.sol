// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "src/interface/IInterpreterV1.sol";

library LibNamespaceSlow {
    function qualifyNamespaceSlow(StateNamespace stateNamespace_) internal view returns (FullyQualifiedNamespace) {
        return FullyQualifiedNamespace.wrap(
            uint256(keccak256(abi.encode(msg.sender, StateNamespace.unwrap(stateNamespace_))))
        );
    }
}
