// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {EvaluableV2} from "rain.interpreter.interface/interface/IInterpreterCallerV2.sol";
import {LibEvaluable} from "src/lib/caller/LibEvaluable.sol";
import {LibEvaluableSlow} from "./LibEvaluableSlow.sol";
import {IInterpreterStoreV1} from "rain.interpreter.interface/interface/IInterpreterStoreV1.sol";
import {IInterpreterV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV2.sol";

contract LibEvaluableTest is Test {
    using LibEvaluable for EvaluableV2;

    function testHashDifferent(EvaluableV2 memory a, EvaluableV2 memory b) public {
        vm.assume(a.interpreter != b.interpreter || a.store != b.store || a.expression != b.expression);
        assertTrue(a.hash() != b.hash());
    }

    function testHashSame(EvaluableV2 memory a) public {
        EvaluableV2 memory b = EvaluableV2(a.interpreter, a.store, a.expression);
        assertEq(a.hash(), b.hash());
    }

    function testHashSensitivity(EvaluableV2 memory a, EvaluableV2 memory b) public {
        vm.assume(a.interpreter != b.interpreter && a.store != b.store && a.expression != b.expression);

        EvaluableV2 memory c;

        assertTrue(a.hash() != b.hash());

        // Check interpreter changes hash.
        c = EvaluableV2(b.interpreter, a.store, a.expression);
        assertTrue(a.hash() != c.hash());

        // Check store changes hash.
        c = EvaluableV2(a.interpreter, b.store, a.expression);
        assertTrue(a.hash() != c.hash());

        // Check expression changes hash.
        c = EvaluableV2(a.interpreter, a.store, b.expression);
        assertTrue(a.hash() != c.hash());

        // Check match.
        c = EvaluableV2(a.interpreter, a.store, a.expression);
        assertEq(a.hash(), c.hash());

        // Check hash doesn't include extraneous data
        uint256 v0 = type(uint256).max;
        uint256 v1 = 0;
        EvaluableV2 memory d = EvaluableV2(IInterpreterV2(address(0)), IInterpreterStoreV1(address(0)), address(0));
        assembly ("memory-safe") {
            mstore(mload(0x40), v0)
        }
        bytes32 hash0 = d.hash();
        assembly ("memory-safe") {
            mstore(mload(0x40), v1)
        }
        bytes32 hash1 = d.hash();
        assertEq(hash0, hash1);
    }

    function testEvaluableHashGas0() public pure {
        EvaluableV2(IInterpreterV2(address(0)), IInterpreterStoreV1(address(0)), address(0)).hash();
    }

    function testEvaluableHashGasSlow0() public pure {
        LibEvaluableSlow.hashSlow(EvaluableV2(IInterpreterV2(address(0)), IInterpreterStoreV1(address(0)), address(0)));
    }

    function testEvaluableReferenceImplementation(EvaluableV2 memory evaluable) public {
        assertEq(LibEvaluable.hash(evaluable), LibEvaluableSlow.hashSlow(evaluable));
    }
}
