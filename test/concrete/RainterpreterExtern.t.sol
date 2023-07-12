// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/interface/IInterpreterV1.sol";
import "src/lib/extern/LibExtern.sol";
import "src/concrete/RainterpreterExtern.sol";

/// @title RainterpreterExternTest
/// Test suite for RainterpreterExtern.
contract RainterpreterExternTest is Test {
    /// Test that ERC165 and IInterpreterExternV1 are supported interfaces as
    /// per ERC165.
    function testRainterpreterExternIERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterExternV1).interfaceId);

        RainterpreterExtern extern = new RainterpreterExtern();
        assertTrue(extern.supportsInterface(type(IERC165).interfaceId));
        assertTrue(extern.supportsInterface(type(IInterpreterExternV1).interfaceId));
        assertFalse(extern.supportsInterface(badInterfaceId));
    }

    /// There's currently only one opcode. It handles exactly 2 inputs. Test
    /// That any number of inputs other than 2 reverts with BadInputs.
    function testRainterpreterExternBadInputs(uint256[] memory inputs) external {
        vm.assume(inputs.length != 2);
        RainterpreterExtern extern = new RainterpreterExtern();
        vm.expectRevert(abi.encodeWithSelector(BadInputs.selector, 2, inputs.length));
        extern.extern(ExternDispatch.wrap(0), inputs);
    }

    /// There's currently only one opcode. For all opcode values other than 0,
    /// test that UnknownOp is thrown.
    function testRainterpreterExternUnknownOp(uint16 opcode, Operand operand, uint256 a, uint256 b) external {
        vm.assume(opcode != 0);
        operand = Operand.wrap(bound(Operand.unwrap(operand), 0, type(uint16).max));
        uint256[] memory inputs = LibUint256Array.arrayFrom(a, b);
        RainterpreterExtern extern = new RainterpreterExtern();
        vm.expectRevert(abi.encodeWithSelector(UnknownOp.selector, opcode));
        extern.extern(LibExtern.encodeExternDispatch(opcode, operand), inputs);
    }
}
