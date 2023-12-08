// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {LibOpERC20AllowanceNP} from "src/lib/op/erc20/LibOpERC20AllowanceNP.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";

/// @title LibOpERC20AllowanceNPTest
/// @notice Test the opcode for getting the allowance of an erc20 token.
contract LibOpERC20AllowanceNPTest is OpTest {
    function testOpERC20AllowanceNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpERC20AllowanceNP.integrity(state, operand);

        assertEq(calcInputs, 3);
        assertEq(calcOutputs, 1);
    }

    function testOpERC20AllowanceNPRun(address token, address owner, address spender, uint256 allowance) external {
        assumeEtchable(token);
        vm.etch(token, hex"fe");

        uint256[] memory inputs = new uint256[](3);
        inputs[0] = uint256(uint160(token));
        inputs[1] = uint256(uint160(owner));
        inputs[2] = uint256(uint160(spender));
        Operand operand = Operand.wrap(uint256(3) << 0x10);

        vm.mockCall(token, abi.encodeWithSelector(IERC20.allowance.selector, owner, spender), abi.encode(allowance));
        // called once for reference, once for run
        vm.expectCall(token, abi.encodeWithSelector(IERC20.allowance.selector, owner, spender), 2);

        opReferenceCheck(
            opTestDefaultInterpreterState(),
            operand,
            LibOpERC20AllowanceNP.referenceFn,
            LibOpERC20AllowanceNP.integrity,
            LibOpERC20AllowanceNP.run,
            inputs
        );
    }

    /// Test the eval of allowance parsed from a string.
    function testOpERC20AllowanceNPEvalHappy(uint256 allowance) external {
        vm.mockCall(
            address(0xdeadbeef),
            abi.encodeWithSelector(IERC20.allowance.selector, address(0xdeadc0de), address(0xdeaddead)),
            abi.encode(allowance)
        );
        checkHappy(
            "_: erc20-allowance(0xdeadbeef 0xdeadc0de 0xdeaddead);", allowance, "0xdeadbeef 0xdeadc0de 0xdeaddead"
        );
    }

    /// Test that a allowance with bad inputs fails integrity.
    function testOpERC20AllowanceNPEvalBadInputs() external {
        checkBadInputs("_: erc20-allowance();", 0, 3, 0);
        checkBadInputs("_: erc20-allowance(0xdeadbeef);", 1, 3, 1);
        checkBadInputs("_: erc20-allowance(0xdeadbeef 0xdeadc0de);", 2, 3, 2);
        checkBadInputs("_: erc20-allowance(0xdeadbeef 0xdeadc0de 0xdeaddead 0xdeaddead);", 4, 3, 4);
    }

    /// Test that operand is disallowed.
    function testOpERC20AllowanceNPEvalOperandDisallowed() external {
        checkUnhappyParse(
            "_: erc20-allowance<0>(0xdeadbeef 0xdeadc0de 0xdeaddead);",
            abi.encodeWithSelector(UnexpectedOperand.selector, 18)
        );
    }
}
