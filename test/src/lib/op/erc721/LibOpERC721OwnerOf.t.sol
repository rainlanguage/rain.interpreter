// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibOpERC721OwnerOf} from "src/lib/op/erc721/LibOpERC721OwnerOf.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {
    IInterpreterV2,
    FullyQualifiedNamespace,
    SourceIndexV2,
    Operand
} from "rain.interpreter.interface/interface/deprecated/IInterpreterV2.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {LibEncodedDispatch} from "rain.interpreter.interface/lib/deprecated/caller/LibEncodedDispatch.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/deprecated/IInterpreterCallerV2.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

/// @title LibOpERC721OwnerOfTest
/// @notice Test the opcode for getting the owner of an erc721 token.
contract LibOpERC721OwnerOfTest is OpTest {
    function testOpERC721OwnerOfNPIntegrity(IntegrityCheckStateNP memory state, uint8 inputs) external {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpERC721OwnerOf.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

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
            LibOpERC721OwnerOf.referenceFn,
            LibOpERC721OwnerOf.integrity,
            LibOpERC721OwnerOf.run,
            inputs
        );
    }

    function testOpERC721OwnerOfNPEvalHappy(address token, uint256 tokenId, address owner) public {
        bytes memory bytecode = iDeployer.parse2(
            bytes(
                string.concat(
                    "_: erc721-owner-of(", Strings.toHexString(token), " ", Strings.toHexString(tokenId), ");"
                )
            )
        );

        assumeEtchable(token);
        vm.etch(token, hex"fe");
        vm.mockCall(token, abi.encodeWithSelector(IERC721.ownerOf.selector, tokenId), abi.encode(owner));
        vm.expectCall(token, abi.encodeWithSelector(IERC721.ownerOf.selector, tokenId), 1);

        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 1);
        assertEq(stack[0], uint256(uint160(owner)));
        assertEq(kvs.length, 0);
    }

    /// Test that owner of without inputs fails integrity check.
    function testOpERC721OwnerOfNPEvalFail0() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
        bytes memory bytecode = iDeployer.parse2("_: erc721-owner-of();");
        (bytecode);
    }

    /// Test that owner of with one input fails integrity check.
    function testOpERC721OwnerOfNPEvalFail1() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
        bytes memory bytecode = iDeployer.parse2("_: erc721-owner-of(0x00);");
        (bytecode);
    }

    /// Test that owner of with too many inputs fails integrity check.
    function testOpERC721OwnerOfNPEvalFail3() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 3, 2, 3));
        bytes memory bytecode = iDeployer.parse2("_: erc721-owner-of(0x00 0x01 0x02);");
        (bytecode);
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
