// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {
    RainterpreterReferenceExternNPE2,
    OPCODE_FUNCTION_POINTERS,
    INTEGRITY_FUNCTION_POINTERS,
    OP_INDEX_INCREMENT,
    LibExternOpIntIncNPE2
} from "src/concrete/RainterpreterReferenceExternNPE2.sol";
import {
    ExternDispatch,
    EncodedExternDispatch,
    IInterpreterExternV3
} from "src/interface/unstable/IInterpreterExternV3.sol";
import {Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {LibExtern} from "src/lib/extern/LibExtern.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {COMPATIBLITY_V1} from "src/interface/unstable/ISubParserV1.sol";
import {OPCODE_EXTERN} from "src/interface/unstable/IInterpreterV2.sol";
import {ExternDispatchConstantsHeightOverflow} from "src/error/ErrSubParse.sol";

contract RainterpreterReferenceExternNPE2IntIncTest is OpTest {
    using Strings for address;

    function testRainterpreterReferenceExternNPE2IntIncHappy() external {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();

        uint256 intIncOpcode = 0;

        ExternDispatch externDispatch = LibExtern.encodeExternDispatch(intIncOpcode, Operand.wrap(0));
        EncodedExternDispatch encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);

        assertEq(
            EncodedExternDispatch.unwrap(encodedExternDispatch),
            0x000000000000000000000000c7183455a4c133ae270771860664b6b7ec320bb1
        );

        uint256[] memory expectedStack = new uint256[](3);
        expectedStack[0] = 4;
        expectedStack[1] = 3;
        expectedStack[2] = EncodedExternDispatch.unwrap(encodedExternDispatch);

        checkHappy(
            // Need the constant in the constant array to be indexable in the operand.
            "_: 0x000000000000000000000000c7183455a4c133ae270771860664b6b7ec320bb1,"
            // Operand is the constant index of the dispatch.
            "three four: extern<0 2>(2 3);",
            expectedStack,
            "inc 2 3 = 3 4"
        );
    }

    function testRainterpreterReferenceExternNPE2IntIncHappySugared() external {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();

        uint256[] memory expectedStack = new uint256[](2);
        expectedStack[0] = 4;
        expectedStack[1] = 3;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ", address(extern).toHexString(), " three four: reference-extern-inc(2 3);"
                )
            ),
            expectedStack,
            "sugared inc 2 3 = 3 4"
        );
    }

    /// Directly test the subparsing of the reference extern opcode.
    function testRainterpreterReferenceExternNPE2IntIncSubParse(uint16 constantsHeight, bytes1 ioByte) external {
        // Extern "only" supports up to constant height of 0xFF.
        constantsHeight = uint16(bound(constantsHeight, 0, 0xFF));
        RainterpreterReferenceExternNPE2 subParser = new RainterpreterReferenceExternNPE2();

        bytes memory wordToParse = bytes("reference-extern-inc");
        (bool success, bytes memory bytecode, uint256[] memory constants) = subParser.subParse(
            COMPATIBLITY_V1,
            bytes.concat(bytes2(constantsHeight), ioByte, bytes2(uint16(wordToParse.length)), wordToParse, bytes32(0))
        );
        assertTrue(success);

        assertEq(bytecode.length, 4);
        assertEq(uint256(uint8(bytecode[0])), OPCODE_EXTERN);
        assertEq(bytecode[1], ioByte);
        // High byte for extern opcode is the outputs which is the same as
        // the inputs for inc.
        assertEq(bytecode[2], ioByte);
        // Low byte for the extern opcode is the constants index of the extern
        // dispatch.
        assertEq(uint16(uint8(bytecode[3])), constantsHeight);

        assertEq(constants.length, 1);
        (IInterpreterExternV3 decodedExtern, ExternDispatch decodedExternDispatch) =
            LibExtern.decodeExternCall(EncodedExternDispatch.wrap(constants[0]));

        // The sub parser is also the extern contract because the reference
        // implementation includes both.
        assertEq(address(decodedExtern), address(subParser));

        (uint256 opcode, Operand operand) = LibExtern.decodeExternDispatch(decodedExternDispatch);
        assertEq(opcode, OP_INDEX_INCREMENT);
        assertEq(Operand.unwrap(operand), 0);
    }

    /// Directly test the subparsing of the reference extern opcode. Check that
    /// we get a false for success if the subparser doesn't recognize the word
    /// but the data is otherwise valid.
    function testRainterpreterReferenceExternNPE2IntIncSubParseUnknownWord(
        uint16 constantsHeight,
        bytes1 ioByte,
        bytes memory unknownWord
    ) external {
        vm.assume(keccak256(unknownWord) != keccak256("reference-extern-inc"));
        vm.assume(unknownWord.length < 32);
        // Extern "only" supports up to constant height of 0xFF.
        constantsHeight = uint16(bound(constantsHeight, 0, 0xFF));
        RainterpreterReferenceExternNPE2 subParser = new RainterpreterReferenceExternNPE2();

        (bool success, bytes memory bytecode, uint256[] memory constants) = subParser.subParse(
            COMPATIBLITY_V1,
            bytes.concat(bytes2(constantsHeight), ioByte, bytes2(uint16(unknownWord.length)), unknownWord, bytes32(0))
        );
        assertFalse(success);
        assertEq(bytecode.length, 0);
        assertEq(constants.length, 0);
    }

    /// Test that the reference implementation errors when constants height is
    /// outside the range of 0xFF.
    function testRainterpreterReferenceExternNPE2IntIncSubParseConstantsHeightTooHigh(
        uint16 constantsHeight,
        bytes1 ioByte
    ) external {
        constantsHeight = uint16(bound(constantsHeight, 0x100, 0xFFFF));
        RainterpreterReferenceExternNPE2 subParser = new RainterpreterReferenceExternNPE2();

        vm.expectRevert(
            abi.encodeWithSelector(ExternDispatchConstantsHeightOverflow.selector, uint256(constantsHeight))
        );
        bytes memory word = bytes("reference-extern-inc");
        (bool success, bytes memory bytecode, uint256[] memory constants) = subParser.subParse(
            COMPATIBLITY_V1,
            bytes.concat(bytes2(constantsHeight), ioByte, bytes2(uint16(word.length)), word, bytes32(0))
        );
        (success, bytecode, constants);
    }

    /// Test the inc library directly. The run function should increment every
    /// value it is passed by 1.
    function testRainterpreterReferenceExternNPE2IntIncRun(Operand operand, uint256[] memory inputs) external {
        uint256[] memory expectedOutputs = new uint256[](inputs.length);
        for (uint256 i = 0; i < inputs.length; i++) {
            vm.assume(inputs[i] < type(uint256).max);
            expectedOutputs[i] = inputs[i] + 1;
        }

        uint256[] memory actualOutputs = LibExternOpIntIncNPE2.run(operand, inputs);
        assertEq(actualOutputs.length, expectedOutputs.length);
        for (uint256 i = 0; i < actualOutputs.length; i++) {
            assertEq(actualOutputs[i], expectedOutputs[i]);
        }
    }

    /// Test the inc library directly. The integrity function should return the
    /// same inputs and outputs.
    function testRainterpreterReferenceExternNPE2IntIncIntegrity(Operand operand, uint256 inputs, uint256 outputs)
        external
    {
        (uint256 calcInputs, uint256 calcOutputs) = LibExternOpIntIncNPE2.integrity(operand, inputs, outputs);
        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, inputs);
    }
}
