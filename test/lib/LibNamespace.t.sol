// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

import "forge-std/Test.sol";

<<<<<<<< HEAD:test/lib/ns/LibNamespace.t.sol
import "src/lib/ns/LibNamespace.sol";
import "test/lib/ns/LibNamespaceSlow.sol";
========
import "./LibNamespaceSlow.sol";
import "src/lib/LibNamespace.sol";
>>>>>>>> 430eee5c5936112da2bdffd65d846224e8332055:test/lib/LibNamespace.t.sol

contract LibNamespaceTest is Test {
    function testQualifyNamespaceReferenceImplementation(StateNamespace stateNamespace) public {
        assertEq(
            FullyQualifiedNamespace.unwrap(LibNamespace.qualifyNamespace(stateNamespace)),
            FullyQualifiedNamespace.unwrap(LibNamespaceSlow.qualifyNamespaceSlow(stateNamespace))
        );
    }

    function testQualifyNamespaceGas0(StateNamespace stateNamespace) public view {
        LibNamespace.qualifyNamespace(stateNamespace);
    }

    function testQualifyNamespaceGasSlow0(StateNamespace stateNamespace) public view {
        LibNamespaceSlow.qualifyNamespaceSlow(stateNamespace);
    }
}
