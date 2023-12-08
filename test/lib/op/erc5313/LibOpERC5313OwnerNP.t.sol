// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {LibOpERC5313OwnerNP} from "src/lib/op/erc5313/LibOpERC5313OwnerNP.sol";
import {IERC5313} from "openzeppelin-contracts/contracts/interfaces/IERC5313.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";

/// @title LibOpERC5313OwnerNPTest
/// @notice Test the opcode for getting the owner of an erc5313 contract.
contract LibOpERC5313OwnerNPTest is OpTest {
    function testOpERC5313OwnerOfNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpERC5313OwnerNP.integrity(state, operand);

        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    function testOpERC5313OwnerOfNPRun(address account, address owner) external {
        assumeEtchable(account);
        vm.etch(account, hex"fe");

        uint256[] memory inputs = new uint256[](1);
        inputs[0] = uint256(uint160(account));
        Operand operand = Operand.wrap(uint256(1) << 0x10);

        vm.mockCall(account, abi.encodeWithSelector(IERC5313.owner.selector), abi.encode(owner));
        // called once for reference, once for run
        vm.expectCall(account, abi.encodeWithSelector(IERC5313.owner.selector), 2);

        opReferenceCheck(
            opTestDefaultInterpreterState(),
            operand,
            LibOpERC5313OwnerNP.referenceFn,
            LibOpERC5313OwnerNP.integrity,
            LibOpERC5313OwnerNP.run,
            inputs
        );
    }

    /// Test the eval of owner parsed from a string.
    function testOpERC5313OwnerNPEvalHappy() external {
        vm.mockCall(
            address(0xdeadbeef), abi.encodeWithSelector(IERC5313.owner.selector), abi.encode(address(0xdeadc0de))
        );
        checkHappy("_: erc5313-owner(0xdeadbeef);", 0xdeadc0de, "0xdeadbeef 0xdeadc0de");
    }

    /// Test that an owner with bad inputs fails integrity.
    function testOpERC5313OwnerNPEvalBadInputs() external {
        checkBadInputs("_: erc5313-owner();", 0, 1, 0);
        checkBadInputs("_: erc5313-owner(0xdeadbeef 0xdeadc0de);", 2, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpERC5313OwnerNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: erc5313-owner<0>(0xdeadbeef);", abi.encodeWithSelector(UnexpectedOperand.selector, 16));
    }
}
