// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {
    RainterpreterExpressionDeployerDeploymentTest
} from "test/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";
import {StateNamespace} from "rain.interpreter.interface/interface/IInterpreterStoreV3.sol";
import {EvalV4, SourceIndexV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {LibNamespace} from "rain.interpreter.interface/lib/ns/LibNamespace.sol";
import {InputsLengthMismatch} from "src/lib/eval/LibEval.sol";

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

}
