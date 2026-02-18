# Pass 1 (Security) - LibOpCall.sol

**File**: `src/lib/op/call/LibOpCall.sol`

## Evidence of Thorough Reading

### Contract/Library
- `LibOpCall` (library, line 69)

### Functions
| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `integrity` | 72 | `internal` | `pure` |
| `run` | 90 | `internal` | `view` |

### Errors/Events/Structs Defined
None defined in this file. Imports:
- `CallOutputsExceedSource` from `src/error/ErrIntegrity.sol` (line 11)

### Imports
- `OperandV2` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 5)
- `InterpreterState` from `../../state/LibInterpreterState.sol` (line 6)
- `IntegrityCheckState` from `../../integrity/LibIntegrityCheck.sol` (line 7)
- `Pointer, LibPointer` from `rain.solmem/lib/LibPointer.sol` (line 8)
- `LibBytecode` from `rain.interpreter.interface/lib/bytecode/LibBytecode.sol` (line 9)
- `LibEval` from `../../eval/LibEval.sol` (line 10)
- `CallOutputsExceedSource` from `../../../error/ErrIntegrity.sol` (line 11)

### Using Directives
- `LibPointer for Pointer` (line 70)

---

## Operand Bit Layout (24-bit operand)

Understanding the operand encoding is essential for reviewing this file. Each opcode in bytecode is 4 bytes: 1 byte opcode index + 3 bytes operand (24 bits). The operand layout for `call` is:

| Bits | Field | Width |
|------|-------|-------|
| 0-15 | `sourceIndex` | 16 bits |
| 16-19 | `inputs` | 4 bits |
| 20-23 | `outputs` | 4 bits |

This is confirmed by both `run` (lines 92-94) and `LibOperand.build` in tests (`test/lib/operand/LibOperand.sol`).

---

## Findings

### Finding 1: No Runtime Bounds Check on `sourceIndex` for `stackBottoms` Array Access

**Severity**: LOW

**Location**: `run`, line 104

**Description**: The `run` function accesses `stackBottoms[sourceIndex]` via assembly without a bounds check:

```solidity
evalStackBottom := mload(add(stackBottoms, mul(add(sourceIndex, 1), 0x20)))
```

If `sourceIndex >= stackBottoms.length`, this reads arbitrary memory beyond the array. The `sourceIndex` is extracted from the operand as `operand & 0xFFFF` (line 92), giving it a range of 0 to 65535.

**Mitigating Factors**: The integrity check at deploy time validates `sourceIndex` via `LibBytecode.sourceInputsOutputsLength(state.bytecode, sourceIndex)` (line 77), which reverts with `SourceIndexOutOfBounds` if the index exceeds the bytecode's source count. The `LibEval.sol` NatSpec explicitly documents this trust relationship: `LibOpCall.run` relies on integrity checks at deploy time to reject invalid source indices in operands (line 28-29 of LibEval.sol). Since bytecode is immutable after deployment, this is safe under the integrity-at-deploy trust model.

**Risk**: Only exploitable if integrity checks are bypassed entirely (e.g., crafted bytecode submitted without going through the expression deployer). The expression deployer enforces integrity checks, so this requires a separate vulnerability in the deploy path.

---

### Finding 2: No Overflow Guard on `inputs` and `outputs` in Stack Pointer Arithmetic

**Severity**: LOW

**Location**: `run`, lines 106, 128

**Description**: The stack pointer arithmetic in the input-copy loop and output-copy loop uses unchecked multiplication:

```solidity
// Input copy (line 106):
let end := add(stackTop, mul(inputs, 0x20))

// Output copy (line 128):
stackTop := sub(stackTop, mul(outputs, 0x20))
```

The `inputs` field is masked to 4 bits (`& 0x0F`, line 93), so its max value is 15. The `outputs` field is `operand >> 0x14` (line 94). Since the operand is masked to 24 bits by the eval loop (`and(shr(..., word), 0xFFFFFF)`), `outputs` has a max value of 15 (4 bits). Therefore `mul(inputs, 0x20)` has a max of `15 * 32 = 480` and `mul(outputs, 0x20)` similarly. No overflow is possible.

**Mitigating Factors**: The 4-bit field widths inherently prevent overflow. Additionally, the integrity check validates that `outputs <= sourceOutputs` (line 79), ensuring the callee actually produces enough values.

**Risk**: No practical risk. The arithmetic is inherently safe due to 4-bit field widths.

---

### Finding 3: Output Copy Loop -- Body and Update Ordering

**Severity**: INFO

**Location**: `run`, lines 127-135

**Description**: The output copy loop has an unconventional structure where the `mstore` is in the body section and the pointer increments are in the update section of the Yul `for` loop:

```solidity
for {} lt(evalStackTop, end) {
    cursor := add(cursor, 0x20)
    evalStackTop := add(evalStackTop, 0x20)
} { mstore(cursor, mload(evalStackTop)) }
```

This is functionally correct -- the body executes first with the initial pointer values, then the update increments them. On the first iteration, `cursor == stackTop` and `evalStackTop` points to the callee's stack top. Each subsequent iteration copies the next item. The loop copies `outputs` items preserving order.

However, this differs from the input-copy loop (lines 107-110) which places the `mstore` as the first statement of the body and the pointer increments in different positions. The inconsistency in loop structure between the two assembly blocks could lead to maintenance confusion.

**Risk**: No functional risk. Observation about code style.

---

### Finding 4: `integrity` Does Not Validate `inputs` Field in Operand Against Source

**Severity**: INFO

**Location**: `integrity`, lines 72-84

**Description**: The `integrity` function extracts `sourceIndex` and `outputs` from the operand, but does NOT extract or validate the `inputs` field (bits 16-19). Instead, it returns `sourceInputs` from `LibBytecode.sourceInputsOutputsLength`. The `integrityCheck2` function in `LibIntegrityCheck.sol` (line 146) compares the integrity function's returned `calcOpInputs` against `bytecodeOpInputs` (the value in the operand's bits 16-19), and reverts with `BadOpInputsLength` if they differ.

This means validation of the `inputs` field is delegated to the caller (`integrityCheck2`), not performed within `LibOpCall.integrity` itself. This is the correct pattern -- `integrity` declares inputs/outputs and the framework enforces consistency.

**Risk**: None. This is a design observation confirming correctness.

---

### Finding 5: Recursion Protection is Gas-Based Only

**Severity**: INFO

**Location**: `run`, lines 90-138

**Description**: The `call` opcode has no explicit recursion guard. Direct recursion (source 0 calling source 0) or indirect recursion (source 0 -> source 1 -> source 0) will cause infinite recursion that terminates only when gas is exhausted, resulting in a revert. The NatSpec at lines 50-53 documents this: "Recursion is not supported. This is because currently there is no laziness in the interpreter, so a recursive call would result in an infinite loop unconditionally."

Test coverage confirms this behavior (`testOpCallRunRecursive` in `LibOpCall.t.sol`).

**Mitigating Factors**: Gas exhaustion provides a guaranteed revert, so this cannot cause permanent state corruption or loss of funds. The recursive call consumes all gas and reverts.

**Risk**: Expression authors who accidentally introduce recursion will lose all gas for the transaction. This is documented behavior.

---

### Finding 6: Assembly Blocks Marked `memory-safe` -- Verification

**Severity**: INFO

**Location**: `run`, lines 103 and 127

**Description**: Both assembly blocks are annotated `memory-safe`. Verifying this claim:

**Block 1 (lines 103-111, input copy)**:
- Reads from `stackBottoms` array (allocated memory, read-only access)
- Reads from caller stack via `mload(stackTop)` (pre-allocated)
- Writes to callee stack via `mstore(evalStackTop, ...)` where `evalStackTop` starts at `evalStackBottom` and moves downward. The callee stack was pre-allocated during deserialization with size determined by `stackAllocation` from the source header.
- The write target is within the pre-allocated callee stack region.

**Block 2 (lines 127-135, output copy)**:
- Writes to caller stack at `stackTop` (which was moved up during input consumption and then back down for output space). The written region overlaps with space that was previously occupied by inputs or newly allocated on the caller's pre-allocated stack.
- Reads from callee stack via `mload(evalStackTop)` (read-only, pre-allocated).

Both blocks operate within pre-allocated memory regions. The `memory-safe` annotation is justified.

---

### Finding 7: `sourceIndex` Restoration After Call

**Severity**: INFO

**Location**: `run`, lines 115-124

**Description**: The function correctly saves and restores `state.sourceIndex`:

```solidity
uint256 currentSourceIndex = state.sourceIndex;
state.sourceIndex = sourceIndex;
evalStackTop = LibEval.evalLoop(state, currentSourceIndex, evalStackTop, evalStackBottom);
state.sourceIndex = currentSourceIndex;
```

The `currentSourceIndex` is also passed to `evalLoop` as `parentSourceIndex` for stack tracing purposes. This ensures that nested calls do not corrupt the caller's source index state. This pattern is correct.

---

## Summary

No CRITICAL or HIGH severity issues were found. The `call` opcode implementation is well-structured with appropriate trust boundaries. Security-relevant invariants (source index bounds, stack sizing, input/output counts) are enforced at deploy time via integrity checks, and the runtime relies on those pre-validated guarantees. The assembly is within pre-allocated memory regions, the `memory-safe` annotations are justified, and all reverts use custom errors.
