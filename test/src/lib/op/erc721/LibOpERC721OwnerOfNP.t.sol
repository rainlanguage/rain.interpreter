// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibOpERC721OwnerOfNP} from "src/lib/op/erc721/LibOpERC721OwnerOfNP.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {
    IInterpreterV2,
    FullyQualifiedNamespace,
    SourceIndexV2,
    Operand
} from "rain.interpreter.interface/interface/unstable/IInterpreterV2.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/unstable/IInterpreterStoreV2.sol";
import {LibEncodedDispatch} from "rain.interpreter.interface/lib/caller/LibEncodedDispatch.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV2.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

/// @title LibOpERC721OwnerOfNPTest
/// @notice Test the opcode for getting the owner of an erc721 token.
contract LibOpERC721OwnerOfNPTest is OpTest {
    function testOpERC721OwnerOfNPIntegrity(IntegrityCheckStateNP memory state, uint8 inputs) external {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpERC721OwnerOfNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    function testOpERC721OwnerOfNPRun(address token, uint256 tokenId, address owner, uint16 operandData) external {
        assumeEtchable(token);
        vm.etch(token, hex"fe");
        vm.mockCall(token, abi.encodeWithSelector(IERC721.ownerOf.selector, tokenId), abi.encode(owner));
        // called once for reference, once for run
        vm.expectCall(token, abi.encodeWithSelector(IERC721.ownerOf.selector, tokenId), 2);

        uint256[] memory inputs = new uint256[](2);
        inputs[0] = uint256(uint160(token));
        inputs[1] = tokenId;
        Operand operand = LibOperand.build(2, 1, operandData);

        opReferenceCheck(
            opTestDefaultInterpreterState(),
            operand,
            LibOpERC721OwnerOfNP.referenceFn,
            LibOpERC721OwnerOfNP.integrity,
            LibOpERC721OwnerOfNP.run,
            inputs
        );
    }

    function testOpERC721OwnerOfNPEval(address token, uint256 tokenId, address owner) public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: erc721-owner-of(0x00 0x01);");
        assertEq(constants.length, 2);
        assertEq(constants[0], 0);
        assertEq(constants[1], 1);
        constants[0] = uint256(uint160(token));
        constants[1] = tokenId;
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV2 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);

        assumeEtchable(token, expression);
        vm.etch(token, hex"fe");
        vm.mockCall(token, abi.encodeWithSelector(IERC721.ownerOf.selector, tokenId), abi.encode(owner));
        vm.expectCall(token, abi.encodeWithSelector(IERC721.ownerOf.selector, tokenId), 1);

        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 1);
        assertEq(stack[0], uint256(uint160(owner)));
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test that owner of without inputs fails integrity check.
    function testOpERC721OwnerOfNPEvalFail0() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: erc721-owner-of();");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
        iDeployer.deployExpression2(bytecode, constants);
    }

    /// Test that owner of with one input fails integrity check.
    function testOpERC721OwnerOfNPEvalFail1() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: erc721-owner-of(0x00);");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
        iDeployer.deployExpression2(bytecode, constants);
    }

    /// Test that owner of with too many inputs fails integrity check.
    function testOpERC721OwnerOfNPEvalFail3() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: erc721-owner-of(0x00 0x01 0x02);");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 3, 2, 3));
        iDeployer.deployExpression2(bytecode, constants);
    }

    /// Test that operand fails integrity check.
    function testOpERC721OwnerOfNPEvalFailOperand() public {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector));
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: erc721-owner-of<0>(0x00 0x01);");
        (bytecode, constants);
    }

    function testOpERC721OwnerOfNPEvalZeroInputs() external {
        checkBadInputs("_: erc721-owner-of();", 0, 2, 0);
    }

    function testOpERC721OwnerOfNPEvalOneInput() external {
        checkBadInputs("_: erc721-owner-of(0x00);", 1, 2, 1);
    }

    function testOpERC721OwnerOfNPEvalThreeInputs() external {
        checkBadInputs("_: erc721-owner-of(0x00 0x01 0x02);", 3, 2, 3);
    }

    function testOpERC721OwnerOfNPEvalZeroOutputs() external {
        checkBadOutputs(": erc721-owner-of(0x00 0x01);", 2, 1, 0);
    }

    function testOpERC721OwnerOfNPTwoOutputs() external {
        checkBadOutputs("_ _: erc721-owner-of(0x00 0x01);", 2, 1, 2);
    }
}
