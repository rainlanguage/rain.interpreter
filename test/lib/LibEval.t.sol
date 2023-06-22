// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

import "forge-std/Test.sol";
import "rain.lib.memkv/LibMemoryKV.sol";
import "sol.lib.memory/LibPointer.sol";
import "sol.lib.memory/LibStackPointer.sol";
import "rain.lib.typecast/LibConvert.sol";

import "src/lib/LibEval.sol";
import "src/lib/LibCompile.sol";

import "./LibCompileSlow.sol";
import "./LibEvalSlow.sol";

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

    function opNoop(InterpreterState memory, Operand, Pointer pointer) internal pure returns (Pointer) {
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

    function prepGasTest(bytes memory source) internal pure returns (InterpreterState memory) {
        function (InterpreterState memory, Operand, Pointer) internal view returns (Pointer)[] memory fns =
            new function (InterpreterState memory, Operand, Pointer) internal view returns (Pointer)[](1);
        fns[0] = opNoop;
        uint256[] memory ufns;
        assembly ("memory-safe") {
            ufns := fns
        }
        bytes memory pointers = LibConvert.unsafeTo16BitBytes(ufns);

        bytes[] memory sources = new bytes[](1);
        sources[0] = source;
        LibCompile.unsafeCompile(sources[0], pointers);

        uint256[] memory empty = new uint256[](0);

        return InterpreterState(
            empty.dataPointer(),
            empty.dataPointer(),
            MemoryKV.wrap(0),
            FullyQualifiedNamespace.wrap(0),
            IInterpreterStoreV1(address(0)),
            new uint256[][](0),
            sources
        );
    }

    function testEvalGas0() public view {
        InterpreterState memory state = prepGasTest(hex"");
        Pointer stackTop = LibEval.eval(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSlow0() public view {
        InterpreterState memory state = prepGasTest(hex"");
        Pointer stackTop = LibEvalSlow.evalSlow(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSimpleLoop0() public view {
        InterpreterState memory state = prepGasTest(hex"");
        Pointer stackTop = LibEvalSlow.evalSimpleLoop(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGas1() public view {
        InterpreterState memory state = prepGasTest(hex"00000000");
        Pointer stackTop = LibEval.eval(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSlow1() public view {
        InterpreterState memory state = prepGasTest(hex"00000000");
        Pointer stackTop = LibEvalSlow.evalSlow(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSimpleLoop1() public view {
        InterpreterState memory state = prepGasTest(hex"00000000");
        Pointer stackTop = LibEvalSlow.evalSimpleLoop(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGas2() public view {
        InterpreterState memory state = prepGasTest(hex"0000000000000000");
        Pointer stackTop = LibEval.eval(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSlow2() public view {
        InterpreterState memory state = prepGasTest(hex"0000000000000000");
        Pointer stackTop = LibEvalSlow.evalSlow(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSimpleLoop2() public view {
        InterpreterState memory state = prepGasTest(hex"0000000000000000");
        Pointer stackTop = LibEvalSlow.evalSimpleLoop(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGas3() public view {
        InterpreterState memory state = prepGasTest(hex"00000000000000000000000000000000");
        Pointer stackTop = LibEval.eval(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSlow3() public view {
        InterpreterState memory state = prepGasTest(hex"00000000000000000000000000000000");
        Pointer stackTop = LibEvalSlow.evalSlow(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSimpleLoop3() public view {
        InterpreterState memory state = prepGasTest(hex"00000000000000000000000000000000");
        Pointer stackTop = LibEvalSlow.evalSimpleLoop(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGas4() public view {
        InterpreterState memory state =
            prepGasTest(hex"0000000000000000000000000000000000000000000000000000000000000000");
        Pointer stackTop = LibEval.eval(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSlow4() public view {
        InterpreterState memory state =
            prepGasTest(hex"0000000000000000000000000000000000000000000000000000000000000000");
        Pointer stackTop = LibEvalSlow.evalSlow(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSimpleLoop4() public view {
        InterpreterState memory state =
            prepGasTest(hex"0000000000000000000000000000000000000000000000000000000000000000");
        Pointer stackTop = LibEvalSlow.evalSimpleLoop(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGas5() public view {
        InterpreterState memory state = prepGasTest(
            hex"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
        Pointer stackTop = LibEval.eval(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSlow5() public view {
        InterpreterState memory state = prepGasTest(
            hex"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
        Pointer stackTop = LibEvalSlow.evalSlow(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSimpleLoop5() public view {
        InterpreterState memory state = prepGasTest(
            hex"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
        Pointer stackTop = LibEvalSlow.evalSimpleLoop(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGas6() public view {
        InterpreterState memory state = prepGasTest(
            hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
        Pointer stackTop = LibEval.eval(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSlow6() public view {
        InterpreterState memory state = prepGasTest(
            hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
        Pointer stackTop = LibEvalSlow.evalSlow(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSimpleLoop6() public view {
        InterpreterState memory state = prepGasTest(
            hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
        Pointer stackTop = LibEvalSlow.evalSimpleLoop(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGas7() public view {
        InterpreterState memory state = prepGasTest(
            hex"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
        Pointer stackTop = LibEval.eval(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSlow7() public view {
        InterpreterState memory state = prepGasTest(
            hex"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
        Pointer stackTop = LibEvalSlow.evalSlow(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSimpleLoop7() public view {
        InterpreterState memory state = prepGasTest(
            hex"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
        Pointer stackTop = LibEvalSlow.evalSimpleLoop(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGas8() public view {
        InterpreterState memory state = prepGasTest(
            hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
        Pointer stackTop = LibEval.eval(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSlow8() public view {
        InterpreterState memory state = prepGasTest(
            hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
        Pointer stackTop = LibEvalSlow.evalSlow(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
    }

    function testEvalGasSimpleLoop8() public view {
        InterpreterState memory state = prepGasTest(
            hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
        Pointer stackTop = LibEvalSlow.evalSimpleLoop(state, SourceIndex.wrap(0), state.stackBottom);
        (stackTop);
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

        uint256[] memory stackSimpleLoop = new uint256[](2);

        InterpreterState memory stateSimpleLoop = InterpreterState(
            stackSimpleLoop.dataPointer(),
            constants.dataPointer(),
            MemoryKV.wrap(0),
            FullyQualifiedNamespace.wrap(0),
            IInterpreterStoreV1(address(0)),
            new uint256[][](0),
            sources
        );

        Pointer stackTopSimpleLoop =
            LibEvalSlow.evalSimpleLoop(stateSimpleLoop, sourceIndex, stateSimpleLoop.stackBottom);

        assertEq(
            Pointer.unwrap(stackTop) - Pointer.unwrap(state.stackBottom),
            Pointer.unwrap(stackTopSimpleLoop) - Pointer.unwrap(stateSimpleLoop.stackBottom)
        );
        assertEq(stack, stackSimpleLoop);
    }
}
