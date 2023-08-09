// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import "../interface/IInterpreterStoreV1.sol";
import "../lib/ns/LibNamespace.sol";

/// Thrown when a `set` call is made with an odd number of arguments.
error RainterpreterStoreOddSetLength(uint256 length);

/// @title RainterpreterStore
/// @notice Simplest possible `IInterpreterStoreV1` that could work.
/// Takes key/value pairings from the input array and stores each in an internal
/// mapping. `StateNamespace` is fully qualified only by `msg.sender` on set and
/// doesn't attempt to do any deduping etc. if the same key appears twice it will
/// be set twice.
contract RainterpreterStore is IInterpreterStoreV1, ERC165 {
    using LibNamespace for StateNamespace;

    /// Store is several tiers of sandbox.
    ///
    /// 0. Address hashed into `FullyQualifiedNamespace` is `msg.sender` so that
    ///    callers cannot attack each other
    /// 1. StateNamespace is caller-provided namespace so that expressions cannot
    ///    attack each other
    /// 2. `uint256` is expression-provided key
    /// 3. `uint256` is expression-provided value
    ///
    /// tiers 0 and 1 are both embodied in the `FullyQualifiedNamespace`.
    // Slither doesn't like the leading underscore.
    //solhint-disable-next-line private-vars-leading-underscore
    mapping(FullyQualifiedNamespace => mapping(uint256 => uint256)) internal sStore;

    // @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IInterpreterStoreV1).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IInterpreterStoreV1
    function set(StateNamespace namespace, uint256[] calldata kvs) external {
        /// This would be picked up by an out of bounds index below, but it's
        /// nice to have a more specific error message.
        if (kvs.length % 2 != 0) {
            revert RainterpreterStoreOddSetLength(kvs.length);
        }
        unchecked {
            FullyQualifiedNamespace fullyQualifiedNamespace = namespace.qualifyNamespace(msg.sender);
            for (uint256 i = 0; i < kvs.length; i += 2) {
                sStore[fullyQualifiedNamespace][kvs[i]] = kvs[i + 1];
            }
        }
    }

    /// @inheritdoc IInterpreterStoreV1
    function get(FullyQualifiedNamespace namespace, uint256 key) external view returns (uint256) {
        return sStore[namespace][key];
    }
}
