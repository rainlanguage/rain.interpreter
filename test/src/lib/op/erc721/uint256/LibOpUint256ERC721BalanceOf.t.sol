// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibOpUint256ERC721BalanceOf} from "src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {
    IInterpreterV2,
    FullyQualifiedNamespace,
    Operand,
    SourceIndexV2
} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {LibEncodedDispatch} from "rain.interpreter.interface/lib/caller/LibEncodedDispatch.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV2.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

/// @title LibOpUint256ERC721BalanceOfTest
/// @notice Test the opcode for getting the balance of an erc721 token.
contract LibOpUint256ERC721BalanceOfTest is OpTest {
    function testOpERC721BalanceOfIntegrity(
        IntegrityCheckStateNP memory state,
        uint8 inputs,
        uint8 outputs,
        uint16 operandData
    ) external {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpUint256ERC721BalanceOf.integrity(state, LibOperand.build(inputs, outputs, operandData));

        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    function testOpERC721BalanceOfRun(address token, address account, uint256 balance, uint16 operandData) external {
        assumeEtchable(token);
        vm.etch(token, hex"fe");

        uint256[] memory inputs = new uint256[](2);
        inputs[0] = uint256(uint160(token));
        inputs[1] = uint256(uint160(account));
        Operand operand = LibOperand.build(2, 1, operandData);

        // invalid token
        vm.mockCall(token, abi.encodeWithSelector(IERC721.balanceOf.selector, account), abi.encode(balance));
        // called once for reference, once for run
        vm.expectCall(token, abi.encodeWithSelector(IERC721.balanceOf.selector, account), 2);

        opReferenceCheck(
            opTestDefaultInterpreterState(),
            operand,
            LibOpUint256ERC721BalanceOf.referenceFn,
            LibOpUint256ERC721BalanceOf.integrity,
            LibOpUint256ERC721BalanceOf.run,
            inputs
        );
    }

    function testOpERC721BalanceOfEval(address token, address account, uint256 balance) public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: uint256-erc721-balance-of(0x00 0x01);");
        assertEq(constants.length, 2);
        assertEq(constants[0], 0);
        assertEq(constants[1], 1);
        constants[0] = uint256(uint160(token));
        constants[1] = uint256(uint160(account));
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV2 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);

        assumeEtchable(token, expression);
        vm.etch(token, hex"fe");
        vm.mockCall(token, abi.encodeWithSelector(IERC721.balanceOf.selector, account), abi.encode(balance));
        vm.expectCall(token, abi.encodeWithSelector(IERC721.balanceOf.selector, account), 1);

        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 1);
        assertEq(stack[0], balance);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test that balance of without inputs fails integrity check.
    function testOpERC721BalanceOfIntegrityFail0() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: uint256-erc721-balance-of();");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
        iDeployer.deployExpression2(bytecode, constants);
    }

    /// Test that balance of with one input fails integrity check.
    function testOpERC721BalanceOfIntegrityFail1() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: uint256-erc721-balance-of(0x00);");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
        iDeployer.deployExpression2(bytecode, constants);
    }

    /// Test that balance of with three inputs fails integrity check.
    function testOpERC721BalanceOfIntegrityFail3() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iParser.parse("_: uint256-erc721-balance-of(0x00 0x01 0x02);");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 3, 2, 3));
        iDeployer.deployExpression2(bytecode, constants);
    }

    /// Test that operand fails integrity check.
    function testOpERC721BalanceOfIntegrityFailOperand() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector));
        (bytes memory bytecode, uint256[] memory constants) =
            iParser.parse("_: uint256-erc721-balance-of<0>(0x00 0x01);");
        (bytecode, constants);
    }

    function testOpERC721BalanceOfZeroInputs() external {
        checkBadInputs("_: uint256-erc721-balance-of();", 0, 2, 0);
    }

    function testOpERC721BalanceOfOneInput() external {
        checkBadInputs("_: uint256-erc721-balance-of(0x00);", 1, 2, 1);
    }

    function testOpERC721BalanceOfThreeInputs() external {
        checkBadInputs("_: uint256-erc721-balance-of(0x00 0x01 0x02);", 3, 2, 3);
    }

    function testOpERC721BalanceOfZeroOutputs() external {
        checkBadOutputs(": uint256-erc721-balance-of(0x00 0x01);", 2, 1, 0);
    }

    function testOpERC721BalanceOfTwoOutputs() external {
        checkBadOutputs("_ _: uint256-erc721-balance-of(0x00 0x01);", 2, 1, 2);
    }
}
