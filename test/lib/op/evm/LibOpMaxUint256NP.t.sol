// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {LibOpMaxUint256NP} from "src/lib/op/evm/LibOpMaxUint256NP.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {
    IInterpreterV2, Operand, SourceIndexV2, FullyQualifiedNamespace
} from "src/interface/unstable/IInterpreterV2.sol";
import {InterpreterStateNP, LibInterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";
import {IInterpreterStoreV1} from "src/interface/IInterpreterStoreV1.sol";
import {SignedContextV1} from "src/interface/IInterpreterCallerV2.sol";

/// @title LibOpMaxUint256NPTest
/// @notice Test the runtime and integrity time logic of LibOpMaxUint256NP.
contract LibOpMaxUint256NPTest is OpTest {
    using LibInterpreterStateNP for InterpreterStateNP;

    /// Directly test the integrity logic of LibOpMaxUint256NP.
    function testOpMaxUint256NPIntegrity(IntegrityCheckStateNP memory state, uint8 inputs) external {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpMaxUint256NP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, 0);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpMaxUint256NP. This tests that the
    /// opcode correctly pushes the max uint256 onto the stack.
    function testOpMaxUint256NPRun() external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        uint256[] memory inputs = new uint256[](0);
        Operand operand = Operand.wrap(0);
        opReferenceCheck(
            state, operand, LibOpMaxUint256NP.referenceFn, LibOpMaxUint256NP.integrity, LibOpMaxUint256NP.run, inputs
        );
    }

    /// Test the eval of LibOpMaxUint256NP parsed from a string.
    function testOpMaxUint256NPEval(FullyQualifiedNamespace namespace) external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: max-int-value();");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);

        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            namespace,
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], type(uint256).max);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test that a max-int-value with inputs fails integrity check.
    function testOpMaxUint256NPEvalFail() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: max-int-value(0x00);");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 0, 1));
        iDeployer.deployExpression2(bytecode, constants);
    }
}
