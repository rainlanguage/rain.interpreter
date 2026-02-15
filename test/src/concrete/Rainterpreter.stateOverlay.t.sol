// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {
    RainterpreterExpressionDeployerDeploymentTest
} from "test/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";
import {StateNamespace} from "rain.interpreter.interface/interface/IInterpreterStoreV3.sol";
import {EvalV4, SourceIndexV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {LibNamespace} from "rain.interpreter.interface/lib/ns/LibNamespace.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";
import {OddSetLength} from "src/error/ErrStore.sol";

contract RainterpreterStateOverlayTest is RainterpreterExpressionDeployerDeploymentTest {
    /// Odd-length stateOverlay MUST revert with OddSetLength.
    function testStateOverlayOddLength(bytes32[] memory stateOverlay) external {
        vm.assume(stateOverlay.length % 2 != 0);

        bytes memory bytecode = I_DEPLOYER.parse2("_: 1;");

        vm.expectRevert(abi.encodeWithSelector(OddSetLength.selector, stateOverlay.length));
        I_INTERPRETER.eval4(
            EvalV4({
                store: I_STORE,
                namespace: LibNamespace.qualifyNamespace(StateNamespace.wrap(0), address(this)),
                bytecode: bytecode,
                sourceIndex: SourceIndexV2.wrap(0),
                context: new bytes32[][](0),
                inputs: new StackItem[](0),
                stateOverlay: stateOverlay
            })
        );
    }

    /// Show that state overlay can prewarm a get.
    function testStateOverlayGet() external view {
        bytes memory bytecode = I_DEPLOYER.parse2("_: get(9);");

        bytes32 k = Float.unwrap(LibDecimalFloat.packLossless(9, 0));
        bytes32 v = bytes32(uint256(42));
        bytes32[] memory stateOverlay = new bytes32[](2);
        stateOverlay[0] = k;
        stateOverlay[1] = v;

        (StackItem[] memory stack, bytes32[] memory kvs) = I_INTERPRETER.eval4(
            EvalV4({
                store: I_STORE,
                namespace: LibNamespace.qualifyNamespace(StateNamespace.wrap(0), address(this)),
                bytecode: bytecode,
                sourceIndex: SourceIndexV2.wrap(0),
                context: new bytes32[][](0),
                inputs: new StackItem[](0),
                stateOverlay: stateOverlay
            })
        );

        assertEq(stack.length, 1);
        assertEq(StackItem.unwrap(stack[0]), v);
        assertEq(kvs.length, 2);
        assertEq(kvs[0], k);
        assertEq(kvs[1], v);
    }

    /// Show that state overlay can be overridden by a set in the bytecode.
    function testStateOverlaySet() external view {
        bytes memory bytecode = I_DEPLOYER.parse2("_:get(9),:set(9 42),_:get(9);");

        bytes32 k = Float.unwrap(LibDecimalFloat.packLossless(9, 0));
        bytes32 v = Float.unwrap(LibDecimalFloat.packLossless(43, 0));
        bytes32[] memory stateOverlay = new bytes32[](2);
        stateOverlay[0] = k;
        stateOverlay[1] = v;

        (StackItem[] memory stack, bytes32[] memory kvs) = I_INTERPRETER.eval4(
            EvalV4({
                store: I_STORE,
                namespace: LibNamespace.qualifyNamespace(StateNamespace.wrap(0), address(this)),
                bytecode: bytecode,
                sourceIndex: SourceIndexV2.wrap(0),
                context: new bytes32[][](0),
                inputs: new StackItem[](0),
                stateOverlay: stateOverlay
            })
        );

        bytes32 setTo = Float.unwrap(LibDecimalFloat.packLossless(42, 0));

        assertEq(stack.length, 2);
        assertEq(StackItem.unwrap(stack[0]), setTo);
        assertEq(StackItem.unwrap(stack[1]), v);
        assertEq(kvs.length, 2);
        assertEq(kvs[0], k);
        assertEq(kvs[1], setTo);
    }
}
