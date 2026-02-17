# Pass 1 (Security) — LibOpConstant.sol

## Evidence of Thorough Reading

**File**: `src/lib/op/00/LibOpConstant.sol` (50 lines)

**Library**: `LibOpConstant`

**Functions**:
| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `integrity(IntegrityCheckState memory, OperandV2)` | 17 | internal | pure |
| `run(InterpreterState memory, OperandV2, Pointer)` | 29 | internal | pure |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` | 41 | internal | pure |

**Errors imported**:
- `OutOfBoundsConstantRead` (from `src/error/ErrIntegrity.sol`, line 5)

**Structs/Events defined**: None

**Imports**:
- `OutOfBoundsConstantRead` from `../../error/ErrIntegrity.sol`
- `IntegrityCheckState` from `../../integrity/LibIntegrityCheck.sol`
- `OperandV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterV4.sol`
- `InterpreterState` from `../../state/LibInterpreterState.sol`
- `Pointer` from `rain.solmem/lib/LibPointer.sol`

---

## Analysis

### Operand Index Extraction

Both `integrity` (line 19) and `run` (line 33) extract the constant index from the low 16 bits of the operand:

- **integrity**: `uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)))` — Solidity-level extraction
- **run**: `and(operand, 0xFFFF)` — Assembly-level extraction
- **referenceFn**: `uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)))` — matches integrity

Since `OperandV2` is `type OperandV2 is bytes32`, in assembly the raw `bytes32` value is used directly. Both `and(operand, 0xFFFF)` and `uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)))` extract the same low 16 bits. These are consistent.

### Integrity Inputs/Outputs vs Run Behavior

`integrity` returns `(0, 1)`: zero inputs consumed, one output produced.

`run` assembly:
- No values are read from the stack (0 inputs consumed).
- `stackTop := sub(stackTop, 0x20)` followed by `mstore(stackTop, value)` pushes exactly 1 value (1 output produced).

These match correctly.

### Assembly Memory Safety (run, lines 32-36)

```solidity
assembly ("memory-safe") {
    let value := mload(add(constants, mul(add(and(operand, 0xFFFF), 1), 0x20)))
    stackTop := sub(stackTop, 0x20)
    mstore(stackTop, value)
}
```

**Array access**: `add(constants, mul(add(index, 1), 0x20))` = `constants + (index + 1) * 32`. Since `constants` is a pointer to the `bytes32[]` memory array header (first 32 bytes = length), element `i` lives at offset `(i + 1) * 32`. This is correct Solidity memory array indexing.

**Bounds check**: The `run` function deliberately skips the OOB check (comment on line 31: "Skip index OOB check and rely on integrity check for that"). This is by design — the integrity check at deploy time validates that `constantIndex < state.constants.length`, so at runtime the index is guaranteed to be valid. The integrity check is enforced by the expression deployer before any expression can be evaluated.

**Stack write**: `stackTop` is decremented by 32 bytes and then written to. The stack allocation is validated by the integrity check system (`StackAllocationMismatch` in `LibIntegrityCheck.sol`), ensuring sufficient stack space is pre-allocated.

### Unchecked Arithmetic

There is no `unchecked` block in this file. The assembly arithmetic (`add`, `sub`, `mul`) is inherently unchecked in the EVM, but:
- `and(operand, 0xFFFF)` constrains the index to [0, 65535], so `add(index, 1)` cannot overflow.
- `mul(add(index, 1), 0x20)` with max index 65535 produces at most `65536 * 32 = 2,097,152`, which cannot overflow a 256-bit value.
- `sub(stackTop, 0x20)` could theoretically underflow if `stackTop < 0x20`, but the integrity check and stack allocation system prevent this.

### Custom Errors

The only revert in this file uses `OutOfBoundsConstantRead` (a custom error defined in `src/error/ErrIntegrity.sol`). No string revert messages are used.

---

## Findings

### INFO-01: `run` relies entirely on integrity check for bounds safety

**Severity**: INFO

**Location**: `run()`, line 31-33

**Description**: The `run` function performs no bounds check on the constant index before reading from the `constants` array in assembly. The comment explicitly states this is intentional: "Skip index OOB check and rely on integrity check for that." If the integrity check were ever bypassed (e.g., through a bug in the expression deployer or a future code change that allows evaluation without integrity checking), the `mload` would read arbitrary memory beyond the constants array.

**Analysis**: This is a deliberate design choice for gas optimization. The integrity check is enforced at deploy time by `RainterpreterExpressionDeployer`, and bytecode hash verification prevents substitution of the deployer. The trust boundary is well-defined: the deployer guarantees all expressions pass integrity before they can be evaluated. For this to be exploitable, the entire deployer verification chain would need to be bypassed, which would constitute a much larger vulnerability. This is noted as informational context, not an actionable risk.

---

### INFO-02: Assembly block is correctly marked `memory-safe`

**Severity**: INFO

**Location**: `run()`, line 32

**Description**: The assembly block is marked `("memory-safe")`. This is correct because:
1. The `mload` reads from an existing Solidity-managed memory array (`constants`), which was allocated by the Solidity memory allocator.
2. The `mstore` writes to `stackTop - 0x20`, which is within the pre-allocated stack region managed by the eval loop.
3. No memory is allocated (the free memory pointer is not modified).
4. The block does not write to memory below `0x40` (scratch space).

The `memory-safe` annotation is accurate and allows the Solidity optimizer to reason correctly about this block.

---

No CRITICAL, HIGH, MEDIUM, or LOW findings identified. The library is compact, the operand extraction is consistent across all three functions, integrity inputs/outputs match runtime behavior, and the assembly is correct and properly annotated.
