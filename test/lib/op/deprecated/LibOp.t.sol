// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "rain.solmem/lib/LibMemCpy.sol";
import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibStackPointer.sol";
import "rain.solmem/lib/LibUint256Array.sol";
import "rain.lib.hash/LibHashNoAlloc.sol";

import "src/lib/op/deprecated/LibOp.sol";
import "test/lib/op/LibOpSlow.sol";

contract LibOpTest is Test {
    using LibUint256Array for uint256[];
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibOp for Pointer;
    using LibOpSlow for Pointer;

    function stackCopies(uint256[] memory stack) internal pure returns (uint256[] memory, uint256[] memory) {
        uint256[] memory a = new uint256[](stack.length);
        uint256[] memory b = new uint256[](stack.length);

        LibMemCpy.unsafeCopyWordsTo(stack.dataPointer(), a.dataPointer(), stack.length);
        LibMemCpy.unsafeCopyWordsTo(stack.dataPointer(), b.dataPointer(), stack.length);

        return (a, b);
    }

    function hashVal(uint256 a) internal pure returns (uint256 b) {
        assembly ("memory-safe") {
            mstore(0, a)
            b := keccak256(0, 0x20)
        }
    }

    function hashOpVal(Operand operand, uint256 a) internal pure returns (uint256 b) {
        assembly ("memory-safe") {
            mstore(0, operand)
            mstore(0x20, a)
            b := keccak256(0, 0x40)
        }
    }

    function hashValVal(uint256 a, uint256 b) internal pure returns (uint256 c) {
        assembly ("memory-safe") {
            mstore(0, a)
            mstore(0x20, b)
            c := keccak256(0, 0x40)
        }
    }

    function hashOpValVal(Operand operand, uint256 a, uint256 b) internal pure returns (uint256 c) {
        assembly ("memory-safe") {
            let pointer := mload(0x40)
            mstore(pointer, operand)
            mstore(add(pointer, 0x20), a)
            mstore(add(pointer, 0x40), b)
            c := keccak256(pointer, 0x60)
        }
    }

    function hashValValVal(uint256 a, uint256 b, uint256 c) internal pure returns (uint256 d) {
        assembly ("memory-safe") {
            let pointer := mload(0x40)
            mstore(pointer, a)
            mstore(add(pointer, 0x20), b)
            mstore(add(pointer, 0x40), c)
            d := keccak256(pointer, 0x60)
        }
    }

    function hashValValValVal(uint256 a, uint256 b, uint256 c, uint256 d) internal pure returns (uint256 e) {
        assembly ("memory-safe") {
            let pointer := mload(0x40)
            mstore(pointer, a)
            mstore(add(pointer, 0x20), b)
            mstore(add(pointer, 0x40), c)
            mstore(add(pointer, 0x60), d)
            e := keccak256(pointer, 0x80)
        }
    }

    function hashArray(uint256[] memory array) internal pure returns (uint256) {
        return uint256(LibHashNoAlloc.hashWords(array));
    }

    function hashValValArray(uint256 a, uint256 b, uint256[] memory array) internal pure returns (uint256) {
        uint256[] memory toHash = new uint256[](array.length + 2);
        toHash[0] = a;
        toHash[1] = b;
        LibMemCpy.unsafeCopyWordsTo(array.dataPointer(), toHash.dataPointer().unsafeAddWords(2), array.length);
        return uint256(LibHashNoAlloc.hashWords(toHash));
    }

    function hashValValValArray(uint256 a, uint256 b, uint256 c, uint256[] memory array)
        internal
        pure
        returns (uint256)
    {
        uint256[] memory toHash = new uint256[](array.length + 3);
        toHash[0] = a;
        toHash[1] = b;
        toHash[2] = c;
        LibMemCpy.unsafeCopyWordsTo(array.dataPointer(), toHash.dataPointer().unsafeAddWords(3), array.length);
        return uint256(LibHashNoAlloc.hashWords(toHash));
    }

    function hashValListList(uint256 a, uint256[] memory xs, uint256[] memory ys)
        internal
        pure
        returns (uint256[] memory zs)
    {
        require(xs.length == ys.length);
        zs = new uint256[](xs.length);
        uint256[] memory toHash = new uint256[](3);
        for (uint256 i = 0; i < xs.length; i++) {
            toHash[0] = a;
            toHash[1] = xs[i];
            toHash[2] = ys[i];
            zs[i] = uint256(LibHashNoAlloc.hashWords(toHash));
        }
    }

    function testApplyFn0(uint256[] memory stack) public {
        vm.assume(stack.length > 1);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();

        uint256 expectedOutput = hashVal(stackPointer.unsafePeek());

        Pointer stackPointerAfter = stackPointer.applyFn(hashVal);
        stackPointerSlow.applyFnSlow(hashVal);

        assertEq(stack, stackSlow);
        assertEq(stackPointer.unsafePeek(), expectedOutput);

        stackBefore[stackBefore.length - 2] = expectedOutput;
        assertEq(stack, stackBefore);
        assertEq(Pointer.unwrap(stackPointerAfter), Pointer.unwrap(stackPointer));
    }

    function testApplyFn1(Operand operand, uint256[] memory stack) public {
        vm.assume(stack.length > 1);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();

        uint256 expectedOutput = hashOpVal(operand, stackPointer.unsafePeek());

        Pointer stackPointerAfter = stackPointer.applyFn(hashOpVal, operand);
        stackPointerSlow.applyFnSlow(hashOpVal, operand);

        assertEq(stack, stackSlow);
        assertEq(stackPointer.unsafePeek(), expectedOutput);

        stackBefore[stackBefore.length - 2] = expectedOutput;
        assertEq(stack, stackBefore);
        assertEq(Pointer.unwrap(stackPointerAfter), Pointer.unwrap(stackPointer));
    }

    function testApplyFn2(uint256[] memory stack) public {
        vm.assume(stack.length > 2);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();

        (uint256 beforeA, uint256 beforeB) = stackPointer.unsafePeek2();
        uint256 expectedOutput = hashValVal(beforeA, beforeB);

        Pointer stackPointerAfter = stackPointer.applyFn(hashValVal);
        stackPointerSlow.applyFnSlow(hashValVal);

        assertEq(stack, stackSlow);
        assertEq(stackPointer.unsafeSubWord().unsafePeek(), expectedOutput);

        // Only the output position changes val.
        stackBefore[stackBefore.length - 3] = expectedOutput;
        assertEq(stack, stackBefore);
        assertEq(Pointer.unwrap(stackPointerAfter), Pointer.unwrap(stackPointer.unsafeSubWord()));
    }

    function testApplyFn3(uint256[] memory stack) public {
        vm.assume(stack.length > 3);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();

        uint256 beforeA = stack[stack.length - 4];
        uint256 beforeB = stack[stack.length - 3];
        uint256 beforeC = stack[stack.length - 2];
        uint256 expectedOutput = hashValValVal(beforeA, beforeB, beforeC);

        Pointer stackPointerAfter = stackPointer.applyFn(hashValValVal);
        stackPointerSlow.applyFnSlow(hashValValVal);

        assertEq(stack, stackSlow);
        assertEq(stackPointerAfter.unsafePeek(), expectedOutput);

        // Only the output position changes val.
        stackBefore[stackBefore.length - 4] = expectedOutput;
        assertEq(stack, stackBefore);
        assertEq(Pointer.unwrap(stackPointerAfter), Pointer.unwrap(stackPointer.unsafeSubWords(2)));
    }

    function testApplyFn4(uint256[] memory stack) public {
        vm.assume(stack.length > 4);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();

        uint256 beforeA = stack[stack.length - 5];
        uint256 beforeB = stack[stack.length - 4];
        uint256 beforeC = stack[stack.length - 3];
        uint256 beforeD = stack[stack.length - 2];
        uint256 expectedOutput = hashValValValVal(beforeA, beforeB, beforeC, beforeD);

        Pointer stackPointerAfter = stackPointer.applyFn(hashValValValVal);
        stackPointerSlow.applyFnSlow(hashValValValVal);

        assertEq(stack, stackSlow);
        assertEq(stackPointerAfter.unsafePeek(), expectedOutput);

        // Only the output position changes val.
        stackBefore[stackBefore.length - 5] = expectedOutput;
        assertEq(stack, stackBefore);
        assertEq(Pointer.unwrap(stackPointerAfter), Pointer.unwrap(stackPointer.unsafeSubWords(3)));
    }

    function testApplyFn5(Operand operand, uint256[] memory stack) public {
        vm.assume(stack.length > 2);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();

        uint256 beforeA = stack[stack.length - 3];
        uint256 beforeB = stack[stack.length - 2];
        uint256 expectedOutput = hashOpValVal(operand, beforeA, beforeB);

        Pointer stackPointerAfter = stackPointer.applyFn(hashOpValVal, operand);
        stackPointerSlow.applyFnSlow(hashOpValVal, operand);

        assertEq(stack, stackSlow);
        assertEq(stackPointerAfter.unsafePeek(), expectedOutput);

        // Only the output position changes val.
        stackBefore[stackBefore.length - 3] = expectedOutput;
        assertEq(stack, stackBefore);
        assertEq(Pointer.unwrap(stackPointerAfter), Pointer.unwrap(stackPointer.unsafeSubWord()));
    }

    function testApplyFnList0(uint256[] memory stack, uint8 length) public {
        vm.assume(stack.length > uint256(length) + 1);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);
        uint256[] memory slice = new uint256[](length);

        LibMemCpy.unsafeCopyWordsTo(stack.endPointer().unsafeSubWords(length + 1), slice.dataPointer(), length);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();

        uint256 expectedOutput = hashArray(slice);

        Pointer stackPointerAfter = stackPointer.applyFn(hashArray, length);
        stackPointerSlow.applyFnSlow(hashArray, length);

        assertEq(stack, stackSlow);
        assertEq(stackPointerAfter.unsafePeek(), expectedOutput);

        // Only the output position changes val.
        stackBefore[stackBefore.length - length - 1] = expectedOutput;
        assertEq(stack, stackBefore);
        assertEq(Pointer.unwrap(stackPointerAfter), Pointer.unwrap(stackPointer.unsafeSubWords(length).unsafeAddWord()));
    }

    function testApplyFnList1(uint256[] memory stack, uint8 length) public {
        vm.assume(stack.length > uint256(length) + 3);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);

        uint256[] memory slice = new uint256[](length);
        LibMemCpy.unsafeCopyWordsTo(stack.endPointer().unsafeSubWords(length + 1), slice.dataPointer(), length);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();

        uint256 a = stack[stack.length - length - 3];
        uint256 b = stack[stack.length - length - 2];
        uint256 expectedOutput = hashValValArray(a, b, slice);

        Pointer stackPointerAfter = stackPointer.applyFn(hashValValArray, length);
        stackPointerSlow.applyFnSlow(hashValValArray, length);

        // The length remains as an artifact of the internal list manipulation.
        stackBefore[stackBefore.length - length - 2] = length;
        stackSlow[stackSlow.length - length - 2] = length;

        assertEq(stack, stackSlow);
        assertEq(stackPointerAfter.unsafePeek(), expectedOutput);

        // The output position changes val.
        stackBefore[stackBefore.length - length - 3] = expectedOutput;
        assertEq(stack, stackBefore);
        assertEq(Pointer.unwrap(stackPointerAfter), Pointer.unwrap(stackPointer.unsafeSubWords(length + 1)));
    }

    function testApplyFnList2(uint256[] memory stack, uint8 length) public {
        vm.assume(stack.length > uint256(length) + 4);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);

        uint256[] memory slice = new uint256[](length);
        LibMemCpy.unsafeCopyWordsTo(stack.endPointer().unsafeSubWords(length + 1), slice.dataPointer(), length);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();

        uint256 a = stack[stack.length - length - 4];
        uint256 b = stack[stack.length - length - 3];
        uint256 c = stack[stack.length - length - 2];
        uint256 expectedOutput = hashValValValArray(a, b, c, slice);

        Pointer stackPointerAfter = stackPointer.applyFn(hashValValValArray, length);
        stackPointerSlow.applyFnSlow(hashValValValArray, length);

        // The length remains as an artifact of the internal list manipulation.
        stackBefore[stackBefore.length - length - 2] = length;
        stackSlow[stackSlow.length - length - 2] = length;

        assertEq(stack, stackSlow);
        assertEq(stackPointerAfter.unsafePeek(), expectedOutput);

        // The output position changes val.
        stackBefore[stackBefore.length - length - 4] = expectedOutput;
        assertEq(stack, stackBefore);
        assertEq(Pointer.unwrap(stackPointerAfter), Pointer.unwrap(stackPointer.unsafeSubWords(length + 2)));
    }

    function testApplyFnValListList0(uint256[] memory stack, uint8 length) public {
        vm.assume(stack.length > uint256(length) * 2 + 2);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);

        uint256[] memory slice1 = new uint256[](length);
        LibMemCpy.unsafeCopyWordsTo(stack.endPointer().unsafeSubWords(length + 1), slice1.dataPointer(), length);

        uint256[] memory slice0 = new uint256[](length);
        LibMemCpy.unsafeCopyWordsTo(stack.endPointer().unsafeSubWords(length * 2 + 1), slice0.dataPointer(), length);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();

        uint256 a = stack[stack.length - (length * 2) - 2];
        uint256[] memory expectedOutput = hashValListList(a, slice0, slice1);

        Pointer stackPointerAfter = stackPointer.applyFn(hashValListList, length);
        stackPointerSlow.applyFnSlow(hashValListList, length);

        // 0 length inputs get written internally without being overwritten
        // again by outputs.
        if (length == 0) {
            stackBefore[stackBefore.length - length * 2 - 2] = length;
            stackSlow[stackSlow.length - length * 2 - 2] = length;
        }
        assertEq(stack, stackSlow);

        uint256[] memory outputSlice = new uint256[](length);
        LibMemCpy.unsafeCopyWordsTo(stackPointerAfter.unsafeSubWords(length), outputSlice.dataPointer(), length);
        assertEq(outputSlice, expectedOutput);

        // The output list changes several vals.
        LibMemCpy.unsafeCopyWordsTo(
            outputSlice.dataPointer(), stackBefore.endPointer().unsafeSubWords(length * 2 + 2), length
        );
        assertEq(stack, stackBefore);
        assertEq(Pointer.unwrap(stackPointerAfter), Pointer.unwrap(stackPointer.unsafeSubWords(length + 1)));
    }

    function testApplyFnN(uint256[] memory stack, uint8 n) public {
        vm.assume(stack.length > uint256(n) + 1);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);
        (stackBefore);
        uint256[] memory slice = new uint256[](n);

        LibMemCpy.unsafeCopyWordsTo(stack.endPointer().unsafeSubWords(n + 1), slice.dataPointer(), n);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();

        uint256 expectedOutput;
        if (n == 0) {
            expectedOutput = 0;
        } else if (n == 1) {
            expectedOutput = slice[slice.length - 1];
        } else {
            expectedOutput = slice[0];
            for (uint256 i = 1; i < slice.length; i++) {
                expectedOutput = uint256(LibHashNoAlloc.combineHashes(bytes32(expectedOutput), bytes32(slice[i])));
            }
        }

        Pointer stackPointerAfter = stackPointer.applyFnN(hashValVal, uint256(n));
        stackPointerSlow.applyFnNSlow(hashValVal, uint256(n));

        assertEq(stack, stackSlow);
        assertEq(expectedOutput, stackPointerAfter.unsafePeek());
        assertEq(Pointer.unwrap(stackPointer.unsafeSubWords(n).unsafeAddWord()), Pointer.unwrap(stackPointerAfter));
    }
}
