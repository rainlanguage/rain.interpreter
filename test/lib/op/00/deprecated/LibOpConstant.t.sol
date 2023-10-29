// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";

import {RainterpreterExpressionDeployerNPDeploymentTest} from
    "test/util/abstract/RainterpreterExpressionDeployerNPDeploymentTest.sol";
import {LibInterpreterState} from "src/lib/state/deprecated/LibInterpreterState.sol";
import {Operand, IInterpreterV1, SourceIndex} from "src/interface/IInterpreterV1.sol";
import {IInterpreterStoreV1, StateNamespace} from "src/interface/IInterpreterStoreV1.sol";
import {LibBytecode} from "src/lib/bytecode/LibBytecode.sol";
import {SignedContextV1} from "src/interface/IInterpreterCallerV2.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";

import {InterpreterState} from "src/lib/state/deprecated/LibInterpreterState.sol";
import {
    IntegrityCheckState,
    LibIntegrityCheck,
    INITIAL_STACK_HIGHWATER
} from "src/lib/integrity/deprecated/LibIntegrityCheck.sol";
import {LibOpConstant} from "src/lib/op/00/deprecated/LibOpConstant.sol";
import {BadConstantRead} from "src/lib/op/00/deprecated/LibOpConstant.sol";

/// @title LibOpConstantTest
/// @notice Test the runtime and integrity time logic of LibOpConstant.
contract LibOpConstantTest is RainterpreterExpressionDeployerNPDeploymentTest {
    using LibUint256Array for uint256[];
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibInterpreterState for InterpreterState;

    /// Directly test the integrity logic of LibOpConstant. This tests the happy
    /// path where the operand points to a constant in the constants array.
    function testOpConstantIntegrity(Operand operand, uint256[] memory constants) external {
        vm.assume(constants.length > 0);
        function(IntegrityCheckState memory, Operand, Pointer)
            view
            returns (Pointer)[] memory integrityCheckers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](1);
        integrityCheckers[0] = LibOpConstant.integrity;

        operand = Operand.wrap(bound(Operand.unwrap(operand), 0, constants.length - 1));

        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), constants, integrityCheckers);
        Pointer stackTop = state.stackBottom;

        Pointer stackTopAfter = LibOpConstant.integrity(state, operand, stackTop);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTopAfter));
    }

    /// Directly test the integrity logic of LibOpConstant. This tests the case
    /// where the operand points past the end of the constants array, which MUST
    /// always error as an OOB read.
    function testOpConstantIntegrityOOBConstants(Operand operand, uint256[] memory constants) external {
        function(IntegrityCheckState memory, Operand, Pointer)
            view
            returns (Pointer)[] memory integrityCheckers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](1);
        integrityCheckers[0] = LibOpConstant.integrity;

        // Bound the operand at or past the constants array.
        operand = Operand.wrap(bound(Operand.unwrap(operand), constants.length, type(uint256).max));

        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), constants, integrityCheckers);
        Pointer stackTop = state.stackBottom;

        vm.expectRevert(abi.encodeWithSelector(BadConstantRead.selector, constants.length, Operand.unwrap(operand)));
        LibOpConstant.integrity(state, operand, stackTop);
    }

    /// Directly test the runtime logic of LibOpConstant. This tests that the
    /// opcode correctly pushes the constant onto the stack. This tests the
    /// happy path where the operand points to a constant in the constants array
    /// for a non-empty constants array.
    ///
    /// We rely on the deployer to force the integrity check to pass, so we don't
    /// run into the unhappy path where out of bounds constants reads occur.
    function testOpConstantRun(Operand operand, uint256 pre, uint256 post, uint256[] memory constants) external {
        InterpreterState memory state;
        vm.assume(constants.length > 0);
        state.constantsBottom = constants.dataPointer();

        operand = Operand.wrap(bound(Operand.unwrap(operand), 0, constants.length - 1));

        // Build a stack with two zeros on it. The first zero will be overridden
        // by the opcode. The second zero will be used to check that the opcode
        // doesn't modify the stack beyond the first element.
        state.stackBottom = LibPointer.allocatedMemoryPointer();
        Pointer stackTop = state.stackBottom.unsafePush(pre);
        Pointer end = stackTop.unsafePush(0).unsafePush(post);
        assembly ("memory-safe") {
            mstore(0x40, end)
        }
        // Constants don't modify the state.
        bytes32 stateFingerprintBefore = state.fingerprint();

        // Run the opcode.
        Pointer stackTopAfter = LibOpConstant.run(state, operand, stackTop);

        // Check we didn't modify state.
        assertEq(state.fingerprint(), stateFingerprintBefore);

        // The constant should be pushed onto the stack without modifying the
        // stack beyond the first element.
        assertEq(state.stackBottom.unsafeReadWord(), pre);
        assertEq(stackTop.unsafeReadWord(), constants[Operand.unwrap(operand)]);
        assertEq(stackTopAfter.unsafeReadWord(), post);
    }

    /// Test the eval of a constant opcode parsed from a string.
    function testOpConstantEvalE2E() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_ _: max-int-value() 1001e15;");

        assertEq(constants.length, 1);
        assertEq(constants[0], 1001e15);

        uint256[] memory minOuputs = new uint256[](1);
        minOuputs[0] = 2;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOuputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        assertEq(stack.length, 2);
        assertEq(stack[0], type(uint256).max);
        assertEq(stack[1], 1001e15);
        assertEq(kvs.length, 0);
    }
}
