// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test, stdError} from "forge-std/Test.sol";
import {LibMemCpy} from "rain.solmem/lib/LibMemCpy.sol";
import {MemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";

import {RainterpreterExpressionDeployerNPE2DeploymentTest} from
    "./RainterpreterExpressionDeployerNPE2DeploymentTest.sol";
import {LibInterpreterStateNP, InterpreterStateNP} from "../../../src/lib/state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP, LibIntegrityCheckNP} from "../../../src/lib/integrity/LibIntegrityCheckNP.sol";

import {LibContext} from "../../../src/lib/caller/LibContext.sol";
import {UnexpectedOperand} from "../../../src/error/ErrParse.sol";
import {BadOpInputsLength} from "../../../src/lib/integrity/LibIntegrityCheckNP.sol";
import {Operand, IInterpreterV2, SourceIndexV2} from "../../../src/interface/unstable/IInterpreterV2.sol";
import {
    IInterpreterStoreV1,
    FullyQualifiedNamespace,
    StateNamespace
} from "../../../src/interface/IInterpreterStoreV1.sol";
import {SignedContextV1} from "../../../src/interface/IInterpreterCallerV2.sol";
import {LibEncodedDispatch} from "../../../src/lib/caller/LibEncodedDispatch.sol";
import {LibNamespace} from "../../../src/lib/ns/LibNamespace.sol";

uint256 constant PRE = uint256(keccak256(abi.encodePacked("pre")));
uint256 constant POST = uint256(keccak256(abi.encodePacked("post")));

abstract contract OpTest is RainterpreterExpressionDeployerNPE2DeploymentTest {
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

    function assumeEtchable(address account) internal view {
        assumeEtchable(account, address(0));
    }

    function assumeEtchable(address account, address expression) internal view {
        assumeNotPrecompile(account);
        vm.assume(account != address(iDeployer));
        vm.assume(account != address(iInterpreter));
        vm.assume(account != address(iStore));
        vm.assume(account != address(iParser));
        vm.assume(account != address(this));
        vm.assume(account != address(vm));
        vm.assume(account != address(expression));
        // The console.
        vm.assume(account != address(0x000000000000000000636F6e736F6c652e6c6f67));
    }

    function opTestDefaultIngegrityCheckState() internal pure returns (IntegrityCheckStateNP memory) {
        return IntegrityCheckStateNP(0, 0, 0, new uint256[](0), 0, "");
    }

    function opTestDefaultInterpreterState() internal view returns (InterpreterStateNP memory) {
        return InterpreterStateNP(
            new Pointer[](0),
            new uint256[](0),
            0,
            MemoryKV.wrap(0),
            // Treat ourselves as the sender as we eval internally to directly
            // test the opcode logic.
            LibNamespace.qualifyNamespace(StateNamespace.wrap(0), address(this)),
            IInterpreterStoreV1(address(iStore)),
            new uint256[][](0),
            "",
            ""
        );
    }

    function opReferenceCheckIntegrity(
        function(IntegrityCheckStateNP memory, Operand) view returns (uint256, uint256) integrityFn,
        Operand operand,
        uint256[] memory constants,
        uint256[] memory inputs
    ) internal returns (uint256) {
        IntegrityCheckStateNP memory integrityState = LibIntegrityCheckNP.newState("", 0, constants);
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
        function(InterpreterStateNP memory, Operand, Pointer) view returns (Pointer) runFn
    ) internal {
        bytes32 stateFingerprintBefore = state.fingerprint();
        pointers.actualStackTopAfter = runFn(state, operand, pointers.stackTop);
        bytes32 stateFingerprintAfter = state.fingerprint();

        assertEq(stateFingerprintBefore, stateFingerprintAfter, "state fingerprint");
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
            assertEq(expectedOutputs[i], pointers.expectedStackTopAfter.unsafeReadWord(), "value");
            pointers.expectedStackTopAfter = pointers.expectedStackTopAfter.unsafeAddWord();
        }
        assertEq(POST, pointers.post.unsafeReadWord(), "post");
    }

    function opReferenceCheck(
        InterpreterStateNP memory state,
        Operand operand,
        function(InterpreterStateNP memory, Operand, uint256[] memory) view returns (uint256[] memory) referenceFn,
        function(IntegrityCheckStateNP memory, Operand) view returns (uint256, uint256) integrityFn,
        function(InterpreterStateNP memory, Operand, Pointer) view returns (Pointer) runFn,
        uint256[] memory inputs
    ) internal {
        uint256 calcOutputs = opReferenceCheckIntegrity(integrityFn, operand, state.constants, inputs);
        ReferenceCheckPointers memory pointers = opReferenceCheckPointers(inputs, calcOutputs);

        opReferenceCheckActual(state, operand, pointers, runFn);
        opReferenceCheckExpectations(state, operand, referenceFn, pointers, inputs, calcOutputs);
    }

    function parseAndEval(bytes memory rainString) internal returns (uint256[] memory, uint256[] memory) {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse(rainString);
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (io);

        // Put something in the caller context, in case we want to read it.
        uint256[][] memory callerContext = new uint256[][](1);
        callerContext[0] = new uint256[](1);
        callerContext[0][0] = rainString.length;

        uint256[][] memory context = LibContext.build(callerContext, new SignedContextV1[](0));
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            LibNamespace.qualifyNamespace(StateNamespace.wrap(0), address(this)),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), type(uint16).max),
            context,
            new uint256[](0)
        );
        return (stack, kvs);
    }

    function checkHappy(bytes memory rainString, uint256 expectedValue, string memory errString) internal {
        (uint256[] memory stack, uint256[] memory kvs) = parseAndEval(rainString);

        assertEq(stack.length, 1);
        assertEq(stack[0], expectedValue, errString);
        assertEq(kvs.length, 0);
    }

    function checkHappy(bytes memory rainString, uint256[] memory expectedStack, string memory errString) internal {
        (uint256[] memory stack, uint256[] memory kvs) = parseAndEval(rainString);

        assertEq(stack.length, expectedStack.length, errString);
        for (uint256 i = 0; i < expectedStack.length; i++) {
            assertEq(stack[i], expectedStack[i], errString);
        }
        assertEq(kvs.length, 0);
    }

    function checkHappyKVs(bytes memory rainString, uint256[] memory expectedKVs, string memory errString) internal {
        (uint256[] memory stack, uint256[] memory kvs) = parseAndEval(rainString);

        assertEq(stack.length, 0);
        assertEq(kvs.length, expectedKVs.length, errString);
        for (uint256 i = 0; i < expectedKVs.length; i++) {
            assertEq(kvs[i], expectedKVs[i], errString);
        }
    }

    function checkUnhappyOverflow(bytes memory rainString) internal {
        checkUnhappy(rainString, stdError.arithmeticError);
    }

    function checkUnhappy(bytes memory rainString, bytes memory err) internal {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse(rainString);
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (io);
        vm.expectRevert(err);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        (stack, kvs);
    }

    function checkUnhappyDeploy(bytes memory rainString, bytes memory err) internal {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse(rainString);
        vm.expectRevert(err);
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (interpreterDeployer, storeDeployer, expression, io);
    }

    function checkUnhappyParse(bytes memory rainString, bytes memory err) internal {
        vm.expectRevert(err);
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse(rainString);
        (bytecode);
        (constants);
    }

    function checkBadInputs(bytes memory rainString, uint256 opIndex, uint256 calcInputs, uint256 bytecodeInputs)
        internal
    {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse(rainString);
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, opIndex, calcInputs, bytecodeInputs));
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (interpreterDeployer, storeDeployer, expression, io);
    }

    function checkDisallowedOperand(bytes memory rainString) internal {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector));
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse(rainString);
        (bytecode);
        (constants);
    }
}
