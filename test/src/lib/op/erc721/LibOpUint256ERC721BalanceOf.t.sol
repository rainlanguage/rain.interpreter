// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckState, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheck.sol";
import {LibOpERC721BalanceOf} from "src/lib/op/erc721/LibOpERC721BalanceOf.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {
    FullyQualifiedNamespace,
    OperandV2,
    SourceIndexV2,
    EvalV4
} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV3.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpERC721BalanceOfTest
/// @notice Test the opcode for getting the balance of an erc721 token.
contract LibOpERC721BalanceOfTest is OpTest {
    function testOpERC721BalanceOfIntegrity(
        IntegrityCheckState memory state,
        uint8 inputs,
        uint8 outputs,
        uint16 operandData
    ) external pure {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpERC721BalanceOf.integrity(state, LibOperand.build(inputs, outputs, operandData));

        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    function testOpERC721BalanceOfRun(address token, address account, uint256 balance, uint16 operandData) external {
        assumeEtchable(token);
        vm.etch(token, hex"fe");

        (, bool lossless) = LibDecimalFloat.fromFixedDecimalLossyPacked(balance, 0);
        vm.assume(lossless);

        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] = StackItem.wrap(bytes32(uint256(uint160(token))));
        inputs[1] = StackItem.wrap(bytes32(uint256(uint160(account))));
        OperandV2 operand = LibOperand.build(2, 1, operandData);

        // invalid token
        vm.mockCall(token, abi.encodeWithSelector(IERC721.balanceOf.selector, account), abi.encode(balance));
        // called once for reference, once for run
        vm.expectCall(token, abi.encodeWithSelector(IERC721.balanceOf.selector, account), 2);

        opReferenceCheck(
            opTestDefaultInterpreterState(),
            operand,
            LibOpERC721BalanceOf.referenceFn,
            LibOpERC721BalanceOf.integrity,
            LibOpERC721BalanceOf.run,
            inputs
        );
    }

    function testOpERC721BalanceOfEvalHappy(address token, address account, uint256 balance) public {
        bytes memory bytecode = iDeployer.parse2(
            bytes(
                string.concat(
                    "_: erc721-balance-of(", Strings.toHexString(token), " ", Strings.toHexString(account), ");"
                )
            )
        );

        (, bool lossless) = LibDecimalFloat.fromFixedDecimalLossyPacked(balance, 0);
        vm.assume(lossless);

        assumeEtchable(token);
        vm.etch(token, hex"fe");
        vm.mockCall(token, abi.encodeWithSelector(IERC721.balanceOf.selector, account), abi.encode(balance));
        vm.expectCall(token, abi.encodeWithSelector(IERC721.balanceOf.selector, account), 1);

        (StackItem[] memory stack, bytes32[] memory kvs) = iInterpreter.eval4(
            EvalV4({
                store: iStore,
                namespace: FullyQualifiedNamespace.wrap(0),
                bytecode: bytecode,
                sourceIndex: SourceIndexV2.wrap(0),
                context: LibContext.build(new bytes32[][](0), new SignedContextV1[](0)),
                inputs: new StackItem[](0),
                stateOverlay: new bytes32[](0)
            })
        );
        assertEq(stack.length, 1);
        assertEq(StackItem.unwrap(stack[0]), bytes32(balance));
        assertEq(kvs.length, 0);
    }

    /// Test that balance of without inputs fails integrity check.
    function testOpERC721BalanceOfIntegrityFail0() external {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
        bytes memory bytecode = iDeployer.parse2("_: erc721-balance-of();");
        (bytecode);
    }

    /// Test that balance of with one input fails integrity check.
    function testOpERC721BalanceOfIntegrityFail1() external {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
        bytes memory bytecode = iDeployer.parse2("_: erc721-balance-of(0x00);");
        (bytecode);
    }

    /// Test that balance of with three inputs fails integrity check.
    function testOpERC721BalanceOfIntegrityFail3() external {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 3, 2, 3));
        bytes memory bytecode = iDeployer.parse2("_: erc721-balance-of(0x00 0x01 0x02);");
        (bytecode);
    }

    /// Test that operand fails integrity check.
    function testOpERC721BalanceOfIntegrityFailOperand() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector));
        bytes memory bytecode = iDeployer.parse2("_: erc721-balance-of<0>(0x00 0x01);");
        (bytecode);
    }

    function testOpERC721BalanceOfZeroInputs() external {
        checkBadInputs("_: erc721-balance-of();", 0, 2, 0);
    }

    function testOpERC721BalanceOfOneInput() external {
        checkBadInputs("_: erc721-balance-of(0x00);", 1, 2, 1);
    }

    function testOpERC721BalanceOfThreeInputs() external {
        checkBadInputs("_: erc721-balance-of(0x00 0x01 0x02);", 3, 2, 3);
    }

    function testOpERC721BalanceOfZeroOutputs() external {
        checkBadOutputs(": erc721-balance-of(0x00 0x01);", 2, 1, 0);
    }

    function testOpERC721BalanceOfTwoOutputs() external {
        checkBadOutputs("_ _: erc721-balance-of(0x00 0x01);", 2, 1, 2);
    }
}
