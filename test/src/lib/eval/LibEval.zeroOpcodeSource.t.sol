// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {
    RainterpreterExpressionDeployerDeploymentTest
} from "test/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";
import {StateNamespace} from "rain.interpreter.interface/interface/IInterpreterStoreV3.sol";
import {EvalV4, SourceIndexV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {LibNamespace} from "rain.interpreter.interface/lib/ns/LibNamespace.sol";

contract LibEvalZeroOpcodeSourceTest is RainterpreterExpressionDeployerDeploymentTest {
    /// Evaluating a zero-opcode source (no inputs, no ops) must succeed
    /// and return no outputs.
    function testEvalZeroOpcodeSource() external view {
        bytes memory bytecode = I_DEPLOYER.parse2(":;");
        (StackItem[] memory stack,) = I_INTERPRETER.eval4(
            EvalV4({
                store: I_STORE,
                namespace: LibNamespace.qualifyNamespace(StateNamespace.wrap(0), address(this)),
                bytecode: bytecode,
                sourceIndex: SourceIndexV2.wrap(0),
                context: new bytes32[][](0),
                inputs: new StackItem[](0),
                stateOverlay: new bytes32[](0)
            })
        );
        assertEq(stack.length, 0);
    }

    /// Zero-opcode source with inputs — inputs appear as outputs with no
    /// ops executed.
    function testEvalZeroOpcodeSourceWithInputs(uint256 a, uint256 b) external view {
        bytes memory bytecode = I_DEPLOYER.parse2("x y:;");
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] = StackItem.wrap(bytes32(a));
        inputs[1] = StackItem.wrap(bytes32(b));
        (StackItem[] memory stack,) = I_INTERPRETER.eval4(
            EvalV4({
                store: I_STORE,
                namespace: LibNamespace.qualifyNamespace(StateNamespace.wrap(0), address(this)),
                bytecode: bytecode,
                sourceIndex: SourceIndexV2.wrap(0),
                context: new bytes32[][](0),
                inputs: inputs,
                stateOverlay: new bytes32[](0)
            })
        );
        assertEq(stack.length, 2);
        assertEq(StackItem.unwrap(stack[0]), bytes32(a));
        assertEq(StackItem.unwrap(stack[1]), bytes32(b));
    }
}
