// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../interface/IInterpreterV1.sol";

library LibNamespace {
    /// Standard way to elevate a caller-provided state namespace to a universal
    /// namespace that is disjoint from all other caller-provided namespaces.
    /// Essentially just hashes the `msg.sender` into the state namespace as-is.
    ///
    /// This is deterministic such that the same combination of state namespace
    /// and caller will produce the same fully qualified namespace, even across
    /// multiple transactions/blocks.
    ///
    /// @param stateNamespace The state namespace as specified by the caller.
    /// @return qualifiedNamespace A fully qualified namespace that cannot
    /// collide with any other state namespace specified by any other caller.
    function qualifyNamespace(StateNamespace stateNamespace)
        internal
        view
        returns (FullyQualifiedNamespace qualifiedNamespace)
    {
        assembly ("memory-safe") {
            mstore(0, caller())
            mstore(0x20, stateNamespace)
            qualifiedNamespace := keccak256(0, 0x40)
        }
    }
}
