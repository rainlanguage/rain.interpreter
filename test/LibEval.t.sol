// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "rain.lib.memkv/LibMemoryKV.sol";
import "sol.lib.memory/LibPointer.sol";
import "sol.lib.memory/LibStackPointer.sol";
import "rain.lib.typecast/LibConvert.sol";
import "./LibCompileSlow.sol";
import "./LibEvalSlow.sol";

import "../src/LibEval.sol";
import "../src/LibCompile.sol";

contract LibEvalTest is Test {
    using LibMemoryKV for MemoryKV;
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibUint256Array for uint256[];

    /// stack index == 0 => stack operand, stack index => 1
    /// stack index == 1 => push operand to stack, stack index => 2
    /// stack index == 2 => add top 2 stack items and operand together, stack index => 1
    function opCount(InterpreterState memory state, Operand operand, Pointer pointer) internal pure returns (Pointer) {
        require(Pointer.unwrap(state.stackBottom) <= Pointer.unwrap(pointer));

        if (Pointer.unwrap(state.stackBottom) == Pointer.unwrap(pointer)) {
            return pointer.unsafePush(Operand.unwrap(operand));
        } else if (Pointer.unwrap(state.stackBottom) == Pointer.unwrap(pointer.unsafeSubWord())) {
            return pointer.unsafePush(Operand.unwrap(operand));
        } else {
            return state.stackBottom.unsafePush(
                uint256(Operand.unwrap(operand)) ^ state.stackBottom.unsafeReadWord() ^ pointer.unsafePeek()
            );
        }
    }

    /// stack index == 0 => op count, stack index => 1
    /// stack index == 1 => hashes stack 0 with operand and stacks it, stack index => 2
    /// stack index == 2 => hashes stack 0 and 1 with operand, stack index => 1
    function opCountOrHash(InterpreterState memory state, Operand operand, Pointer pointer)
        internal
        pure
        returns (Pointer)
    {
        require(Pointer.unwrap(state.stackBottom) <= Pointer.unwrap(pointer));
        if (Pointer.unwrap(state.stackBottom) == Pointer.unwrap(pointer)) {
            return opCount(state, operand, pointer);
        } else if (Pointer.unwrap(state.stackBottom) == Pointer.unwrap(pointer.unsafeSubWord())) {
            Pointer location = state.stackBottom;
            uint256 value;
            assembly ("memory-safe") {
                mstore(0, mload(location))
                mstore(0, operand)
                value := keccak256(0, 0x40)
            }
            return pointer.unsafePush(value);
        } else {
            Pointer location = pointer.unsafeSubWords(2);
            uint256 value;
            assembly ("memory-safe") {
                let memoryPointer := mload(0x40)
                mstore(memoryPointer, mload(location))
                mstore(add(memoryPointer, 0x20), mload(add(location, 0x20)))
                mstore(add(memoryPointer, 0x40), operand)
                value := keccak256(memoryPointer, 0x60)
            }
            return location.unsafePush(value);
        }
    }

    function opNoop(InterpreterState memory, Operand, Pointer pointer)
        internal
        pure
        returns (Pointer) {
            return pointer;
        }

    function opcodeFunctionPointers() internal pure returns (bytes memory) {
        function (InterpreterState memory, Operand, Pointer) internal view returns (Pointer)[] memory fns =
            new function (InterpreterState memory, Operand, Pointer) internal view returns (Pointer)[](2);
        fns[0] = opCount;
        fns[1] = opCountOrHash;
        uint256[] memory ufns;
        assembly ("memory-safe") {
            ufns := fns
        }
        return LibConvert.unsafeTo16BitBytes(ufns);
    }

    function testEvalGas0() public {
        uint256 x;
        assembly ("memory-safe") {
            x := opNoop
        }
        assertEq(x, 5);
    }

    function testEval(bytes[] memory sources, uint256[] memory constants, SourceIndex sourceIndex) public {
        vm.assume(SourceIndex.unwrap(sourceIndex) < sources.length);

        bytes memory pointers = opcodeFunctionPointers();
        for (uint256 i = 0; i < sources.length; i++) {
            vm.assume(sources[i].length % 4 == 0);
            LibCompileSlow.convertToOps(sources[i], pointers);
            LibCompile.unsafeCompile(sources[i], pointers);
        }
        uint256[] memory stack = new uint256[](2);

        InterpreterState memory state = InterpreterState(
            stack.dataPointer(),
            constants.dataPointer(),
            MemoryKV.wrap(0),
            FullyQualifiedNamespace.wrap(0),
            IInterpreterStoreV1(address(0)),
            new uint256[][](0),
            sources
        );

        Pointer stackTop = LibEval.eval(state, sourceIndex, state.stackBottom);
        uint256[] memory stackSlow = new uint256[](2);

        InterpreterState memory stateSlow = InterpreterState(
            stackSlow.dataPointer(),
            constants.dataPointer(),
            MemoryKV.wrap(0),
            FullyQualifiedNamespace.wrap(0),
            IInterpreterStoreV1(address(0)),
            new uint256[][](0),
            sources
        );

        Pointer stackTopSlow = LibEvalSlow.evalSlow(stateSlow, sourceIndex, stateSlow.stackBottom);

        assertEq(
            Pointer.unwrap(stackTop) - Pointer.unwrap(state.stackBottom),
            Pointer.unwrap(stackTopSlow) - Pointer.unwrap(stateSlow.stackBottom)
        );
        assertEq(stack, stackSlow);
    }
}
