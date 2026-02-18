# Pass 2 (Test Coverage) -- LibIntegrityCheck.sol

## Evidence of Thorough Reading

### Source file: `src/lib/integrity/LibIntegrityCheck.sol`

**Library:** `LibIntegrityCheck`

**Struct:**
- `IntegrityCheckState` (line 18) -- fields: `stackIndex`, `stackMaxIndex`, `readHighwater`, `constants`, `opIndex`, `bytecode`

**Functions:**
- `newState(bytes memory bytecode, uint256 stackIndex, bytes32[] memory constants)` (line 39) -- constructs an `IntegrityCheckState` with initial stack depth, max, and highwater all set to `stackIndex`
- `integrityCheck2(bytes memory fPointers, bytes memory bytecode, bytes32[] memory constants)` (line 74) -- walks every opcode in every source, validates IO, stack depth, allocation, and outputs

**Errors used (imported):**
- `OpcodeOutOfRange` (from `src/error/ErrIntegrity.sol`, line 8) -- thrown at line 140
- `StackAllocationMismatch` (from `src/error/ErrIntegrity.sol`, line 9) -- thrown at line 183
- `StackOutputsMismatch` (from `src/error/ErrIntegrity.sol`, line 10) -- thrown at line 188
- `StackUnderflow` (from `src/error/ErrIntegrity.sol`, line 11) -- thrown at line 154
- `StackUnderflowHighwater` (from `src/error/ErrIntegrity.sol`, line 12) -- thrown at line 160
- `BadOpInputsLength` (from `rain.interpreter.interface/error/ErrIntegrity.sol`, line 14) -- thrown at line 147
- `BadOpOutputsLength` (from `rain.interpreter.interface/error/ErrIntegrity.sol`, line 14) -- thrown at line 150

### Test file: `test/src/lib/integrity/LibIntegrityCheck.t.sol`

**Contract:** `LibIntegrityCheckTest`

**Functions:**
- `integrityCheck2External(bytes, bytes, bytes32[])` (line 16) -- external wrapper for `vm.expectRevert`
- `buildSingleOpBytecode(uint256 opcodeIndex)` (line 27) -- helper to build minimal bytecode
- `testOpcodeOutOfRange(uint256 opcodeIndex)` (line 55) -- fuzz test for `OpcodeOutOfRange`
- `testOpcodeInRange()` (line 67) -- boundary test verifying max valid opcode does not trigger `OpcodeOutOfRange`

## Findings

### A12-1: No direct test for `StackUnderflow` revert path

**Severity:** HIGH

The `StackUnderflow` error (line 154) is thrown when `calcOpInputs > state.stackIndex`, i.e., an opcode tries to consume more stack values than are available. No test in the entire `test/` directory triggers or asserts on `StackUnderflow`. A grep for `StackUnderflow` across `test/` returns zero matches (the only hits are for `StackUnderflowHighwater`). This means the underflow protection path has no coverage -- a regression that silently removes this check would go undetected.

**Location:** `src/lib/integrity/LibIntegrityCheck.sol` lines 153-155

---

### A12-2: No direct test for `StackUnderflowHighwater` revert path

**Severity:** HIGH

The `StackUnderflowHighwater` error (line 160) is thrown when the stack index drops below the read highwater after consuming inputs. This protects against an opcode reading values that a previous multi-output opcode wrote, which would violate the immutability invariant. No test in the entire `test/` directory triggers or asserts on `StackUnderflowHighwater`. A grep for `StackUnderflowHighwater` across `test/` returns zero matches. The highwater mechanism is a critical safety property and has no coverage.

**Location:** `src/lib/integrity/LibIntegrityCheck.sol` lines 159-161

---

### A12-3: No direct test for `StackAllocationMismatch` revert path

**Severity:** HIGH

The `StackAllocationMismatch` error (line 183) is thrown after source processing when the computed `stackMaxIndex` does not match the bytecode-declared stack allocation. No test in the entire `test/` directory triggers or asserts on `StackAllocationMismatch`. A grep for the error name across `test/` returns zero matches. This check ensures the bytecode's declared allocation is consistent with the integrity analysis; without test coverage, a regression could allow mismatched allocations to pass.

**Location:** `src/lib/integrity/LibIntegrityCheck.sol` lines 182-184

---

### A12-4: No direct test for `StackOutputsMismatch` revert path

**Severity:** HIGH

The `StackOutputsMismatch` error (line 188) is thrown when the final stack index after processing all opcodes in a source does not match the declared output count. No test in the entire `test/` directory triggers or asserts on `StackOutputsMismatch`. A grep for the error name across `test/` returns zero matches. This check validates that the bytecode's declared outputs are consistent with actual opcode behavior.

**Location:** `src/lib/integrity/LibIntegrityCheck.sol` lines 187-189

---

### A12-5: No test for `newState` initialization correctness

**Severity:** MEDIUM

The `newState` function (line 39) initializes `IntegrityCheckState` with `stackIndex`, `stackMaxIndex`, and `readHighwater` all set to the input `stackIndex` parameter and `opIndex` set to 0. While `newState` is called indirectly by `OpTest.sol` (line 96) and `LibOpStack.t.sol` (lines 44, 65), no test verifies the returned struct fields are correct. If the field ordering in the struct literal were accidentally swapped (e.g., `constants` and `readHighwater`), no test would catch it. A unit test asserting the individual fields of the returned `IntegrityCheckState` is missing.

**Location:** `src/lib/integrity/LibIntegrityCheck.sol` lines 39-58

---

### A12-6: No test for multi-output highwater advancement logic

**Severity:** MEDIUM

Lines 173-175 advance `readHighwater` to `stackIndex` when an opcode produces more than one output (`calcOpOutputs > 1`). This is a critical invariant -- it prevents subsequent opcodes from reading intermediate multi-output values. No test directly verifies this logic. There is no test that constructs a scenario with a multi-output opcode followed by a read that would violate the highwater, nor is there a positive test confirming highwater advancement. The `readHighwater` field name does not appear anywhere in `test/`.

**Location:** `src/lib/integrity/LibIntegrityCheck.sol` lines 173-175

---

### A12-7: No test for `stackMaxIndex` tracking logic

**Severity:** LOW

Lines 168-170 update `stackMaxIndex` when `stackIndex` exceeds it. This tracking feeds into the `StackAllocationMismatch` check. While the allocation check itself is also untested (A12-3), the max-tracking logic is independently untestable in isolation since it is only observable through the allocation comparison. This is noted for completeness -- fixing A12-3 would provide indirect coverage of this path.

**Location:** `src/lib/integrity/LibIntegrityCheck.sol` lines 168-170

---

### A12-8: No test for zero-source bytecode (`sourceCount == 0`)

**Severity:** LOW

When `sourceCount` is 0, `integrityCheck2` returns an empty `io` bytes array without entering the loop. No test exercises this edge case. While `checkNoOOBPointers` may reject such bytecode upstream (it is also untested in `test/`), the behavior of `integrityCheck2` with zero sources should be explicitly verified.

**Location:** `src/lib/integrity/LibIntegrityCheck.sol` lines 80, 97, 107

---

### A12-9: No test for multi-source bytecode integrity checking

**Severity:** LOW

The `integrityCheck2` function iterates over all sources (`for (uint256 i = 0; i < sourceCount; i++)`). The only test constructs bytecode with `sourceCount = 1`. No test exercises bytecode with 2 or more sources to verify that independent `IntegrityCheckState` is correctly constructed per source, that the `io` output array is correctly populated for each source, or that a failure in a non-first source is caught.

**Location:** `src/lib/integrity/LibIntegrityCheck.sol` lines 107-190

---

### A12-10: `BadOpInputsLength` and `BadOpOutputsLength` only have indirect coverage

**Severity:** INFO

The `BadOpInputsLength` (line 147) and `BadOpOutputsLength` (line 150) error paths are not directly tested in the `LibIntegrityCheck` test file. However, they have substantial indirect coverage through op-specific tests (e.g., `LibOpMaxPositiveValue.t.sol`, `LibOpConstant.t.sol`, `LibOpERC721BalanceOf.t.sol`, and many others) that use the `checkBadInputs`/`checkBadOutputs` helpers in `OpTest.sol`, which call through `parse2` and ultimately reach `integrityCheck2`. This indirect coverage is adequate but could be made more explicit.

**Location:** `src/lib/integrity/LibIntegrityCheck.sol` lines 146-151
