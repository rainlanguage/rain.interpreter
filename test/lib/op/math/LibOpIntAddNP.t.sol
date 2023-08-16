// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "rain.solmem/lib/LibUint256Array.sol";

import "test/util/abstract/OpTest.sol";
import "src/lib/caller/LibContext.sol";
import {UnexpectedOperand} from "src/lib/parse/LibParseOperand.sol";

contract LibOpIntAddNPTest is OpTest {
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpIntAddNP. This tests the happy
    /// path where the inputs input and calc match.
    function testOpIntAddNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        inputs = uint8(bound(inputs, 2, type(uint8).max));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpIntAddNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntAddNP. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpIntAddNPIntegrityUnhappyZeroInputs(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntAddNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntAddNP. This tests the unhappy
    /// path where the operand is invalid due to 1 inputs.
    function testOpIntAddNPIntegrityUnhappyOneInput(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntAddNP.integrity(state, Operand.wrap(0x010000));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpIntAddNP.
    function testOpIntAddNPRun(InterpreterStateNP memory state, uint256[] memory inputs) external {
        vm.assume(inputs.length >= 2);
        Operand operand = Operand.wrap(uint256(inputs.length) << 0x10);
        uint256 overflows = 0;
        assembly ("memory-safe") {
            let cursor := inputs
            let end := add(cursor, mul(add(mload(cursor), 1), 0x20))
            cursor := add(cursor, 0x20)
            for { let a := 0 } lt(cursor, end) { cursor := add(cursor, 0x20) } {
                let b := mload(cursor)
                let sum := add(a, b)
                if lt(sum, a) { overflows := add(overflows, 1) }
                a := sum
            }
        }
        if (overflows > 0) {
            vm.expectRevert(stdError.arithmeticError);
        }
        opReferenceCheck(state, operand, LibOpIntAddNP.referenceFn, LibOpIntAddNP.integrity, LibOpIntAddNP.run, inputs);
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests zero inputs.
    function testOpIntAddNPEvalZeroInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: int-add();");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (interpreterDeployer);
        (storeDeployer);
        (expression);
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests zero inputs.
    function testOpDecimal18AddNPEvalZeroInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: decimal18-add();");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (interpreterDeployer);
        (storeDeployer);
        (expression);
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests one input.
    function testOpIntAddNPEvalOneInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: int-add(5);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (interpreterDeployer);
        (storeDeployer);
        (expression);
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests one input.
    function testOpDecimal18AddNPEvalOneInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: decimal18-add(5);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (interpreterDeployer);
        (storeDeployer);
        (expression);
    }

    function checkHappy(bytes memory rainString, uint256 expectedValue) internal {
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
        assertEq(stack[0], expectedValue);
        assertEq(kvs.length, 0);
    }

    function checkUnhappyOverflow(bytes memory rainString) internal {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse(rainString);
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        vm.expectRevert(stdError.arithmeticError);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        (stack);
        (kvs);
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests two inputs.
    /// Tests the happy path where the addition does not overflow.
    function testOpIntAddNPEval2InputsHappy() external {
        checkHappy("_: int-add(5 6);", 11);
        checkHappy("_: int-add(6 5);", 11);
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests two inputs.
    /// Tests the happy path where the addition does not overflow.
    function testOpDecimal18AddNPEval2InputsHappy() external {
        checkHappy("_: decimal18-add(5 6);", 11);
        checkHappy("_: decimal18-add(6 5);", 11);
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests two inputs.
    /// Tests that adding 0 to 0 is 0.
    function testOpIntAddNPEval2InputsHappyZero() external {
        checkHappy("_: int-add(0 0);", 0);
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests two inputs.
    /// Tests that adding 0 to 0 is 0.
    function testOpDecimal18AddNPEval2InputsHappyZero() external {
        checkHappy("_: decimal18-add(0 0);", 0);
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests two inputs.
    /// Tests that adding 0 to 1 is 1.
    function testOpIntAddNPEval2InputsHappyZeroOne() external {
        checkHappy("_: int-add(0 1);", 1);
        checkHappy("_: int-add(1 0);", 1);
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests two inputs.
    /// Tests that adding 0 to 1 is 1.
    function testOpDecimal18AddNPEval2InputsHappyZeroOne() external {
        checkHappy("_: decimal18-add(0 1);", 1);
        checkHappy("_: decimal18-add(1 0);", 1);
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests two inputs.
    /// Tests that adding 0 to max-integer-value() is max-integer-value().
    function testOpIntAddNPEval2InputsHappyZeroMax() external {
        checkHappy("_: int-add(0 max-integer-value());", type(uint256).max);
        checkHappy("_: int-add(max-integer-value() 0);", type(uint256).max);
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests two inputs.
    /// Tests that adding 0 to max-integer-value() is max-integer-value().
    function testOpDecimal18AddNPEval2InputsHappyZeroMax() external {
        checkHappy("_: decimal18-add(0 max-integer-value());", type(uint256).max);
        checkHappy("_: decimal18-add(max-integer-value() 0);", type(uint256).max);
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests two inputs.
    /// Tests the unhappy path where the addition does overflow.
    function testOpIntAddNPEval2InputsUnhappy() external {
        checkUnhappyOverflow("_: int-add(max-integer-value() 1);");
        checkUnhappyOverflow("_: int-add(1 max-integer-value());");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests two inputs.
    /// Tests the unhappy path where the addition does overflow.
    function testOpDecimal18AddNPEval2InputsUnhappy() external {
        checkUnhappyOverflow("_: decimal18-add(max-integer-value() 1);");
        checkUnhappyOverflow("_: decimal18-add(1 max-integer-value());");
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests three inputs.
    /// Tests the happy path where the addition does not overflow.
    function testOpIntAddNPEval3InputsHappy() external {
        checkHappy("_: int-add(5 6 7);", 18);
        checkHappy("_: int-add(6 5 7);", 18);
        checkHappy("_: int-add(7 6 5);", 18);
        checkHappy("_: int-add(5 7 6);", 18);
        checkHappy("_: int-add(6 7 5);", 18);
        checkHappy("_: int-add(7 5 6);", 18);
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests three inputs.
    /// Tests the happy path where the addition does not overflow.
    function testOpDecimal18AddNPEval3InputsHappy() external {
        checkHappy("_: decimal18-add(5 6 7);", 18);
        checkHappy("_: decimal18-add(6 5 7);", 18);
        checkHappy("_: decimal18-add(7 6 5);", 18);
        checkHappy("_: decimal18-add(5 7 6);", 18);
        checkHappy("_: decimal18-add(6 7 5);", 18);
        checkHappy("_: decimal18-add(7 5 6);", 18);
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests three inputs.
    /// Tests the unhappy path where the addition does overflow.
    function testOpIntAddNPEval3InputsUnhappy() external {
        checkUnhappyOverflow("_: int-add(max-integer-value() 1 1);");
        checkUnhappyOverflow("_: int-add(1 max-integer-value() 1);");
        checkUnhappyOverflow("_: int-add(1 1 max-integer-value());");
        checkUnhappyOverflow("_: int-add(max-integer-value() max-integer-value() 1);");
        checkUnhappyOverflow("_: int-add(max-integer-value() 1 max-integer-value());");
        checkUnhappyOverflow("_: int-add(1 max-integer-value() max-integer-value());");
        checkUnhappyOverflow("_: int-add(max-integer-value() max-integer-value() max-integer-value());");
        checkUnhappyOverflow("_: int-add(max-integer-value() 1 0);");
        checkUnhappyOverflow("_: int-add(1 max-integer-value() 0);");
        checkUnhappyOverflow("_: int-add(1 0 max-integer-value());");
        checkUnhappyOverflow("_: int-add(max-integer-value() max-integer-value() 0);");
        checkUnhappyOverflow("_: int-add(max-integer-value() 0 max-integer-value());");
        checkUnhappyOverflow("_: int-add(0 max-integer-value() max-integer-value());");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests three inputs.
    /// Tests the unhappy path where the addition does overflow.
    function testOpDecimal18AddNPEval3InputsUnhappy() external {
        checkUnhappyOverflow("_: decimal18-add(max-integer-value() 1 1);");
        checkUnhappyOverflow("_: decimal18-add(1 max-integer-value() 1);");
        checkUnhappyOverflow("_: decimal18-add(1 1 max-integer-value());");
        checkUnhappyOverflow("_: decimal18-add(max-integer-value() max-integer-value() 1);");
        checkUnhappyOverflow("_: decimal18-add(max-integer-value() 1 max-integer-value());");
        checkUnhappyOverflow("_: decimal18-add(1 max-integer-value() max-integer-value());");
        checkUnhappyOverflow("_: decimal18-add(max-integer-value() max-integer-value() max-integer-value());");
        checkUnhappyOverflow("_: decimal18-add(max-integer-value() 1 0);");
        checkUnhappyOverflow("_: decimal18-add(1 max-integer-value() 0);");
        checkUnhappyOverflow("_: decimal18-add(1 0 max-integer-value());");
        checkUnhappyOverflow("_: decimal18-add(max-integer-value() max-integer-value() 0);");
        checkUnhappyOverflow("_: decimal18-add(max-integer-value() 0 max-integer-value());");
        checkUnhappyOverflow("_: decimal18-add(0 max-integer-value() max-integer-value());");
    }

    /// Test the eval of `int-add` opcode parsed from a string.
    /// Tests that operands are disallowed.
    function testOpIntAddNPEvalOperandDisallowed() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector, 10));
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: int-add<0>();");
        (bytecode);
        (constants);
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests that operands are disallowed.
    function testOpDecimal18AddNPEvalOperandDisallowed() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector, 16));
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: decimal18-add<0>();");
        (bytecode);
        (constants);
    }
}
