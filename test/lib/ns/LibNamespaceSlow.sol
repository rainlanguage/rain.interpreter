// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

import "src/interface/IInterpreterV1.sol";

library LibNamespaceSlow {
    /// Implements an abi encoding based version of `qualifyNamespace` that is
    /// slower than the version in `LibNamespace` because the abi encoding
    /// requires additional logic and memory allocations.
    function qualifyNamespaceSlow(StateNamespace stateNamespace, address sender)
        internal
        pure
        returns (FullyQualifiedNamespace)
    {
        return
            FullyQualifiedNamespace.wrap(uint256(keccak256(abi.encode(StateNamespace.unwrap(stateNamespace), sender))));
    }
}
