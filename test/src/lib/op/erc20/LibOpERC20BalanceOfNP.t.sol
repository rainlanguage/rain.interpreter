// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {LibOpERC20BalanceOfNP} from "src/lib/op/erc20/LibOpERC20BalanceOfNP.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

/// @title LibOpERC20BalanceOfNPTest
/// @notice Test the opcode for getting the balance of an erc20 token.
contract LibOpERC20BalanceOfNPTest is OpTest {
    function testOpERC20BalanceOfNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpERC20BalanceOfNP.integrity(state, operand);

        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    function testOpERC20BalanceOfNPRun(address token, address account, uint256 balance, uint16 operandData) external {
        assumeEtchable(token);
        vm.etch(token, hex"fe");

        uint256[] memory inputs = new uint256[](2);
        inputs[0] = uint256(uint160(token));
        inputs[1] = uint256(uint160(account));
        Operand operand = LibOperand.build(2, 1, operandData);

        vm.mockCall(token, abi.encodeWithSelector(IERC20.balanceOf.selector, account), abi.encode(balance));
        // called once for reference, once for run
        vm.expectCall(token, abi.encodeWithSelector(IERC20.balanceOf.selector, account), 2);

        opReferenceCheck(
            opTestDefaultInterpreterState(),
            operand,
            LibOpERC20BalanceOfNP.referenceFn,
            LibOpERC20BalanceOfNP.integrity,
            LibOpERC20BalanceOfNP.run,
            inputs
        );
    }

    /// Test the eval of balanceOf parsed from a string.
    function testOpERC20BalanceOfNPEvalHappy(uint256 balance) external {
        vm.mockCall(
            address(0xdeadbeef),
            abi.encodeWithSelector(IERC20.balanceOf.selector, address(0xdeadc0de)),
            abi.encode(balance)
        );
        checkHappy("_: erc20-balance-of(0xdeadbeef 0xdeadc0de);", balance, "0xdeadbeef 0xdeadc0de");
    }

    /// Test that a balanceOf with bad inputs fails integrity.
    function testOpERC20BalanceOfNPEvalZeroInputs() external {
        checkBadInputs("_: erc20-balance-of();", 0, 2, 0);
    }

    function testOpERC20BalanceOfNPEvalOneInput() external {
        checkBadInputs("_: erc20-balance-of(0xdeadbeef);", 1, 2, 1);
    }

    function testOpERC20BalanceOfNPEvalThreeInputs() external {
        checkBadInputs("_: erc20-balance-of(0xdeadbeef 0xdeadc0de 0xdeadc0de);", 3, 2, 3);
    }

    function testOpERC20BalanceOfNPEvalZeroOutputs() external {
        checkBadOutputs(": erc20-balance-of(0xdeadbeef 0xdeadc0de);", 2, 1, 0);
    }

    function testOpERC20BalanceOfNPEvalTwoOutputs() external {
        checkBadOutputs("_ _: erc20-balance-of(0xdeadbeef 0xdeadc0de);", 2, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpERC20BalanceOfNPEvalOperandDisallowed() external {
        checkUnhappyParse(
            "_: erc20-balance-of<0>(0xdeadbeef 0xdeadc0de);", abi.encodeWithSelector(UnexpectedOperand.selector)
        );
    }
}
