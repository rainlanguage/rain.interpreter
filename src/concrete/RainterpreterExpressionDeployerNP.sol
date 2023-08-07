// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibStackPointer.sol";
import "rain.datacontract/lib/LibDataContract.sol";
import "rain.erc1820/lib/LibIERC1820.sol";

import "../interface/unstable/IExpressionDeployerV2.sol";
import "../interface/unstable/IDebugExpressionDeployerV2.sol";
import "../interface/unstable/IDebugInterpreterV2.sol";
import "../interface/unstable/IParserV1.sol";

import "../lib/integrity/LibIntegrityCheck.sol";
import "../lib/state/LibInterpreterStateDataContractNP.sol";
import "../lib/op/LibAllStandardOpsNP.sol";
import {LibParse, LibParseMeta} from "../lib/parse/LibParse.sol";

import "./RainterpreterNP.sol";

/// @dev Thrown when the pointers known to the expression deployer DO NOT match
/// the interpreter it is constructed for. This WILL cause undefined expression
/// behaviour so MUST REVERT.
/// @param actualPointers The actual function pointers found at the interpreter
/// address upon construction.
error UnexpectedPointers(bytes actualPointers);

/// Thrown when the `RainterpreterExpressionDeployer` is constructed with unknown
/// interpreter bytecode.
/// @param actualBytecodeHash The bytecode hash that was found at the interpreter
/// address upon construction.
error UnexpectedInterpreterBytecodeHash(bytes32 actualBytecodeHash);

/// @dev There are more entrypoints defined by the minimum stack outputs than
/// there are provided sources. This means the calling contract WILL attempt to
/// eval a dangling reference to a non-existent source at some point, so this
/// MUST REVERT.
error EntrypointMissing(uint256 expectedEntrypoints, uint256 actualEntrypoints);

/// Thrown when some entrypoint has non-zero inputs. This is not allowed as
/// only internal dispatches can have source level inputs.
error EntrypointNonZeroInput(uint256 entrypointIndex, uint256 inputsLength);

/// Thrown when some entrypoint has less outputs than the minimum required.
error EntrypointMinOutputs(uint256 entrypointIndex, uint256 outputsLength, uint256 minOutputs);

/// The bytecode and integrity function disagree on number of inputs.
error BadOpInputsLength(uint256 opIndex, uint256 calculatedInputs, uint256 bytecodeInputs);

/// The stack underflowed during integrity check.
error StackUnderflow(uint256 opIndex, uint256 stackIndex, uint256 calculatedInputs);

/// The stack underflowed the highwater during integrity check.
error StackUnderflowHighwater(uint256 opIndex, uint256 stackIndex, uint256 stackHighwater);

/// The stack max index does not match the bytecode allocation.
error StackMaxIndexMismatch(uint256 stackMaxIndex, uint256 bytecodeAllocation);

/// The bytecode stack allocation does not match the allocation calculated by
/// the integrity check.
error StackAllocationMismatch(uint256 stackMaxIndex, uint256 bytecodeAllocation);

/// The final stack index does not match the bytecode outputs.
error StackOutputsMismatch(uint256 stackIndex, uint256 bytecodeOutputs);

/// Thrown when the `Rainterpreter` is constructed with unknown store bytecode.
/// @param actualBytecodeHash The bytecode hash that was found at the store
/// address upon construction.
error UnexpectedStoreBytecodeHash(bytes32 actualBytecodeHash);

/// Thrown when the `Rainterpreter` is constructed with unknown opMeta.
error UnexpectedOpMetaHash(bytes32 actualOpMeta);

// /// Thrown when the integrity check returns a negative stack index.
// /// @param index The negative index.
// error NegativeStackIndex(int256 index);

/// @dev The function pointers for the integrity check fns.
bytes constant INTEGRITY_FUNCTION_POINTERS = hex"144a14c4152b152b152b152b";

/// @dev Hash of the known interpreter bytecode.
bytes32 constant INTERPRETER_BYTECODE_HASH = bytes32(0xf30cc4ab09f0f113c506bc8616c35c838293ff06b29d9ed46a1161538ef01dee);

/// @dev Hash of the known store bytecode.
bytes32 constant STORE_BYTECODE_HASH = bytes32(0xd6130168250d3957ae34f8026c2bdbd7e21d35bb202e8540a9b3abcbc232ddb6);

/// @dev Hash of the known authoring meta.
bytes32 constant AUTHORING_META_HASH = bytes32(0xfabffb8bff66e519a08a9294c12c2971c63b4176ee2946287fdf1c6eb192b6bb);

bytes constant PARSE_META =
    hex"0100000000010000000080200000000200010000000000001000000000000000000005448fdb0088702d04d7225403beccb001038384028857ce";

/// All config required to construct a `Rainterpreter`.
/// @param interpreter The `IInterpreterV1` to use for evaluation. MUST match
/// known bytecode.
/// @param store The `IInterpreterStoreV1`. MUST match known bytecode.
/// @param authoringMeta The authoring meta as per `IParserV1`.
struct RainterpreterExpressionDeployerConstructionConfig {
    address interpreter;
    address store;
    bytes authoringMeta;
}

library LibRainterpreterExpressionDeployerNPMeta {
    function buildParseMetaFromAuthoringMeta(bytes memory inputAuthoringMeta) internal pure returns (bytes memory) {
        bytes32[] memory words = abi.decode(inputAuthoringMeta, (bytes32[]));
        return LibParseMeta.buildMeta(words, 2);
    }
}

/// @title RainterpreterExpressionDeployer
/// @notice !!!EXPERIMENTAL!!! This is the deployer for the RainterpreterNP
/// interpreter. Notably includes onchain parsing/compiling of expressions from
/// Rainlang strings.
contract RainterpreterExpressionDeployerNP is IExpressionDeployerV2, IDebugExpressionDeployerV2, IParserV1, ERC165 {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibUint256Array for uint256[];

    /// The config of the deployed expression including uncompiled sources. Will
    /// only be emitted after the config passes the integrity check.
    /// @param sender The caller of `deployExpression`.
    /// @param bytecode As per `IExpressionDeployerV2`.
    /// @param constants As per `IExpressionDeployerV2`.
    /// @param minOutputs As per `IExpressionDeployerV2`.
    event NewExpression(address sender, bytes bytecode, uint256[] constants, uint256[] minOutputs);

    /// The address of the deployed expression. Will only be emitted once the
    /// expression can be loaded and deserialized into an evaluable interpreter
    /// state.
    /// @param sender The caller of `deployExpression`.
    /// @param expression The address of the deployed expression.
    event ExpressionAddress(address sender, address expression);

    /// The interpreter with known bytecode that this deployer is constructed
    /// for.
    IInterpreterV1 public immutable iInterpreter;
    /// The store with known bytecode that this deployer is constructed for.
    IInterpreterStoreV1 public immutable iStore;

    constructor(RainterpreterExpressionDeployerConstructionConfig memory config) {
        // Set the immutables.
        IInterpreterV1 interpreter = IInterpreterV1(config.interpreter);
        IInterpreterStoreV1 store = IInterpreterStoreV1(config.store);
        iInterpreter = interpreter;
        iStore = store;

        // Guard against serializing incorrect function pointers, which would
        // cause undefined runtime behaviour for corrupted opcodes.
        bytes memory functionPointers = interpreter.functionPointers();
        if (keccak256(functionPointers) != keccak256(OPCODE_FUNCTION_POINTERS)) {
            revert UnexpectedPointers(functionPointers);
        }
        // Guard against an interpreter with unknown bytecode.
        bytes32 interpreterHash;
        assembly ("memory-safe") {
            interpreterHash := extcodehash(interpreter)
        }
        if (interpreterHash != INTERPRETER_BYTECODE_HASH) {
            /// THIS IS NOT A SECURITY CHECK. IT IS AN INTEGRITY CHECK TO PREVENT
            /// HONEST MISTAKES.
            revert UnexpectedInterpreterBytecodeHash(interpreterHash);
        }

        // Guard against an store with unknown bytecode.
        bytes32 storeHash;
        assembly ("memory-safe") {
            storeHash := extcodehash(store)
        }
        if (storeHash != STORE_BYTECODE_HASH) {
            /// THIS IS NOT A SECURITY CHECK. IT IS AN INTEGRITY CHECK TO PREVENT
            /// HONEST MISTAKES.
            revert UnexpectedStoreBytecodeHash(storeHash);
        }

        /// This IS a security check. This prevents someone making an exact
        /// bytecode copy of the interpreter and shipping different meta for
        /// the copy to lie about what each op does in the interpreter.
        bytes32 configAuthoringMetaHash = keccak256(config.authoringMeta);
        if (configAuthoringMetaHash != AUTHORING_META_HASH) {
            revert UnexpectedOpMetaHash(configAuthoringMetaHash);
        }

        emit DISpair(msg.sender, address(this), address(interpreter), address(store), config.authoringMeta);

        IERC1820_REGISTRY.setInterfaceImplementer(
            address(this), IERC1820_REGISTRY.interfaceHash(IERC1820_NAME_IEXPRESSION_DEPLOYER_V1), address(this)
        );
    }

    // @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId_) public view virtual override returns (bool) {
        return interfaceId_ == type(IExpressionDeployerV2).interfaceId || interfaceId_ == type(IERC165).interfaceId;
    }

    /// @inheritdoc IDebugExpressionDeployerV2
    function offchainDebugEval(
        FullyQualifiedNamespace namespace,
        bytes memory expressionData,
        SourceIndex sourceIndex,
        uint256 maxOutputs,
        uint256[][] memory context,
        uint256[] memory inputs,
        uint256
    ) external view returns (uint256[] memory, uint256[] memory) {
        // IntegrityCheckState memory integrityCheckState =
        //     LibIntegrityCheck.newState(sources, constants, integrityFunctionPointers());
        // Pointer stackTop = integrityCheckState.stackBottom;
        // stackTop = LibIntegrityCheck.push(integrityCheckState, stackTop, initialStack.length);
        // {
        //     Pointer stackTopAfter =
        //         LibIntegrityCheck.ensureIntegrity(integrityCheckState, sourceIndex, stackTop, minOutputs);
        //     (stackTopAfter);
        // }

        // uint256[] memory stack;
        // {
        //     int256 stackLength = integrityCheckState.stackBottom.toIndexSigned(integrityCheckState.stackMaxTop);
        //     if (stackLength < 0) {
        //         revert NegativeStackIndex(stackLength);
        //     }
        //     for (uint256 i_; i_ < sources.length; i_++) {
        //         LibCompile.unsafeCompile(sources[i_], OPCODE_FUNCTION_POINTERS);
        //     }
        //     stack = new uint256[](uint256(stackLength));
        //     LibMemCpy.unsafeCopyWordsTo(initialStack.dataPointer(), stack.dataPointer(), initialStack.length);
        // }

        // The return is used by returning it, so this is a false positive.
        //slither-disable-next-line unused-return
        return IDebugInterpreterV2(address(iInterpreter)).offchainDebugEval(
            iStore, namespace, expressionData, sourceIndex, maxOutputs, context, inputs
        );
    }

    /// @inheritdoc IParserV1
    function authoringMetaHash() external pure virtual override returns (bytes32) {
        return AUTHORING_META_HASH;
    }

    /// @inheritdoc IParserV1
    function buildParseMeta(bytes memory authoringMeta) external pure virtual override returns (bytes memory) {
        bytes32 inputAuthoringMetaHash = keccak256(authoringMeta);
        if (inputAuthoringMetaHash != AUTHORING_META_HASH) {
            revert AuthoringMetaHashMismatch(AUTHORING_META_HASH, inputAuthoringMetaHash);
        }
        return LibRainterpreterExpressionDeployerNPMeta.buildParseMetaFromAuthoringMeta(authoringMeta);
    }

    /// @inheritdoc IParserV1
    function parseMeta() public pure virtual override returns (bytes memory) {
        return PARSE_META;
    }

    /// @inheritdoc IParserV1
    function parse(bytes memory data) external pure virtual override returns (bytes memory, uint256[] memory) {
        // The return is used by returning it, so this is a false positive.
        //slither-disable-next-line unused-return
        return LibParse.parse(data, parseMeta());
    }

    /// @inheritdoc IExpressionDeployerV2
    function deployExpression(bytes memory bytecode, uint256[] memory constants, uint256[] memory minOutputs)
        external
        returns (IInterpreterV1, IInterpreterStoreV1, address)
    {
        integrityCheck(bytecode, constants, minOutputs);

        emit NewExpression(msg.sender, bytecode, constants, minOutputs);

        (DataContractMemoryContainer container, Pointer pointer) =
            LibDataContract.newContainer(LibInterpreterStateDataContractNP.serializeSizeNP(bytecode, constants));

        // Serialize the state config into bytes that can be deserialized later
        // by the interpreter.
        LibInterpreterStateDataContractNP.unsafeSerializeNP(pointer, bytecode, constants);

        // Deploy the serialized expression onchain.
        address expression = LibDataContract.write(container);

        // Emit and return the address of the deployed expression.
        emit ExpressionAddress(msg.sender, expression);

        return (iInterpreter, iStore, expression);
    }

    /// Drives an integrity check of the provided bytecode and constants.
    /// @param bytecode The bytecode to check.
    /// @param constants The constants to check.
    /// @param minOutputs The minimum number of outputs expected from each of
    /// the sources. Only applies to sources that are entrypoints. Internal
    /// sources have their integrity checked implicitly by the use of opcodes
    /// such as `call` that have min/max outputs in their operand.
    function integrityCheck(bytes memory bytecode, uint256[] memory constants, uint256[] memory minOutputs)
        internal
        view
    {
        unchecked {
            uint256 sourceCount = LibBytecode.sourceCount(bytecode);

            // Ensure that we are not missing any entrypoints expected by the calling
            // contract.
            if (minOutputs.length > sourceCount) {
                revert EntrypointMissing(minOutputs.length, sourceCount);
            }

            bytes memory fPointers = INTEGRITY_FUNCTION_POINTERS;
            uint256 fPointersStart;
            assembly {
                fPointersStart := add(fPointers, 0x20)
            }

            // Run the integrity check over each source.
            for (uint256 i = 0; i < sourceCount; i++) {
                // Ensure that each entrypoint has zero source inputs.
                uint256 inputsLength = LibBytecode.sourceInputsLength(bytecode, i);

                // Ensure that each entrypoint has the minimum number of outputs.
                uint256 outputsLength = LibBytecode.sourceOutputsLength(bytecode, i);

                // This is an entrypoint so has additional restrictions.
                if (i < minOutputs.length) {
                    if (inputsLength != 0) {
                        revert EntrypointNonZeroInput(i, inputsLength);
                    }

                    if (outputsLength < minOutputs[i]) {
                        revert EntrypointMinOutputs(i, outputsLength, minOutputs[i]);
                    }
                }

                IntegrityCheckStateNP memory state =
                    LibIntegrityCheckNP.newState(bytecode, inputsLength, constants.length);

                // Have low 4 bytes of cursor overlap the first op, skipping the
                // prefix.
                uint256 cursor = Pointer.unwrap(LibBytecode.sourcePointer(bytecode, i)) - 0x18;
                uint256 end = cursor + LibBytecode.sourceOpsLength(bytecode, i) * 4;

                while (cursor < end) {
                    Operand operand;
                    uint256 bytecodeOpInputs;
                    function(IntegrityCheckStateNP memory, Operand)
                    view
                    returns (uint256, uint256) f;
                    assembly ("memory-safe") {
                        let word := mload(cursor)
                        f := shr(0xf0, mload(add(fPointersStart, mul(byte(28, word), 2))))
                        // 3 bytes mask.
                        operand := and(word, 0xFFFFFF)
                        bytecodeOpInputs := byte(29, word)
                    }
                    (uint256 calcOpInputs, uint256 calcOpOutputs) = f(state, operand);
                    if (calcOpInputs != bytecodeOpInputs) {
                        revert BadOpInputsLength(state.opIndex, calcOpInputs, bytecodeOpInputs);
                    }

                    if (calcOpInputs > state.stackIndex) {
                        revert StackUnderflow(state.opIndex, state.stackIndex, calcOpInputs);
                    }
                    state.stackIndex -= calcOpInputs;

                    // The stack index can't move below the highwater.
                    if (state.stackIndex < state.readHighwater) {
                        revert StackUnderflowHighwater(state.opIndex, state.stackIndex, state.readHighwater);
                    }

                    // Let's assume that sane opcode implementations don't
                    // overflow uint256 due to their outputs.
                    state.stackIndex += calcOpOutputs;

                    // Ensure the max stack index is updated if needed.
                    if (state.stackIndex > state.stackMaxIndex) {
                        state.stackMaxIndex = state.stackIndex;
                    }

                    // If there are multiple outputs the highwater MUST move.
                    if (calcOpOutputs > 1) {
                        state.readHighwater = state.stackIndex;
                    }

                    state.opIndex++;
                    cursor += 4;
                }

                // The final stack max index MUST match the bytecode allocation.
                if (state.stackMaxIndex != LibBytecode.sourceStackAllocation(bytecode, i)) {
                    revert StackAllocationMismatch(state.stackMaxIndex, LibBytecode.sourceStackAllocation(bytecode, i));
                }

                // The final stack index MUST match the bytecode source outputs.
                if (state.stackIndex != outputsLength) {
                    revert StackOutputsMismatch(state.stackIndex, outputsLength);
                }
            }
        }
    }

    /// Defines all the function pointers to integrity checks. This is the
    /// expression deployer's equivalent of the opcode function pointers and
    /// follows a near identical dispatch process. These are never compiled into
    /// source and are instead indexed into directly by the integrity check. The
    /// indexing into integrity pointers (which has an out of bounds check) is a
    /// proxy for enforcing that all opcode pointers exist at runtime, so the
    /// length of the integrity pointers MUST match the length of opcode function
    /// pointers. This function is `virtual` so that it can be overridden
    /// pairwise with overrides to `functionPointers` on `Rainterpreter`.
    /// @return The list of integrity function pointers.
    function integrityFunctionPointers() external view virtual returns (bytes memory) {
        return LibAllStandardOpsNP.integrityFunctionPointersNP();
    }
}
