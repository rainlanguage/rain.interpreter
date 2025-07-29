// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest, IntegrityCheckState, OperandV2, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpPow} from "src/lib/op/math/LibOpPow.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";

contract LibOpPowTest is OpTest {

    function beforeOpTestConstructor() internal override virtual {
        vm.createSelectFork("https://1rpc.io/arb");
    }

    /// Directly test the integrity logic of LibOpPow.
    /// Inputs are always 2, outputs are always 1.
    function testOpPowIntegrity(IntegrityCheckState memory state, OperandV2 operand) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpPow.integrity(state, operand);
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

//     /// Directly test the runtime logic of LibOpPow.
//     function testOpPowRun(uint256 a, uint256 b) public view {
//         // @TODO This is a hack to get around the fact that we are very likely
//         // to overflow uint256 if we just fuzz it, and that it's clunky to
//         // determine whether it will overflow or not. Basically the overflow
//         // check is exactly the same as the implementation, including all the
//         // intermediate squaring, so it seems like a bit of circular logic to
//         // do things that way.
//         a = bound(a, 0, type(uint64).max);
//         b = bound(b, 0, 10);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(2, 1, 0);
//         uint256[] memory inputs = new uint256[](2);
//         inputs[0] = a;
//         inputs[1] = b;

//         opReferenceCheck(state, operand, LibOpPow.referenceFn, LibOpPow.integrity, LibOpPow.run, inputs);
//     }

/// Test the eval of `power`.
function testOpPowEval() external view {
    // 0 ^ 0
    // checkHappy("_: power(0 0);", Float.unwrap(LibDecimalFloat.packLossless(1, 0)), "0 0");
    // 0 ^ 1
    checkHappy("_: power(0 1);", 0, "0 1");
    // 1 ^ 0
    checkHappy("_: power(1 0);", Float.unwrap(LibDecimalFloat.packLossless(1e3, -3)), "1 0");
    // 1 ^ 1
    checkHappy("_: power(1 1);", Float.unwrap(LibDecimalFloat.packLossless(1e3, -3)), "1 1");
    // 1 ^ 2
    checkHappy("_: power(1 2);", Float.unwrap(LibDecimalFloat.packLossless(1e3, -3)), "1 2");
    // 2 ^ 2
    checkHappy("_: power(2 2);", Float.unwrap(LibDecimalFloat.packLossless(3999, -3)), "2 2");
    // 2 ^ 3
    checkHappy("_: power(2 3);", Float.unwrap(LibDecimalFloat.packLossless(7998, -3)), "2 3");
    // 2 ^ 4
    checkHappy("_: power(2 4);", Float.unwrap(LibDecimalFloat.packLossless(1600, -2)), "2 4");
    // sqrt 4 = 2
    checkHappy("_: power(4 0.5);", Float.unwrap(LibDecimalFloat.packLossless(2e3, -3)), "4 5");
}

    /// Test the eval of `power` for bad inputs.
    function testOpPowEvalOneInput() external {
        checkBadInputs("_: power(1);", 1, 2, 1);
    }

    function testOpPowThreeInputs() external {
        checkBadInputs("_: power(1 1 1);", 3, 2, 3);
    }

    function testOpPowZeroOutputs() external {
        checkBadOutputs(": power(1 1);", 2, 1, 0);
    }

    function testOpPowTwoOutputs() external {
        checkBadOutputs("_ _: power(1 1);", 2, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpPowEvalOperandDisallowed() external {
        checkUnhappyParse("_: power<0>(1 1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
