// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "rain.solmem/lib/LibMemCpy.sol";
import "rain.solmem/lib/LibUint256Array.sol";
import "rain.solmem/lib/LibPointer.sol";

import "./RainterpreterExpressionDeployerDeploymentTest.sol";
import "../../../src/lib/state/LibInterpreterStateNP.sol";

import "src/lib/caller/LibContext.sol";
import {UnexpectedOperand} from "src/lib/parse/LibParseOperand.sol";

uint256 constant PRE = uint256(keccak256(abi.encodePacked("pre")));
uint256 constant POST = uint256(keccak256(abi.encodePacked("post")));

abstract contract OpTest is RainterpreterExpressionDeployerDeploymentTest {
    using LibInterpreterStateNP for InterpreterStateNP;
    using LibUint256Array for uint256[];
    using LibPointer for Pointer;

    struct ReferenceCheckPointers {
        Pointer pre;
        Pointer post;
        Pointer stackTop;
        Pointer expectedStackTopAfter;
        // Initially this won't be populated. It will be populated by the
        // real function call.
        Pointer actualStackTopAfter;
    }

    function opReferenceCheckIntegrity(
        function(IntegrityCheckStateNP memory, Operand) pure returns (uint256, uint256) integrityFn,
        Operand operand,
        uint256[] memory constants,
        uint256[] memory inputs
    ) internal returns (uint256) {
        IntegrityCheckStateNP memory integrityState = LibIntegrityCheckNP.newState("", 0, constants.length);
        (uint256 calcInputs, uint256 calcOutputs) = integrityFn(integrityState, operand);
        assertEq(calcInputs, inputs.length, "inputs length");
        assertEq(calcInputs, Operand.unwrap(operand) >> 0x10, "operand inputs");
        return calcOutputs;
    }

    function opReferenceCheckPointers(uint256[] memory inputs, uint256 calcOutputs)
        internal
        pure
        returns (ReferenceCheckPointers memory pointers)
    {
        {
            uint256 inputsLength = inputs.length;
            Pointer prePointer;
            Pointer postPointer;
            Pointer stackTop;
            Pointer expectedStackTopAfter;
            assembly ("memory-safe") {
                let headroom := 0x20
                if gt(calcOutputs, inputsLength) {
                    headroom := add(headroom, mul(sub(calcOutputs, inputsLength), 0x20))
                }
                postPointer := mload(0x40)
                stackTop := add(postPointer, headroom)
                // Copy the inputs to the stack.
                let readCursor := add(inputs, 0x20)
                let writeCursor := stackTop
                prePointer := add(stackTop, mul(inputsLength, 0x20))
                for {} lt(writeCursor, prePointer) {
                    writeCursor := add(writeCursor, 0x20)
                    readCursor := add(readCursor, 0x20)
                } { mstore(writeCursor, mload(readCursor)) }

                expectedStackTopAfter := sub(add(stackTop, mul(inputsLength, 0x20)), mul(calcOutputs, 0x20))
                mstore(0x40, add(prePointer, 0x20))
            }
            pointers.pre = prePointer;
            pointers.pre.unsafeWriteWord(PRE);
            pointers.post = postPointer;
            pointers.post.unsafeWriteWord(POST);
            pointers.stackTop = stackTop;
            pointers.expectedStackTopAfter = expectedStackTopAfter;
            LibMemCpy.unsafeCopyWordsTo(inputs.dataPointer(), pointers.stackTop, inputs.length);
        }
    }

    function opReferenceCheckActual(
        InterpreterStateNP memory state,
        Operand operand,
        ReferenceCheckPointers memory pointers,
        function(InterpreterStateNP memory, Operand, Pointer) view returns (Pointer) runFn,
        bool allowStateMutations
    ) internal {
        bytes32 stateFingerprintBefore = state.fingerprint();
        pointers.actualStackTopAfter = runFn(state, operand, pointers.stackTop);
        bytes32 stateFingerprintAfter = state.fingerprint();

        if (!allowStateMutations) {
            assertEq(stateFingerprintBefore, stateFingerprintAfter, "state fingerprint");
        }
    }

    function opReferenceCheckExpectations(
        InterpreterStateNP memory state,
        Operand operand,
        function(InterpreterStateNP memory, Operand, uint256[] memory) view returns (uint256[] memory) referenceFn,
        ReferenceCheckPointers memory pointers,
        uint256[] memory inputs,
        uint256 calcOutputs
    ) internal {
        uint256[] memory expectedOutputs = referenceFn(state, operand, inputs);
        assertEq(expectedOutputs.length, calcOutputs, "expected outputs length");

        assertEq(
            Pointer.unwrap(pointers.actualStackTopAfter),
            Pointer.unwrap(pointers.expectedStackTopAfter),
            "stack top after"
        );
        assertEq(PRE, pointers.pre.unsafeReadWord(), "pre");
        for (uint256 i = 0; i < expectedOutputs.length; i++) {
            console2.log("expectedOutputs[i]", expectedOutputs[i]);
            assertEq(expectedOutputs[i], pointers.expectedStackTopAfter.unsafeReadWord(), "value");
            pointers.expectedStackTopAfter = pointers.expectedStackTopAfter.unsafeAddWord();
        }
        assertEq(POST, pointers.post.unsafeReadWord(), "post");
    }

    function opReferenceCheck(
        InterpreterStateNP memory state,
        Operand operand,
        function(InterpreterStateNP memory, Operand, uint256[] memory) view returns (uint256[] memory) referenceFn,
        function(IntegrityCheckStateNP memory, Operand) pure returns (uint256, uint256) integrityFn,
        function(InterpreterStateNP memory, Operand, Pointer) view returns (Pointer) runFn,
        uint256[] memory inputs,
        bool allowStateMutations
    ) internal {
        uint256 calcOutputs = opReferenceCheckIntegrity(integrityFn, operand, state.constants, inputs);
        ReferenceCheckPointers memory pointers = opReferenceCheckPointers(inputs, calcOutputs);

        opReferenceCheckActual(state, operand, pointers, runFn, allowStateMutations);
        opReferenceCheckExpectations(state, operand, referenceFn, pointers, inputs, calcOutputs);
    }

    function opReferenceCheck(
        InterpreterStateNP memory state,
        Operand operand,
        function(InterpreterStateNP memory, Operand, uint256[] memory) view returns (uint256[] memory) referenceFn,
        function(IntegrityCheckStateNP memory, Operand) pure returns (uint256, uint256) integrityFn,
        function(InterpreterStateNP memory, Operand, Pointer) view returns (Pointer) runFn,
        uint256[] memory inputs
    ) internal {
        opReferenceCheck(state, operand, referenceFn, integrityFn, runFn, inputs, false);
    }

    function checkHappy(bytes memory rainString, uint256 expectedValue, string memory errString) internal {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse(rainString);
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);

        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], expectedValue, errString);
        assertEq(kvs.length, 0);
    }

    function checkUnhappyOverflow(bytes memory rainString) internal {
        checkUnhappy(rainString, stdError.arithmeticError);
    }

    function checkUnhappy(bytes memory rainString, bytes memory err) internal {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse(rainString);
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        vm.expectRevert(err);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        (stack);
        (kvs);
    }

    function checkBadInputs(bytes memory rainString, uint256 opIndex, uint256 calcInputs, uint256 bytecodeInputs)
        internal
    {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse(rainString);
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 0;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, opIndex, calcInputs, bytecodeInputs));
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (interpreterDeployer);
        (storeDeployer);
        (expression);
    }

    function checkDisallowedOperand(bytes memory rainString, uint256 offset) internal {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector, offset));
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse(rainString);
        (bytecode);
        (constants);
    }
}
