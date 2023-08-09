// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "rain.solmem/lib/LibPointer.sol";
import "src/lib/integrity/deprecated/LibIntegrityCheck.sol";

/// @title LibIntegrityCheckApplyFnTest
/// Tests all the variations of applyFn in the integrity check.
contract LibIntegrityCheckApplyFnTest is Test {
    using LibPointer for Pointer;
    using LibIntegrityCheck for IntegrityCheckState;
    using LibStackPointer for Pointer;

    /// Empty function that takes one input and returns one output.
    function i1o1(uint256) internal view returns (uint256) {}

    /// Empty function that takes one input and returns one output, with operand.
    function i1o1Operand(Operand, uint256) internal view returns (uint256) {}

    /// Empty function that takes two inputs and returns zero outputs.
    function i2o0(uint256, uint256) internal view {}

    /// Empty function that takes two inputs and returns one output.
    function i2o1(uint256, uint256) internal view returns (uint256) {}

    /// Empty function that takes two inputs and returns one output, with
    /// operand.
    function i2o1Operand(Operand, uint256, uint256) internal view returns (uint256) {}

    /// Empty function that takes three inputs and returns one output.
    function i3o1(uint256, uint256, uint256) internal view returns (uint256) {}

    /// Empty function that takes four inputs and returns one output.
    function i4o1(uint256, uint256, uint256, uint256) internal view returns (uint256) {}

    /// Empty function that takes a dynamic array of inputs and returns one
    /// output.
    function iDo1(uint256[] memory) internal view returns (uint256) {}

    /// Empty function that takes 2 inputs, a dynamic array of inputs, and
    /// returns one output.
    function i2Do1(uint256, uint256, uint256[] memory) internal view returns (uint256) {}

    /// Empty function that takes 3 inputs, a dynamic array of inputs, and
    /// returns one output.
    function i3Do1(uint256, uint256, uint256, uint256[] memory) internal view returns (uint256) {}

    /// Empty function that takes one input, 2 dynamic arrays of inputs, and
    /// returns a dynamic array of outputs.
    function i1DDoD(uint256, uint256[] memory, uint256[] memory) internal view returns (uint256[] memory) {}

    /// Calling applyFn over i1o1 should first pop one word off the stack, then
    /// push one word back on. For this test, we assume that the stack is at
    /// least one word deep which means there is no transient underflow. In this
    /// case the net result is that the stack top is unchanged.
    function testIntegrityCheckApplyFni1o1(Pointer stackTop) external {
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop), Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(2)), type(uint256).max
            )
        );
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.syncStackMaxTop(stackTop);
        Pointer stackTopAfter = state.applyFn(stackTop, i1o1);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(INITIAL_STACK_BOTTOM));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Calling applyFn over i1o1 should first pop one word off the stack, then
    /// push one word back on. If the stack is zero words deep, relative to the
    /// highwater, then the inital pop will underflow the stack.
    function testIntegrityCheckApplyFni1o1Underflow(Pointer stackTop, Pointer highwater) external {
        // Avoid numeric underflow of the virtual stack space.
        highwater = Pointer.wrap(bound(Pointer.unwrap(highwater), 0x40, type(uint256).max - 0x20));
        vm.assume(Pointer.unwrap(highwater) % 0x20 == 0);
        // Ensure the stack top underflows the highwater when popping one word.
        stackTop = Pointer.wrap(bound(Pointer.unwrap(stackTop), 0x40, Pointer.unwrap(highwater.unsafeAddWord())));
        vm.assume(Pointer.unwrap(stackTop) % 0x20 == 0);
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.stackHighwater = highwater;
        state.syncStackMaxTop(stackTop);
        vm.expectRevert(
            abi.encodeWithSelector(
                StackPopUnderflow.selector,
                state.stackBottom.toIndexSigned(state.stackHighwater),
                state.stackBottom.toIndexSigned(stackTop.unsafeSubWords(1))
            )
        );
        Pointer stackTopAfter = state.applyFn(stackTop, i1o1);
        (stackTopAfter);
    }

    /// Calling applyFn over i2o0 should first pop two words off the stack, then
    /// push zero words back on. For this test, we assume that the stack is at
    /// least two words deep which means there is no transient underflow. In this
    /// case the net result is that the stack top is decremented by two words.
    function testIntegrityCheckApplyFni2o0(Pointer stackTop) external {
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop), Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(3)), type(uint256).max
            )
        );
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.syncStackMaxTop(stackTop);
        Pointer stackTopAfter = state.applyFn(stackTop, i2o0);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeSubWords(2)));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(INITIAL_STACK_BOTTOM));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Calling applyFn over i2o0 should first pop two words off the stack, then
    /// push zero words back on. If the stack is zero or one words deep, relative
    /// to the highwater, then the inital pop will underflow the stack.
    function testIntegrityCheckApplyFni2o0Underflow(Pointer stackTop, Pointer highwater) external {
        // Avoid numeric underflow of the virtual stack space.
        highwater = Pointer.wrap(bound(Pointer.unwrap(highwater), 0x40, type(uint256).max - 0x40));
        vm.assume(Pointer.unwrap(highwater) % 0x20 == 0);
        // Ensure the stack top underflows the highwater when popping two words.
        stackTop = Pointer.wrap(bound(Pointer.unwrap(stackTop), 0x40, Pointer.unwrap(highwater.unsafeAddWords(2))));
        vm.assume(Pointer.unwrap(stackTop) % 0x20 == 0);
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.stackHighwater = highwater;
        state.syncStackMaxTop(stackTop);
        vm.expectRevert(
            abi.encodeWithSelector(
                StackPopUnderflow.selector,
                state.stackBottom.toIndexSigned(state.stackHighwater),
                state.stackBottom.toIndexSigned(stackTop.unsafeSubWords(2))
            )
        );
        Pointer stackTopAfter = state.applyFn(stackTop, i2o0);
        (stackTopAfter);
    }

    /// Calling applyFn over i2o1 should first pop two words off the stack, then
    /// push one word back on. For this test, we assume that the stack is at
    /// least two words deep which means there is no transient underflow. In this
    /// case the net result is that the stack top is decremented by one word.
    function testIntegrityCheckApplyFni2o1(Pointer stackTop) external {
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop), Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(3)), type(uint256).max
            )
        );
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.syncStackMaxTop(stackTop);
        Pointer stackTopAfter = state.applyFn(stackTop, i2o1);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeSubWords(1)));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(INITIAL_STACK_BOTTOM));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Calling applyFn over i2o1 should first pop two words off the stack, then
    /// push one word back on. If the stack is zero or one words deep, relative
    /// to the highwater, then the inital pop will underflow the stack.
    function testIntegrityCheckApplyFni2o1Underflow(Pointer stackTop, Pointer highwater) external {
        // Avoid numeric underflow of the virtual stack space.
        highwater = Pointer.wrap(bound(Pointer.unwrap(highwater), 0x40, type(uint256).max - 0x40));
        vm.assume(Pointer.unwrap(highwater) % 0x20 == 0);
        // Ensure the stack top underflows the highwater when popping two words.
        stackTop = Pointer.wrap(bound(Pointer.unwrap(stackTop), 0x40, Pointer.unwrap(highwater.unsafeAddWords(2))));
        vm.assume(Pointer.unwrap(stackTop) % 0x20 == 0);
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.syncStackMaxTop(stackTop);
        state.stackHighwater = highwater;
        vm.expectRevert(
            abi.encodeWithSelector(
                StackPopUnderflow.selector,
                state.stackBottom.toIndexSigned(state.stackHighwater),
                state.stackBottom.toIndexSigned(stackTop.unsafeSubWords(2))
            )
        );
        Pointer stackTopAfter = state.applyFn(stackTop, i2o1);
        (stackTopAfter);
    }

    /// Calling applyFnN over i2o1 should be equivalent to calling applyFn n - 1
    /// times over i2o1 for n > 1.
    function testIntegrityCheckApplyFnNi2o1(Pointer stackTop, uint8 n) external {
        vm.assume(n > 1);
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop),
                Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(uint256(n) + 1)),
                type(uint256).max
            )
        );
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.syncStackMaxTop(stackTop);
        Pointer stackTopAfter = state.applyFnN(stackTop, i2o1, uint256(n));

        IntegrityCheckState memory referenceState =
            LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        referenceState.syncStackMaxTop(stackTop);
        Pointer referenceStackTopAfter = stackTop;
        for (uint8 i = 0; i < n - 1; i++) {
            referenceStackTopAfter = referenceState.applyFn(referenceStackTopAfter, i2o1);
        }

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(referenceStackTopAfter));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(referenceState.stackBottom));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(referenceState.stackMaxTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(referenceState.stackHighwater));
    }

    /// Calling applyFnN over i2o1 should behave as identity for n = 1.
    function testIntegrityCheckApplyFnN1i2o1(Pointer stackTop) external {
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop), Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(2)), type(uint256).max
            )
        );
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.syncStackMaxTop(stackTop);
        Pointer stackTopAfter = state.applyFnN(stackTop, i2o1, 1);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(INITIAL_STACK_BOTTOM));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Calling applyFnN over i2o1 should behave as a falsey push for n = 0.
    function testIntegrityCheckApplyFnN0i2o1(Pointer stackTop) external {
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop), Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(1)), type(uint256).max
            )
        );
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.syncStackMaxTop(stackTop);
        Pointer stackTopAfter = state.applyFnN(stackTop, i2o1, 0);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(INITIAL_STACK_BOTTOM));
        assertTrue(Pointer.unwrap(state.stackMaxTop) >= Pointer.unwrap(stackTopAfter));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Calling applyFnN over i3o1 should first pop three words off the stack,
    /// then push one word back on. For this test, we assume that the stack is at
    /// least three words deep which means there is no transient underflow. In
    /// this case the net result is that the stack top is decremented by two
    /// words.
    function testIntegrityCheckApplyFni3o1(Pointer stackTop) external {
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop), Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(4)), type(uint256).max
            )
        );
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.syncStackMaxTop(stackTop);
        Pointer stackTopAfter = state.applyFn(stackTop, i3o1);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeSubWords(2)));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(INITIAL_STACK_BOTTOM));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Calling applyFn over i3o1 should first pop three words off the stack,
    /// then push one word back on. If the stack is zero, one, or two words deep,
    /// relative to the highwater, then the inital pop will underflow the stack.
    function testIntegrityCheckApplyFni3o1Underflow(Pointer stackTop, Pointer highwater) external {
        highwater = Pointer.wrap(bound(Pointer.unwrap(highwater), 0x60, type(uint256).max - 0x60));
        vm.assume(Pointer.unwrap(highwater) % 0x20 == 0);
        stackTop = Pointer.wrap(bound(Pointer.unwrap(stackTop), 0x60, Pointer.unwrap(highwater.unsafeAddWords(3))));
        vm.assume(Pointer.unwrap(stackTop) % 0x20 == 0);
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.stackHighwater = highwater;
        state.syncStackMaxTop(stackTop);
        vm.expectRevert(
            abi.encodeWithSelector(
                StackPopUnderflow.selector,
                state.stackBottom.toIndexSigned(state.stackHighwater),
                state.stackBottom.toIndexSigned(stackTop.unsafeSubWords(3))
            )
        );
        Pointer stackTopAfter = state.applyFn(stackTop, i3o1);
        (stackTopAfter);
    }

    /// Calling applyFn over i4o1 should first pop four words off the stack,
    /// then push one word back on. For this test, we assume that the stack is at
    /// least four words deep which means there is no transient underflow. In
    /// this case the net result is that the stack top is decremented by three
    /// words.
    function testIntegrityCheckApplyFni4o1(Pointer stackTop) external {
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop), Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(5)), type(uint256).max
            )
        );
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.syncStackMaxTop(stackTop);
        Pointer stackTopAfter = state.applyFn(stackTop, i4o1);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeSubWords(3)));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(INITIAL_STACK_BOTTOM));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Calling applyFn over i4o1 should first pop four words off the stack,
    /// then push one word back on. If the stack is zero, one, two, or three
    /// words deep, relative to the highwater, then the inital pop will underflow
    /// the stack.
    function testIntegrityCheckApplyFni4o1Underflow(Pointer stackTop, Pointer highwater) external {
        highwater = Pointer.wrap(bound(Pointer.unwrap(highwater), 0x80, type(uint256).max - 0x80));
        vm.assume(Pointer.unwrap(highwater) % 0x20 == 0);
        stackTop = Pointer.wrap(bound(Pointer.unwrap(stackTop), 0x80, Pointer.unwrap(highwater.unsafeAddWords(4))));
        vm.assume(Pointer.unwrap(stackTop) % 0x20 == 0);
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.stackHighwater = highwater;
        state.syncStackMaxTop(stackTop);
        vm.expectRevert(
            abi.encodeWithSelector(
                StackPopUnderflow.selector,
                state.stackBottom.toIndexSigned(state.stackHighwater),
                state.stackBottom.toIndexSigned(stackTop.unsafeSubWords(4))
            )
        );
        Pointer stackTopAfter = state.applyFn(stackTop, i4o1);
        (stackTopAfter);
    }

    /// Calling applyFn over i1o1Operand should first pop one word off the stack,
    /// then push one word back on. For this test, we assume that the stack is at
    /// least one word deep which means there is no transient underflow. In this
    /// case the net result is that the stack top is unchanged.
    function testIntegrityCheckApplyFni1o1Operand(Pointer stackTop) external {
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop), Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(2)), type(uint256).max
            )
        );
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.syncStackMaxTop(stackTop);
        Pointer stackTopAfter = state.applyFn(stackTop, i1o1Operand);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(INITIAL_STACK_BOTTOM));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Calling applyFn over i1o1Operand should first pop one word off the stack,
    /// then push one word back on. If the stack is zero words deep, relative to
    /// the highwater, then the inital pop will underflow the stack.
    function testIntegrityCheckApplyFni1o1OperandUnderflow(Pointer stackTop, Pointer highwater) external {
        highwater = Pointer.wrap(bound(Pointer.unwrap(highwater), 0x40, type(uint256).max - 0x40));
        vm.assume(Pointer.unwrap(highwater) % 0x20 == 0);
        stackTop = Pointer.wrap(bound(Pointer.unwrap(stackTop), 0x40, Pointer.unwrap(highwater.unsafeAddWord())));
        vm.assume(Pointer.unwrap(stackTop) % 0x20 == 0);
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.stackHighwater = highwater;
        state.syncStackMaxTop(stackTop);
        vm.expectRevert(
            abi.encodeWithSelector(
                StackPopUnderflow.selector,
                state.stackBottom.toIndexSigned(state.stackHighwater),
                state.stackBottom.toIndexSigned(stackTop.unsafeSubWords(1))
            )
        );
        Pointer stackTopAfter = state.applyFn(stackTop, i1o1Operand);
        (stackTopAfter);
    }

    /// Calling applyFn over i2o1Operand should first pop two words off the stack,
    /// then push one word back on. For this test, we assume that the stack is at
    /// least two words deep which means there is no transient underflow. In this
    /// case the net result is that the stack top is decremented by one word.
    function testIntegrityCheckApplyFni2o1Operand(Pointer stackTop) external {
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop), Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(3)), type(uint256).max
            )
        );
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.syncStackMaxTop(stackTop);
        Pointer stackTopAfter = state.applyFn(stackTop, i2o1Operand);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeSubWords(1)));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(INITIAL_STACK_BOTTOM));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Calling applyFn over i2o1Operand should first pop two words off the stack,
    /// then push one word back on. If the stack is zero or one words deep,
    /// relative to the highwater, then the inital pop will underflow the stack.
    function testIntegrityCheckApplyFni2o1OperandUnderflow(Pointer stackTop, Pointer highwater) external {
        highwater = Pointer.wrap(bound(Pointer.unwrap(highwater), 0x40, type(uint256).max - 0x40));
        vm.assume(Pointer.unwrap(highwater) % 0x20 == 0);
        stackTop = Pointer.wrap(bound(Pointer.unwrap(stackTop), 0x40, Pointer.unwrap(highwater.unsafeAddWords(2))));
        vm.assume(Pointer.unwrap(stackTop) % 0x20 == 0);
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);

        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.stackHighwater = highwater;
        state.syncStackMaxTop(stackTop);
        vm.expectRevert(
            abi.encodeWithSelector(
                StackPopUnderflow.selector,
                state.stackBottom.toIndexSigned(state.stackHighwater),
                state.stackBottom.toIndexSigned(stackTop.unsafeSubWords(2))
            )
        );
        Pointer stackTopAfter = state.applyFn(stackTop, i2o1Operand);
        (stackTopAfter);
    }

    /// Calling applyFn over iDo1 should first pop a dynamic length of words off
    /// the stack, then push one word back on. For this test, we assume that the
    /// stack is at least as deep as the highwater plus the length of the dynamic
    /// array which means there is no transient underflow. In this case the net
    /// result is that the stack top is decremented by the length of the dynamic
    /// array - 1.
    function testIntegrityCheckApplyFniDo1(Pointer stackTop, uint256[] memory array) external {
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop),
                Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(array.length + 1)),
                type(uint256).max - 0x20
            )
        );
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.syncStackMaxTop(stackTop);
        Pointer stackTopAfter = state.applyFn(stackTop, iDo1, array.length);
        state.syncStackMaxTop(stackTopAfter);

        // Net result is decreased stack height.
        if (array.length > 0) {
            assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeSubWords(array.length - 1)));
            assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        }
        // Net result is increased stack height.
        else {
            assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
            assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTopAfter));
        }
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(INITIAL_STACK_BOTTOM));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Calling applyFn over iDo1 should first pop a dynamic length of words off
    /// the stack, then push one word back on. If the stack depth is less than
    /// the highwater plus the length of the dynamic array, then the inital pop
    /// will underflow the stack.
    function testIntegrityCheckApplyFniDo1Underflow(Pointer stackTop, Pointer highwater, uint256[] memory array)
        external
    {
        highwater = Pointer.wrap(
            bound(Pointer.unwrap(highwater), 0x20 * array.length, type(uint256).max - (array.length + 1) * 0x20)
        );
        vm.assume(Pointer.unwrap(highwater) % 0x20 == 0);
        stackTop = Pointer.wrap(
            bound(Pointer.unwrap(stackTop), 0x20 * array.length, Pointer.unwrap(highwater.unsafeAddWords(array.length)))
        );
        vm.assume(Pointer.unwrap(stackTop) % 0x20 == 0);
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.stackHighwater = highwater;
        state.syncStackMaxTop(stackTop);
        vm.expectRevert(
            abi.encodeWithSelector(
                StackPopUnderflow.selector,
                state.stackBottom.toIndexSigned(state.stackHighwater),
                state.stackBottom.toIndexSigned(stackTop.unsafeSubWords(array.length))
            )
        );
        Pointer stackTopAfter = state.applyFn(stackTop, iDo1, array.length);
        (stackTopAfter);
    }

    /// Calling applyFn over i2Do1 should first pop two words off the stack, then
    /// pop a dynamic length of words off the stack, then push one word back on.
    /// For this test, we assume that the stack is at least two words plus the
    /// length of the dynamic array deep which means there is no transient
    /// underflow. In this case the net result is that the stack top is
    /// decremented by the length of the dynamic array plus one.
    function testIntegrityCheckApplyFni2Do1(Pointer stackTop, uint256[] memory array) external {
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop),
                Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(array.length + 3)),
                type(uint256).max
            )
        );
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
            new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](
                    0
                );
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.syncStackMaxTop(stackTop);
        Pointer stackTopAfter = state.applyFn(stackTop, i2Do1, array.length);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeSubWords(array.length + 1)));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(INITIAL_STACK_BOTTOM));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Calling applyFn over i2Do1 should first pop two words off the stack, then
    /// pop a dynamic length of words off the stack, then push one word back on.
    /// If the stack depth is less than two words plus the length of the dynamic
    /// array, then the inital pop will underflow the stack.
    function testIntegrityCheckApplyFni2Do1Underflow(Pointer stackTop, Pointer highwater, uint256[] memory array)
        external
    {
        highwater = Pointer.wrap(
            bound(Pointer.unwrap(highwater), 0x20 * array.length + 0x40, type(uint256).max - (array.length + 2) * 0x20)
        );
        vm.assume(Pointer.unwrap(highwater) % 0x20 == 0);
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop),
                0x20 * array.length + 0x40,
                Pointer.unwrap(highwater.unsafeAddWords(array.length + 2))
            )
        );
        vm.assume(Pointer.unwrap(stackTop) % 0x20 == 0);
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers = new function(IntegrityCheckState memory, Operand, Pointer)
                    view
                    returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.stackHighwater = highwater;
        state.syncStackMaxTop(stackTop);
        vm.expectRevert(
            abi.encodeWithSelector(
                StackPopUnderflow.selector,
                state.stackBottom.toIndexSigned(state.stackHighwater),
                state.stackBottom.toIndexSigned(stackTop.unsafeSubWords(array.length + 2))
            )
        );
        Pointer stackTopAfter = state.applyFn(stackTop, i2Do1, array.length);
        (stackTopAfter);
    }

    /// Calling applyFn over i3Do1 should first pop three words off the stack,
    /// then pop a dynamic length of words off the stack, then push one word back
    /// on. For this test, we assume that the stack is at least three words plus
    /// the length of the dynamic array deep which means there is no transient
    /// underflow. In this case the net result is that the stack top is
    /// decremented by the length of the dynamic array plus two.
    function testIntegrityCheckApplyFni3Do1(Pointer stackTop, uint256[] memory array) public {
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop),
                Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(array.length + 4)),
                type(uint256).max
            )
        );
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers = new function(
                    IntegrityCheckState memory,
                    Operand,
                    Pointer
                ) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.syncStackMaxTop(stackTop);
        Pointer stackTopAfter = state.applyFn(stackTop, i3Do1, array.length);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeSubWords(array.length + 2)));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(INITIAL_STACK_BOTTOM));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Calling applyFn over i3Do1 should first pop three words off the stack,
    /// then pop a dynamic length of words off the stack, then push one word back
    /// on. If the stack depth is less than three words plus the length of the
    /// dynamic array, then the inital pop will underflow the stack.
    function testIntegrityCheckApplyFni3Do1Underflow(Pointer stackTop, Pointer highwater, uint256[] memory array)
        external
    {
        highwater = Pointer.wrap(
            bound(Pointer.unwrap(highwater), 0x20 * array.length + 0x60, type(uint256).max - (array.length + 3) * 0x20)
        );
        vm.assume(Pointer.unwrap(highwater) % 0x20 == 0);
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop),
                0x20 * array.length + 0x60,
                Pointer.unwrap(highwater.unsafeAddWords(array.length + 3))
            )
        );
        vm.assume(Pointer.unwrap(stackTop) % 0x20 == 0);
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers = new function(
                    IntegrityCheckState memory,
                    Operand,
                    Pointer
                ) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.stackHighwater = highwater;
        state.syncStackMaxTop(stackTop);
        vm.expectRevert(
            abi.encodeWithSelector(
                StackPopUnderflow.selector,
                state.stackBottom.toIndexSigned(state.stackHighwater),
                state.stackBottom.toIndexSigned(stackTop.unsafeSubWords(array.length + 3))
            )
        );
        Pointer stackTopAfter = state.applyFn(stackTop, i3Do1, array.length);
        (stackTopAfter);
    }

    /// Calling applyFn over i1DDoD should first pop twice the dynamic length
    /// of words plus one off the stack, then push the dynamic length of words
    /// back on. For this test, we assume that the stack is at least twice the
    /// length of the dynamic array plus one deep which means there is no
    /// transient underflow. In this case the net result is that the stack top is
    /// decremented by the length of the dynamic array plus one.
    function testIntegrityCheckApplyFni1DDoD(Pointer stackTop, uint256[] memory array) external {
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop),
                Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(array.length * 2 + 2)),
                type(uint256).max
            )
        );
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers = new function(
                    IntegrityCheckState memory,
                    Operand,
                    Pointer
                ) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        state.syncStackMaxTop(stackTop);
        Pointer stackTopAfter = state.applyFn(stackTop, i1DDoD, array.length);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeSubWords(array.length + 1)));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(INITIAL_STACK_BOTTOM));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        if (array.length > 1) {
            assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(stackTopAfter.unsafeSubWord()));
        } else {
            assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
        }
    }

    /// Calling applyFn over i1DDoD should first pop twice the dynamic length
    /// of words plus one off the stack, then push the dynamic length of words
    /// back on. If the stack depth is less than twice the length of the dynamic
    /// array plus one, then the inital pop will underflow the stack.
    function testIntegrityCheckApplyFni1DDoDUnderflow(Pointer stackTop, Pointer highwater, uint256[] memory array)
        external
    {
        highwater = Pointer.wrap(
            bound(
                Pointer.unwrap(highwater),
                0x20 * array.length * 2 + 0x40,
                type(uint256).max - (array.length * 2 + 2) * 0x20
            )
        );
        vm.assume(Pointer.unwrap(highwater) % 0x20 == 0);
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop),
                0x20 * array.length * 2 + 0x40,
                Pointer.unwrap(highwater.unsafeAddWords(array.length * 2 + 1))
            )
        );
        vm.assume(Pointer.unwrap(stackTop) % 0x20 == 0);
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers = new function(
                    IntegrityCheckState memory,
                    Operand,
                    Pointer
                ) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);

        state.stackHighwater = highwater;
        state.syncStackMaxTop(stackTop);
        vm.expectRevert(
            abi.encodeWithSelector(
                StackPopUnderflow.selector,
                state.stackBottom.toIndexSigned(state.stackHighwater),
                state.stackBottom.toIndexSigned(stackTop.unsafeSubWords(array.length * 2 + 1))
            )
        );
        Pointer stackTopAfter = state.applyFn(stackTop, i1DDoD, array.length);
        (stackTopAfter);
    }
}
