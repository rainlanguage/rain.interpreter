// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheck.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {LibOpUint256ERC20TotalSupply} from "src/lib/op/erc20/uint256/LibOpUint256ERC20TotalSupply.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

/// @title LibOpUint256ERC20TotalSupplyTest
/// @notice Test the opcode for getting the total supply of an erc20 contract.
contract LibOpUint256ERC20TotalSupplyTest is OpTest {
    function testOpERC20TotalSupplyIntegrity(IntegrityCheckState memory state, OperandV2 operand) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpUint256ERC20TotalSupply.integrity(state, operand);

        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    function testOpERC20TotalSupplyRun(address account, uint256 totalSupply, uint16 operandData) external {
        assumeEtchable(account);
        vm.etch(account, hex"fe");

        StackItem[] memory inputs = new StackItem[](1);
        inputs[0] = StackItem.wrap(bytes32(uint256(uint160(account))));
        OperandV2 operand = LibOperand.build(1, 1, operandData);

        vm.mockCall(account, abi.encodeWithSelector(IERC20.totalSupply.selector), abi.encode(totalSupply));
        // called once for reference, once for run
        vm.expectCall(account, abi.encodeWithSelector(IERC20.totalSupply.selector), 2);

        opReferenceCheck(
            opTestDefaultInterpreterState(),
            operand,
            LibOpUint256ERC20TotalSupply.referenceFn,
            LibOpUint256ERC20TotalSupply.integrity,
            LibOpUint256ERC20TotalSupply.run,
            inputs
        );
    }

    /// Test the eval of totalSupply parsed from a string.
    function testOpERC20TotalSupplyEvalHappy(uint256 totalSupply) external {
        vm.mockCall(address(0xdeadbeef), abi.encodeWithSelector(IERC20.totalSupply.selector), abi.encode(totalSupply));
        checkHappy("_: uint256-erc20-total-supply(0xdeadbeef);", bytes32(totalSupply), "0xdeadbeef 0xdeadc0de");
    }

    /// Test that a totalSupply with bad inputs fails integrity.
    function testOpERC20TotalSupplyEvalZeroInputs() external {
        checkBadInputs("_: uint256-erc20-total-supply();", 0, 1, 0);
    }

    function testOpERC20TotalSupplyEvalTwoInputs() external {
        checkBadInputs("_: uint256-erc20-total-supply(0xdeadbeef 0xdeadc0de);", 2, 1, 2);
    }

    function testOpERC20TotalSupplyEvalZeroOutputs() external {
        checkBadOutputs(": uint256-erc20-total-supply(0xdeadbeef);", 1, 1, 0);
    }

    function testOpERC20TotalSupplyEvalTwoOutputs() external {
        checkBadOutputs("_ _: uint256-erc20-total-supply(0xdeadbeef);", 1, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpERC20TotalSupplyEvalOperandDisallowed() external {
        checkUnhappyParse(
            "_: uint256-erc20-total-supply<0>(0xdeadbeef);", abi.encodeWithSelector(UnexpectedOperand.selector)
        );
    }
}
