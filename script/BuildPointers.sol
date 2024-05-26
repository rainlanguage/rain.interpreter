// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {RainterpreterNPE2} from "src/concrete/RainterpreterNPE2.sol";
import {RainterpreterStoreNPE2} from "src/concrete/RainterpreterStoreNPE2.sol";
import {IInterpreterV2} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {RainterpreterParserNPE2} from "src/concrete/RainterpreterParserNPE2.sol";

contract BuildPointers is Script {
    function filePrefix() internal pure returns (string memory) {
        return string.concat(
            "// THIS FILE IS AUTOGENERATED BY ./script/BuildPointers.sol\n\n",
            "// This file is committed to the repository because there is a circular\n"
            "// dependency between the contract and its pointers file. The contract\n"
            "// needs the pointers file to exist so that it can compile, and the pointers\n"
            "// file needs the contract to exist so that it can be compiled.\n\n",
            "// SPDX-License-Identifier: CAL\n",
            "pragma solidity =0.8.25;\n"
        );
    }

    function pathForContract(string memory contractName) internal pure returns (string memory) {
        return string.concat("src/generated/", contractName, ".pointers.sol");
    }

    function bytesToHex(bytes memory data) internal pure returns (string memory) {
        string memory hexString = vm.toString(data);
        assembly ("memory-safe") {
            // Remove the leading 0x
            let newHexString := add(hexString, 2)
            mstore(newHexString, sub(mload(hexString), 2))
            hexString := newHexString
        }
        return hexString;
    }

    function bytecodeHashConstantString(address instance) internal view returns (string memory) {
        bytes32 bytecodeHash;
        assembly {
            bytecodeHash := extcodehash(instance)
        }
        return string.concat(
            "\n",
            "/// @dev Hash of the known bytecode.\n",
            "bytes32 constant BYTECODE_HASH = bytes32(",
            vm.toString(bytecodeHash),
            ");\n"
        );
    }

    function interpreterFunctionPointersConstantString(IInterpreterV2 interpreter)
        internal
        view
        returns (string memory)
    {
        return string.concat(
            "\n",
            "/// @dev The function pointers known to the interpreter for dynamic dispatch.\n",
            "/// By setting these as a constant they can be inlined into the interpreter\n",
            "/// and loaded at eval time for very low gas (~100) due to the compiler\n",
            "/// optimising it to a single `codecopy` to build the in memory bytes array.\n",
            "bytes constant OPCODE_FUNCTION_POINTERS =\n",
            "    hex\"",
            bytesToHex(interpreter.functionPointers()),
            "\";\n"
        );
    }

    function literalParserFunctionPointersConstantString(RainterpreterParserNPE2 instance)
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            "\n",
            "/// @dev Every two bytes is a function pointer for a literal parser.\n",
            "/// Literal dispatches are determined by the first byte(s) of the literal\n",
            "/// rather than a full word lookup, and are done with simple conditional\n",
            "/// jumps as the possibilities are limited compared to the number of words we\n"
            "/// have.\n",
            "bytes constant LITERAL_PARSER_FUNCTION_POINTERS = hex\"",
            bytesToHex(instance.buildLiteralParserFunctionPointers()),
            "\";\n"
        );
    }

    function operatorHandlerFunctionPointersConstantString(RainterpreterParserNPE2 instance)
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            "\n",
            "/// @dev Every two bytes is a function pointer for an operand handler.\n",
            "/// These positional indexes all map to the same indexes looked up in the parse\n",
            "/// meta.\n",
            "bytes constant OPERAND_HANDLER_FUNCTION_POINTERS = hex\"",
            bytesToHex(instance.buildOperandHandlerFunctionPointers()),
            "\";\n"
        );
    }

    function buildFileForContract(address instance, string memory contractName, string memory body) internal {
        string memory path = pathForContract(contractName);

        if (vm.exists(path)) {
            vm.removeFile(path);
        }
        vm.writeFile(path, string.concat(filePrefix(), bytecodeHashConstantString(instance), body));
    }

    function buildRainterpreterNPE2Pointers() internal {
        RainterpreterNPE2 interpreter = new RainterpreterNPE2();

        buildFileForContract(
            address(interpreter), "RainterpreterNPE2", interpreterFunctionPointersConstantString(interpreter)
        );
    }

    function buildRainterpreterStoreNPE2Pointers() internal {
        RainterpreterStoreNPE2 store = new RainterpreterStoreNPE2();

        buildFileForContract(address(store), "RainterpreterStoreNPE2", "");
    }

    function buildRainterpreterParserNPE2Pointers() internal {
        RainterpreterParserNPE2 parser = new RainterpreterParserNPE2();

        buildFileForContract(
            address(parser), "RainterpreterParserNPE2", string.concat(
                operatorHandlerFunctionPointersConstantString(parser),
                literalParserFunctionPointersConstantString(parser)
            )
        );
    }

    function run() external {
        buildRainterpreterNPE2Pointers();
        buildRainterpreterStoreNPE2Pointers();
        buildRainterpreterParserNPE2Pointers();
    }
}
