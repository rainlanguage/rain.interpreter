// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {OPCODE_EXTERN, OperandV2} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {LibExternOpIntInc, OP_INDEX_INCREMENT} from "src/lib/extern/reference/op/LibExternOpIntInc.sol";
import {LibExtern} from "src/lib/extern/LibExtern.sol";
import {
    EncodedExternDispatchV2,
    IInterpreterExternV4
} from "rain.interpreter.interface/interface/IInterpreterExternV4.sol";

contract LibExternOpIntIncSubParserTest is Test {
    /// subParser must return extern bytecode targeting OP_INDEX_INCREMENT with
    /// a single constant encoding the extern dispatch. Fuzz all inputs.
    function testSubParserIntInc(uint16 constantsHeight, uint256 ioByte, OperandV2 operand) external view {
        (bool success, bytes memory bytecode, bytes32[] memory constants) =
            LibExternOpIntInc.subParser(uint256(constantsHeight), ioByte, operand);
        assertTrue(success);
        assertEq(bytecode.length, 4);
        assertEq(uint256(uint8(bytecode[0])), OPCODE_EXTERN);
        assertEq(uint8(bytecode[1]), uint8(ioByte));
        assertEq((uint16(uint8(bytecode[2])) << 8) | uint16(uint8(bytecode[3])), constantsHeight);
        assertEq(constants.length, 1);
        bytes32 expectedDispatch = EncodedExternDispatchV2.unwrap(
            LibExtern.encodeExternCall(
                IInterpreterExternV4(address(this)),
                LibExtern.encodeExternDispatch(OP_INDEX_INCREMENT, operand)
            )
        );
        assertEq(constants[0], expectedDispatch);
    }
}
