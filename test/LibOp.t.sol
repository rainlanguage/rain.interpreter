// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "sol.lib.memory/LibMemCpy.sol";
import "sol.lib.memory/LibPointer.sol";
import "sol.lib.memory/LibStackPointer.sol";
import "sol.lib.memory/LibUint256Array.sol";

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

    function uncheckedInc(uint256 a) internal pure returns (uint256 b) {
        unchecked {
            b = a + 1;
        }
    }

    function uncheckedAddOperand(Operand operand, uint256 a) internal pure returns (uint256 b) {
        unchecked {
            b = Operand.unwrap(operand) + a;
        }
    }

    function uncheckedAdd(uint256 a, uint256 b) internal pure returns (uint256 c) {
        unchecked {
            c = a + b;
        }
    }

    function testApplyFn0(uint256[] memory stack) public {
        vm.assume(stack.length > 1);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();
        Pointer stackPointerBefore = stackBefore.endPointer().unsafeSubWord();

        stackPointer.applyFn(uncheckedInc);
        stackPointerSlow.applyFnSlow(uncheckedInc);

        assertEq(stack, stackSlow);
        assertEq(stackPointer.unsafePeek(), uncheckedInc(stackPointerBefore.unsafePeek()));

        stackBefore[stackBefore.length - 2] = stack[stack.length - 2];
        assertEq(stack, stackBefore);
    }

    function testApplyFn1(Operand operand, uint256[] memory stack) public {
        vm.assume(stack.length > 1);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();
        Pointer stackPointerBefore = stackBefore.endPointer().unsafeSubWord();

        stackPointer.applyFn(uncheckedAddOperand, operand);
        stackPointerSlow.applyFnSlow(uncheckedAddOperand, operand);

        assertEq(stack, stackSlow);
        assertEq(stackPointer.unsafePeek(), uncheckedAddOperand(operand, stackPointerBefore.unsafePeek()));

        stackBefore[stackBefore.length - 2] = stack[stack.length - 2];
        assertEq(stack, stackBefore);
    }

    function testApplyFn2(uint256[] memory stack) public {
        vm.assume(stack.length > 2);

        (uint256[] memory stackBefore, uint256[] memory stackSlow) = stackCopies(stack);

        Pointer stackPointer = stack.endPointer().unsafeSubWord();
        Pointer stackPointerSlow = stackSlow.endPointer().unsafeSubWord();
        Pointer stackPointerBefore = stackBefore.endPointer().unsafeSubWord();

        stackPointer.applyFn(uncheckedAdd);
        stackPointerSlow.applyFnSlow(uncheckedAdd);

        assertEq(stack, stackSlow);
        (uint256 beforeA, uint256 beforeB) = stackPointerBefore.unsafePeek2();
        assertEq(stackPointer.unsafeSubWord().unsafePeek(), uncheckedAdd(beforeA, beforeB));

        stackBefore[stackBefore.length - 2] = stack[stack.length - 2];
        stackBefore[stackBefore.length - 3] = stack[stack.length - 3];
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

        uint256 expected = 0;
        if (n > 0) {
            for (uint256 i = 0; i < slice.length; i++) {
                unchecked {
                    expected += slice[i];
                }
            }
        } else {
            expected = 0;
        }

        Pointer stackPointerAfter = stackPointer.applyFnN(uncheckedAdd, uint256(n));
        stackPointerSlow.applyFnNSlow(uncheckedAdd, uint256(n));

        assertEq(stack, stackSlow);
        assertEq(expected, stackPointerAfter.unsafePeek());
        assertEq(Pointer.unwrap(stackPointer.unsafeSubWords(n).unsafeAddWord()), Pointer.unwrap(stackPointerAfter));
    }
}
