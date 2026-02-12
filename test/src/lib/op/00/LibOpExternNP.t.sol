// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OpTest} from "test/abstract/OpTest.sol";

import {NotAnExternContract} from "src/error/ErrExtern.sol";
import {IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheck.sol";
import {InterpreterState} from "src/lib/state/LibInterpreterState.sol";
import {OperandV2} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {LibOpExternNP} from "src/lib/op/00/LibOpExternNP.sol";
import {LibExtern} from "src/lib/extern/LibExtern.sol";
import {
    EncodedExternDispatchV2,
    IInterpreterExternV4,
    ExternDispatchV2,
    StackItem
} from "rain.interpreter.interface/interface/IInterpreterExternV4.sol";
import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpExternNPTest
/// @notice Test the runtime and integrity time logic of LibOpExternNP.
contract LibOpExternNPTest is OpTest {
    using LibUint256Array for uint256[];

    function mockImplementsERC165IInterpreterExternV4(IInterpreterExternV4 extern) internal {
        // Extern needs to implement ERC165 for the interface.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IERC165.supportsInterface.selector, type(IInterpreterExternV4).interfaceId),
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
        IntegrityCheckState memory state,
        IInterpreterExternV4 extern,
        uint16 constantIndex,
        uint8 inputs,
        uint8 outputs
    ) external {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));

        assumeEtchable(address(extern));
        vm.etch(address(extern), hex"fe");
        mockImplementsERC165IInterpreterExternV4(extern);

        vm.assume(state.constants.length > 0);
        constantIndex = uint16(bound(constantIndex, 0, state.constants.length - 1));

        OperandV2 operand = LibOperand.build(inputs, outputs, constantIndex);
        ExternDispatchV2 externDispatch = LibExtern.encodeExternDispatch(0, operand);
        EncodedExternDispatchV2 encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);
        state.constants[constantIndex] = EncodedExternDispatchV2.unwrap(encodedExternDispatch);

        // Extern integrity needs to match the inputs and outputs.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV4.externIntegrity.selector, externDispatch),
            // Have the mock modify the inputs and outputs slightly so we know
            // the implementation is hitting the mock.
            abi.encode(inputs + 1, outputs + 1)
        );
        vm.expectCall(
            address(extern), abi.encodeWithSelector(IInterpreterExternV4.externIntegrity.selector, externDispatch), 1
        );
        (uint256 calcInputs, uint256 calcOutputs) = LibOpExternNP.integrity(state, operand);

        assertEq(calcInputs, inputs + 1, "inputs");
        assertEq(calcOutputs, outputs + 1, "outputs");
    }

    function testOpExternNPIntegrityNotAnExternContract(
        IntegrityCheckState memory state,
        IInterpreterExternV4 extern,
        uint16 constantIndex,
        uint8 inputs,
        uint8 outputs
    ) external {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));

        assumeEtchable(address(extern));
        vm.etch(address(extern), hex"fe");
        // Extern needs to implement ERC165 for the interface.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IERC165.supportsInterface.selector, type(IInterpreterExternV4).interfaceId),
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
        constantIndex = uint16(bound(constantIndex, 0, state.constants.length - 1));

        OperandV2 operand = LibOperand.build(inputs, outputs, constantIndex);
        ExternDispatchV2 externDispatch = LibExtern.encodeExternDispatch(0, operand);
        EncodedExternDispatchV2 encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);
        state.constants[constantIndex] = EncodedExternDispatchV2.unwrap(encodedExternDispatch);

        vm.expectRevert(abi.encodeWithSelector(NotAnExternContract.selector, address(extern)));
        this.externalIntegrity(state, operand);
    }

    /// This needs to be exposed externally so that mocks and reverts play nice
    /// with each other.
    function externalIntegrity(IntegrityCheckState memory state, OperandV2 operand)
        external
        view
        returns (uint256, uint256)
    {
        return LibOpExternNP.integrity(state, operand);
    }

    /// Test the eval of extern directly.
    function testOpExternNPRunHappy(
        IInterpreterExternV4 extern,
        bytes32[] memory constants,
        uint16 constantIndex,
        StackItem[] memory inputs,
        StackItem[] memory outputs
    ) external {
        vm.assume(constants.length > 0);
        if (inputs.length > 0x0F) {
            {
                uint256[] memory inputsCopy;
                assembly ("memory-safe") {
                    inputsCopy := inputs
                }
                inputsCopy.truncate(0x0F);
            }
        }
        if (outputs.length > 0x0F) {
            {
                uint256[] memory outputsCopy;
                assembly ("memory-safe") {
                    outputsCopy := outputs
                }
                outputsCopy.truncate(0x0F);
            }
        }

        InterpreterState memory state = opTestDefaultInterpreterState();
        state.constants = constants;

        assumeEtchable(address(extern));
        vm.etch(address(extern), hex"fe");
        mockImplementsERC165IInterpreterExternV4(extern);

        constantIndex = uint16(bound(constantIndex, 0, state.constants.length - 1));

        OperandV2 operand = LibOperand.build(uint8(inputs.length), uint8(outputs.length), constantIndex);
        ExternDispatchV2 externDispatch = LibExtern.encodeExternDispatch(0, operand);
        EncodedExternDispatchV2 encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);
        state.constants[constantIndex] = EncodedExternDispatchV2.unwrap(encodedExternDispatch);

        // Extern integrity needs to match the inputs and outputs.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV4.externIntegrity.selector, externDispatch),
            abi.encode(inputs.length, outputs.length)
        );

        // Extern run needs to match the inputs and outputs.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV4.extern.selector, externDispatch, inputs),
            abi.encode(outputs)
        );
        // Expect this for both the reference fn and the run.
        vm.expectCall(
            address(extern), abi.encodeWithSelector(IInterpreterExternV4.extern.selector, externDispatch, inputs), 2
        );

        opReferenceCheck(state, operand, LibOpExternNP.referenceFn, LibOpExternNP.integrity, LibOpExternNP.run, inputs);
    }

    /// Test the eval of extern parsed from a string.
    function testOpExternNPEvalHappy() external {
        IInterpreterExternV4 extern = IInterpreterExternV4(address(0xdeadbeef));
        vm.etch(address(extern), hex"fe");
        uint256 opcode = 5;
        OperandV2 operand = OperandV2.wrap(bytes32(uint256(0x10)));

        ExternDispatchV2 externDispatch = LibExtern.encodeExternDispatch(opcode, operand);
        assertEq(
            ExternDispatchV2.unwrap(externDispatch), 0x0000000000000000000000000000000000000000000000000000000000050010
        );

        EncodedExternDispatchV2 encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);
        assertEq(
            EncodedExternDispatchV2.unwrap(encodedExternDispatch),
            0x00000000000000000005001000000000000000000000000000000000deadbeef
        );

        mockImplementsERC165IInterpreterExternV4(extern);
        // Extern integrity needs to match the inputs and outputs.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV4.externIntegrity.selector, externDispatch),
            abi.encode(2, 1)
        );

        bytes32[] memory externInputs = new bytes32[](2);
        externInputs[0] = Float.unwrap(LibDecimalFloat.packLossless(20, 0));
        externInputs[1] = Float.unwrap(LibDecimalFloat.packLossless(83, 0));
        bytes32[] memory externOutputs = new bytes32[](1);
        externOutputs[0] = Float.unwrap(LibDecimalFloat.packLossless(99, 0));
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV4.extern.selector, externDispatch, externInputs),
            abi.encode(externOutputs)
        );

        StackItem[] memory expectedStack = new StackItem[](2);
        expectedStack[0] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(99, 0)));
        expectedStack[1] = StackItem.wrap(0x00000000000000000005001000000000000000000000000000000000deadbeef);

        checkHappy(
            // Need the constant in the constant array to be indexable in the operand.
            "_: 0x00000000000000000005001000000000000000000000000000000000deadbeef,"
            // Operand is the constant index of the dispatch then the number of outputs.
            // 2 inputs and 1 output matches the mocked integrity check.
            "_: extern<0>(20 83);",
            expectedStack,
            "0xdeadbeef 20 83 99"
        );
    }

    /// Test the eval of extern parsed from a string with multiple inputs and
    /// outputs.
    function testOpExternNPEvalMultipleInputsOutputsHappy() external {
        IInterpreterExternV4 extern = IInterpreterExternV4(address(0xdeadbeef));
        vm.etch(address(extern), hex"fe");
        uint256 opcode = 5;
        OperandV2 operand = OperandV2.wrap(bytes32(uint256(0x10)));

        ExternDispatchV2 externDispatch = LibExtern.encodeExternDispatch(opcode, operand);
        assertEq(
            ExternDispatchV2.unwrap(externDispatch), 0x0000000000000000000000000000000000000000000000000000000000050010
        );

        EncodedExternDispatchV2 encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);
        assertEq(
            EncodedExternDispatchV2.unwrap(encodedExternDispatch),
            0x00000000000000000005001000000000000000000000000000000000deadbeef
        );

        mockImplementsERC165IInterpreterExternV4(extern);
        // Extern integrity needs to match the inputs and outputs.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV4.externIntegrity.selector, externDispatch),
            abi.encode(3, 3)
        );

        StackItem[] memory externInputs = new StackItem[](3);
        externInputs[0] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(1, 0)));
        externInputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(2, 0)));
        externInputs[2] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(3, 0)));

        StackItem[] memory externOutputs = new StackItem[](3);
        externOutputs[0] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(4, 0)));
        externOutputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(5, 0)));
        externOutputs[2] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(6, 0)));

        StackItem[] memory expectedStack = new StackItem[](4);
        expectedStack[0] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(6, 0)));
        expectedStack[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(5, 0)));
        expectedStack[2] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(4, 0)));
        expectedStack[3] = StackItem.wrap(0x00000000000000000005001000000000000000000000000000000000deadbeef);

        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV4.extern.selector, externDispatch, externInputs),
            abi.encode(externOutputs)
        );
        vm.expectCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV4.extern.selector, externDispatch, externInputs),
            1
        );

        checkHappy(
            // Need the constant in the constant array to be indexable in the operand.
            "_: 0x00000000000000000005001000000000000000000000000000000000deadbeef,"
            // Operand is the constant index of the dispatch then the number of outputs.
            // 3 inputs and 3 outputs matches the mocked integrity check.
            "four five six: extern<0>(1 2 3);",
            expectedStack,
            "0xdeadbeef 1 2 3 4 5 6"
        );
    }
}
