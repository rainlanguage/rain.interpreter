// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import "../../../lib/rain.solmem/src/lib/LibPointer.sol";
import "../../../lib/rain.solmem/src/lib/LibStackPointer.sol";

import "../../interface/IExpressionDeployerV1.sol";
import "../../interface/IInterpreterV1.sol";

/// @dev The virtual stack pointers are never read or written so don't need to
/// point to a real location in memory. We only care that the stack never moves
/// below its starting point at the stack bottom. For the virtual stack used by
/// the integrity check we can start it in the middle of the `uint256` range and
/// achieve something analogous to signed integers with unsigned integer types.
Pointer constant INITIAL_STACK_BOTTOM = Pointer.wrap(0x20 ** 0x20);

/// @dev Highwater starts underneath stack bottom as it errors on an greater than
/// _or equal to_ check.
Pointer constant INITIAL_STACK_HIGHWATER = Pointer.wrap(Pointer.unwrap(INITIAL_STACK_BOTTOM) - 0x20);

/// It is a misconfiguration to set the initial stack bottom to zero or some
/// small value as this trivially exposes the integrity check to potential
/// underflow issues that are gas intensive to repeatedly guard against on every
/// pop. The initial stack bottom for an `IntegrityCheckState` should be
/// `INITIAL_STACK_BOTTOM` to safely avoid the need for underflow checks due to
/// pops and pushes.
/// @param stackBottom The stack bottom that was set and is invalid.
error MinStackBottom(Pointer stackBottom);

/// The virtual stack top has underflowed the stack highwater (or zero) during an
/// integrity check. The highwater will initially be the stack bottom but MAY
/// move higher due to certain operations such as placing multiple outputs on the
/// stack or copying from a stack position. The highwater prevents subsequent
/// popping of values that are considered immutable.
/// @param stackHighwaterIndex Index of the stack highwater at the moment of
/// underflow.
/// @param stackTopIndex Index of the stack top at the moment of underflow.
error StackPopUnderflow(int256 stackHighwaterIndex, int256 stackTopIndex);

/// The final stack produced by some source did not hit the minimum required for
/// its calling context.
/// @param minStackOutputs The required minimum stack height.
/// @param actualStackOutputs The final stack height after evaluating a source.
/// Will be less than the min stack outputs if this error is thrown. MAY be
/// negative if the stack underflowed.
error MinFinalStack(uint256 minStackOutputs, int256 actualStackOutputs);

/// Running an integrity check is a stateful operation. As well as the basic
/// configuration of what is being checked such as the sources and size of the
/// constants, the current and maximum stack height is being recomputed on every
/// checked opcode. The stack is virtual during the integrity check so whatever
/// the `Pointer` values are during the check, it's always undefined
/// behaviour to actually try to read/write to them.
///
/// @param sources All the sources of the expression are provided to the
/// integrity check as any entrypoint and non-entrypoint can `call` into some
/// other source at any time, provided the overall inputs and outputs to the
/// stack are valid.
/// @param constantsLength The integrity check assumes the existence of some
/// opcode that will read from a predefined list of constants. Technically this
/// opcode MAY NOT exist in some interpreter but it seems highly likely to be
/// included in most setups. The integrity check only needs the length of the
/// constants array to check for out of bounds reads, which allows runtime
/// behaviour to read without additional gas for OOB index checks.
/// @param stackBottom Pointer to the bottom of the virtual stack that the
/// integrity check uses to simulate a real eval.
/// @param stackHighwater Pointer to the highest point the virtual stack has
/// frozen into an immutable state. This is used to prevent writes to values
/// that should be read-only due to the Rainlang execution model.
/// @param stackMaxTop Pointer to the maximum height the virtual stack has
/// reached during the integrity check. The current virtual stack height will
/// be handled separately to the state during the check.
/// @param integrityFunctionPointers We pass an array of all the function
/// pointers to per-opcode integrity checks around with the state to facilitate
/// simple recursive integrity checking.
struct IntegrityCheckState {
    // Sources in zeroth position as we read from it in assembly without paying
    // gas to calculate offsets.
    bytes[] sources;
    uint256 constantsLength;
    Pointer stackBottom;
    Pointer stackHighwater;
    Pointer stackMaxTop;
    function(IntegrityCheckState memory, Operand, Pointer)
        view
        returns (Pointer)[] integrityFunctionPointers;
}

/// @title LibIntegrityCheck
/// @notice "Dry run" versions of the key logic from `LibStackPointer` that
/// allows us to simulate a virtual stack based on the Solidity type system
/// itself. The core loop of an integrity check is to dispatch an integrity-only
/// version of a runtime opcode that then uses `LibIntegrityCheck` to apply a
/// function that simulates a stack movement. The simulated stack movement will
/// move a pointer to memory in the same way as a real pop/push would at runtime
/// but without any associated logic or even allocating and writing data in
/// memory on the other side of the pointer. Every pop is checked for out of
/// bounds reads, even if it is an intermediate pop within the logic of a single
/// opcode. The _gross_ stack movement is just as important as the net movement.
/// For example, consider a simple ERC20 total supply read. The _net_ movement
/// of a total supply read is 0, it pops the token address then pushes the total
/// supply. However the _gross_ movement is first -1 then +1, so we have to guard
/// against the -1 underflowing while reading the token address _during_ the
/// simulated opcode dispatch. In general this can be subtle, complex and error
/// prone, which is why `LibIntegrityCheck` and `LibStackPointer` take function
/// signatures as arguments, so that the overloading mechanism in Solidity itself
/// enforces correct pop/push calculations for every opcode.
library LibIntegrityCheck {
    using LibIntegrityCheck for IntegrityCheckState;
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;

    /// Build a new integrity check state from sane defaults. The initialization
    /// of the stack bottom and highwater are important to avoid underflows
    /// during the integrity check.
    /// @param sources The sources of the expression to check.
    /// @param constants The constants of the expression to check.
    /// @param integrityFns The integrity check function pointers for each
    /// opcode.
    /// @return The new integrity check state.
    function newState(
        bytes[] memory sources,
        uint256[] memory constants,
        function(IntegrityCheckState memory, Operand, Pointer)
            view
            returns (Pointer)[] memory integrityFns
    ) internal pure returns (IntegrityCheckState memory) {
        return IntegrityCheckState(
            sources, constants.length, INITIAL_STACK_BOTTOM, INITIAL_STACK_HIGHWATER, INITIAL_STACK_BOTTOM, integrityFns
        );
    }

    /// If the given stack pointer is above the current state of the max stack
    /// top, the max stack top will be moved to the stack pointer.
    /// i.e. this works like `stackMaxTop = stackMaxTop.max(stackPointer)` but
    /// with the type unwrapping boilerplate included for convenience.
    /// @param integrityCheckState The state of the current integrity check
    /// including the current max stack top.
    /// @param stackPointer The stack pointer to compare and potentially swap
    /// the max stack top for.
    function syncStackMaxTop(IntegrityCheckState memory integrityCheckState, Pointer stackPointer) internal pure {
        if (Pointer.unwrap(stackPointer) > Pointer.unwrap(integrityCheckState.stackMaxTop)) {
            integrityCheckState.stackMaxTop = stackPointer;
        }
    }

    /// The main integrity check loop. Designed so that it can be called
    /// recursively by the dispatched integrity opcodes to support arbitrary
    /// nesting of sources and substacks, loops, etc.
    /// If ANY of the integrity checks for ANY opcode fails the entire integrity
    /// check will revert.
    /// @param integrityCheckState Current state of the integrity check passed
    /// by reference to allow for recursive/nested integrity checking.
    /// @param sourceIndex The source to check the integrity of which can be
    /// either an entrypoint or a non-entrypoint source if this is a recursive
    /// call to `ensureIntegrity`.
    /// @param stackTop The current top of the virtual stack as a pointer. This
    /// can be manipulated to create effective substacks/scoped/immutable
    /// runtime values by restricting how the `stackTop` can move at deploy
    /// time.
    /// @param minStackOutputs The minimum stack height required by the end of
    /// this integrity check. The caller MUST ensure that it sets this value high
    /// enough so that it can safely read enough values from the final stack
    /// without out of bounds reads. The external interface to the expression
    /// deployer accepts an array of minimum stack heights against entrypoints,
    /// but the internal checks can be recursive against non-entrypoints and each
    /// opcode such as `call` can build scoped stacks, etc. so here we just put
    /// defining the requirements back on the caller.
    function ensureIntegrity(
        IntegrityCheckState memory integrityCheckState,
        SourceIndex sourceIndex,
        Pointer stackTop,
        uint8 minStackOutputs
    ) internal view returns (Pointer) {
        unchecked {
            // It's generally more efficient to ensure the stack bottom has
            // plenty of headroom to make underflows from pops impossible rather
            // than guard every single pop against underflow.
            if (Pointer.unwrap(integrityCheckState.stackBottom) < Pointer.unwrap(INITIAL_STACK_BOTTOM)) {
                revert MinStackBottom(integrityCheckState.stackBottom);
            }
            uint256 cursor;
            uint256 end;
            // Guard against out of bounds reads of the sources array.
            bytes memory source = integrityCheckState.sources[SourceIndex.unwrap(sourceIndex)];
            assembly ("memory-safe") {
                cursor := source
                end := add(cursor, mload(cursor))
            }

            // Loop until complete.
            while (cursor < end) {
                uint256 opcode;
                Operand operand;
                cursor += 4;
                assembly ("memory-safe") {
                    let op := mload(cursor)
                    operand := and(op, 0xFFFF)
                    opcode := and(shr(16, op), 0xFFFF)
                }
                // We index into the function pointers here rather than using raw
                // assembly to ensure that any opcodes that we don't have a
                // pointer for will error as a standard Solidity OOB read.
                stackTop = integrityCheckState.integrityFunctionPointers[opcode](integrityCheckState, operand, stackTop);
            }
            int256 finalStackOutputs = integrityCheckState.stackBottom.toIndexSigned(stackTop);
            if (int256(uint256(minStackOutputs)) > finalStackOutputs) {
                revert MinFinalStack(minStackOutputs, finalStackOutputs);
            }
            return stackTop;
        }
    }

    /// Push a single virtual item onto the virtual stack.
    /// Simply moves the stack top up one and syncs the interpreter max stack
    /// height with it if needed.
    /// @param integrityCheckState The state of the current integrity check.
    /// @param stackTop The pointer to the virtual stack top for the current
    /// integrity check.
    /// @return The stack top after it has pushed an item.
    function push(IntegrityCheckState memory integrityCheckState, Pointer stackTop) internal pure returns (Pointer) {
        stackTop = stackTop.unsafeAddWord();
        integrityCheckState.syncStackMaxTop(stackTop);
        return stackTop;
    }

    /// Overloaded `push` to support `n` pushes in a single movement.
    /// `n` MAY be 0 and this is a virtual noop stack movement.
    /// @param integrityCheckState as per `push`.
    /// @param stackTop as per `push`.
    /// @param n The number of items to push to the virtual stack.
    function push(IntegrityCheckState memory integrityCheckState, Pointer stackTop, uint256 n)
        internal
        pure
        returns (Pointer)
    {
        stackTop = stackTop.unsafeAddWords(n);
        // Any time we push more than 1 item to the stack we move the highwater
        // to the last item, as nested multioutput is disallowed.
        if (n > 1) {
            Pointer lastItem = stackTop.unsafeSubWord();
            integrityCheckState.stackHighwater = Pointer.unwrap(integrityCheckState.stackHighwater)
                > Pointer.unwrap(lastItem) ? integrityCheckState.stackHighwater : lastItem;
        }
        integrityCheckState.syncStackMaxTop(stackTop);
        return stackTop;
    }

    /// As push for 0+ values. Does NOT move the highwater. This may be useful if
    /// the highwater is already calculated somehow by the caller. This is also
    /// dangerous if used incorrectly as it could allow uncaught underflows to
    /// creep in.
    /// @param integrityCheckState as per `push`.
    /// @param stackTop as per `push`.
    /// @param n The number of items to push to the virtual stack.
    function pushIgnoreHighwater(IntegrityCheckState memory integrityCheckState, Pointer stackTop, uint256 n)
        internal
        pure
        returns (Pointer)
    {
        stackTop = stackTop.unsafeAddWords(n);
        integrityCheckState.syncStackMaxTop(stackTop);
        return stackTop;
    }

    /// Ensures that pops have not underflowed the stack, i.e. that the stack
    /// top is not below the stack bottom. We set a large stack bottom that is
    /// impossible to underflow within gas limits with realistic pops so that
    /// we don't have to deal with a numeric underflow of the stack top.
    /// @param integrityCheckState As per `pop`.
    /// @param stackTop as per `pop`.
    function popUnderflowCheck(IntegrityCheckState memory integrityCheckState, Pointer stackTop) internal pure {
        if (Pointer.unwrap(stackTop) <= Pointer.unwrap(integrityCheckState.stackHighwater)) {
            revert StackPopUnderflow(
                integrityCheckState.stackBottom.toIndexSigned(integrityCheckState.stackHighwater),
                integrityCheckState.stackBottom.toIndexSigned(stackTop)
            );
        }
    }

    /// Move the stock top down one item then check that it hasn't underflowed
    /// the stack bottom. If all virtual stack movements are defined in terms
    /// of pops and pushes this will enforce that the gross stack movements do
    /// not underflow, which would lead to out of bounds stack reads at runtime.
    /// @param integrityCheckState The state of the current integrity check.
    /// @param stackTop The virtual stack top before an item is popped.
    /// @return The virtual stack top after the pop.
    function pop(IntegrityCheckState memory integrityCheckState, Pointer stackTop) internal pure returns (Pointer) {
        stackTop = stackTop.unsafeSubWord();
        integrityCheckState.popUnderflowCheck(stackTop);
        return stackTop;
    }

    /// Overloaded `pop` to support `n` pops in a single movement.
    /// `n` MAY be 0 and this is a virtual noop stack movement.
    /// @param integrityCheckState as per `pop`.
    /// @param stackTop as per `pop`.
    /// @param n The number of items to pop off the virtual stack.
    function pop(IntegrityCheckState memory integrityCheckState, Pointer stackTop, uint256 n)
        internal
        pure
        returns (Pointer)
    {
        stackTop = stackTop.unsafeSubWords(n);
        integrityCheckState.popUnderflowCheck(stackTop);
        return stackTop;
    }

    /// DANGEROUS pop that does no underflow/highwater checks. The caller MUST
    /// ensure that this does not result in illegal stack reads.
    /// @param stackTop as per `pop`.
    /// @param n as per `pop`.
    function popIgnoreHighwater(IntegrityCheckState memory, Pointer stackTop, uint256 n)
        internal
        pure
        returns (Pointer)
    {
        return stackTop.unsafeSubWords(n);
    }

    /// Maps `function(uint256) internal view returns (uint256)` to pops and
    /// pushes once. The function itself is irrelevant we only care about the
    /// signature to know how many items are popped/pushed.
    /// @param integrityCheckState as per `pop` and `push`.
    /// @param stackTop as per `pop` and `push`.
    /// @return The stack top after the function has been applied once.
    function applyFn(
        IntegrityCheckState memory integrityCheckState,
        Pointer stackTop,
        function(uint256) internal view returns (uint256)
    ) internal pure returns (Pointer) {
        return integrityCheckState.push(integrityCheckState.pop(stackTop));
    }

    /// Maps `function(uint256, uint256) internal view` to pops and pushes once.
    /// The function itself is irrelevant we only care about the signature to
    /// know how many items are popped/pushed.
    /// @param integrityCheckState as per `pop` and `push`.
    /// @param stackTop as per `pop` and `push`.
    /// @return The stack top after the function has been applied once.
    function applyFn(
        IntegrityCheckState memory integrityCheckState,
        Pointer stackTop,
        function(uint256, uint256) internal view
    ) internal pure returns (Pointer) {
        return integrityCheckState.pop(stackTop, 2);
    }

    /// Maps `function(uint256, uint256) internal view returns (uint256)` to
    /// pops and pushes once. The function itself is irrelevant we only care
    /// about the signature to know how many items are popped/pushed.
    /// @param integrityCheckState as per `pop` and `push`.
    /// @param stackTop as per `pop` and `push`.
    /// @return The stack top after the function has been applied once.
    function applyFn(
        IntegrityCheckState memory integrityCheckState,
        Pointer stackTop,
        function(uint256, uint256) internal view returns (uint256)
    ) internal pure returns (Pointer) {
        return integrityCheckState.push(integrityCheckState.pop(stackTop, 2));
    }

    /// Reduces `function(uint256, uint256) internal view returns (uint256)`over
    /// N stack items. The function itself is irrelevant we only care about the
    /// signature to know how many items are popped/pushed. This is the same as
    /// calling `applyFn` N - 1 times in a loop, because the first reduction
    /// takes two items off the stack to start the accumulator, then each
    /// subsequent reduction takes one item off the stack to incorporate into the
    /// accumulator.
    ///
    /// As per LibOp the behaviour below n = 2 is somewhat arbitrary but is
    /// defined as:
    ///
    /// - n = 0: Value `0` is _pushed_ to the stack.
    /// - n = 1: Noop.
    ///
    /// Which is interpreted as:
    ///
    /// - n = 0: Falsey outcome.
    /// - n = 1: Accumulator without any further inputs = Identity.
    ///
    /// Which pragmatically looks something like:
    ///
    /// - n = 0: `_: add();`
    /// - n = 1: `_: add(1);`
    ///
    /// @param integrityCheckState as per `pop` and `push`.
    /// @param stackTop as per `pop` and `push`.
    /// @param n The number of times the function is applied to the stack.
    /// @return The stack top after the function has been applied n times.
    function applyFnN(
        IntegrityCheckState memory integrityCheckState,
        Pointer stackTop,
        function(uint256, uint256) internal view returns (uint256),
        uint256 n
    ) internal pure returns (Pointer) {
        if (n > 1) {
            return integrityCheckState.push(integrityCheckState.pop(stackTop, n));
        } else if (n == 1) {
            return stackTop;
        } else {
            return integrityCheckState.push(stackTop);
        }
    }

    /// Maps
    /// `function(uint256, uint256, uint256) internal view returns (uint256)` to
    /// pops and pushes once. The function itself is irrelevant we only care
    /// about the signature to know how many items are popped/pushed.
    /// @param integrityCheckState as per `pop` and `push`.
    /// @param stackTop as per `pop` and `push`.
    /// @return The stack top after the function has been applied once.
    function applyFn(
        IntegrityCheckState memory integrityCheckState,
        Pointer stackTop,
        function(uint256, uint256, uint256) internal view returns (uint256)
    ) internal pure returns (Pointer) {
        return integrityCheckState.push(integrityCheckState.pop(stackTop, 3));
    }

    /// Maps
    /// ```
    /// function(uint256, uint256, uint256, uint256)
    ///     internal
    ///     view
    ///     returns (uint256)
    /// ```
    /// to pops and pushes once. The function itself is irrelevant we only care
    /// about the signature to know how many items are popped/pushed.
    /// @param integrityCheckState as per `pop` and `push`.
    /// @param stackTop as per `pop` and `push`.
    /// @return The stack top after the function has been applied once.
    function applyFn(
        IntegrityCheckState memory integrityCheckState,
        Pointer stackTop,
        function(uint256, uint256, uint256, uint256)
            internal
            view
            returns (uint256)
    ) internal pure returns (Pointer) {
        return integrityCheckState.push(integrityCheckState.pop(stackTop, 4));
    }

    /// Maps `function(Operand, uint256) internal view returns (uint256)` to
    /// pops and pushes once. The function itself is irrelevant we only care
    /// about the signature to know how many items are popped/pushed.
    ///
    /// The operand MUST NOT influence the stack movements if this application
    /// is to be valid.
    ///
    /// @param integrityCheckState as per `pop` and `push`.
    /// @param stackTop as per `pop` and `push`.
    /// @return The stack top after the function has been applied once.
    function applyFn(
        IntegrityCheckState memory integrityCheckState,
        Pointer stackTop,
        function(Operand, uint256) internal view returns (uint256)
    ) internal pure returns (Pointer) {
        return integrityCheckState.push(integrityCheckState.pop(stackTop));
    }

    /// Maps
    /// `function(Operand, uint256, uint256) internal view returns (uint256)` to
    /// pops and pushes once. The function itself is irrelevant we only care
    /// about the signature to know how many items are popped/pushed.
    ///
    /// The operand MUST NOT influence the stack movements if this application
    /// is to be valid.
    ///
    /// @param integrityCheckState as per `pop` and `push`.
    /// @param stackTop as per `pop` and `push`.
    /// @return The stack top after the function has been applied once.
    function applyFn(
        IntegrityCheckState memory integrityCheckState,
        Pointer stackTop,
        function(Operand, uint256, uint256) internal view returns (uint256)
    ) internal pure returns (Pointer) {
        return integrityCheckState.push(integrityCheckState.pop(stackTop, 2));
    }

    /// Maps `function(uint256[] memory) internal view returns (uint256)` to
    /// pops and pushes once given that we know the length of the dynamic array
    /// at deploy time. The function itself is irrelevant we only care about the
    /// signature to know how many items are popped/pushed.
    /// @param integrityCheckState as per `pop` and `push`.
    /// @param stackTop as per `pop` and `push`.
    /// @param length The length of the dynamic input array.
    /// @return The stack top after the function has been applied once.
    function applyFn(
        IntegrityCheckState memory integrityCheckState,
        Pointer stackTop,
        function(uint256[] memory) internal view returns (uint256),
        uint256 length
    ) internal pure returns (Pointer) {
        return integrityCheckState.push(integrityCheckState.pop(stackTop, length));
    }

    /// Maps
    /// ```
    /// function(uint256, uint256, uint256[] memory)
    ///     internal
    ///     view
    ///     returns (uint256)
    /// ```
    /// to pops and pushes once given that we know the length of the dynamic
    /// array at deploy time. The function itself is irrelevant we only care
    /// about the signature to know how many items are popped/pushed.
    /// @param integrityCheckState as per `pop` and `push`.
    /// @param stackTop as per `pop` and `push`.
    /// @param length The length of the dynamic input array.
    /// @return The stack top after the function has been applied once.
    function applyFn(
        IntegrityCheckState memory integrityCheckState,
        Pointer stackTop,
        function(uint256, uint256, uint256[] memory)
            internal
            view
            returns (uint256),
        uint256 length
    ) internal pure returns (Pointer) {
        unchecked {
            return integrityCheckState.push(integrityCheckState.pop(stackTop, length + 2));
        }
    }

    /// Maps
    /// ```
    /// function(uint256, uint256, uint256, uint256[] memory)
    ///     internal
    ///     view
    ///     returns (uint256)
    /// ```
    /// to pops and pushes once given that we know the length of the dynamic
    /// array at deploy time. The function itself is irrelevant we only care
    /// about the signature to know how many items are popped/pushed.
    /// @param integrityCheckState as per `pop` and `push`.
    /// @param stackTop as per `pop` and `push`.
    /// @param length The length of the dynamic input array.
    /// @return The stack top after the function has been applied once.
    function applyFn(
        IntegrityCheckState memory integrityCheckState,
        Pointer stackTop,
        function(uint256, uint256, uint256, uint256[] memory)
            internal
            view
            returns (uint256),
        uint256 length
    ) internal pure returns (Pointer) {
        unchecked {
            return integrityCheckState.push(integrityCheckState.pop(stackTop, length + 3));
        }
    }

    /// Maps
    /// ```
    /// function(uint256, uint256[] memory, uint256[] memory)
    ///     internal
    ///     view
    ///     returns (uint256[] memory)
    /// ```
    /// to pops and pushes once given that we know the length of the dynamic
    /// array at deploy time. The function itself is irrelevant we only care
    /// about the signature to know how many items are popped/pushed.
    /// @param integrityCheckState as per `pop` and `push`.
    /// @param stackTop as per `pop` and `push`.
    /// @param length The length of the dynamic input array.
    /// @return The stack top after the function has been applied once.
    function applyFn(
        IntegrityCheckState memory integrityCheckState,
        Pointer stackTop,
        function(uint256, uint256[] memory, uint256[] memory)
            internal
            view
            returns (uint256[] memory),
        uint256 length
    ) internal pure returns (Pointer) {
        unchecked {
            return integrityCheckState.push(integrityCheckState.pop(stackTop, length * 2 + 1), length);
        }
    }
}
