// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheck.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {LibOpUint256ERC20Allowance} from "src/lib/op/erc20/uint256/LibOpUint256ERC20Allowance.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

/// @title LibOpUint256ERC20AllowanceTest
/// @notice Test the opcode for getting the allowance of an erc20 token.
contract LibOpUint256ERC20AllowanceTest is OpTest {
    function testOpERC20AllowanceIntegrity(IntegrityCheckState memory state, OperandV2 operand) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpUint256ERC20Allowance.integrity(state, operand);

        assertEq(calcInputs, 3);
        assertEq(calcOutputs, 1);
    }

    function testOpERC20AllowanceRun(address token, address owner, address spender, uint256 allowance) external {
        assumeEtchable(token);
        vm.etch(token, hex"fe");

        StackItem[] memory inputs = new StackItem[](3);
        inputs[0] = StackItem.wrap(bytes32(uint256(uint160(token))));
        inputs[1] = StackItem.wrap(bytes32(uint256(uint160(owner))));
        inputs[2] = StackItem.wrap(bytes32(uint256(uint160(spender))));
        OperandV2 operand = LibOperand.build(3, 1, 0);

        vm.mockCall(token, abi.encodeWithSelector(IERC20.allowance.selector, owner, spender), abi.encode(allowance));
        // called once for reference, once for run
        vm.expectCall(token, abi.encodeWithSelector(IERC20.allowance.selector, owner, spender), 2);

        opReferenceCheck(
            opTestDefaultInterpreterState(),
            operand,
            LibOpUint256ERC20Allowance.referenceFn,
            LibOpUint256ERC20Allowance.integrity,
            LibOpUint256ERC20Allowance.run,
            inputs
        );
    }

    /// Test the eval of allowance parsed from a string.
    function testOpERC20AllowanceEvalHappy(uint256 allowance) external {
        vm.mockCall(
            address(0xdeadbeef),
            abi.encodeWithSelector(IERC20.allowance.selector, address(0xdeadc0de), address(0xdeaddead)),
            abi.encode(allowance)
        );
        checkHappy(
            "_: uint256-erc20-allowance(0xdeadbeef 0xdeadc0de 0xdeaddead);",
            bytes32(allowance),
            "0xdeadbeef 0xdeadc0de 0xdeaddead"
        );
    }

    /// Test that a allowance with bad inputs fails integrity.
    function testOpERC20AllowanceEvalZeroInputs() external {
        checkBadInputs("_: uint256-erc20-allowance();", 0, 3, 0);
    }

    function testOpERC20AllowanceEvalOneInput() external {
        checkBadInputs("_: uint256-erc20-allowance(0xdeadbeef);", 1, 3, 1);
    }

    function testOpERC20AllowanceEvalTwoInputs() external {
        checkBadInputs("_: uint256-erc20-allowance(0xdeadbeef 0xdeadc0de);", 2, 3, 2);
    }

    function testOpERC20AllowanceEvalFourInputs() external {
        checkBadInputs("_: uint256-erc20-allowance(0xdeadbeef 0xdeadc0de 0xdeaddead 0xdeaddead);", 4, 3, 4);
    }

    function testOpERC20AllowanceEvalZeroOutputs() external {
        checkBadOutputs(": uint256-erc20-allowance(0xdeadbeef 0xdeadc0de 0xdeaddead);", 3, 1, 0);
    }

    function testOpERC20AllowanceEvalTwoOutputs() external {
        checkBadOutputs("_ _: uint256-erc20-allowance(0xdeadbeef 0xdeadc0de 0xdeaddead);", 3, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpERC20AllowanceEvalOperandDisallowed() external {
        checkUnhappyParse(
            "_: uint256-erc20-allowance<0>(0xdeadbeef 0xdeadc0de 0xdeaddead);",
            abi.encodeWithSelector(UnexpectedOperand.selector)
        );
    }
}
