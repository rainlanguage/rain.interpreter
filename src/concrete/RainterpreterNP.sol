// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import "lib/rain.lib.typecast/src/LibCast.sol";
import "lib/rain.datacontract/src/lib/LibDataContract.sol";

import "../interface/unstable/IDebugInterpreterV2.sol";

import {LibEvalNP} from "../lib/eval/LibEvalNP.sol";
import "../lib/ns/LibNamespace.sol";
import {LibInterpreterStateDataContractNP} from "../lib/state/LibInterpreterStateDataContractNP.sol";
import "../lib/caller/LibEncodedDispatch.sol";

import {LibAllStandardOpsNP} from "../lib/op/LibAllStandardOpsNP.sol";
import {LibStackPointer} from "lib/rain.solmem/src/lib/LibStackPointer.sol";
import {LibUint256Array} from "lib/rain.solmem/src/lib/LibUint256Array.sol";

/// Thrown when the stack length is negative during eval.
error NegativeStackLength(int256 length);

/// Thrown when the source index is invalid during eval. This is a runtime check
/// for the exposed external eval entrypoint. Internally recursive evals are
/// expected to preflight check the source index.
error InvalidSourceIndex(SourceIndex sourceIndex);

/// @dev The function pointers known to the interpreter for dynamic dispatch.
/// By setting these as a constant they can be inlined into the interpreter
/// and loaded at eval time for very low gas (~100) due to the compiler
/// optimising it to a single `codecopy` to build the in memory bytes array.
bytes constant OPCODE_FUNCTION_POINTERS =
    hex"0c590ca50ce00dc40dfe0e2d0e5c0e5c0eab0eda0f3c0fc4106b107f10d510e910fe111811231137114c11c91214123a125c1273127312be130913541354139f139f13ea14351480148014cb15b215e5163c";

/// @title RainterpreterNP
/// @notice !!EXPERIMENTAL!! implementation of a Rainlang interpreter that is
/// compatible with native onchain Rainlang parsing. Initially copied verbatim
/// from the JS compatible Rainterpreter. This interpreter is deliberately
/// separate from the JS Rainterpreter to allow for experimentation with the
/// onchain interpreter without affecting the JS interpreter, up to and including
/// a complely different execution model and opcodes.
contract RainterpreterNP is IInterpreterV1, IDebugInterpreterV2, ERC165 {
    using LibStackPointer for Pointer;
    using LibPointer for Pointer;
    using LibStackPointer for uint256[];
    using LibUint256Array for uint256[];
    using LibEvalNP for InterpreterStateNP;
    using LibNamespace for StateNamespace;
    using LibInterpreterStateDataContractNP for bytes;
    using LibMemoryKV for MemoryKV;
    using LibNamespace for StateNamespace;

    /// There are MANY ways that eval can be forced into undefined/corrupt
    /// behaviour by passing in invalid data. This is a deliberate design
    /// decision to allow for the interpreter to be as gas efficient as
    /// possible. The interpreter is provably read only, it contains no state
    /// changing evm opcodes reachable on any logic path. This means that
    /// the caller can only harm themselves by passing in invalid data and
    /// either reverting, exhausting gas or getting back some garbage data.
    /// The caller can trivially protect themselves from these OOB issues by
    /// ensuring the integrity check has successfully run over the bytecode
    /// before calling eval. Any smart contract caller can do this by using a
    /// trusted and appropriate deployer contract to deploy the bytecode, which
    /// will automatically run the integrity check during deployment, then
    /// keeping a registry of trusted expression addresses for itself in storage.
    ///
    /// This appears first in the contract in the hope that the compiler will
    /// put it in the most efficient internal dispatch location to save a few
    /// gas per eval call.
    ///
    /// @inheritdoc IInterpreterV1
    function eval(
        IInterpreterStoreV1 store,
        StateNamespace namespace,
        EncodedDispatch dispatch,
        uint256[][] memory context
    ) external view returns (uint256[] memory, uint256[] memory) {
        // Decode the dispatch.
        (address expression, SourceIndex sourceIndex16, uint256 maxOutputs) = LibEncodedDispatch.decode(dispatch);
        bytes memory expressionData = LibDataContract.read(expression);

        // Need to clean source index as it is a uint16.
        uint256 sourceIndex;
        assembly ("memory-safe") {
            sourceIndex := and(sourceIndex16, 0xFFFF)
        }

        InterpreterStateNP memory state = expressionData.unsafeDeserializeNP(
            sourceIndex, namespace.qualifyNamespace(msg.sender), store, context, OPCODE_FUNCTION_POINTERS
        );
        return state.evalNP(new uint256[](0), maxOutputs);
    }

    // @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IInterpreterV1).interfaceId || interfaceId == type(IDebugInterpreterV2).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IDebugInterpreterV2
    function offchainDebugEval(
        IInterpreterStoreV1 store,
        FullyQualifiedNamespace namespace,
        bytes memory expressionData,
        SourceIndex sourceIndex16,
        uint256 maxOutputs,
        uint256[][] memory context,
        uint256[] memory inputs
    ) external view returns (uint256[] memory, uint256[] memory) {
        // Need to clean source index as it is a uint16.
        uint256 sourceIndex;
        assembly ("memory-safe") {
            sourceIndex := and(sourceIndex16, 0xFFFF)
        }
        InterpreterStateNP memory state =
            expressionData.unsafeDeserializeNP(sourceIndex, namespace, store, context, OPCODE_FUNCTION_POINTERS);
        return state.evalNP(inputs, maxOutputs);
    }

    /// @inheritdoc IInterpreterV1
    function functionPointers() external view virtual returns (bytes memory) {
        return LibAllStandardOpsNP.opcodeFunctionPointers();
    }
}
