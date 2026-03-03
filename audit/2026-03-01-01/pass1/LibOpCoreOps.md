# Pass 1 (Security) -- LibOpCall, LibOpConstant, LibOpContext, LibOpStack

Agent IDs: A17 (LibOpCall), A18 (LibOpConstant), A19 (LibOpContext), A26 (LibOpStack)

## Evidence of Thorough Reading

### LibOpCall.sol (src/lib/op/call/LibOpCall.sol, 171 lines)

**Library**: `LibOpCall` (line 69)

**Functions**:
| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `integrity` | 85 | `internal` | `pure` |
| `run` | 122 | `internal` | `view` |

**Imports**:
- `OperandV2` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 5)
- `InterpreterState` from `../../state/LibInterpreterState.sol` (line 6)
- `IntegrityCheckState` from `../../integrity/LibIntegrityCheck.sol` (line 7)
- `Pointer` from `rain.solmem/lib/LibPointer.sol` (line 8)
- `LibBytecode` from `rain.interpreter.interface/lib/bytecode/LibBytecode.sol` (line 9)
- `LibEval` from `../../eval/LibEval.sol` (line 10)
- `CallOutputsExceedSource` from `../../../error/ErrIntegrity.sol` (line 11)

**Errors imported**: `CallOutputsExceedSource`

**Operand bit layout (24-bit operand)**:
| Bits | Field | Width |
|---|---|---|
| 0-15 | `sourceIndex` | 16 bits |
| 16-19 | `inputs` | 4 bits |
| 20-23 | `outputs` | 4 bits |

Confirmed by `integrity` (lines 86-87), `run` (lines 124-126), and `LibOperand.build` in test helpers.

---

### LibOpConstant.sol (src/lib/op/00/LibOpConstant.sol, 61 lines)

**Library**: `LibOpConstant` (line 15)

**Functions**:
| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `integrity` | 21 | `internal` | `pure` |
| `run` | 37 | `internal` | `pure` |
| `referenceFn` | 52 | `internal` | `pure` |

**Imports**:
- `OutOfBoundsConstantRead` from `../../../error/ErrIntegrity.sol` (line 5)
- `IntegrityCheckState` from `../../integrity/LibIntegrityCheck.sol` (line 6)
- `OperandV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 7)
- `InterpreterState` from `../../state/LibInterpreterState.sol` (line 8)
- `Pointer` from `rain.solmem/lib/LibPointer.sol` (line 9)

**Errors imported**: `OutOfBoundsConstantRead`

**Operand**: low 16 bits encode the constant index.

---

### LibOpContext.sol (src/lib/op/00/LibOpContext.sol, 63 lines)

**Library**: `LibOpContext` (line 12)

**Functions**:
| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `integrity` | 16 | `internal` | `pure` |
| `run` | 28 | `internal` | `pure` |
| `referenceFn` | 47 | `internal` | `pure` |

**Imports**:
- `Pointer` from `rain.solmem/lib/LibPointer.sol` (line 5)
- `OperandV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 6)
- `InterpreterState` from `../../state/LibInterpreterState.sol` (line 7)
- `IntegrityCheckState` from `../../integrity/LibIntegrityCheck.sol` (line 8)

**Errors imported**: None (relies on Solidity's built-in `Panic(0x32)` for array OOB).

**Operand**: low 8 bits = row index `i`, bits 8-15 = column index `j`.

---

### LibOpStack.sol (src/lib/op/00/LibOpStack.sol, 73 lines)

**Library**: `LibOpStack` (line 15)

**Functions**:
| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `integrity` | 21 | `internal` | `pure` |
| `run` | 41 | `internal` | `pure` |
| `referenceFn` | 58 | `internal` | `pure` |

**Imports**:
- `Pointer` from `rain.solmem/lib/LibPointer.sol` (line 5)
- `InterpreterState` from `../../state/LibInterpreterState.sol` (line 6)
- `IntegrityCheckState` from `../../integrity/LibIntegrityCheck.sol` (line 7)
- `OperandV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 8)
- `OutOfBoundsStackRead` from `../../../error/ErrIntegrity.sol` (line 9)

**Errors imported**: `OutOfBoundsStackRead`

**Operand**: low 16 bits encode the stack read index.

---

## Findings

No CRITICAL, HIGH, MEDIUM, or LOW findings identified across the four files.

The analysis below documents the security-relevant design decisions and confirms their correctness.

---

### A17-INFO-01: LibOpCall -- No runtime bounds check on `sourceIndex` for `stackBottoms` access

**Severity**: INFO

**File**: `src/lib/op/call/LibOpCall.sol`
**Location**: `run`, line 136

**Description**: The `run` function accesses `stackBottoms[sourceIndex]` via assembly pointer arithmetic without a Solidity bounds check:

```solidity
evalStackBottom := mload(add(stackBottoms, mul(add(sourceIndex, 1), 0x20)))
```

If `sourceIndex >= stackBottoms.length`, this reads arbitrary memory. The `sourceIndex` is extracted from the operand as `operand & 0xFFFF` (line 124), giving a range of 0 to 65535.

**Analysis**: The integrity check at deploy time validates `sourceIndex` via `LibBytecode.sourceInputsOutputsLength(state.bytecode, sourceIndex)` (line 90), which calls `sourcePointer` -> `sourceRelativeOffset`, which reverts with `SourceIndexOutOfBounds` for out-of-range indices. Bytecode is immutable after serialization. The `stackBottoms` array is constructed from the same bytecode source count, so a valid `sourceIndex` is always in bounds. This is the standard trust model: deploy-time integrity guarantees runtime safety. The NatSpec documents this explicitly (lines 111-116).

---

### A17-INFO-02: LibOpCall -- Output copy loop uses unconventional Yul for-loop structure

**Severity**: INFO

**File**: `src/lib/op/call/LibOpCall.sol`
**Location**: `run`, lines 159-167

**Description**: The output copy loop places the `mstore` in the body and pointer increments in the update clause:

```solidity
for {} lt(evalStackTop, end) {
    cursor := add(cursor, 0x20)
    evalStackTop := add(evalStackTop, 0x20)
} { mstore(cursor, mload(evalStackTop)) }
```

This is correct: the body executes first with the initial pointer values (`cursor == stackTop`, `evalStackTop` == callee's final stack top), then the update increments both pointers. The loop copies `outputs` items in order. Verified: the first store writes `cursor[0] = evalStackTop[0]`, then the update advances both. The final state is `outputs` values copied from callee stack to caller stack.

The input copy loop (lines 139-142) uses a different structure (incrementing `stackTop` in the body, decrementing `evalStackTop` before the store). The asymmetry is intentional: inputs are copied in reverse order (caller's top becomes callee's bottom), outputs are copied in forward order.

---

### A17-INFO-03: LibOpCall -- Recursion terminates only via gas exhaustion

**Severity**: INFO

**File**: `src/lib/op/call/LibOpCall.sol`
**Location**: `run`, lines 122-170

**Description**: No explicit recursion guard exists. Direct recursion (source 0 calling source 0) or indirect recursion (source 0 -> source 1 -> source 0) will consume all gas and revert. The NatSpec documents this at lines 50-53. Test coverage confirms this behavior (`testOpCallRunRecursive` in `LibOpCall.t.sol`).

**Analysis**: Gas exhaustion guarantees a revert, preventing infinite execution. No state corruption or fund loss is possible. Expression authors who accidentally create recursive expressions lose gas. This is documented and tested.

---

### A17-INFO-04: LibOpCall -- `integrity` validates `sourceIndex` and `outputs` but not `inputs`

**Severity**: INFO

**File**: `src/lib/op/call/LibOpCall.sol`
**Location**: `integrity`, lines 85-97

**Description**: The `integrity` function extracts `sourceIndex` and `outputs` from the operand but does not extract the `inputs` field. Instead, it returns `sourceInputs` from `LibBytecode.sourceInputsOutputsLength`. The framework (`LibIntegrityCheck.integrityCheck2`, line 159) compares the returned `calcOpInputs` against `bytecodeOpInputs` and reverts with `BadOpInputsLength` if they differ.

**Analysis**: This is the correct pattern. The integrity function declares the canonical IO, and the framework enforces consistency with the bytecode. Validation is not missing; it is delegated to the framework layer. Test `testOpCallRunInputsMismatch` in `LibOpCall.t.sol` confirms the revert.

---

### A17-INFO-05: LibOpCall -- Assembly blocks correctly marked `memory-safe`

**Severity**: INFO

**File**: `src/lib/op/call/LibOpCall.sol`
**Location**: `run`, lines 135, 159

**Description**: Both assembly blocks read from and write to pre-allocated memory regions (caller stack, callee stack, `stackBottoms` array). No new memory is allocated. The input copy writes within the callee's pre-allocated stack (from `evalStackBottom` downward, bounded by `stackAllocation`). The output copy writes within the caller's pre-allocated stack (at `stackTop`, bounded by the caller's allocation). Both annotations are correct.

---

### A18-INFO-01: LibOpConstant -- `run` relies entirely on integrity for bounds safety

**Severity**: INFO

**File**: `src/lib/op/00/LibOpConstant.sol`
**Location**: `run`, lines 37-46

**Description**: The `run` function reads from the constants array in assembly without a bounds check:

```solidity
let value := mload(add(constants, mul(add(and(operand, 0xFFFF), 1), 0x20)))
```

The comment on line 39 states: "Skip index OOB check and rely on integrity check for that." The `integrity` function (line 24) validates `constantIndex < state.constants.length`, reverting with `OutOfBoundsConstantRead` if violated. Since the deployer enforces integrity at deploy time and bytecode is immutable, the runtime index is guaranteed valid.

**Analysis**: Standard trust model. Tests cover both the happy path (`testOpConstantRun`, `testOpConstantEval`) and the OOB revert (`testOpConstantIntegrityOOBConstants`, `testOpConstantIntegrityMaxIndex`, `testOpConstantEvalZeroConstants`).

---

### A18-INFO-02: LibOpConstant -- Operand extraction is consistent across all three functions

**Severity**: INFO

**File**: `src/lib/op/00/LibOpConstant.sol`
**Location**: Lines 23, 41, 57

**Description**: All three functions extract the constant index from the low 16 bits of the operand:
- `integrity` (line 23): `uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)))`
- `run` (line 41): `and(operand, 0xFFFF)` (assembly, raw bytes32 value)
- `referenceFn` (line 57): `uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)))`

Since `OperandV2` is `type OperandV2 is bytes32`, in assembly the raw bytes32 value's low 16 bits match `OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF))`. These are equivalent.

---

### A19-INFO-01: LibOpContext -- Integrity cannot validate context bounds at compile time

**Severity**: INFO

**File**: `src/lib/op/00/LibOpContext.sol`
**Location**: `integrity`, line 16

**Description**: The `integrity` function returns `(0, 1)` without validating the operand indices against context dimensions. The comment on lines 18-19 explains this is intentional: context shape is unknown at deploy time. Expressions that pass integrity can still revert at runtime with `Panic(0x32)` if `i` or `j` exceed the actual context dimensions.

**Analysis**: This is a known design limitation. The Solidity-level array access at line 35 (`state.context[i][j]`) provides runtime bounds checking via compiler-generated code. Tests confirm OOB reverts: `testOpContextRunOOBi`, `testOpContextRunOOBj`, `testOpContextEvalOOBi`, `testOpContextEvalOOBj`, `testOpContextEvalEmptyInnerArray`.

---

### A19-INFO-02: LibOpContext -- Runtime OOB produces Panic rather than custom error

**Severity**: INFO

**File**: `src/lib/op/00/LibOpContext.sol`
**Location**: `run`, line 35

**Description**: When `state.context[i][j]` is out of bounds, Solidity emits `Panic(0x32)` rather than a custom error. The project convention is custom errors, but replacing this would require manual bounds checking in assembly, which would sacrifice the automatic bounds checking the code explicitly relies on (comment on lines 31-34).

**Analysis**: Pragmatic tradeoff. The Panic revert is still a safe revert (transaction rolls back), just not as informative as a custom error. The cost of a manual check with custom error would add gas to every context access, which is a hot path.

---

### A26-INFO-01: LibOpStack -- `run` relies entirely on integrity for bounds safety

**Severity**: INFO

**File**: `src/lib/op/00/LibOpStack.sol`
**Location**: `run`, lines 41-49

**Description**: The `run` function reads from the stack via assembly without bounds checking:

```solidity
let stackBottom := mload(add(mload(state), mul(0x20, add(sourceIndex, 1))))
let stackValue := mload(sub(stackBottom, mul(0x20, add(and(operand, 0xFFFF), 1))))
```

The first line loads `state.stackBottoms[sourceIndex]` via pointer arithmetic on the struct's first field. The second line reads from `stackBottom - (readIndex + 1) * 0x20`. If `readIndex` exceeds the stack depth, this reads arbitrary memory before the stack.

**Analysis**: The `integrity` function (line 24) validates `readIndex < state.stackIndex`, which ensures the read is within the currently computed stack depth. The `LibIntegrityCheck` framework additionally enforces that the stack index never drops below the `readHighwater` (line 172 of `LibIntegrityCheck.sol`), and `LibOpStack.integrity` advances `readHighwater` when needed (line 29-31). This prevents stack reads from being invalidated by subsequent pops. Standard trust model.

---

### A26-INFO-02: LibOpStack -- `readHighwater` tracking prevents dangling stack reads

**Severity**: INFO

**File**: `src/lib/op/00/LibOpStack.sol`
**Location**: `integrity`, lines 29-31

**Description**: When `readIndex > state.readHighwater`, the integrity function updates `readHighwater` to `readIndex`. The `LibIntegrityCheck` framework (line 172) then reverts with `StackUnderflowHighwater` if any subsequent opcode would consume stack below this mark. This ensures that a stack position read by the `stack` opcode cannot later be consumed and overwritten by another opcode.

**Analysis**: This is a correctness-critical invariant. Without the highwater tracking, the `stack` opcode could read a position that a later opcode pops, leading to the `run` function reading stale or overwritten data. The mechanism is correctly implemented. Note that the check uses `<` (strict less-than), meaning the highwater mark position itself is protected -- it cannot be popped.

---

### A26-INFO-03: LibOpStack -- `referenceFn` uses Solidity bounds-checked access

**Severity**: INFO

**File**: `src/lib/op/00/LibOpStack.sol`
**Location**: `referenceFn`, lines 58-72

**Description**: The reference function uses `state.stackBottoms[state.sourceIndex]` (Solidity-level bounds-checked array access, line 66) and Solidity's checked arithmetic for `stackBottom - (readIndex + 1) * 0x20` (line 67). This provides a safer implementation for differential testing against `run`. The only assembly is writing the loaded value into the output array (line 70). The `testOpStackRunReferenceFnParity` test confirms parity between `run` and `referenceFn`.

---

## Summary

Across all four files, no CRITICAL, HIGH, MEDIUM, or LOW severity issues were identified.

All four opcodes follow the same architectural pattern:
1. **Integrity at deploy time** validates operand fields against structural limits (source count, constants length, stack depth).
2. **Runtime (`run`)** uses unchecked assembly for gas efficiency, relying on the integrity guarantees.
3. The expression deployer enforces that integrity checks pass before any expression can be evaluated.
4. Bytecode is immutable after deployment, so integrity-validated invariants cannot become stale.

The assembly blocks are correctly annotated as `memory-safe`. All reverts use custom errors (except `LibOpContext`, which relies on Solidity's built-in `Panic(0x32)` for array bounds checking -- an intentional tradeoff documented in the code). Operand extraction is consistent between `integrity`, `run`, and `referenceFn` across all four files. Test coverage is thorough, including happy paths, OOB error paths, boundary conditions, and differential testing against reference implementations.
