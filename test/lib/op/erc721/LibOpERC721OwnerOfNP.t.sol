// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibOpERC721OwnerOfNP} from "src/lib/op/erc721/LibOpERC721OwnerOfNP.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {IInterpreterV2, StateNamespace, SourceIndexV2, Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {IInterpreterStoreV1} from "src/interface/IInterpreterStoreV1.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {SignedContextV1} from "src/interface/IInterpreterCallerV2.sol";
import {UnexpectedOperand} from "src/lib/parse/LibParseOperand.sol";

/// @title LibOpERC721OwnerOfNPTest
/// @notice Test the opcode for getting the owner of an erc721 token.
contract LibOpERC721OwnerOfNPTest is OpTest {
    function testOpERC721OwnerOfNPIntegrity(IntegrityCheckStateNP memory state, uint8 inputs) external {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpERC721OwnerOfNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    function testOpERC721OwnerOfNPRun(address token, uint256 tokenId, address owner) external {
        assumeNotPrecompile(token);
        vm.assume(token != address(this));
        vm.assume(token != address(vm));
        // The console.
        vm.assume(token != address(0x000000000000000000636F6e736F6c652e6c6f67));

        uint256[] memory inputs = new uint256[](2);
        inputs[0] = uint256(uint160(token));
        inputs[1] = tokenId;
        Operand operand = Operand.wrap(uint256(2) << 0x10);

        // invalid token
        vm.etch(token, hex"fe");
        vm.mockCall(token, abi.encodeWithSelector(IERC721.ownerOf.selector, tokenId), abi.encode(owner));
        // called once for reference, once for run
        vm.expectCall(token, abi.encodeWithSelector(IERC721.ownerOf.selector, tokenId), 2);

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
        assumeNotPrecompile(token);
        vm.assume(token != address(this));
        vm.assume(token != address(vm));
        // The console.
        vm.assume(token != address(0x000000000000000000636F6e736F6c652e6c6f67));

        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: erc721-owner-of(0x00 0x01);");
        assertEq(constants.length, 2);
        assertEq(constants[0], 0);
        assertEq(constants[1], 1);
        constants[0] = uint256(uint160(token));
        constants[1] = tokenId;
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);

        vm.mockCall(token, abi.encodeWithSelector(IERC721.ownerOf.selector, tokenId), abi.encode(owner));
        vm.expectCall(token, abi.encodeWithSelector(IERC721.ownerOf.selector, tokenId), 1);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        assertEq(stack.length, 1);
        assertEq(stack[0], uint256(uint160(owner)));
        assertEq(kvs.length, 0);
    }

    /// Test that owner of without inputs fails integrity check.
    function testOpERC721OwnerOfNPEvalFail0() public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: erc721-owner-of();");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }

    /// Test that owner of with one input fails integrity check.
    function testOpERC721OwnerOfNPEvalFail1() public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: erc721-owner-of(0x00);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }

    /// Test that owner of with too many inputs fails integrity check.
    function testOpERC721OwnerOfNPEvalFail3() public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: erc721-owner-of(0x00 0x01 0x02);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 3, 2, 3));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }

    /// Test that operand fails integrity check.
    function testOpERC721OwnerOfNPEvalFailOperand() public {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector, 18));
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: erc721-owner-of<0>(0x00 0x01);");
        (bytecode, constants);
    }
}
