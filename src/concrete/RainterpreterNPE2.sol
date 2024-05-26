// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {LibMemoryKV, MemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";
import {LibCast} from "rain.lib.typecast/LibCast.sol";
import {LibDataContract} from "rain.datacontract/lib/LibDataContract.sol";

import {LibEvalNP} from "../lib/eval/LibEvalNP.sol";
import {LibInterpreterStateDataContractNP} from "../lib/state/LibInterpreterStateDataContractNP.sol";
import {LibEncodedDispatch} from "rain.interpreter.interface/lib/caller/LibEncodedDispatch.sol";
import {InterpreterStateNP} from "../lib/state/LibInterpreterStateNP.sol";
import {LibAllStandardOpsNP} from "../lib/op/LibAllStandardOpsNP.sol";
import {
    SourceIndexV2,
    IInterpreterV2,
    StateNamespace,
    EncodedDispatch,
    FullyQualifiedNamespace,
    IInterpreterStoreV2
} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {IInterpreterV3} from "rain.interpreter.interface/interface/unstable/IInterpreterV3.sol";
import {INTERPRETER_BYTECODE_HASH, OPCODE_FUNCTION_POINTERS} from "../generated/RainterpreterNPE2.pointers.sol";

/// @title RainterpreterNPE2
/// @notice Implementation of a Rainlang interpreter that is compatible with
/// native onchain Rainlang parsing.
contract RainterpreterNPE2 is IInterpreterV2, IInterpreterV3, ERC165 {
    using LibEvalNP for InterpreterStateNP;
    using LibInterpreterStateDataContractNP for bytes;

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
    /// @inheritdoc IInterpreterV2
    function eval2(
        IInterpreterStoreV2 store,
        FullyQualifiedNamespace namespace,
        EncodedDispatch dispatch,
        uint256[][] memory context,
        uint256[] memory inputs
    ) external view virtual returns (uint256[] memory, uint256[] memory) {
        // Decode the dispatch.
        (address expression, SourceIndexV2 sourceIndex, uint256 maxOutputs) = LibEncodedDispatch.decode2(dispatch);
        bytes memory expressionData = LibDataContract.read(expression);

        InterpreterStateNP memory state = expressionData.unsafeDeserializeNP(
            SourceIndexV2.unwrap(sourceIndex), namespace, store, context, OPCODE_FUNCTION_POINTERS
        );
        // We use the return by returning it. Slither false positive.
        //slither-disable-next-line unused-return
        return state.eval2(inputs, maxOutputs);
    }

    /// @inheritdoc IInterpreterV3
    function eval3(
        IInterpreterStoreV2 store,
        FullyQualifiedNamespace namespace,
        bytes calldata bytecode,
        SourceIndexV2 sourceIndex,
        uint256[][] calldata context,
        uint256[] calldata inputs
    ) external view virtual override returns (uint256[] memory, uint256[] memory) {
        InterpreterStateNP memory state = bytecode.unsafeDeserializeNP(
            SourceIndexV2.unwrap(sourceIndex), namespace, store, context, OPCODE_FUNCTION_POINTERS
        );
        // We use the return by returning it. Slither false positive.
        //slither-disable-next-line unused-return
        return state.eval2(inputs, type(uint256).max);
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IInterpreterV2).interfaceId || interfaceId == type(IInterpreterV3).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IInterpreterV2
    function functionPointers() external view virtual override(IInterpreterV2, IInterpreterV3) returns (bytes memory) {
        return LibAllStandardOpsNP.opcodeFunctionPointers();
    }
}
