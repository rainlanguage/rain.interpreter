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
import {InterpreterStateNP} from "../lib/state/LibInterpreterStateNP.sol";
import {LibAllStandardOpsNP} from "../lib/op/LibAllStandardOpsNP.sol";
import {
    SourceIndexV2,
    StateNamespace,
    FullyQualifiedNamespace,
    IInterpreterStoreV2,
    IInterpreterV4
} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {
    BYTECODE_HASH as INTERPRETER_BYTECODE_HASH,
    OPCODE_FUNCTION_POINTERS
} from "../generated/RainterpreterNPE2.pointers.sol";
import {IOpcodeToolingV1} from "rain.sol.codegen/interface/IOpcodeToolingV1.sol";

/// @title RainterpreterNPE2
/// @notice Implementation of a Rainlang interpreter that is compatible with
/// native onchain Rainlang parsing.
contract RainterpreterNPE2 is IInterpreterV4, IOpcodeToolingV1, ERC165 {
    using LibEvalNP for InterpreterStateNP;
    using LibInterpreterStateDataContractNP for bytes;

    /// @inheritdoc IInterpreterV4
    function eval4(
        IInterpreterStoreV2 store,
        FullyQualifiedNamespace namespace,
        bytes calldata bytecode,
        SourceIndexV2 sourceIndex,
        uint256[][] calldata context,
        uint256[] calldata inputs,
        uint256[] calldata stateOverlay
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
        return interfaceId == type(IInterpreterV4).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IOpcodeToolingV1
    function buildOpcodeFunctionPointers() public view virtual override returns (bytes memory) {
        return LibAllStandardOpsNP.opcodeFunctionPointers();
    }
}
