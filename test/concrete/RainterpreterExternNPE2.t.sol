// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {Test} from "forge-std/Test.sol";
import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {IInterpreterExternV2, ExternDispatch} from "src/interface/IInterpreterExternV2.sol";
import {IInterpreterV2, Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {LibExtern} from "src/lib/extern/LibExtern.sol";
import {RainterpreterExternNPE2, UnknownOp, BadInputs} from "src/concrete/RainterpreterExternNPE2.sol";

/// @title RainterpreterExternNPE2Test
/// Test suite for RainterpreterExternNPE2.
contract RainterpreterExternNPE2Test is Test {
    /// Test that ERC165 and IInterpreterExternV2 are supported interfaces as
    /// per ERC165.
    function testRainterpreterExternNPE2IERC165(uint32 badInterfaceIdUint) external {
        // https://github.com/foundry-rs/foundry/issues/6115
        bytes4 badInterfaceId = bytes4(badInterfaceIdUint);

        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterExternV2).interfaceId);

        RainterpreterExternNPE2 extern = new RainterpreterExternNPE2();
        assertTrue(extern.supportsInterface(type(IERC165).interfaceId));
        assertTrue(extern.supportsInterface(type(IInterpreterExternV2).interfaceId));
        assertFalse(extern.supportsInterface(badInterfaceId));
    }

    /// There's currently only one opcode. It handles exactly 2 inputs. Test
    /// That any number of inputs other than 2 reverts with BadInputs.
    function testRainterpreterExternNPE2BadInputs(uint256[] memory inputs) external {
        vm.assume(inputs.length != 2);
        RainterpreterExternNPE2 extern = new RainterpreterExternNPE2();
        vm.expectRevert(abi.encodeWithSelector(BadInputs.selector, 2, inputs.length));
        extern.extern(ExternDispatch.wrap(0), inputs);
    }

    /// There's currently only one opcode. For all opcode values other than 0,
    /// test that UnknownOp is thrown.
    function testRainterpreterExternNPE2UnknownOp(uint16 opcode, Operand operand, uint256 a, uint256 b) external {
        vm.assume(opcode != 0);
        operand = Operand.wrap(bound(Operand.unwrap(operand), 0, type(uint16).max));
        uint256[] memory inputs = LibUint256Array.arrayFrom(a, b);
        RainterpreterExternNPE2 extern = new RainterpreterExternNPE2();
        vm.expectRevert(abi.encodeWithSelector(UnknownOp.selector, opcode));
        extern.extern(LibExtern.encodeExternDispatch(opcode, operand), inputs);
    }
}
