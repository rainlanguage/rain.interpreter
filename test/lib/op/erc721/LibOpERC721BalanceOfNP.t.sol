// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {Operand} from "src/interface/IInterpreterV1.sol";
import {LibOpERC721BalanceOfNP} from "src/lib/op/erc721/LibOpERC721BalanceOfNP.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {IInterpreterV1, StateNamespace, SourceIndex} from "src/interface/IInterpreterV1.sol";
import {IInterpreterStoreV1} from "src/interface/IInterpreterStoreV1.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {SignedContextV1} from "src/interface/IInterpreterCallerV2.sol";

/// @title LibOpERC721BalanceOfNPTest
/// @notice Test the opcode for getting the balance of an erc721 token.
contract LibOpERC721BalanceOfNPTest is OpTest {
    function testOpERC721BalanceOfNPIntegrity(IntegrityCheckStateNP memory state, uint8 inputs) external {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpERC721BalanceOfNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    function testOpERC721BalanceOfNPRun(address token, address account, uint256 balance) external {
        assumeNotPrecompile(token);
        vm.assume(token != address(this));
        vm.assume(token != address(vm));
        // The console.
        vm.assume(token != address(0x000000000000000000636F6e736F6c652e6c6f67));

        uint256[] memory inputs = new uint256[](2);
        inputs[0] = uint256(uint160(token));
        inputs[1] = uint256(uint160(account));
        Operand operand = Operand.wrap(uint256(2) << 0x10);

        // invalid token
        vm.etch(token, hex"fe");
        vm.mockCall(token, abi.encodeWithSelector(IERC721.balanceOf.selector, account), abi.encode(balance));
        // called once for reference, once for run
        vm.expectCall(token, abi.encodeWithSelector(IERC721.balanceOf.selector, account), 2);

        opReferenceCheck(
            opTestDefaultInterpreterState(),
            operand,
            LibOpERC721BalanceOfNP.referenceFn,
            LibOpERC721BalanceOfNP.integrity,
            LibOpERC721BalanceOfNP.run,
            inputs
        );
    }

    function testOpERC721BalanceOfNPEval(address token, address account, uint256 balance) public {
        assumeNotPrecompile(token);
        vm.assume(token != address(this));
        vm.assume(token != address(vm));
        // The console.
        vm.assume(token != address(0x000000000000000000636F6e736F6c652e6c6f67));

        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: erc721-balance-of(0x00 0x01);");
        assertEq(constants.length, 2);
        assertEq(constants[0], 0);
        assertEq(constants[1], 1);
        constants[0] = uint256(uint160(token));
        constants[1] = uint256(uint160(account));
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);

        vm.mockCall(token, abi.encodeWithSelector(IERC721.balanceOf.selector, account), abi.encode(balance));
        vm.expectCall(token, abi.encodeWithSelector(IERC721.balanceOf.selector, account), 1);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        assertEq(stack.length, 1);
        assertEq(stack[0], balance);
        assertEq(kvs.length, 0);
    }

    /// Test that balance of without inputs fails integrity check.
    function testOpERC721BalanceOfNPIntegrityFail0() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: erc721-balance-of();");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }

    /// Test that balance of with one input fails integrity check.
    function testOpERC721BalanceOfNPIntegrityFail1() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: erc721-balance-of(0x00);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }

    /// Test that balance of with three inputs fails integrity check.
    function testOpERC721BalanceOfNPIntegrityFail3() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: erc721-balance-of(0x00 0x01 0x02);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 3, 2, 3));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }
}
