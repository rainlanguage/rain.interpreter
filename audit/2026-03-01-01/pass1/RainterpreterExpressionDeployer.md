# Pass 1 (Security) -- RainterpreterExpressionDeployer.sol (A47)

## Evidence of Thorough Reading

### Contract

`RainterpreterExpressionDeployer` (line 26), inheriting from `IDescribedByMetaV1`, `IParserV2`, `IParserPragmaV1`, `IIntegrityToolingV1`, `ERC165`.

### Functions

| Function | Line | Visibility | Mutability | Modifiers |
|---|---|---|---|---|
| `supportsInterface(bytes4)` | 34 | public | view | virtual override |
| `parse2(bytes memory)` | 41 | external | view | virtual override |
| `parsePragma1(bytes calldata)` | 66 | external | view | virtual override |
| `buildIntegrityFunctionPointers()` | 73 | external | view | virtual |
| `describedByMetaV1()` | 78 | external | pure | override |

### Types/Errors/Constants Defined

None defined directly in this file. All errors are defined transitively:
- From `LibIntegrityCheck`: `OpcodeOutOfRange`, `BadOpInputsLength`, `BadOpOutputsLength`, `StackUnderflow`, `StackUnderflowHighwater`, `StackAllocationMismatch`, `StackOutputsMismatch`
- From `RainterpreterParser`: parse errors, `ParseMemoryOverflow`

### Constants Imported

- `INTEGRITY_FUNCTION_POINTERS` -- packed 2-byte function pointers for integrity check (line 16)
- `DESCRIBED_BY_META_HASH` -- hash of the CBOR-encoded meta describing this contract (line 17)

### Imports (lines 5--21)

- `ERC165`, `IERC165` from OpenZeppelin
- `Pointer` from `rain.solmem`
- `IParserV2` from `rain.interpreter.interface`
- `IParserPragmaV1`, `PragmaV1` from `rain.interpreter.interface`
- `IDescribedByMetaV1` from `rain.metadata`
- `LibIntegrityCheck` (internal, `src/lib/integrity/`)
- `LibInterpreterStateDataContract` (internal, `src/lib/state/`)
- `LibAllStandardOps` (internal, `src/lib/op/`)
- `INTEGRITY_FUNCTION_POINTERS`, `DESCRIBED_BY_META_HASH` from generated pointers
- `IIntegrityToolingV1` from `rain.sol.codegen`
- `RainterpreterParser` (internal, `src/concrete/`)
- `LibInterpreterDeploy` (internal, `src/lib/deploy/`)

---

## Security Analysis

### Pipeline walkthrough: `parse2`

1. **Parse**: Calls `RainterpreterParser(PARSER_DEPLOYED_ADDRESS).unsafeParse(data)` (line 43). This is an external `view` call to a deterministic Zoltu-deployed address. Returns `(bytes memory bytecode, bytes32[] memory constants)`.

2. **Serialize**: Computes `serializeSize(bytecode, constants)` (line 45), allocates memory via inline assembly (lines 48--53), then writes via `unsafeSerialize(cursor, bytecode, constants)` (line 54). The serialized format is `[constants_length][constants_data...][bytecode_length][bytecode_data...]`.

3. **Integrity check**: Calls `integrityCheck2(INTEGRITY_FUNCTION_POINTERS, bytecode, constants)` (line 56). This walks every opcode in every source, calling each opcode's integrity function. Reverts on any structural mismatch (stack underflow, opcode out of range, allocation mismatch, etc.).

4. **Return**: Returns the serialized bytes. The integrity check result (`io`) is discarded (line 57--58) because `IParserV2` does not use it.

### Ordering: serialize before integrity check

The deployer serializes the bytecode before running the integrity check. If the integrity check reverts, the serialized data is never returned. If the integrity check passes, the serialized data is valid. Both `serializeSize` and `unsafeSerialize` are `pure` with no side effects. The `checkNoOOBPointers` validation in `integrityCheck2` guards against structurally malformed bytecode before opcode iteration. The ordering is safe.

### No runtime codehash verification

The deployer calls `PARSER_DEPLOYED_ADDRESS` without verifying `extcodehash`. The code hash constants in `LibInterpreterDeploy` exist for build-time/test verification only. This is an architectural decision: deterministic Zoltu deployment provides the trust anchor. If no contract exists at the address, the external call reverts (empty code -> revert on ABI decode). If a different contract exists (which cannot happen with deterministic deployment unless the chain has a different genesis), it would need to conform to the ABI of `unsafeParse`, and any structurally invalid output would be caught by `integrityCheck2`.

### Assembly block in `parse2` (lines 48--53)

```solidity
assembly ("memory-safe") {
    serialized := mload(0x40)
    mstore(0x40, add(serialized, add(0x20, size)))
    mstore(serialized, size)
    cursor := add(serialized, 0x20)
}
```

This allocates `size + 0x20` bytes at the free memory pointer, writes the length, and sets the cursor past the length word. The `"memory-safe"` annotation is correct: it only reads/writes the free memory region and updates `0x40`.

### `virtual` modifiers

All public/external functions are `virtual`. This allows subclassing, but any subclass would be a different contract at a different address with a different codehash. The deterministic deployment model ensures that `EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS` points to the exact unmodified `RainterpreterExpressionDeployer` bytecode. Subclasses cannot impersonate the canonical deployer.

### Access control

All functions are permissionless. This is by design: `parse2` and `parsePragma1` are `view` (no state changes), `buildIntegrityFunctionPointers` is `view` (returns a constant), and `describedByMetaV1` is `pure`. There is no state to protect.

---

## Findings

### A47-1: `serializeSize` unchecked overflow in `parse2` context -- LOW

**Location:** Line 45 (deployer), calling `LibInterpreterStateDataContract.serializeSize` (line 26--31 of `src/lib/state/LibInterpreterStateDataContract.sol`)

**Description:** `serializeSize` uses `unchecked` arithmetic: `size = bytecode.length + constants.length * 0x20 + 0x40`. The multiplication `constants.length * 0x20` can overflow if `constants.length >= 2^251`. The subsequent addition can also overflow.

**Impact:** If overflow occurred, `size` would be smaller than the actual data. The assembly block (lines 48--53) would allocate a too-small buffer and `mstore(0x40, ...)` would set the free memory pointer too low. `unsafeSerialize` would then write past the allocated region, corrupting the free memory pointer and subsequent memory allocations. Depending on what follows, this could corrupt the integrity check state or the returned data.

**Mitigating factors:**
1. The `constants` array is produced by `unsafeParse`, which is subject to the parser's `checkParseMemoryOverflow` modifier (reverts if free memory pointer reaches `0x10000`). This means `constants.length` is bounded by `~0x10000 / 0x20 = 2048` in practice.
2. Even without the parser constraint, allocating an array of length `2^251` would require `2^256` bytes of memory, which would exhaust gas immediately.
3. The NatSpec on `serializeSize` documents this precondition.

**Severity:** LOW -- the overflow is mathematically possible but practically unreachable due to EVM memory/gas constraints and the parser's memory overflow check.

### A47-2: No `@notice` tag on contract-level NatSpec -- INFO

**Location:** Lines 23--25

**Description:** The contract has a `@title` tag (line 23) followed by a `@notice` tag (line 24). According to the codebase convention, when any explicit tag is present, all entries must be explicitly tagged. The current NatSpec is correct: `@title` on line 23 and `@notice` on lines 24--25. No issue here -- confirming correctness.

**Severity:** INFO -- NatSpec is correct.

### A47-3: `describedByMetaV1` lacks `virtual` unlike other functions -- INFO

**Location:** Line 78

**Description:** All other public/external functions in the contract have the `virtual` modifier, but `describedByMetaV1` uses only `override` (no `virtual`). This means a subclass cannot override the meta hash. This is inconsistent with the other functions but not a security concern -- the meta hash is a compile-time constant and there is no reason for a subclass to override it.

**Severity:** INFO -- stylistic inconsistency, not a security issue.

---

## Summary

No CRITICAL, HIGH, or MEDIUM findings. The `RainterpreterExpressionDeployer` is a small, focused contract that orchestrates parsing, serialization, and integrity checking. The pipeline is correctly ordered (serialize is side-effect-free; integrity check reverts on invalid bytecode). The assembly memory allocation is correct and properly annotated. The security model relies on deterministic Zoltu deployment rather than runtime hash verification, which is appropriate for the architecture.

Previous audit findings from `2026-02-17-03` have been addressed:
- Test coverage gaps (A47-1, A47-2 from pass 2) are now covered by `RainterpreterExpressionDeployer.parse2.t.sol` and `RainterpreterExpressionDeployer.parsePragma1.t.sol`.
- NatSpec issues (A47-1, A47-2 from pass 1 triage) have been fixed.

| Severity | Count |
|---|---|
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 2 |
