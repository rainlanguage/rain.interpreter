// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.interface.interpreter/IInterpreterV1.sol";

import "sol.lib.memory/LibPointer.sol";
import "sol.lib.memory/LibStackPointer.sol";

library LibOpSlow {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibOpSlow for Pointer;

    function applyFnSlow(Pointer pointer, function(uint256) internal view returns (uint256) f)
        internal
        view
        returns (Pointer)
    {
        (Pointer popped, uint256 a) = pointer.unsafePop();
        Pointer pushed = popped.unsafePush(f(a));
        return pushed;
    }

    function applyFnSlow(Pointer pointer, function(Operand, uint256) internal view returns (uint256) f, Operand operand)
        internal
        view
        returns (Pointer)
    {
        (Pointer popped, uint256 a) = pointer.unsafePop();
        Pointer pushed = popped.unsafePush(f(operand, a));
        return pushed;
    }

    function applyFnSlow(Pointer pointer, function(uint256, uint256) internal view returns (uint256) f)
        internal
        view
        returns (Pointer)
    {
        (Pointer popped0, uint256 b) = pointer.unsafePop();
        (Pointer popped1, uint256 a) = popped0.unsafePop();
        Pointer pushed = popped1.unsafePush(f(a, b));
        return pushed;
    }

    function applyFnSlow(Pointer pointer, function(uint256, uint256, uint256) internal view returns (uint256) f)
        internal
        view
        returns (Pointer)
    {
        (Pointer popped0, uint256 c) = pointer.unsafePop();
        (Pointer popped1, uint256 b) = popped0.unsafePop();
        (Pointer popped2, uint256 a) = popped1.unsafePop();
        Pointer pushed = popped2.unsafePush(f(a, b, c));
        return pushed;
    }

    function applyFnNSlow(Pointer pointer, function(uint256, uint256) internal view returns (uint256) f, uint256 n)
        internal
        view
        returns (Pointer)
    {
        // n=0 evaluates to 0 and removes no values from the stack, so has the
        // effect of pushing 0.
        if (n == 0) {
            return pointer.unsafePush(0);
        }
        // n=1 evaluates to the top value `x`, which has the effect of popping
        // `x` then pushing `x`, which is a noop.
        else if (n == 1) {
            return pointer;
        } else {
            Pointer pointerAfter = pointer.unsafeSubWords(n);
            Pointer cursor = pointerAfter;
            uint256 accumulator = cursor.unsafeReadWord();
            cursor = cursor.unsafeAddWord();
            while (Pointer.unwrap(cursor) < Pointer.unwrap(pointer)) {
                accumulator = f(accumulator, cursor.unsafeReadWord());
                cursor = cursor.unsafeAddWord();
            }
            return pointerAfter.unsafePush(accumulator);
        }
    }
}
