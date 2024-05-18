// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {LibOpERC20TotalSupplyNP} from "src/lib/op/erc20/LibOpERC20TotalSupplyNP.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

/// @title LibOpERC20TotalSupplyNPTest
/// @notice Test the opcode for getting the total supply of an erc20 contract.
contract LibOpERC20TotalSupplyNPTest is OpTest {
    function testOpERC20TotalSupplyNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpERC20TotalSupplyNP.integrity(state, operand);

        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    function testOpERC20TotalSupplyNPRun(address account, uint256 totalSupply, uint16 operandData) external {
        assumeEtchable(account);
        vm.etch(account, hex"fe");

        uint256[] memory inputs = new uint256[](1);
        inputs[0] = uint256(uint160(account));
        Operand operand = LibOperand.build(1, 1, operandData);

        vm.mockCall(account, abi.encodeWithSelector(IERC20.totalSupply.selector), abi.encode(totalSupply));
        // called once for reference, once for run
        vm.expectCall(account, abi.encodeWithSelector(IERC20.totalSupply.selector), 2);

        opReferenceCheck(
            opTestDefaultInterpreterState(),
            operand,
            LibOpERC20TotalSupplyNP.referenceFn,
            LibOpERC20TotalSupplyNP.integrity,
            LibOpERC20TotalSupplyNP.run,
            inputs
        );
    }

    /// Test the eval of totalSupply parsed from a string.
    function testOpERC20TotalSupplyNPEvalHappy(uint256 totalSupply) external {
        vm.mockCall(address(0xdeadbeef), abi.encodeWithSelector(IERC20.totalSupply.selector), abi.encode(totalSupply));
        checkHappy("_: erc20-total-supply(0xdeadbeef);", totalSupply, "0xdeadbeef 0xdeadc0de");
    }

    /// Test that a totalSupply with bad inputs fails integrity.
    function testOpERC20TotalSupplyNPEvalZeroInputs() external {
        checkBadInputs("_: erc20-total-supply();", 0, 1, 0);
    }

    function testOpERC20TotalSupplyNPEvalTwoInputs() external {
        checkBadInputs("_: erc20-total-supply(0xdeadbeef 0xdeadc0de);", 2, 1, 2);
    }

    function testOpERC20TotalSupplyNPEvalZeroOutputs() external {
        checkBadOutputs(": erc20-total-supply(0xdeadbeef);", 1, 1, 0);
    }

    function testOpERC20TotalSupplyNPEvalTwoOutputs() external {
        checkBadOutputs("_ _: erc20-total-supply(0xdeadbeef);", 1, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpERC20TotalSupplyNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: erc20-total-supply<0>(0xdeadbeef);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
