// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";
import "src/lib/caller/LibContext.sol";
import {ExcessRHSItems} from "src/lib/parse/LibParse.sol";
import {LibOpEnsureNP, EnsureFailed} from "src/lib/op/logic/LibOpEnsureNP.sol";

contract LibOpEnsureNPTest is OpTest {
    /// Directly test the integrity logic of LibOpEnsureNP. This tests the
    /// happy path where there is at least one input.
    function testOpEnsureNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        inputs = uint8(bound(inputs, 1, type(uint8).max));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpEnsureNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));
        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 0);
    }

    /// Directly test the integrity logic of LibOpEnsureNP. This tests the
    /// unhappy path where there are no inputs.
    function testOpEnsureNPIntegrityUnhappy(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpEnsureNP.integrity(state, Operand.wrap(0));
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 0);
    }

    /// Directly test the run logic of LibOpEnsureNP.
    function testOpEnsureNPRun(uint256[] memory inputs, uint16 errorCode) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.assume(inputs.length > 0);
        vm.assume(inputs.length <= type(uint8).max);
        Operand operand = Operand.wrap(uint256(inputs.length) << 0x10 | uint256(errorCode));
        for (uint256 i = 0; i < inputs.length; i++) {
            if (inputs[i] == 0) {
                vm.expectRevert(abi.encodeWithSelector(EnsureFailed.selector, errorCode, i));
                break;
            }
        }
        opReferenceCheck(state, operand, LibOpEnsureNP.referenceFn, LibOpEnsureNP.integrity, LibOpEnsureNP.run, inputs);
    }

    /// Test the eval of `ensure` parsed from a string. Tests zero inputs.
    function testOpEnsureNPEvalZero() external {
        checkBadInputs(":ensure();", 0, 1, 0);
    }

    /// Test the eval of `ensure` parsed from a string. Tests that ensure cannot
    /// be used on the same line as another word as it has non-one outputs.
    /// Tests ensuring with an addition on the same line.
    function testOpEnsureNPEvalBadOutputs() external {
        vm.expectRevert(abi.encodeWithSelector(ExcessRHSItems.selector, 24));
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_:ensure(1) int-add(1 1);");
        (bytecode);
        (constants);
    }

    /// Test the eval of `ensure` parsed from a string. Tests that ensure cannot
    /// be used on the same line as another word as it has non-one outputs.
    /// Tests ensuring with another ensure on the same line.
    function testOpEnsureNPEvalBadOutputs2() external {
        vm.expectRevert(abi.encodeWithSelector(ExcessRHSItems.selector, 20));
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse(":ensure(1) ensure(1);");
        (bytecode);
        (constants);
    }

    /// Test the eval of `ensure` parsed from a string. Tests the happy path
    /// where all inputs are nonzero.
    function testOpEnsureNPEvalHappy() external {
        // Check without operand.
        checkHappy(":ensure(1), _:1;", 1, "1");
        checkHappy(":ensure(5), _:1;", 1, "5");
        checkHappy(":ensure(1 2), _:1;", 1, "1 2");
        checkHappy(":ensure(1 2 3), _:1;", 1, "1 2 3");
        checkHappy(":ensure(1 2 3 4), _:1;", 1, "1 2 3 4");
        checkHappy(":ensure(1 2 3 4 5), _:1;", 1, "1 2 3 4 5");

        // Check with 0 operand.
        checkHappy(":ensure<0>(1), _:1;", 1, "1");
        checkHappy(":ensure<0>(5), _:1;", 1, "5");
        checkHappy(":ensure<0>(1 2), _:1;", 1, "1 2");
        checkHappy(":ensure<0>(1 2 3), _:1;", 1, "1 2 3");
        checkHappy(":ensure<0>(1 2 3 4), _:1;", 1, "1 2 3 4");
        checkHappy(":ensure<0>(1 2 3 4 5), _:1;", 1, "1 2 3 4 5");

        // Check with 1 operand.
        checkHappy(":ensure<1>(1), _:1;", 1, "1");
        checkHappy(":ensure<1>(5), _:1;", 1, "5");
        checkHappy(":ensure<1>(1 2), _:1;", 1, "1 2");
        checkHappy(":ensure<1>(1 2 3), _:1;", 1, "1 2 3");
        checkHappy(":ensure<1>(1 2 3 4), _:1;", 1, "1 2 3 4");
        checkHappy(":ensure<1>(1 2 3 4 5), _:1;", 1, "1 2 3 4 5");

        // Check with max uint16 operand.
        checkHappy(":ensure<0xFFFF>(1), _:1;", 1, "1");
        checkHappy(":ensure<0xFFFF>(5), _:1;", 1, "5");
        checkHappy(":ensure<0xFFFF>(1 2), _:1;", 1, "1 2");
        checkHappy(":ensure<0xFFFF>(1 2 3), _:1;", 1, "1 2 3");
        checkHappy(":ensure<0xFFFF>(1 2 3 4), _:1;", 1, "1 2 3 4");
        checkHappy(":ensure<0xFFFF>(1 2 3 4 5), _:1;", 1, "1 2 3 4 5");
    }

    /// Test the eval of `ensure` parsed from a string. Tests the unhappy path
    /// where at least one input is zero.
    function testOpEnsureNPEvalUnhappy() external {
        // Check without operand.
        checkUnhappy(":ensure(0), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0, 0));
        checkUnhappy(":ensure(0 1), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0, 0));
        checkUnhappy(":ensure(1 0), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0, 1));
        checkUnhappy(":ensure(0 1 2), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0, 0));
        checkUnhappy(":ensure(1 0 2), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0, 1));
        checkUnhappy(":ensure(1 2 0), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0, 2));

        // Check with 0 operand.
        checkUnhappy(":ensure<0>(0), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0, 0));
        checkUnhappy(":ensure<0>(0 1), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0, 0));
        checkUnhappy(":ensure<0>(1 0), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0, 1));
        checkUnhappy(":ensure<0>(0 1 2), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0, 0));
        checkUnhappy(":ensure<0>(1 0 2), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0, 1));
        checkUnhappy(":ensure<0>(1 2 0), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0, 2));

        // Check with 1 operand.
        checkUnhappy(":ensure<1>(0), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 1, 0));
        checkUnhappy(":ensure<1>(0 1), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 1, 0));
        checkUnhappy(":ensure<1>(1 0), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 1, 1));
        checkUnhappy(":ensure<1>(0 1 2), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 1, 0));
        checkUnhappy(":ensure<1>(1 0 2), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 1, 1));
        checkUnhappy(":ensure<1>(1 2 0), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 1, 2));

        // Check with max uint16 operand.
        checkUnhappy(":ensure<0xFFFF>(0), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0xFFFF, 0));
        checkUnhappy(":ensure<0xFFFF>(0 1), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0xFFFF, 0));
        checkUnhappy(":ensure<0xFFFF>(1 0), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0xFFFF, 1));
        checkUnhappy(":ensure<0xFFFF>(0 1 2), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0xFFFF, 0));
        checkUnhappy(":ensure<0xFFFF>(1 0 2), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0xFFFF, 1));
        checkUnhappy(":ensure<0xFFFF>(1 2 0), _:1;", abi.encodeWithSelector(EnsureFailed.selector, 0xFFFF, 2));
    }
}
