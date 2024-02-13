// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {LibNamespace, StateNamespace, FullyQualifiedNamespace} from "src/lib/ns/LibNamespace.sol";
import {LibNamespaceSlow} from "test/src/lib/ns/LibNamespaceSlow.sol";

contract LibNamespaceTest is Test {
    function testQualifyNamespaceReferenceImplementation(StateNamespace stateNamespace, address sender) public {
        assertEq(
            FullyQualifiedNamespace.unwrap(LibNamespace.qualifyNamespace(stateNamespace, sender)),
            FullyQualifiedNamespace.unwrap(LibNamespaceSlow.qualifyNamespaceSlow(stateNamespace, sender))
        );
    }

    function testQualifyNamespaceGas0(StateNamespace stateNamespace, address sender) public pure {
        LibNamespace.qualifyNamespace(stateNamespace, sender);
    }

    function testQualifyNamespaceGasSlow0(StateNamespace stateNamespace, address sender) public pure {
        LibNamespaceSlow.qualifyNamespaceSlow(stateNamespace, sender);
    }
}
