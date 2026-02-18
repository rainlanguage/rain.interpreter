// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {
    RainterpreterExpressionDeployerDeploymentTest
} from "test/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";
import {StateNamespace} from "rain.interpreter.interface/interface/IInterpreterStoreV3.sol";
import {EvalV4, SourceIndexV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {LibNamespace} from "rain.interpreter.interface/lib/ns/LibNamespace.sol";
import {InputsLengthMismatch} from "src/error/ErrEval.sol";

contract RainterpreterEvalTest is RainterpreterExpressionDeployerDeploymentTest {
    /// Passing more inputs than the source expects MUST revert.
    function testInputsLengthMismatchTooMany(uint8 extraInputs) external {
        vm.assume(extraInputs > 0);

        // Source expects 0 inputs.
        bytes memory bytecode = I_DEPLOYER.parse2("_: 1;");

        StackItem[] memory inputs = new StackItem[](extraInputs);

        vm.expectRevert(abi.encodeWithSelector(InputsLengthMismatch.selector, 0, extraInputs));
        I_INTERPRETER.eval4(
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
    }

    /// Passing fewer inputs than the source expects MUST revert.
    function testInputsLengthMismatchTooFew(uint8 expectedInputs, uint8 actualInputs) external {
        expectedInputs = uint8(bound(expectedInputs, 1, 15));
        vm.assume(actualInputs < expectedInputs);

        // Build rainlang with expectedInputs LHS names: "a b c ... :;"
        bytes memory rainlang = new bytes(2 * uint256(expectedInputs) + 1);
        for (uint256 i = 0; i < expectedInputs; i++) {
            rainlang[i * 2] = bytes1(uint8(0x61) + uint8(i));
            if (i < uint256(expectedInputs) - 1) {
                rainlang[i * 2 + 1] = " ";
            }
        }
        rainlang[uint256(expectedInputs) * 2 - 1] = ":";
        rainlang[uint256(expectedInputs) * 2] = ";";

        bytes memory bytecode = I_DEPLOYER.parse2(rainlang);
        StackItem[] memory inputs = new StackItem[](actualInputs);

        vm.expectRevert(abi.encodeWithSelector(InputsLengthMismatch.selector, expectedInputs, actualInputs));
        I_INTERPRETER.eval4(
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
    }
}
