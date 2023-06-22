// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "src/interface/IInterpreterV1.sol";

import "sol.lib.memory/LibPointer.sol";
import "sol.lib.memory/LibStackPointer.sol";
import "sol.lib.memory/LibUint256Array.sol";

library LibOpSlow {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibOpSlow for Pointer;
    using LibUint256Array for uint256[];

    function applyFnSlow(Pointer pointer, function(uint256) internal view returns (uint256) f)
        internal
        view
        returns (Pointer)
    {
        (Pointer popped, uint256 a) = pointer.unsafePop();
        return popped.unsafePush(f(a));
    }

    function applyFnSlow(Pointer pointer, function(Operand, uint256) internal view returns (uint256) f, Operand operand)
        internal
        view
        returns (Pointer)
    {
        (Pointer popped, uint256 a) = pointer.unsafePop();
        return popped.unsafePush(f(operand, a));
    }

    function applyFnSlow(Pointer pointer, function(uint256, uint256) internal view returns (uint256) f)
        internal
        view
        returns (Pointer)
    {
        (Pointer popped0, uint256 b) = pointer.unsafePop();
        (Pointer popped1, uint256 a) = popped0.unsafePop();
        return popped1.unsafePush(f(a, b));
    }

    function applyFnSlow(Pointer pointer, function(uint256, uint256, uint256) internal view returns (uint256) f)
        internal
        view
        returns (Pointer)
    {
        (Pointer popped0, uint256 c) = pointer.unsafePop();
        (Pointer popped1, uint256 b) = popped0.unsafePop();
        (Pointer popped2, uint256 a) = popped1.unsafePop();
        return popped2.unsafePush(f(a, b, c));
    }

    function applyFnSlow(
        Pointer pointer,
        function(uint256, uint256, uint256, uint256) internal view returns (uint256) f
    ) internal view returns (Pointer) {
        (Pointer popped0, uint256 d) = pointer.unsafePop();
        (Pointer popped1, uint256 c) = popped0.unsafePop();
        (Pointer popped2, uint256 b) = popped1.unsafePop();
        (Pointer popped3, uint256 a) = popped2.unsafePop();
        return popped3.unsafePush(f(a, b, c, d));
    }

    function applyFnSlow(
        Pointer pointer,
        function(Operand, uint256, uint256) internal view returns (uint256) f,
        Operand operand
    ) internal view returns (Pointer) {
        (Pointer popped0, uint256 b) = pointer.unsafePop();
        (Pointer popped1, uint256 a) = popped0.unsafePop();
        return popped1.unsafePush(f(operand, a, b));
    }

    function applyFnSlow(Pointer pointer, function(uint256[] memory) internal view returns (uint256) f, uint256 length)
        internal
        view
        returns (Pointer)
    {
        uint256[] memory array = new uint256[](length);
        Pointer bottom = pointer.unsafeSubWords(length);
        LibMemCpy.unsafeCopyWordsTo(bottom, array.dataPointer(), length);
        return bottom.unsafePush(f(array));
    }

    function applyFnSlow(
        Pointer pointer,
        function(uint256, uint256, uint256[] memory) internal view returns (uint256) f,
        uint256 length
    ) internal view returns (Pointer) {
        uint256[] memory array = new uint256[](length);
        Pointer bottom = pointer.unsafeSubWords(length + 2);
        LibMemCpy.unsafeCopyWordsTo(bottom.unsafeAddWords(2), array.dataPointer(), length);
        uint256 a = bottom.unsafeReadWord();
        uint256 b = bottom.unsafeAddWord().unsafeReadWord();
        return bottom.unsafePush(f(a, b, array));
    }

    function applyFnSlow(
        Pointer pointer,
        function(uint256, uint256, uint256, uint256[] memory) internal view returns (uint256) f,
        uint256 length
    ) internal view returns (Pointer) {
        uint256[] memory array = new uint256[](length);
        Pointer bottom = pointer.unsafeSubWords(length + 3);
        LibMemCpy.unsafeCopyWordsTo(bottom.unsafeAddWords(3), array.dataPointer(), length);
        uint256 a = bottom.unsafeReadWord();
        uint256 b = bottom.unsafeAddWord().unsafeReadWord();
        uint256 c = bottom.unsafeAddWords(2).unsafeReadWord();
        return bottom.unsafePush(f(a, b, c, array));
    }

    function applyFnSlow(
        Pointer pointer,
        function(uint256, uint256[] memory, uint256[] memory) internal view returns (uint256[] memory) f,
        uint256 length
    ) internal view returns (Pointer) {
        uint256[] memory slice1 = new uint256[](length);
        LibMemCpy.unsafeCopyWordsTo(pointer.unsafeSubWords(length), slice1.dataPointer(), length);

        uint256[] memory slice0 = new uint256[](length);
        LibMemCpy.unsafeCopyWordsTo(pointer.unsafeSubWords(length * 2), slice0.dataPointer(), length);

        Pointer bottom = pointer.unsafeSubWords(length * 2 + 1);
        uint256 a = bottom.unsafeReadWord();

        uint256[] memory output = f(a, slice0, slice1);
        LibMemCpy.unsafeCopyWordsTo(output.dataPointer(), bottom, length);

        return bottom.unsafeAddWords(length);
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
