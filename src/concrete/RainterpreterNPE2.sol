// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

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

/// @dev Hash of the known interpreter bytecode.
bytes32 constant INTERPRETER_BYTECODE_HASH = bytes32(0x5e084dbcc252e1db75b6a4d09f9be7f4b62f370cca5beaa1f32951ec8ee78f63);

/// @dev The function pointers known to the interpreter for dynamic dispatch.
/// By setting these as a constant they can be inlined into the interpreter
/// and loaded at eval time for very low gas (~100) due to the compiler
/// optimising it to a single `codecopy` to build the in memory bytes array.
bytes constant OPCODE_FUNCTION_POINTERS =
    hex"0ce70d380d7a0f46102d103f1051106a10ac10fe110f112011c211ff12bd136d12bd13f11493150b153a1569156915b815e7164c17201773178717e017f418091823182e18421857188f18b618ce18dc195c196a1978199319a819c019d919e719f51a031a111a5f1a771a8f1aa91aa91ac01add1af41b491b571b571ba51bf31c411c411c8f1c8f1cdd1d2b1d791d791d791d791e1d1f04";

/// @title RainterpreterNPE2
/// @notice Implementation of a Rainlang interpreter that is compatible with
/// native onchain Rainlang parsing.
contract RainterpreterNPE2 is IInterpreterV2, ERC165 {
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

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IInterpreterV2).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IInterpreterV2
    function functionPointers() external view virtual returns (bytes memory) {
        return LibAllStandardOpsNP.opcodeFunctionPointers();
    }
}
