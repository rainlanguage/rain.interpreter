// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";

import "src/lib/caller/LibContext.sol";

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
    function testOpMaxUint256NPRun(InterpreterStateNP memory state, uint256 seed) external {
        uint256[] memory inputs = new uint256[](0);
        Operand operand = Operand.wrap(0);
        opReferenceCheck(
            state,
            seed,
            operand,
            LibOpMaxUint256NP.referenceFn,
            LibOpMaxUint256NP.integrity,
            LibOpMaxUint256NP.run,
            inputs
        );
    }

    /// Test the eval of LibOpMaxUint256NP parsed from a string.
    function testOpMaxUint256NPEval(StateNamespace namespace) external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: max-uint-256();");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);

        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            namespace,
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], type(uint256).max);
        assertEq(kvs.length, 0);
    }

    /// Test that a max-uint-256 with inputs fails integrity check.
    function testOpMaxUint256NPEvalFail() public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: max-uint-256(0x00);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 0, 1));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }
}
