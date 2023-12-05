// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {Test} from "forge-std/Test.sol";
import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {IInterpreterExternV3, ExternDispatch} from "src/interface/unstable/IInterpreterExternV3.sol";
import {IInterpreterV2, Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {LibExtern} from "src/lib/extern/LibExtern.sol";
import {BaseRainterpreterExternNPE2, BadInputs} from "src/abstract/BaseRainterpreterExternNPE2.sol";

/// @title BaseRainterpreterExternNPE2Test
/// Test suite for BaseRainterpreterExternNPE2.
contract BaseRainterpreterExternNPE2Test is Test {
    /// Test that ERC165 and IInterpreterExternV3 are supported interfaces as
    /// per ERC165.
    function testRainterpreterExternNPE2IERC165(uint32 badInterfaceIdUint) external {
        // https://github.com/foundry-rs/foundry/issues/6115
        bytes4 badInterfaceId = bytes4(badInterfaceIdUint);

        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterExternV3).interfaceId);

        BaseRainterpreterExternNPE2 extern = new BaseRainterpreterExternNPE2();
        assertTrue(extern.supportsInterface(type(IERC165).interfaceId));
        assertTrue(extern.supportsInterface(type(IInterpreterExternV3).interfaceId));
        assertFalse(extern.supportsInterface(badInterfaceId));
    }
}
