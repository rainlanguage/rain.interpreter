# Pass 1 (Security) -- RainterpreterExpressionDeployer.sol (A06)

## Evidence of Thorough Reading

**Contract name:** `RainterpreterExpressionDeployer`
**File:** `src/concrete/RainterpreterExpressionDeployer.sol` (81 lines)

### Inheritance

- `IDescribedByMetaV1` (line 27)
- `IParserV2` (line 28)
- `IParserPragmaV1` (line 29)
- `IIntegrityToolingV1` (line 30)
- `ERC165` (line 31)

### Functions

| Function | Visibility | Line |
|---|---|---|
| `supportsInterface(bytes4)` | public view virtual override | 34 |
| `parse2(bytes memory)` | external view virtual override | 41 |
| `parsePragma1(bytes calldata)` | external view virtual override | 66 |
| `buildIntegrityFunctionPointers()` | external view virtual override | 73 |
| `describedByMetaV1()` | external pure virtual override | 78 |

### Imports / Constants Used

| Import | Source |
|---|---|
| `ERC165` | openzeppelin-contracts (line 5) |
| `Pointer` | rain.solmem/lib/LibPointer.sol (line 6) |
| `IParserV2` | rain.interpreter.interface (line 7) |
| `IParserPragmaV1`, `PragmaV1` | rain.interpreter.interface (line 8) |
| `IDescribedByMetaV1` | rain.metadata (line 10) |
| `LibIntegrityCheck` | ../lib/integrity/LibIntegrityCheck.sol (line 12) |
| `LibInterpreterStateDataContract` | ../lib/state/LibInterpreterStateDataContract.sol (line 13) |
| `LibAllStandardOps` | ../lib/op/LibAllStandardOps.sol (line 14) |
| `INTEGRITY_FUNCTION_POINTERS` | generated pointers (line 16) |
| `DESCRIBED_BY_META_HASH` | generated pointers (line 17) |
| `IIntegrityToolingV1` | rain.sol.codegen (line 19) |
| `RainterpreterParser` | ./RainterpreterParser.sol (line 20) |
| `LibInterpreterDeploy` | ../lib/deploy/LibInterpreterDeploy.sol (line 21) |

### Types / Errors / Constants Defined

No custom types, errors, or constants are defined in this file. All constants are imported from generated pointers.

## Security Review

### `parse2` (lines 41-61)

The function:
1. Calls `RainterpreterParser(LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS).unsafeParse(data)` to parse raw Rainlang into bytecode + constants (line 42-43).
2. Calls `serializeSize(bytecode, constants)` to compute buffer size (line 45).
3. Allocates memory via assembly block (lines 48-53).
4. Calls `unsafeSerialize(cursor, bytecode, constants)` to write serialized data (line 54).
5. Runs `integrityCheck2(INTEGRITY_FUNCTION_POINTERS, bytecode, constants)` (line 56).
6. Returns the serialized bytes (line 60).

**Assembly block analysis (lines 48-53):**
- Reads free memory pointer: `serialized := mload(0x40)` -- correct.
- Advances free memory pointer: `mstore(0x40, add(serialized, add(0x20, size)))` -- allocates length prefix (0x20) + data (size). Correct.
- Stores length: `mstore(serialized, size)` -- writes the byte length. Correct.
- Sets cursor: `cursor := add(serialized, 0x20)` -- points past the length prefix. Correct.
- The block is annotated `"memory-safe"`. The allocation pattern is standard.

**Serialization before integrity check:** The serialized data is computed before the integrity check runs. If the integrity check reverts, the serialized data is never returned. If it passes, the serialized data is valid. Both functions are `pure` with no side effects. The ordering is safe.

**Parser trust model:** `PARSER_DEPLOYED_ADDRESS` is a compile-time constant derived from deterministic Zoltu factory deployment. There is no runtime codehash verification of the parser. This is by design -- the deployer and parser are deployed deterministically, and the address constant is baked into the deployer's bytecode. An attacker cannot change what address the deployer calls without deploying a different deployer.

### `parsePragma1` (lines 66-70)

Delegates directly to `RainterpreterParser(LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS).parsePragma1(data)`. Same trust model as `parse2`. The `data` parameter is `calldata`, passed through without modification. No issues.

### `buildIntegrityFunctionPointers` (lines 73-75)

Delegates to `LibAllStandardOps.integrityFunctionPointers()`. Pure computation, no security concern.

### `describedByMetaV1` (lines 78-80)

Returns the compile-time constant `DESCRIBED_BY_META_HASH`. No security concern.

### `supportsInterface` (lines 34-38)

Standard ERC165 implementation checking four interface IDs plus the parent. No security concern.

### Reentrancy

All functions are `view` or `pure`. No state mutations occur in this contract. No reentrancy risk.

### Error handling

- `parse2` relies on `unsafeParse` to revert on invalid Rainlang.
- `integrityCheck2` reverts with custom errors (`OpcodeOutOfRange`, `StackAllocationMismatch`, `StackOutputsMismatch`, `StackUnderflow`, `StackUnderflowHighwater`, `BadOpInputsLength`, `BadOpOutputsLength`).
- No string revert messages are used anywhere in this contract.

### Dismissed prior findings

- **A47-1 (serializeSize unchecked overflow):** Previously dismissed. `constants.length >= 2^251` is unreachable due to parser memory limits. Not re-flagged.

## Findings

No findings.

The contract is a thin coordinator with no state, no storage, no value handling, and all functions are `view` or `pure`. The assembly block is a standard memory allocation pattern. The parser address is a compile-time constant from deterministic deployment. All error paths use custom errors. Previous audits have already examined and dismissed the only theoretical concern (`serializeSize` overflow). The contract is sound.
