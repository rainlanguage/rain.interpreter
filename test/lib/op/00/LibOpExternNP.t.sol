// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OpTest} from "test/util/abstract/OpTest.sol";

import {NotAnExternContract} from "src/error/ErrExtern.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
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
    function mockImplementsERC165IInterpreterExternV3(IInterpreterExternV3 extern) internal {
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
    }

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
        mockImplementsERC165IInterpreterExternV3(extern);

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

    /// Test the eval of extern directly.
    function testOpExternNPRunHappy(
        IInterpreterExternV3 extern,
        uint256[] memory constants,
        uint256 constantIndex,
        uint256[] memory inputs,
        uint256[] memory outputs
    ) external {
        vm.assume(constants.length > 0);
        vm.assume(constants.length <= type(uint8).max);
        vm.assume(inputs.length <= type(uint8).max);
        vm.assume(outputs.length <= type(uint8).max);

        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        state.constants = constants;

        assumeEtchable(address(extern));
        vm.etch(address(extern), hex"fe");
        mockImplementsERC165IInterpreterExternV3(extern);

        constantIndex = bound(constantIndex, 0, state.constants.length - 1);

        Operand operand = Operand.wrap(inputs.length << 0x10 | outputs.length << 0x08 | constantIndex);
        ExternDispatch externDispatch = LibExtern.encodeExternDispatch(0, operand);
        EncodedExternDispatch encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);
        state.constants[constantIndex] = EncodedExternDispatch.unwrap(encodedExternDispatch);

        // Extern integrity needs to match the inputs and outputs.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV3.externIntegrity.selector, externDispatch),
            abi.encode(inputs.length, outputs.length)
        );

        // Extern run needs to match the inputs and outputs.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV3.extern.selector, externDispatch, inputs),
            abi.encode(outputs)
        );
        // Expect this for both the reference fn and the run.
        vm.expectCall(
            address(extern), abi.encodeWithSelector(IInterpreterExternV3.extern.selector, externDispatch, inputs), 2
        );

        opReferenceCheck(state, operand, LibOpExternNP.referenceFn, LibOpExternNP.integrity, LibOpExternNP.run, inputs);
    }

    /// Test the eval of extern parsed from a string.
    function testOpExternNPEvalHappy() external {
        IInterpreterExternV3 extern = IInterpreterExternV3(address(0xdeadbeef));
        vm.etch(address(extern), hex"fe");
        uint256 opcode = 5;
        Operand operand = Operand.wrap(0x10);

        ExternDispatch externDispatch = LibExtern.encodeExternDispatch(opcode, operand);
        assertEq(
            ExternDispatch.unwrap(externDispatch), 0x0000000000000000000000000000000000000000000000000000000000050010
        );

        EncodedExternDispatch encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);
        assertEq(
            EncodedExternDispatch.unwrap(encodedExternDispatch),
            0x00000000000000000005001000000000000000000000000000000000deadbeef
        );

        mockImplementsERC165IInterpreterExternV3(extern);
        // Extern integrity needs to match the inputs and outputs.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV3.externIntegrity.selector, externDispatch),
            abi.encode(2, 1)
        );

        uint256[] memory externInputs = new uint256[](2);
        externInputs[0] = 20;
        externInputs[1] = 83;
        uint256[] memory externOutputs = new uint256[](1);
        externOutputs[0] = 99;
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV3.extern.selector, externDispatch, externInputs),
            abi.encode(externOutputs)
        );

        uint256[] memory expectedStack = new uint256[](2);
        expectedStack[0] = 99;
        expectedStack[1] = 0x00000000000000000005001000000000000000000000000000000000deadbeef;

        checkHappy(
            // Need the constant in the constant array to be indexable in the operand.
            "_: 0x00000000000000000005001000000000000000000000000000000000deadbeef,"
            // Operand is the constant index of the dispatch then the number of outputs.
            // 2 inputs and 1 output matches the mocked integrity check.
            "_: extern<0 1>(20 83);",
            expectedStack,
            "0xdeadbeef 20 83 99"
        );
    }
}
