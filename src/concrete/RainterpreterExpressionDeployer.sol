// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {ERC165, IERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IParserV2} from "rain.interpreter.interface/interface/IParserV2.sol";
import {IParserPragmaV1, PragmaV1} from "rain.interpreter.interface/interface/IParserPragmaV1.sol";

import {IDescribedByMetaV1} from "rain.metadata/interface/IDescribedByMetaV1.sol";

import {LibIntegrityCheck} from "../lib/integrity/LibIntegrityCheck.sol";
import {LibInterpreterStateDataContract} from "../lib/state/LibInterpreterStateDataContract.sol";
import {LibAllStandardOps} from "../lib/op/LibAllStandardOps.sol";
import {
    INTEGRITY_FUNCTION_POINTERS,
    DESCRIBED_BY_META_HASH
} from "../generated/RainterpreterExpressionDeployer.pointers.sol";
import {IIntegrityToolingV1} from "rain.sol.codegen/interface/IIntegrityToolingV1.sol";
import {RainterpreterParser} from "./RainterpreterParser.sol";
import {LibInterpreterDeploy} from "../lib/deploy/LibInterpreterDeploy.sol";

/// @title RainterpreterExpressionDeployer
contract RainterpreterExpressionDeployer is
    IDescribedByMetaV1,
    IParserV2,
    IParserPragmaV1,
    IIntegrityToolingV1,
    ERC165
{
    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IDescribedByMetaV1).interfaceId || interfaceId == type(IParserV2).interfaceId
            || interfaceId == type(IParserPragmaV1).interfaceId || interfaceId == type(IIntegrityToolingV1).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IParserV2
    function parse2(bytes memory data) external view virtual override returns (bytes memory) {
        (bytes memory bytecode, bytes32[] memory constants) =
            RainterpreterParser(LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS).unsafeParse(data);

        uint256 size = LibInterpreterStateDataContract.serializeSize(bytecode, constants);
        bytes memory serialized;
        Pointer cursor;
        assembly ("memory-safe") {
            serialized := mload(0x40)
            mstore(0x40, add(serialized, add(0x20, size)))
            mstore(serialized, size)
            cursor := add(serialized, 0x20)
        }
        LibInterpreterStateDataContract.unsafeSerialize(cursor, bytecode, constants);

        bytes memory io = LibIntegrityCheck.integrityCheck2(INTEGRITY_FUNCTION_POINTERS, bytecode, constants);
        // Nothing is done with IO in IParserV2.
        (io);

        return serialized;
    }

    /// This is just here for convenience for `IParserV2` consumers, it would be
    /// more gas efficient to call the parser directly.
    /// @inheritdoc IParserPragmaV1
    function parsePragma1(bytes calldata data) external view virtual override returns (PragmaV1 memory) {
        // The parser at the deterministic Zoltu address is also an
        // IParserPragmaV1.
        return RainterpreterParser(LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS).parsePragma1(data);
    }

    /// Defines all the function pointers to integrity checks. This is the
    /// expression deployer's equivalent of the opcode function pointers and
    /// follows a near identical dispatch process. These are never compiled into
    /// source and are instead indexed into directly by the integrity check. The
    /// indexing into integrity pointers (which has an out of bounds check) is a
    /// proxy for enforcing that all opcode pointers exist at runtime, so the
    /// length of the integrity pointers MUST match the length of opcode function
    /// pointers. This function is `virtual` so that it can be overridden
    /// pairwise with overrides to `buildOpcodeFunctionPointers` on
    /// `Rainterpreter`.
    /// @return The list of integrity function pointers.
    /// @inheritdoc IIntegrityToolingV1
    function buildIntegrityFunctionPointers() external view virtual returns (bytes memory) {
        return LibAllStandardOps.integrityFunctionPointers();
    }

    /// @inheritdoc IDescribedByMetaV1
    function describedByMetaV1() external pure override returns (bytes32) {
        return DESCRIBED_BY_META_HASH;
    }
}
