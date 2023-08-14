// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "rain.solmem/lib/LibPointer.sol";

import "src/lib/integrity/deprecated/LibIntegrityCheck.sol";
import "src/lib/parse/LibParse.sol";
import "src/lib/bytecode/LibBytecode.sol";

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

    function parseMeta() internal pure returns (bytes memory) {
        AuthoringMeta[] memory authoringMeta = new AuthoringMeta[](4);
        authoringMeta[0] = AuthoringMeta("revert", 0, "always reverts");
        authoringMeta[1] = AuthoringMeta("push", 0, "increase the stack top by one");
        authoringMeta[2] = AuthoringMeta("pop", 0, "decrease the stack top by one");
        authoringMeta[3] = AuthoringMeta("invalid", 0, "has no implementation in the integrity check, should revert");
        return LibParseMeta.buildParseMeta(authoringMeta, 2);
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
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(expression, parseMeta());
        bytes[] memory sources = LibBytecode.bytecodeToSources(bytecode);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(sources, constants, integrityPointers());
        return (state, state.stackBottom);
    }

    /// Integrity check doesn't support min outputs greater than
    /// `type(uint16).max` even though the interface is full `uint256`.
    /// This is a sane range for this implementation of an interpreter, but also
    /// it guards against overflowing signed ints when comparing against
    /// potentially negative stack heights internally.
    function testIntegrityEnsureIntegrityMinStackOutputsOverflow(uint256 minOutputs) public {
        minOutputs = bound(minOutputs, uint256(type(uint16).max) + 1, type(uint256).max);
        (IntegrityCheckState memory state, Pointer stackTop) = newState(":;");
        vm.expectRevert(abi.encodeWithSelector(UnsupportedStackHeight.selector, minOutputs));
        state.ensureIntegrity(SourceIndex.wrap(0), stackTop, minOutputs);
    }

    /// If an integrity check is encountered that is not implemented, the
    /// integrity check should revert.
    function testIntegrityEnsureIntegrityNotImplementedSingleSource() public {
        // Test an invalid op in isolation.
        (IntegrityCheckState memory state, Pointer stackTop) = newState("_:invalid();");
        vm.expectRevert(stdError.indexOOBError);
        state.ensureIntegrity(SourceIndex.wrap(0), stackTop, 0);

        // Test an invalid op in a series of otherwise valid ops.
        (IntegrityCheckState memory state2, Pointer stackTop2) = newState("_ _ _: push() invalid() pop();");
        vm.expectRevert(stdError.indexOOBError);
        state2.ensureIntegrity(SourceIndex.wrap(0), stackTop2, 0);
    }

    /// In a multisource situation, invalid ops will only trigger a revert if
    /// they are in the source that is being checked.
    function testIntegrityEnsureIntegrityNotImplementedMultiSource() public {
        // Source 0 will have an invalid op and revert.
        (IntegrityCheckState memory state, Pointer stackTop) = newState("_:invalid(); _: push();");
        vm.expectRevert(stdError.indexOOBError);
        Pointer stackTopAfter = state.ensureIntegrity(SourceIndex.wrap(0), stackTop, 0);

        // Source 1 will have valid ops so will not revert.
        (IntegrityCheckState memory state2, Pointer stackTop2) = newState("_: invalid(); _: push();");
        state2.ensureIntegrity(SourceIndex.wrap(1), stackTop2, 0);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
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
        (IntegrityCheckState memory state, Pointer stackTop) = newState("_: revert();");
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
    function testIntegrityEnsureIntegrityMinStack1Valid() public {
        (IntegrityCheckState memory state, Pointer stackTop) = newState("_: push();");
        Pointer stackTopAfter = state.ensureIntegrity(SourceIndex.wrap(0), stackTop, 1);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
    }

    /// An empty string has no sources so should error as there is nothing to
    /// check.
    function testIntegrityEnsureIntegrityEmpty(SourceIndex sourceIndex) public {
        (IntegrityCheckState memory state, Pointer stackTop) = newState("");
        vm.expectRevert(stdError.indexOOBError);
        state.ensureIntegrity(sourceIndex, stackTop, 0);
    }

    /// An empty source with no minimum stack should not error.
    function testIntegrityEnsureIntegrityMinStack0Empty() public {
        (IntegrityCheckState memory state, Pointer stackTop) = newState(":;");
        Pointer stackTopAfter = state.ensureIntegrity(SourceIndex.wrap(0), stackTop, 0);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop));
    }

    /// Reading past the number of sources that exist should error.
    /// Test reading past a single source.
    function testIntegrityEnsureIntegrityOOB(SourceIndex sourceIndex) public {
        vm.assume(SourceIndex.unwrap(sourceIndex) > 0);
        (IntegrityCheckState memory state, Pointer stackTop) = newState(":;");
        vm.expectRevert(stdError.indexOOBError);
        state.ensureIntegrity(sourceIndex, stackTop, 0);
    }

    /// Reading past the number of sources that exist should error.
    /// Test reading past multiple sources.
    function testIntegrityEnsureIntegrityOOBMulti(SourceIndex sourceIndex) public {
        vm.assume(SourceIndex.unwrap(sourceIndex) > 1);
        (IntegrityCheckState memory state, Pointer stackTop) = newState(":;:;");
        vm.expectRevert(stdError.indexOOBError);
        state.ensureIntegrity(sourceIndex, stackTop, 0);
    }

    /// If the min final stack is set higher than 0 the stack must be at least
    /// that high. This test checks that min stack of 1 will error if the stack
    /// is too small.
    function testIntegrityEnsureIntegrityMinStack1Underflow(uint8 minStackOutputs) public {
        vm.assume(minStackOutputs > 0);
        (IntegrityCheckState memory state, Pointer stackTop) = newState(":;");
        vm.expectRevert(abi.encodeWithSelector(MinFinalStack.selector, minStackOutputs, 0));
        state.ensureIntegrity(SourceIndex.wrap(0), stackTop, minStackOutputs);
    }

    /// If the min final stack is set higher than 0 the stack must be at least
    /// that high. This test checks that min stack of 2 can be satisfied.
    function testIntegrityEnsureIntegrityMinStack2(uint8 minStackOutputs) public {
        minStackOutputs = uint8(bound(minStackOutputs, 0, 2));
        (IntegrityCheckState memory state, Pointer stackTop) = newState("_ _: push() push();");
        Pointer stackTopAfter = state.ensureIntegrity(SourceIndex.wrap(0), stackTop, minStackOutputs);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord().unsafeAddWord()));
    }

    /// If the min final stack is set higher than 0 the stack must be at least
    /// that high. This test checks that min stack of 2 will error if the stack
    /// is too small.
    function testIntegrityEnsureIntegrityMinStack2Underflow(uint8 minStackOutputs) public {
        vm.assume(minStackOutputs > 1);
        (IntegrityCheckState memory state, Pointer stackTop) = newState("_: push();");
        vm.expectRevert(abi.encodeWithSelector(MinFinalStack.selector, minStackOutputs, 1));
        state.ensureIntegrity(SourceIndex.wrap(0), stackTop, minStackOutputs);
    }
}
