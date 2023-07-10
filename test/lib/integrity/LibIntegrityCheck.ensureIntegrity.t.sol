// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "rain.solmem/lib/LibPointer.sol";

import "src/lib/integrity/LibIntegrityCheck.sol";
import "src/lib/parse/LibParse.sol";

/// Thrown by `integrityReverts` to show that the integrity check can revert
/// with a custom error.
error BadIntegrity();

/// @title LibIntegrityCheckEnsureIntegrityTest
/// `ensureIntegrity` is the main entry point for the integrity check library as
/// it takes a fresh state, parsed indexes and runs the integrity check for each
/// index-opcode.
contract LibIntegrityCheckEnsureIntegrityTest is Test {
    using LibPointer for Pointer;
    using LibIntegrityCheck for IntegrityCheckState;

    function integrityReverts(IntegrityCheckState memory, Operand, Pointer) internal pure returns (Pointer) {
        revert BadIntegrity();
    }

    function integrityPushes(IntegrityCheckState memory state, Operand, Pointer stackTop)
        internal
        pure
        returns (Pointer)
    {
        return state.push(stackTop);
    }

    function integrityPops(IntegrityCheckState memory state, Operand, Pointer stackTop)
        internal
        pure
        returns (Pointer)
    {
        return state.pop(stackTop);
    }

    function parseMeta() internal pure returns (bytes memory meta) {
        bytes32[] memory words = new bytes32[](3);
        words[0] = "revert";
        words[1] = "push";
        words[2] = "pop";
        return LibParseMeta.buildMetaExpander(words, 2);
    }

    function integrityPointers()
        internal
        pure
        returns (function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[] memory pointers)
    {
        pointers = new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](3);
        pointers[0] = integrityReverts;
        pointers[1] = integrityPushes;
        pointers[2] = integrityPops;
    }

    /// Builds a new state for testing the integrity of a very simple DSL. The
    /// DSL only exists to help exercise the integrity check logic.
    /// @param expression The expression to parse.
    /// @return state The new integrity check state.
    /// @return stackTop The stack top pointer.
    function newState(bytes memory expression) internal pure returns (IntegrityCheckState memory, Pointer) {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(expression, parseMeta());
        IntegrityCheckState memory state = LibIntegrityCheck.newState(sources, constants, integrityPointers());
        return (state, state.stackBottom);
    }

    /// If the stack bottom is ever less than the initial stack bottom constant
    /// the integrity check should revert with MinStackBottom.
    function testIntegrityEnsureIntegrityMinStackBottom(
        Pointer stackBottom,
        SourceIndex sourceIndex,
        uint8 minStackOutputs
    ) public {
        stackBottom = Pointer.wrap(bound(Pointer.unwrap(stackBottom), 0, Pointer.unwrap(INITIAL_STACK_BOTTOM) - 1));
        IntegrityCheckState memory state =
            LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), integrityPointers());
        Pointer stackTop = state.stackBottom;
        state.stackBottom = stackBottom;
        vm.expectRevert(abi.encodeWithSelector(MinStackBottom.selector, state.stackBottom));
        state.ensureIntegrity(sourceIndex, stackTop, minStackOutputs);
    }

    /// If a reverting integrity check is encountered, the integrity check
    /// should revert overall.
    function testIntegrityEnsureIntegrityRevert() public {
        (IntegrityCheckState memory state, Pointer stackTop) = newState(": revert();");
        vm.expectRevert(abi.encodeWithSelector(BadIntegrity.selector));
        Pointer stackTopAfter = state.ensureIntegrity(SourceIndex.wrap(0), stackTop, 0);
        (stackTopAfter);
    }

    /// Reverting can happen in the middle of a series of integrity checks.
    function testIntegrityEnsureIntegrityRevertMiddle() public {
        (IntegrityCheckState memory state, Pointer stackTop) = newState("_: push(), _: revert(), _: push();");
        vm.expectRevert(abi.encodeWithSelector(BadIntegrity.selector));
        Pointer stackTopAfter = state.ensureIntegrity(SourceIndex.wrap(0), stackTop, 0);
        (stackTopAfter);
    }

    /// Pushing a value onto the stack should increase the stack top by one.
    function testIntegrityEnsureIntegrityPush() public {
        (IntegrityCheckState memory state, Pointer stackTop) = newState("_: push();");
        Pointer stackTopAfter = state.ensureIntegrity(SourceIndex.wrap(0), stackTop, 0);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
    }

    /// Pushing two values onto the stack should increase the stack top by two.
    function testIntegrityEnsureIntegrityPushPush() public {
        (IntegrityCheckState memory state, Pointer stackTop) = newState("_ _: push() push();");
        Pointer stackTopAfter = state.ensureIntegrity(SourceIndex.wrap(0), stackTop, 0);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord().unsafeAddWord()));
    }

    /// Pushing and then popping should have the same stack top as before.
    function testIntegrityEnsureIntegrityPop() public {
        (IntegrityCheckState memory state, Pointer stackTop) = newState("_ _: push() pop();");
        Pointer stackTopAfter = state.ensureIntegrity(SourceIndex.wrap(0), stackTop, 0);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop));
    }

    /// Popping without pushing will underflow the stack.
    function testIntegrityEnsureIntegrityPopUnderflow() public {
        (IntegrityCheckState memory state, Pointer stackTop) = newState("_: pop();");
        vm.expectRevert(abi.encodeWithSelector(StackPopUnderflow.selector, -1, -1));
        state.ensureIntegrity(SourceIndex.wrap(0), stackTop, 0);
    }

    /// A more complex series of pushes and pops should work.
    function testIntegrityEnsureIntegrityPushPop() public {
        (IntegrityCheckState memory state, Pointer stackTop) =
            newState("_ _: push(), _: push(), _:pop(), _: push(), _: pop(), _: pop();");
        Pointer stackTopAfter = state.ensureIntegrity(SourceIndex.wrap(0), stackTop, 0);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop));
    }

    /// If the min final stack is set higher than 0 the stack must be at least
    /// that high. This test checks that min stack of 1 can be satisfied.
    function testIntegrityEnsureIntegrityMinStack1() public {
        (IntegrityCheckState memory state, Pointer stackTop) = newState("_: push();");
        Pointer stackTopAfter = state.ensureIntegrity(SourceIndex.wrap(0), stackTop, 1);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
    }

    /// If the min final stack is set higher than 0 the stack must be at least
    /// that high. This test checks that min stack of 1 will error if the stack
    /// is too small.
    function testIntegrityEnsureIntegrityMinStack1Underflow() public {
        (IntegrityCheckState memory state, Pointer stackTop) = newState(":;");
        vm.expectRevert(abi.encodeWithSelector(MinFinalStack.selector, 1, 0));
        state.ensureIntegrity(SourceIndex.wrap(0), stackTop, 1);
    }

    /// If the min final stack is set higher than 0 the stack must be at least
    /// that high. This test checks that min stack of 2 can be satisfied.
    function testIntegrityEnsureIntegrityMinStack2() public {
        (IntegrityCheckState memory state, Pointer stackTop) = newState("_ _: push() push();");
        Pointer stackTopAfter = state.ensureIntegrity(SourceIndex.wrap(0), stackTop, 2);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord().unsafeAddWord()));
    }

    /// If the min final stack is set higher than 0 the stack must be at least
    /// that high. This test checks that min stack of 2 will error if the stack
    /// is too small.
    function testIntegrityEnsureIntegrityMinStack2Underflow() public {
        (IntegrityCheckState memory state, Pointer stackTop) = newState("_: push();");
        vm.expectRevert(abi.encodeWithSelector(MinFinalStack.selector, 2, 1));
        state.ensureIntegrity(SourceIndex.wrap(0), stackTop, 2);
    }
}
