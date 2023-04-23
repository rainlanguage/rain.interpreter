// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.interface.interpreter/IInterpreterV1.sol";
import "sol.lib.memory/LibPointer.sol";
import "sol.lib.memory/LibMemCpy.sol";
import "sol.lib.memory/LibStackPointer.sol";
import "sol.lib.memory/LibUint256Array.sol";

/// Thrown when the length of an array as the result of an applied function does
/// not match expectations.
error UnexpectedResultLength(uint256 expectedLength, uint256 actualLength);

library LibOp {
    using LibUint256Array for uint256[];
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;

    /// Execute a function, reading and writing inputs and outputs on the stack.
    /// The caller MUST ensure this does not result in unsafe reads and writes.
    /// @param pointer The stack top to read and write to.
    /// @param f The function to run on the stack.
    /// @return The new stack top above the outputs of f.
    function applyFn(Pointer pointer, function(uint256) internal view returns (uint256) f)
        internal
        view
        returns (Pointer)
    {
        uint256 io;
        uint256 location;
        assembly ("memory-safe") {
            location := sub(pointer, 0x20)
            io := mload(location)
        }
        io = f(io);
        assembly ("memory-safe") {
            mstore(location, io)
        }
        return pointer;
    }

    /// Execute a function, reading and writing inputs and outputs on the stack.
    /// The caller MUST ensure this does not result in unsafe reads and writes.
    /// @param pointer The stack top to read and write to.
    /// @param f The function to run on the stack.
    /// @return The new stack top above the outputs of f.
    function applyFn(Pointer pointer, function(Operand, uint256) internal view returns (uint256) f, Operand operand)
        internal
        view
        returns (Pointer)
    {
        uint256 io;
        uint256 location;
        assembly ("memory-safe") {
            location := sub(pointer, 0x20)
            io := mload(location)
        }
        io = f(operand, io);
        assembly ("memory-safe") {
            mstore(location, io)
        }
        return pointer;
    }

    /// Execute a function, reading and writing inputs and outputs on the stack.
    /// The caller MUST ensure this does not result in unsafe reads and writes.
    /// @param stackTop_ The stack top to read and write to.
    /// @param fn_ The function to run on the stack.
    /// @return The new stack top above the outputs of fn_.
    function applyFn(Pointer stackTop_, function(uint256, uint256) internal view returns (uint256) fn_)
        internal
        view
        returns (Pointer)
    {
        uint256 a_;
        uint256 b_;
        uint256 location_;
        assembly ("memory-safe") {
            stackTop_ := sub(stackTop_, 0x20)
            location_ := sub(stackTop_, 0x20)
            a_ := mload(location_)
            b_ := mload(stackTop_)
        }
        a_ = fn_(a_, b_);
        assembly ("memory-safe") {
            mstore(location_, a_)
        }
        return stackTop_;
    }

    /// Reduce a function N times, reading and writing inputs and the accumulated
    /// result on the stack.
    /// The caller MUST ensure this does not result in unsafe reads and writes.
    /// @param stackTop_ The stack top to read and write to.
    /// @param fn_ The function to run on the stack.
    /// @param n_ The number of times to apply fn_ to accumulate a final result.
    /// @return stackTopAfter_ The new stack top above the outputs of fn_.
    function applyFnN(Pointer stackTop_, function(uint256, uint256) internal view returns (uint256) fn_, uint256 n_)
        internal
        view
        returns (Pointer)
    {
        unchecked {
            uint256 bottom_;
            uint256 cursor_;
            uint256 a_;
            uint256 b_;
            Pointer stackTopAfter_;
            assembly ("memory-safe") {
                bottom_ := sub(stackTop_, mul(n_, 0x20))
                a_ := mload(bottom_)
                stackTopAfter_ := add(bottom_, 0x20)
                cursor_ := stackTopAfter_
            }
            while (cursor_ < Pointer.unwrap(stackTop_)) {
                assembly ("memory-safe") {
                    b_ := mload(cursor_)
                }
                a_ = fn_(a_, b_);
                cursor_ += 0x20;
            }
            assembly ("memory-safe") {
                mstore(bottom_, a_)
            }
            return stackTopAfter_;
        }
    }

    /// Reduce a function N times, reading and writing inputs and the accumulated
    /// result on the stack.
    /// The caller MUST ensure this does not result in unsafe reads and writes.
    /// @param stackTop_ The stack top to read and write to.
    /// @param fn_ The function to run on the stack.
    /// @param n_ The number of times to apply fn_ to accumulate a final result.
    /// @return stackTopAfter_ The new stack top above the outputs of fn_.
    function applyFnN(Pointer stackTop_, function(uint256) internal view fn_, uint256 n_)
        internal
        view
        returns (Pointer)
    {
        uint256 cursor_;
        uint256 a_;
        Pointer stackTopAfter_;
        assembly ("memory-safe") {
            stackTopAfter_ := sub(stackTop_, mul(n_, 0x20))
            cursor_ := stackTopAfter_
        }
        while (cursor_ < Pointer.unwrap(stackTop_)) {
            assembly ("memory-safe") {
                a_ := mload(cursor_)
                cursor_ := add(cursor_, 0x20)
            }
            fn_(a_);
        }
        return stackTopAfter_;
    }

    /// Execute a function, reading and writing inputs and outputs on the stack.
    /// The caller MUST ensure this does not result in unsafe reads and writes.
    /// @param stackTop_ The stack top to read and write to.
    /// @param fn_ The function to run on the stack.
    /// @return The new stack top above the outputs of fn_.
    function applyFn(Pointer stackTop_, function(uint256, uint256, uint256) internal view returns (uint256) fn_)
        internal
        view
        returns (Pointer)
    {
        uint256 a_;
        uint256 b_;
        uint256 c_;
        uint256 location_;
        assembly ("memory-safe") {
            stackTop_ := sub(stackTop_, 0x40)
            location_ := sub(stackTop_, 0x20)
            a_ := mload(location_)
            b_ := mload(stackTop_)
            c_ := mload(add(stackTop_, 0x20))
        }
        a_ = fn_(a_, b_, c_);
        assembly ("memory-safe") {
            mstore(location_, a_)
        }
        return stackTop_;
    }

    /// Execute a function, reading and writing inputs and outputs on the stack.
    /// The caller MUST ensure this does not result in unsafe reads and writes.
    /// @param stackTop_ The stack top to read and write to.
    /// @param fn_ The function to run on the stack.
    /// @return The new stack top above the outputs of fn_.
    function applyFn(
        Pointer stackTop_,
        function(uint256, uint256, uint256, uint256)
            internal
            view
            returns (uint256) fn_
    ) internal view returns (Pointer) {
        uint256 a_;
        uint256 b_;
        uint256 c_;
        uint256 d_;
        uint256 location_;
        assembly ("memory-safe") {
            stackTop_ := sub(stackTop_, 0x60)
            location_ := sub(stackTop_, 0x20)
            a_ := mload(location_)
            b_ := mload(stackTop_)
            c_ := mload(add(stackTop_, 0x20))
            d_ := mload(add(stackTop_, 0x40))
        }
        a_ = fn_(a_, b_, c_, d_);
        assembly ("memory-safe") {
            mstore(location_, a_)
        }
        return stackTop_;
    }

    /// Execute a function, reading and writing inputs and outputs on the stack.
    /// The caller MUST ensure this does not result in unsafe reads and writes.
    /// @param stackTop_ The stack top to read and write to.
    /// @param fn_ The function to run on the stack.
    /// @param operand_ Operand is passed from the source instead of the stack.
    /// @return The new stack top above the outputs of fn_.
    function applyFn(
        Pointer stackTop_,
        function(Operand, uint256, uint256) internal view returns (uint256) fn_,
        Operand operand_
    ) internal view returns (Pointer) {
        uint256 a_;
        uint256 b_;
        uint256 location_;
        assembly ("memory-safe") {
            stackTop_ := sub(stackTop_, 0x20)
            location_ := sub(stackTop_, 0x20)
            a_ := mload(location_)
            b_ := mload(stackTop_)
        }
        a_ = fn_(operand_, a_, b_);
        assembly ("memory-safe") {
            mstore(location_, a_)
        }
        return stackTop_;
    }

    /// Execute a function, reading and writing inputs and outputs on the stack.
    /// The caller MUST ensure this does not result in unsafe reads and writes.
    /// @param stackTop The stack top to read and write to.
    /// @param f The function to run on the stack.
    /// @param length The length of the array to pass to f from the stack.
    /// @return The new stack top above the outputs of f.
    function applyFn(Pointer stackTop, function(uint256[] memory) internal view returns (uint256) f, uint256 length)
        internal
        view
        returns (Pointer)
    {
        (uint256 a, uint256[] memory tail) = stackTop.unsafeList(length);
        uint256 b = f(tail);
        return tail.startPointer().unsafePush(a).unsafePush(b);
    }

    /// Execute a function, reading and writing inputs and outputs on the stack.
    /// The caller MUST ensure this does not result in unsafe reads and writes.
    /// @param stackTop The stack top to read and write to.
    /// @param f The function to run on the stack.
    /// @param length The length of the array to pass to f from the stack.
    /// @return stackTopAfter The new stack top above the outputs of f.
    function applyFn(
        Pointer stackTop,
        function(uint256, uint256, uint256[] memory)
            internal
            view
            returns (uint256) f,
        uint256 length
    ) internal view returns (Pointer) {
        (uint256 b, uint256[] memory tail) = stackTop.unsafeList(length);
        Pointer stackTopAfter = tail.startPointer();
        (Pointer location, uint256 a) = stackTopAfter.unsafePop();
        location.unsafeWriteWord(f(a, b, tail));
        return stackTopAfter;
    }

    /// Execute a function, reading and writing inputs and outputs on the stack.
    /// The caller MUST ensure this does not result in unsafe reads and writes.
    /// @param stackTop The stack top to read and write to.
    /// @param f The function to run on the stack.
    /// @param length The length of the array to pass to f from the stack.
    /// @return The new stack top above the outputs of f.
    function applyFn(
        Pointer stackTop,
        function(uint256, uint256, uint256, uint256[] memory)
            internal
            view
            returns (uint256) f,
        uint256 length
    ) internal view returns (Pointer) {
        (uint256 c, uint256[] memory tail) = stackTop.unsafeList(length);
        (Pointer stackTopAfter, uint256 b) = tail.startPointer().unsafePop();
        uint256 a = stackTopAfter.unsafePeek();
        stackTopAfter.unsafeSubWord().unsafeWriteWord(f(a, b, c, tail));
        return stackTopAfter;
    }

    /// Execute a function, reading and writing inputs and outputs on the stack.
    /// The caller MUST ensure this does not result in unsafe reads and writes.
    /// @param stackTop The stack top to read and write to.
    /// @param f The function to run on the stack.
    /// @param length The length of the arrays to pass to f from the stack.
    /// @return The new stack top above the outputs of f.
    function applyFn(
        Pointer stackTop,
        function(uint256, uint256[] memory, uint256[] memory)
            internal
            view
            returns (uint256[] memory) f,
        uint256 length
    ) internal view returns (Pointer) {
        Pointer csStart = stackTop.unsafeSubWords(length);
        uint256[] memory cs = new uint256[](length);
        LibMemCpy.unsafeCopyWordsTo(csStart, cs.dataPointer(), length);
        (uint256 a, uint256[] memory bs) = csStart.unsafeList(length);

        uint256[] memory results = f(a, bs, cs);
        if (results.length != length) {
            revert UnexpectedResultLength(length, results.length);
        }

        Pointer bottom = bs.startPointer();
        LibMemCpy.unsafeCopyWordsTo(results.dataPointer(), bottom, length);
        return bottom.unsafeAddWords(length);
    }
}
