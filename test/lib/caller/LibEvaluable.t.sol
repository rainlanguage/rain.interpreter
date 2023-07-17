// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "../../../lib/forge-std/src/Test.sol";
import "../../../src/lib/caller/LibEvaluable.sol";
import "./LibEvaluableSlow.sol";

contract LibEvaluableTest is Test {
    using LibEvaluable for Evaluable;

    function testHashDifferent(Evaluable memory a, Evaluable memory b) public {
        vm.assume(a.interpreter != b.interpreter || a.store != b.store || a.expression != b.expression);
        assertTrue(a.hash() != b.hash());
    }

    function testHashSame(Evaluable memory a) public {
        Evaluable memory b = Evaluable(a.interpreter, a.store, a.expression);
        assertEq(a.hash(), b.hash());
    }

    function testHashSensitivity(Evaluable memory a, Evaluable memory b) public {
        vm.assume(a.interpreter != b.interpreter && a.store != b.store && a.expression != b.expression);

        Evaluable memory c;

        assertTrue(a.hash() != b.hash());

        // Check interpreter changes hash.
        c = Evaluable(b.interpreter, a.store, a.expression);
        assertTrue(a.hash() != c.hash());

        // Check store changes hash.
        c = Evaluable(a.interpreter, b.store, a.expression);
        assertTrue(a.hash() != c.hash());

        // Check expression changes hash.
        c = Evaluable(a.interpreter, a.store, b.expression);
        assertTrue(a.hash() != c.hash());

        // Check match.
        c = Evaluable(a.interpreter, a.store, a.expression);
        assertEq(a.hash(), c.hash());

        // Check hash doesn't include extraneous data
        uint256 v0 = type(uint256).max;
        uint256 v1 = 0;
        Evaluable memory d = Evaluable(IInterpreterV1(address(0)), IInterpreterStoreV1(address(0)), address(0));
        assembly {
            mstore(mload(0x40), v0)
        }
        bytes32 hash0 = d.hash();
        assembly {
            mstore(mload(0x40), v1)
        }
        bytes32 hash1 = d.hash();
        assertEq(hash0, hash1);
    }

    function testEvaluableHashGas0() public pure {
        Evaluable(IInterpreterV1(address(0)), IInterpreterStoreV1(address(0)), address(0)).hash();
    }

    function testEvaluableHashGasSlow0() public pure {
        LibEvaluableSlow.hashSlow(Evaluable(IInterpreterV1(address(0)), IInterpreterStoreV1(address(0)), address(0)));
    }

    function testEvaluableReferenceImplementation(Evaluable memory evaluable) public {
        assertEq(LibEvaluable.hash(evaluable), LibEvaluableSlow.hashSlow(evaluable));
    }
}
