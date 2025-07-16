// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheck.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {LibOpERC5313Owner} from "src/lib/op/erc5313/LibOpERC5313Owner.sol";
import {IERC5313} from "openzeppelin-contracts/contracts/interfaces/IERC5313.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

/// @title LibOpERC5313OwnerTest
/// @notice Test the opcode for getting the owner of an erc5313 contract.
contract LibOpERC5313OwnerTest is OpTest {
    function testOpERC5313OwnerOfIntegrity(IntegrityCheckState memory state, OperandV2 operand) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpERC5313Owner.integrity(state, operand);

        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    function testOpERC5313OwnerOfRun(address account, address owner, uint16 operandData) external {
        assumeEtchable(account);
        vm.etch(account, hex"fe");

        StackItem[] memory inputs = new StackItem[](1);
        inputs[0] = StackItem.wrap(bytes32(uint256(uint160(account))));
        OperandV2 operand = LibOperand.build(1, 1, operandData);

        vm.mockCall(account, abi.encodeWithSelector(IERC5313.owner.selector), abi.encode(owner));
        // called once for reference, once for run
        vm.expectCall(account, abi.encodeWithSelector(IERC5313.owner.selector), 2);

        opReferenceCheck(
            opTestDefaultInterpreterState(),
            operand,
            LibOpERC5313Owner.referenceFn,
            LibOpERC5313Owner.integrity,
            LibOpERC5313Owner.run,
            inputs
        );
    }

    /// Test the eval of owner parsed from a string.
    function testOpERC5313OwnerEvalHappy() external {
        vm.mockCall(
            address(0xdeadbeef), abi.encodeWithSelector(IERC5313.owner.selector), abi.encode(address(0xdeadc0de))
        );
        checkHappy("_: erc5313-owner(0xdeadbeef);", bytes32(uint256(0xdeadc0de)), "0xdeadbeef 0xdeadc0de");
    }

    /// Test that an owner with bad inputs fails integrity.
    function testOpERC5313OwnerEvalZeroInputs() external {
        checkBadInputs("_: erc5313-owner();", 0, 1, 0);
    }

    function testOpERC5313OwnerEvalTwoInputs() external {
        checkBadInputs("_: erc5313-owner(0xdeadbeef 0xdeadc0de);", 2, 1, 2);
    }

    function testOpERC5313OwnerEvalZeroOutputs() external {
        checkBadOutputs(": erc5313-owner(0xdeadbeef);", 1, 1, 0);
    }

    function testOpERC5313OwnerEvalTwoOutputs() external {
        checkBadOutputs("_ _: erc5313-owner(0xdeadbeef);", 1, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpERC5313OwnerEvalOperandDisallowed() external {
        checkUnhappyParse("_: erc5313-owner<0>(0xdeadbeef);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
