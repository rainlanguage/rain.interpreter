// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {RainterpreterStore} from "src/concrete/RainterpreterStore.sol";
import {StateNamespace} from "rain.interpreter.interface/lib/ns/LibNamespace.sol";

/// @title RainterpreterStoreSetEmptyArrayTest
/// @notice A50-3: Test that `set()` with an empty (zero-length) `kvs` array
/// succeeds without reverting.
contract RainterpreterStoreSetEmptyArrayTest is Test {
    /// @notice set() with a zero-length kvs array must not revert.
    function testSetEmptyArray() external {
        RainterpreterStore store = new RainterpreterStore();
        StateNamespace namespace = StateNamespace.wrap(1);

        bytes32[] memory kvs = new bytes32[](0);
        store.set(namespace, kvs);
    }

    /// @notice set() with a zero-length kvs array should not emit any Set
    /// events.
    function testSetEmptyArrayNoEvents() external {
        RainterpreterStore store = new RainterpreterStore();
        StateNamespace namespace = StateNamespace.wrap(1);

        bytes32[] memory kvs = new bytes32[](0);

        vm.recordLogs();
        store.set(namespace, kvs);

        assertEq(vm.getRecordedLogs().length, 0, "empty set should emit no events");
    }

    /// @notice Fuzz variant: set() with empty array and any namespace must not
    /// revert.
    /// forge-config: default.fuzz.runs = 100
    function testSetEmptyArrayFuzz(StateNamespace namespace) external {
        RainterpreterStore store = new RainterpreterStore();
        bytes32[] memory kvs = new bytes32[](0);
        store.set(namespace, kvs);
    }
}
