// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {RainterpreterNPE2} from "src/concrete/RainterpreterNPE2.sol";
import {RainterpreterStoreNPE2} from "src/concrete/RainterpreterStoreNPE2.sol";
import {IInterpreterV2} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {RainterpreterParserNPE2, PARSE_META_BUILD_DEPTH} from "src/concrete/RainterpreterParserNPE2.sol";
import {
    RainterpreterExpressionDeployerNPE2,
    RainterpreterExpressionDeployerNPE2ConstructionConfigV2
} from "src/concrete/RainterpreterExpressionDeployerNPE2.sol";
import {RainterpreterReferenceExternNPE2} from "src/concrete/extern/RainterpreterReferenceExternNPE2.sol";
import {LibAllStandardOpsNP, AuthoringMetaV2} from "src/lib/op/LibAllStandardOpsNP.sol";
import {LibParseMeta} from "src/lib/parse/LibParseMeta.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from "src/lib/constants/ExpressionDeployerNPConstants.sol";

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
            "/// jumps as the possibilities are limited compared to the number of words we\n" "/// have.\n",
            "bytes constant LITERAL_PARSER_FUNCTION_POINTERS = hex\"",
            bytesToHex(instance.buildLiteralParserFunctionPointers()),
            "\";\n"
        );
    }

    function operandHandlerFunctionPointersConstantString(RainterpreterParserNPE2 instance)
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            "\n",
            "/// @dev Every two bytes is a function pointer for an operand handler.\n",
            "/// These positional indexes all map to the same indexes looked up in the parse\n",
            "/// meta.\n",
            "bytes constant OPERAND_HANDLER_FUNCTION_POINTERS =\n",
            "    hex\"",
            bytesToHex(instance.buildOperandHandlerFunctionPointers()),
            "\";\n"
        );
    }

    function parseMetaConstantString(bytes memory authoringMetaBytes) internal pure returns (string memory) {
        AuthoringMetaV2[] memory authoringMeta = abi.decode(authoringMetaBytes, (AuthoringMetaV2[]));
        bytes memory parseMeta = LibParseMeta.buildParseMetaV2(authoringMeta, PARSE_META_BUILD_DEPTH);
        return string.concat(
            "\n",
            "/// @dev Encodes the parser meta that is used to lookup word definitions.\n",
            "/// The structure of the parser meta is:\n",
            "/// - 1 byte: The depth of the bloom filters\n",
            "/// - 1 byte: The hashing seed\n",
            "/// - The bloom filters, each is 32 bytes long, one for each build depth.\n",
            "/// - All the items for each word, each is 4 bytes long. Each item's first byte\n",
            "///   is its opcode index, the remaining 3 bytes are the word fingerprint.\n",
            "/// To do a lookup, the word is hashed with the seed, then the first byte of the\n",
            "/// hash is compared against the bloom filter. If there is a hit then we count\n",
            "/// the number of 1 bits in the bloom filter up to this item's 1 bit. We then\n",
            "/// treat this a the index of the item in the items array. We then compare the\n",
            "/// word fingerprint against the fingerprint of the item at this index. If the\n",
            "/// fingerprints equal then we have a match, else we increment the seed and try\n",
            "/// again with the next bloom filter, offsetting all the indexes by the total\n",
            "/// bit count of the previous bloom filter. If we reach the end of the bloom\n",
            "/// filters then we have a miss.\n",
            "bytes constant PARSE_META =\n",
            "    hex\"",
            bytesToHex(parseMeta),
            "\";\n\n",
            "/// @dev The build depth of the parser meta.\n",
            "uint8 constant PARSE_META_BUILD_DEPTH = ",
            vm.toString(PARSE_META_BUILD_DEPTH),
            ";\n"
        );
    }

    function integrityFunctionPointersConstantString(RainterpreterExpressionDeployerNPE2 deployer)
        internal
        view
        returns (string memory)
    {
        return string.concat(
            "\n",
            "/// @dev The function pointers for the integrity check fns.\n",
            "bytes constant INTEGRITY_FUNCTION_POINTERS =\n",
            "    hex\"",
            bytesToHex(deployer.integrityFunctionPointers()),
            "\";\n"
        );
    }

    function describedByMetaHashConstantString(bytes memory describedByMeta) internal pure returns (string memory) {
        return string.concat(
            "\n",
            "/// @dev The hash of the meta that describes the contract.\n",
            "bytes32 constant DESCRIBED_BY_META_HASH = bytes32(",
            vm.toString(keccak256(describedByMeta)),
            ");\n"
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
            address(parser),
            "RainterpreterParserNPE2",
            string.concat(
                parseMetaConstantString(LibAllStandardOpsNP.authoringMetaV2()),
                operandHandlerFunctionPointersConstantString(parser),
                literalParserFunctionPointersConstantString(parser)
            )
        );
    }

    function buildRainterpreterExpressionDeployerNPE2Pointers() internal {
        RainterpreterNPE2 interpreter = new RainterpreterNPE2();
        RainterpreterStoreNPE2 store = new RainterpreterStoreNPE2();
        RainterpreterParserNPE2 parser = new RainterpreterParserNPE2();

        RainterpreterExpressionDeployerNPE2 deployer = new RainterpreterExpressionDeployerNPE2(
            RainterpreterExpressionDeployerNPE2ConstructionConfigV2(
                address(interpreter), address(store), address(parser)
            )
        );

        buildFileForContract(
            address(deployer),
            "RainterpreterExpressionDeployerNPE2",
            string.concat(
                describedByMetaHashConstantString(vm.readFileBinary(EXPRESSION_DEPLOYER_NP_META_PATH)),
                integrityFunctionPointersConstantString(deployer)
            )
        );
    }

    function buildRainterpreterReferenceExternNPE2Pointers() internal {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();

        buildFileForContract(address(extern), "RainterpreterReferenceExternNPE2", "");
    }

    function run() external {
        buildRainterpreterNPE2Pointers();
        buildRainterpreterStoreNPE2Pointers();
        buildRainterpreterParserNPE2Pointers();
        buildRainterpreterExpressionDeployerNPE2Pointers();
        buildRainterpreterReferenceExternNPE2Pointers();
    }
}
