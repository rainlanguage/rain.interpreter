// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "./LibNamespaceSlow.sol";
import "../src/LibNamespace.sol";

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
