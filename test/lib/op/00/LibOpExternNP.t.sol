// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OpTest} from "test/util/abstract/OpTest.sol";

import {NotAnExternContract} from "src/error/ErrExtern.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {LibOpExternNP} from "src/lib/op/00/LibOpExternNP.sol";
import {LibExtern} from "src/lib/extern/LibExtern.sol";
import {
    EncodedExternDispatch,
    IInterpreterExternV3,
    ExternDispatch
} from "src/interface/unstable/IInterpreterExternV3.sol";
import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";

/// @title LibOpExternNPTest
/// @notice Test the runtime and integrity time logic of LibOpExternNP.
contract LibOpExternNPTest is OpTest {
    function testOpExternNPIntegrityHappy(
        IntegrityCheckStateNP memory state,
        IInterpreterExternV3 extern,
        uint256 constantIndex,
        uint256 inputs,
        uint256 outputs
    ) external {
        inputs = bound(inputs, 0, 0xFF);
        outputs = bound(outputs, 0, 0xFF);

        assumeEtchable(address(extern));
        vm.etch(address(extern), hex"fe");
        // Extern needs to implement ERC165 for the interface.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IERC165.supportsInterface.selector, type(IInterpreterExternV3).interfaceId),
            abi.encode(true)
        );
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IERC165.supportsInterface.selector, type(IERC165).interfaceId),
            abi.encode(true)
        );
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IERC165.supportsInterface.selector, bytes4(0xFFFFFFFF)),
            abi.encode(false)
        );

        vm.assume(state.constants.length > 0);
        constantIndex = bound(constantIndex, 0, state.constants.length - 1);

        Operand operand = Operand.wrap(inputs << 0x10 | outputs << 0x08 | constantIndex);
        ExternDispatch externDispatch = LibExtern.encodeExternDispatch(0, operand);
        EncodedExternDispatch encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);
        state.constants[constantIndex] = EncodedExternDispatch.unwrap(encodedExternDispatch);

        // Extern integrity needs to match the inputs and outputs.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV3.externIntegrity.selector, externDispatch),
            // Have the mock modify the inputs and outputs slightly so we know
            // the implementation is hitting the mock.
            abi.encode(inputs + 1, outputs + 1)
        );
        vm.expectCall(
            address(extern), abi.encodeWithSelector(IInterpreterExternV3.externIntegrity.selector, externDispatch), 1
        );
        (uint256 calcInputs, uint256 calcOutputs) = LibOpExternNP.integrity(state, operand);

        assertEq(calcInputs, inputs + 1, "inputs");
        assertEq(calcOutputs, outputs + 1, "outputs");
    }

    function testOpExternNPIntegrityNotAnExternContract(
        IntegrityCheckStateNP memory state,
        IInterpreterExternV3 extern,
        uint256 constantIndex,
        uint256 inputs,
        uint256 outputs
    ) external {
        inputs = bound(inputs, 0, 0xFF);
        outputs = bound(outputs, 0, 0xFF);

        assumeEtchable(address(extern));
        vm.etch(address(extern), hex"fe");
        // Extern needs to implement ERC165 for the interface.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IERC165.supportsInterface.selector, type(IInterpreterExternV3).interfaceId),
            // If this is false then the contract is not an extern.
            abi.encode(false)
        );
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IERC165.supportsInterface.selector, type(IERC165).interfaceId),
            abi.encode(true)
        );
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IERC165.supportsInterface.selector, bytes4(0xFFFFFFFF)),
            abi.encode(false)
        );

        vm.assume(state.constants.length > 0);
        constantIndex = bound(constantIndex, 0, state.constants.length - 1);

        Operand operand = Operand.wrap(inputs << 0x10 | outputs << 0x08 | constantIndex);
        ExternDispatch externDispatch = LibExtern.encodeExternDispatch(0, operand);
        EncodedExternDispatch encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);
        state.constants[constantIndex] = EncodedExternDispatch.unwrap(encodedExternDispatch);

        vm.expectRevert(abi.encodeWithSelector(NotAnExternContract.selector, address(extern)));
        this.externalIntegrity(state, operand);
    }

    /// This needs to be exposed externally so that mocks and reverts play nice
    /// with each other.
    function externalIntegrity(IntegrityCheckStateNP memory state, Operand operand)
        external
        view
        returns (uint256, uint256)
    {
        return LibOpExternNP.integrity(state, operand);
    }
}
