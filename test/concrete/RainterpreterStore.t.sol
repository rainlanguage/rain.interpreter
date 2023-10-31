// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";

import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {LibMemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";

import {LibNamespace} from "src/lib/ns/LibNamespace.sol";
import {RainterpreterStoreNPE2} from "src/concrete/RainterpreterStoreNPE2.sol";

/// @title RainterpreterStoreNPE2Test
/// Test suite for RainterpreterStoreNPE2.
contract RainterpreterStoreNPE2Test is Test {
    using LibNamespace for StateNamespace;
    using LibMemoryKV for MemoryKV;
    using Address for address;

    /// Store should introspect support for `IERC165` and `IInterpreterStoreV1`.
    /// It should not support any other interface.
    function testRainterpreterStoreIERC165(uint32 badInterfaceIdUint) external {
        // https://github.com/foundry-rs/foundry/issues/6115
        bytes4 badInterfaceId = bytes4(badInterfaceIdUint);

        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterStoreV1).interfaceId);

        RainterpreterStore store = new RainterpreterStore();
        assertTrue(store.supportsInterface(type(IERC165).interfaceId));
        assertTrue(store.supportsInterface(type(IInterpreterStoreV1).interfaceId));
        assertFalse(store.supportsInterface(badInterfaceId));
    }

    /// Ensure the store gives a decent error message when an odd number of
    /// arguments is passed to `set`.
    function testRainterpreterStoreSetOddLength(StateNamespace namespace, uint256[] memory kvs) external {
        vm.assume(kvs.length % 2 != 0);

        RainterpreterStore store = new RainterpreterStore();
        vm.expectRevert(abi.encodeWithSelector(RainterpreterStoreOddSetLength.selector, kvs.length));
        store.set(namespace, kvs);
    }

    /// Store should set and get values correctly.
    /// This test assumes no dupes.
    function testRainterpreterStoreSetGetNoDupesSingle(StateNamespace namespace, uint256[] memory kvs) external {
        // Truncate to even length.
        uint256 newLength = kvs.length - (kvs.length % 2);
        LibUint256Array.truncate(kvs, newLength);
        // Remove dupe keys by simply hashing the index with each key.
        for (uint256 i = 0; i < kvs.length; i += 2) {
            kvs[i] = uint256(keccak256(abi.encodePacked(i, kvs[i])));
        }
        RainterpreterStore store = new RainterpreterStore();
        store.set(namespace, kvs);

        for (uint256 i = 0; i < kvs.length; i += 2) {
            uint256 key = kvs[i];
            uint256 value = kvs[i + 1];
            assertEq(store.get(namespace.qualifyNamespace(address(this)), key), value);
        }
    }

    /// Represents a single `set` call to the store.
    /// @param namespace The namespace to set values in.
    /// @param kvs The key/value pairs to set.
    struct Set {
        StateNamespace namespace;
        uint256[] kvs;
    }

    /// Store should get and set values correctly across many namespaces.
    function testRainterpreterStoreSetGetNoDupesMany(Set[] memory sets) external {
        uint256 setsLength = sets.length >= 10 ? 10 : sets.length;
        uint256[] memory refs;
        assembly ("memory-safe") {
            refs := sets
        }
        LibUint256Array.truncate(refs, setsLength);

        for (uint256 i = 0; i < sets.length; i++) {
            // Truncate to even length.
            uint256 newLength = sets[i].kvs.length - (sets[i].kvs.length % 2);
            newLength = newLength >= 10 ? 10 : newLength;
            LibUint256Array.truncate(sets[i].kvs, newLength);
            // Remove dupe keys by simply hashing the index with each key.
            for (uint256 j = 0; j < sets[i].kvs.length; j += 2) {
                sets[i].kvs[j] = uint256(keccak256(abi.encodePacked(j, sets[i].kvs[j])));
            }
        }

        RainterpreterStore store = new RainterpreterStore();
        for (uint256 i = 0; i < sets.length; i++) {
            store.set(sets[i].namespace, sets[i].kvs);
            for (uint256 j = 0; j < sets[i].kvs.length; j += 2) {
                uint256 key = sets[i].kvs[j];
                uint256 value = sets[i].kvs[j + 1];
                assertEq(store.get(sets[i].namespace.qualifyNamespace(address(this)), key), value);
            }
        }
    }

    /// Fixed size version of `Set` that helps the fuzzer NOT blow up all
    /// available memory. Requires some cheeky assembly to get around the
    /// fixed size to dynamic size conversion.
    /// @param namespace The namespace to set values in.
    /// @param kvs The key/value pairs to set.
    struct Set11 {
        StateNamespace namespace;
        uint256[11] kvs;
    }
    /// Store should handle dupes correctly, where subsequent writes override
    /// previous writes to the same key (i.e. like a k/v store). The assumption
    /// is that the fuzzer will generate some dupes just randomly, so there's
    /// no special logic to make that happen.

    function testRainterpreterStoreSetGetDupes(Set11[] memory sets) external {
        vm.assume(sets.length < 20);

        RainterpreterStore store = new RainterpreterStore();
        for (uint256 i = 0; i < sets.length; i++) {
            uint256[11] memory kvsFixed = sets[i].kvs;
            uint256[] memory kvs;
            assembly ("memory-safe") {
                kvs := kvsFixed
                mstore(kvs, 10)
            }

            store.set(sets[i].namespace, kvs);
            MemoryKV kv = MemoryKV.wrap(0);

            for (uint256 j = 0; j < kvs.length; j += 2) {
                uint256 key = kvs[j];
                uint256 value = kvs[j + 1];
                kv = LibMemoryKV.set(kv, MemoryKVKey.wrap(key), MemoryKVVal.wrap(value));
            }

            uint256[] memory finalKVs = kv.toUint256Array();
            for (uint256 j = 0; j < finalKVs.length; j += 2) {
                uint256 key = finalKVs[j];
                uint256 value = finalKVs[j + 1];
                assertEq(store.get(sets[i].namespace.qualifyNamespace(address(this)), key), value);
            }
        }
    }
}
