// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "rain.solmem/lib/LibPointer.sol";
import "src/lib/integrity/LibIntegrityCheck.sol";

/// @title LibIntegrityCheckPushPopTest
/// Test the basic push and pop movements of the integrity check.
contract LibIntegrityCheckPushPopTest is Test {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;

    /// Test that building a new state works.
    function testIntegrityCheckNewState(bytes[] memory sources, uint256[] memory constants) external {
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(sources, constants, pointers);
        assertEq(state.constantsLength, constants.length);
        assertEq(keccak256(abi.encode(state.sources)), keccak256(abi.encode(sources)));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(INITIAL_STACK_BOTTOM));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(INITIAL_STACK_BOTTOM));
    }

    /// Test that syncing the stack max top is a noop when the stack pointer is
    /// below the current max top.
    function testIntegrityCheckSyncStackMaxTopNoop(Pointer stackMaxTop, Pointer stackTop) external {
        vm.assume(Pointer.unwrap(stackMaxTop) >= Pointer.unwrap(INITIAL_STACK_BOTTOM));
        vm.assume(Pointer.unwrap(stackTop) <= Pointer.unwrap(stackMaxTop));
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0)
        );
        state.stackMaxTop = stackMaxTop;

        Pointer a = state.stackMaxTop;
        LibIntegrityCheck.syncStackMaxTop(state, stackTop);
        Pointer b = state.stackMaxTop;
        assertEq(Pointer.unwrap(a), Pointer.unwrap(b));
    }

    /// Test that syncing the stack max top updates the stack max top when the
    /// stack pointer is above the current max top.
    function testIntegrityCheckSyncStackMaxTop(Pointer stackTop) external {
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0)
        );
        vm.assume(Pointer.unwrap(stackTop) > Pointer.unwrap(state.stackMaxTop));

        LibIntegrityCheck.syncStackMaxTop(state, stackTop);
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
    }

    /// Test that pushing a value updates the stack top and syncs the stack max.
    function testIntegrityCheckPush() external {
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0)
        );
        Pointer stackTop = state.stackBottom;

        Pointer stackTopAfter = LibIntegrityCheck.push(state, stackTop);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTopAfter));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Test that pushing a single value with the n push variant behaves exactly
    /// the same as the regular push.
    function testIntegrityCheckPushN() external {
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0)
        );
        Pointer stackTop = state.stackBottom;

        Pointer stackTopAfter = LibIntegrityCheck.push(state, stackTop, 1);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTopAfter));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// The n variant should gracefully handle a 0 push.
    function testIntegrityCheckPushNZero() external {
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0)
        );
        Pointer stackTop = state.stackBottom;

        Pointer stackTopAfter = LibIntegrityCheck.push(state, stackTop, 0);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// The n variant should allow pushing multiple values. In this case the
    /// highwater MUST also move.
    function testIntegrityCheckPushNMultiple(uint8 n) external {
        vm.assume(n > 1);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0)
        );
        Pointer stackTop = state.stackBottom;

        Pointer stackTopAfter = LibIntegrityCheck.push(state, stackTop, n);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWords(n)));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTopAfter));
        // Highwater points AT the immutable value, not PAST it.
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(stackTopAfter.unsafeSubWord()));
    }

    /// The "ignore highwater" variant of push should behave identically to the
    /// n variant for 0 values.
    function testIntegrityCheckPushIgnoreHighwaterZero() external {
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0)
        );
        Pointer stackTop = state.stackBottom;

        Pointer stackTopAfter = LibIntegrityCheck.pushIgnoreHighwater(state, stackTop, 0);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));

        IntegrityCheckState memory referenceState = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0)
        );
        Pointer stackTopAfterReference = LibIntegrityCheck.push(referenceState, stackTop, 0);
        assertEq(Pointer.unwrap(stackTopAfterReference), Pointer.unwrap(stackTopAfter));
        assertEq(Pointer.unwrap(referenceState.stackMaxTop), Pointer.unwrap(state.stackMaxTop));
        assertEq(Pointer.unwrap(referenceState.stackHighwater), Pointer.unwrap(state.stackHighwater));
    }

    /// The "ignore highwater" variant of push should behave identically to the
    /// n variant for 1 value.
    function testIntegrityCheckPushIgnoreHighwaterOne() external {
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0)
        );
        Pointer stackTop = state.stackBottom;

        Pointer stackTopAfter = LibIntegrityCheck.pushIgnoreHighwater(state, stackTop, 1);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTopAfter));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));

        IntegrityCheckState memory referenceState = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0)
        );
        Pointer stackTopAfterReference = LibIntegrityCheck.push(referenceState, stackTop, 1);
        assertEq(Pointer.unwrap(stackTopAfterReference), Pointer.unwrap(stackTopAfter));
        assertEq(Pointer.unwrap(referenceState.stackMaxTop), Pointer.unwrap(state.stackMaxTop));
        assertEq(Pointer.unwrap(referenceState.stackHighwater), Pointer.unwrap(state.stackHighwater));
    }

    /// The "ignore highwater" variant of push should NOT update the highwater
    /// when pushing multiple values.
    function testIntegrityCheckPushIgnoreHighwaterMultiple(uint8 n) external {
        vm.assume(n > 1);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0)
        );
        Pointer stackTop = state.stackBottom;

        Pointer stackTopAfter = LibIntegrityCheck.pushIgnoreHighwater(state, stackTop, n);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWords(n)));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTopAfter));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Test that the underflow check reverts when the stack pointer moves into
    /// the highwater as that would imply that the stack can be written over an
    /// immutable value.
    function testIntegrityCheckUnderflowHighwater(Pointer stackTop) external {
        stackTop = Pointer.wrap(bound(Pointer.unwrap(stackTop), 0, Pointer.unwrap(INITIAL_STACK_HIGHWATER)));
        vm.assume(Pointer.unwrap(stackTop) % 0x20 == 0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0)
        );

        // The error reports an index not a virtual stack pointer.
        vm.expectRevert(
            abi.encodeWithSelector(
                StackPopUnderflow.selector,
                state.stackBottom.toIndexSigned(state.stackHighwater),
                state.stackBottom.toIndexSigned(stackTop)
            )
        );
        LibIntegrityCheck.popUnderflowCheck(state, stackTop);
    }

    /// Test that the underflow check DOES NOT revert when the stack pointer
    /// is above the highwater.
    function testIntegrityCheckUnderflowNoHighwater(Pointer stackTop) external pure {
        vm.assume(Pointer.unwrap(stackTop) > Pointer.unwrap(INITIAL_STACK_HIGHWATER));
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0)
        );

        LibIntegrityCheck.popUnderflowCheck(state, stackTop);
    }

    /// Test that popping a value without underflow simply subtracts 1 word.
    /// It does NOT update the stack max top or the highwater.
    function testIntegrityCheckPopNoUnderflow(Pointer stackTop) external {
        vm.assume(Pointer.unwrap(stackTop) > Pointer.unwrap(INITIAL_STACK_BOTTOM));
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0)
        );
        state.stackMaxTop = stackTop;

        Pointer stackTopAfter = LibIntegrityCheck.pop(state, stackTop);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeSubWord()));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Test that popping a value below the highwater reverts as per the
    /// underflow check.
    function testIntegrityCheckPopUnderflow(Pointer stackTop) external {
        // Avoid underflow of the virtual pointer. An underflow could never
        // happen in practice as the stack bottom starts somewhere near infinity.
        stackTop =
            Pointer.wrap(bound(Pointer.unwrap(stackTop), 0x40, Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWord())));
        vm.assume(Pointer.unwrap(stackTop) % 0x20 == 0);

        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer) view
                returns (Pointer)[](0)
        );

        // The error reports an index not a virtual stack pointer.
        vm.expectRevert(
            abi.encodeWithSelector(
                StackPopUnderflow.selector,
                state.stackBottom.toIndexSigned(state.stackHighwater),
                state.stackBottom.toIndexSigned(stackTop.unsafeSubWord())
            )
        );
        LibIntegrityCheck.pop(state, stackTop);
    }

    /// Check that the n variant of pop gracefully handles a 0 pop.
    function testIntegrityCheckPopNZero(Pointer stackTop) external {
        vm.assume(Pointer.unwrap(stackTop) > Pointer.unwrap(INITIAL_STACK_BOTTOM));
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer)
                view returns (Pointer)[](0)
        );
        state.stackMaxTop = stackTop;

        Pointer stackTopAfter = LibIntegrityCheck.pop(state, stackTop, 0);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }

    /// Check that the n variant of pop behaves identically to the regular pop
    /// for 1 pop.
    function testIntegrityCheckPopNOne(Pointer stackTop) external {
        vm.assume(Pointer.unwrap(stackTop) >= Pointer.unwrap(INITIAL_STACK_BOTTOM.unsafeAddWord()));
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer)
                view returns (Pointer)[](0)
        );
        state.stackMaxTop = stackTop;

        Pointer stackTopAfter = LibIntegrityCheck.pop(state, stackTop, 1);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeSubWord()));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));

        IntegrityCheckState memory referenceState = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer)
                view returns (Pointer)[](0)
        );
        referenceState.stackMaxTop = stackTop;
        Pointer stackTopAfterReference = LibIntegrityCheck.pop(state, stackTop);
        assertEq(Pointer.unwrap(stackTopAfterReference), Pointer.unwrap(stackTopAfter));
        assertEq(Pointer.unwrap(referenceState.stackMaxTop), Pointer.unwrap(state.stackMaxTop));
        assertEq(Pointer.unwrap(referenceState.stackHighwater), Pointer.unwrap(state.stackHighwater));
    }

    /// Check that the n variant of pop behaves identically to the regular pop
    /// for multiple pops.
    function testIntegrityCheckPopNMultiple(Pointer stackTop, uint8 n) external {
        vm.assume(Pointer.unwrap(stackTop) >= Pointer.unwrap(INITIAL_STACK_BOTTOM.unsafeAddWords(n)));
        vm.assume(n > 1);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer)
                view returns (Pointer)[](0)
        );
        state.stackMaxTop = stackTop;

        Pointer stackTopAfter = LibIntegrityCheck.pop(state, stackTop, n);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeSubWords(n)));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));

        IntegrityCheckState memory referenceState = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer)
                view returns (Pointer)[](0)
        );
        referenceState.stackMaxTop = stackTop;
        Pointer stackTopAfterReference = stackTop;
        for (uint8 i = 0; i < n; i++) {
            stackTopAfterReference = LibIntegrityCheck.pop(referenceState, stackTopAfterReference);
        }
        assertEq(Pointer.unwrap(stackTopAfterReference), Pointer.unwrap(stackTopAfter));
        assertEq(Pointer.unwrap(referenceState.stackMaxTop), Pointer.unwrap(state.stackMaxTop));
        assertEq(Pointer.unwrap(referenceState.stackHighwater), Pointer.unwrap(state.stackHighwater));
    }

    /// Check that the n variant of pop catches underflow just like the regular
    /// pop.
    function testIntegrityCheckPopNUnderflow(Pointer stackTop, uint8 n) external {
        stackTop = Pointer.wrap(
            bound(
                Pointer.unwrap(stackTop),
                Pointer.unwrap(Pointer.wrap(0).unsafeAddWords(n)),
                Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(n))
            )
        );
        vm.assume(n > 1);
        vm.assume(Pointer.unwrap(stackTop) % 0x20 == 0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(IntegrityCheckState memory, Operand, Pointer)
                view returns (Pointer)[](0)
        );

        // The error reports an index not a virtual stack pointer.
        vm.expectRevert(
            abi.encodeWithSelector(
                StackPopUnderflow.selector,
                state.stackBottom.toIndexSigned(state.stackHighwater),
                state.stackBottom.toIndexSigned(stackTop.unsafeSubWords(n))
            )
        );
        LibIntegrityCheck.pop(state, stackTop, n);
    }

    /// The "ignore highwater" variant of pop should behave identically to the
    /// n variant for 0 pops.
    function testIntegrityCheckPopIgnoreHighwaterZero(Pointer stackTop) external {
        vm.assume(Pointer.unwrap(stackTop) > Pointer.unwrap(INITIAL_STACK_BOTTOM));
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(
                IntegrityCheckState memory,
                Operand,
                Pointer
            ) view returns (Pointer)[](0)
        );
        state.stackMaxTop = stackTop;

        Pointer stackTopAfter = LibIntegrityCheck.popIgnoreHighwater(state, stackTop, 0);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));

        IntegrityCheckState memory referenceState = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(
                IntegrityCheckState memory,
                Operand,
                Pointer
            ) view returns (Pointer)[](0)
        );
        referenceState.stackMaxTop = stackTop;
        Pointer stackTopAfterReference = LibIntegrityCheck.pop(state, stackTop, 0);
        assertEq(Pointer.unwrap(stackTopAfterReference), Pointer.unwrap(stackTopAfter));
        assertEq(Pointer.unwrap(referenceState.stackMaxTop), Pointer.unwrap(state.stackMaxTop));
        assertEq(Pointer.unwrap(referenceState.stackHighwater), Pointer.unwrap(state.stackHighwater));
    }

    /// The "ignore highwater" variant of pop should behave identically to the
    /// n variant for 1 pop.
    function testIntegrityCheckPopIgnoreHighwaterOne(Pointer stackTop) external {
        vm.assume(Pointer.unwrap(stackTop) >= Pointer.unwrap(INITIAL_STACK_BOTTOM.unsafeAddWord()));
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(
                IntegrityCheckState memory,
                Operand,
                Pointer
            ) view returns (Pointer)[](0)
        );
        state.stackMaxTop = stackTop;

        Pointer stackTopAfter = LibIntegrityCheck.popIgnoreHighwater(state, stackTop, 1);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeSubWord()));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));

        IntegrityCheckState memory referenceState = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(
                IntegrityCheckState memory,
                Operand,
                Pointer
            ) view returns (Pointer)[](0)
        );
        referenceState.stackMaxTop = stackTop;
        Pointer stackTopAfterReference = LibIntegrityCheck.pop(referenceState, stackTop, 1);
        assertEq(Pointer.unwrap(stackTopAfterReference), Pointer.unwrap(stackTopAfter));
        assertEq(Pointer.unwrap(referenceState.stackMaxTop), Pointer.unwrap(state.stackMaxTop));
        assertEq(Pointer.unwrap(referenceState.stackHighwater), Pointer.unwrap(state.stackHighwater));
    }

    /// The "ignore highwater" variant of pop should NOT revert on underflow.
    function testIntegrityCheckPopIgnoreHighwaterUnderflow(Pointer stackTop, uint8 n) external {
        vm.assume(Pointer.unwrap(stackTop) >= Pointer.unwrap(Pointer.wrap(0).unsafeAddWords(n)));
        vm.assume(Pointer.unwrap(stackTop) < Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(n)));
        IntegrityCheckState memory state = LibIntegrityCheck.newState(
            new bytes[](0),
            new uint256[](0),
            new function(
                IntegrityCheckState memory,
                Operand,
                Pointer
            ) view returns (Pointer)[](0)
        );
        LibIntegrityCheck.syncStackMaxTop(state, stackTop);

        Pointer stackMaxTopBefore = state.stackMaxTop;
        Pointer stackTopAfter = LibIntegrityCheck.popIgnoreHighwater(state, stackTop, n);
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeSubWords(n)));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackMaxTopBefore));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    }
}
