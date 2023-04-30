// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "sol.lib.memory/LibMemCpy.sol";
import "sol.lib.memory/LibPointer.sol";
import "sol.lib.memory/LibStackPointer.sol";
import "sol.lib.memory/LibUint256Array.sol";
import "rain.lib.hash/LibHashNoAlloc.sol";

import "../src/LibOp.sol";
import "./LibOpSlow.sol";

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

    function testApplyFn0(uint256[] memory stack) public {
        vm.assume(stack.length > 1);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();

        uint256 expectedOutput = hashVal(stackPointer.unsafePeek());

        stackPointer.applyFn(hashVal);
        stackPointerSlow.applyFnSlow(hashVal);

        assertEq(stack, stackSlow);
        assertEq(stackPointer.unsafePeek(), expectedOutput);

        stackBefore[stackBefore.length - 2] = expectedOutput;
        assertEq(stack, stackBefore);
    }

    function testApplyFn1(Operand operand, uint256[] memory stack) public {
        vm.assume(stack.length > 1);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();

        uint256 expectedOutput = hashOpVal(operand, stackPointer.unsafePeek());

        stackPointer.applyFn(hashOpVal, operand);
        stackPointerSlow.applyFnSlow(hashOpVal, operand);

        assertEq(stack, stackSlow);
        assertEq(stackPointer.unsafePeek(), expectedOutput);

        stackBefore[stackBefore.length - 2] = expectedOutput;
        assertEq(stack, stackBefore);
    }

    function testApplyFn2(uint256[] memory stack) public {
        vm.assume(stack.length > 2);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();

        (uint256 beforeA, uint256 beforeB) = stackPointer.unsafePeek2();
        uint256 expectedOutput = hashValVal(beforeA, beforeB);

        stackPointer.applyFn(hashValVal);
        stackPointerSlow.applyFnSlow(hashValVal);

        assertEq(stack, stackSlow);
        assertEq(stackPointer.unsafeSubWord().unsafePeek(), expectedOutput);

        // Only the output position changes val.
        stackBefore[stackBefore.length - 3] = expectedOutput;
        assertEq(stack, stackBefore);
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
