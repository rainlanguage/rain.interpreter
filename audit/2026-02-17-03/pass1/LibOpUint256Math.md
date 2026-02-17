# Pass 1 (Security) -- Growth + uint256 Math Opcodes

Auditor: Claude Opus 4.6
Date: 2026-02-17
Audit namespace: 2026-02-17-03

## Files Reviewed

### 1. `src/lib/op/math/growth/LibOpExponentialGrowth.sol`

**Library:** `LibOpExponentialGrowth`

**Functions:**
| Function | Line | Visibility |
|----------|------|------------|
| `integrity(IntegrityCheckState memory, OperandV2)` | 18 | internal pure |
| `run(InterpreterState memory, OperandV2, Pointer stackTop)` | 24 | internal view |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` | 43 | internal view |

**Errors/Events/Structs:** None defined.

**Using:** `LibDecimalFloat for Float`

---

### 2. `src/lib/op/math/growth/LibOpLinearGrowth.sol`

**Library:** `LibOpLinearGrowth`

**Functions:**
| Function | Line | Visibility |
|----------|------|------------|
| `integrity(IntegrityCheckState memory, OperandV2)` | 18 | internal pure |
| `run(InterpreterState memory, OperandV2, Pointer stackTop)` | 24 | internal pure |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` | 44 | internal pure |

**Errors/Events/Structs:** None defined.

**Using:** `LibDecimalFloat for Float`

---

### 3. `src/lib/op/math/uint256/LibOpMaxUint256.sol`

**Library:** `LibOpMaxUint256`

**Functions:**
| Function | Line | Visibility |
|----------|------|------------|
| `integrity(IntegrityCheckState memory, OperandV2)` | 14 | internal pure |
| `run(InterpreterState memory, OperandV2, Pointer stackTop)` | 19 | internal pure |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` | 29 | internal pure |

**Errors/Events/Structs:** None defined.

---

### 4. `src/lib/op/math/uint256/LibOpUint256Add.sol`

**Library:** `LibOpUint256Add`

**Functions:**
| Function | Line | Visibility |
|----------|------|------------|
| `integrity(IntegrityCheckState memory, OperandV2 operand)` | 14 | internal pure |
| `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` | 24 | internal pure |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` | 56 | internal pure |

**Errors/Events/Structs:** None defined.

---

### 5. `src/lib/op/math/uint256/LibOpUint256Div.sol`

**Library:** `LibOpUint256Div`

**Functions:**
| Function | Line | Visibility |
|----------|------|------------|
| `integrity(IntegrityCheckState memory, OperandV2 operand)` | 15 | internal pure |
| `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` | 24 | internal pure |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` | 57 | internal pure |

**Errors/Events/Structs:** None defined.

---

### 6. `src/lib/op/math/uint256/LibOpUint256Mul.sol`

**Library:** `LibOpUint256Mul`

**Functions:**
| Function | Line | Visibility |
|----------|------|------------|
| `integrity(IntegrityCheckState memory, OperandV2 operand)` | 14 | internal pure |
| `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` | 24 | internal pure |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` | 56 | internal pure |

**Errors/Events/Structs:** None defined.

---

### 7. `src/lib/op/math/uint256/LibOpUint256Pow.sol`

**Library:** `LibOpUint256Pow`

**Functions:**
| Function | Line | Visibility |
|----------|------|------------|
| `integrity(IntegrityCheckState memory, OperandV2 operand)` | 14 | internal pure |
| `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` | 24 | internal pure |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` | 56 | internal pure |

**Errors/Events/Structs:** None defined.

---

### 8. `src/lib/op/math/uint256/LibOpUint256Sub.sol`

**Library:** `LibOpUint256Sub`

**Functions:**
| Function | Line | Visibility |
|----------|------|------------|
| `integrity(IntegrityCheckState memory, OperandV2 operand)` | 14 | internal pure |
| `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` | 24 | internal pure |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` | 57 | internal pure |

**Errors/Events/Structs:** None defined.

---

## Security Analysis

### Stack Direction and Mechanics

The interpreter stack grows downward: `stackTop` is the lowest address (top of stack). Pushing decrements `stackTop` by 0x20; popping increments it. Stack memory is pre-allocated by the eval loop based on the integrity check's declared inputs/outputs.

### Integrity / Run Consistency Verification

For each file, I verified that the number of stack values consumed and produced by `run` matches what `integrity` declares:

| Opcode | integrity (in, out) | run pops | run pushes | Consistent |
|--------|---------------------|----------|------------|------------|
| exponential-growth | (3, 1) | 3 (via assembly) | 1 (via assembly) | Yes |
| linear-growth | (3, 1) | 3 (via assembly) | 1 (via assembly) | Yes |
| max-uint256 | (0, 1) | 0 | 1 (sub 0x20) | Yes |
| uint256-add (N inputs) | (max(N,2), 1) | max(N,2) | 1 | Yes |
| uint256-div (N inputs) | (max(N,2), 1) | max(N,2) | 1 | Yes |
| uint256-mul (N inputs) | (max(N,2), 1) | max(N,2) | 1 | Yes |
| uint256-pow (N inputs) | (max(N,2), 1) | max(N,2) | 1 | Yes |
| uint256-sub (N inputs) | (max(N,2), 1) | max(N,2) | 1 | Yes |

For the N-ary ops, I specifically verified the edge cases where the operand encodes 0 or 1 for the input count. In both cases, `integrity` clamps to 2, and `run` always pops exactly 2 in the initial block then enters the while loop only when `i < inputs`. Since `inputs` is also extracted from the operand in `run`, and 0 and 1 are both < 2, the loop body never executes for those values. The final `sub(stackTop, 0x20)` then pushes 1 result. This is consistent.

### Assembly Memory Safety

All assembly blocks in all 8 files are annotated `"memory-safe"`. The operations performed are:

1. **Reads** (`mload`) from `stackTop` and `stackTop + 0x20` -- within the pre-allocated stack region.
2. **Pointer arithmetic** (`add`/`sub` on `stackTop`) -- adjusting the stack pointer within bounds guaranteed by integrity checks.
3. **Writes** (`mstore`) to the adjusted `stackTop` -- writing results back into the stack region.

No free memory pointer manipulation occurs. No memory allocation or reallocation. All access is within the interpreter's pre-allocated stack memory, bounded by integrity checks. The `"memory-safe"` annotations are valid.

### Checked vs Unchecked Arithmetic

- **Checked (safe):** `a += b`, `a -= b`, `a *= b`, `a /= b`, `a = a ** b` in all `run` functions use Solidity 0.8.x checked arithmetic. Overflow, underflow, and division by zero will revert as expected.
- **Unchecked (safe):** Only `i++` loop counter increments are unchecked. Since `i` starts at 2 and `inputs` is masked to 4 bits (max 15), the counter cannot overflow.
- **referenceFn unchecked (intentional):** All `referenceFn` implementations use `unchecked` blocks. This is by design -- the comment explains it allows tests to distinguish overflow reverts from the production `run` function vs the reference.

### Custom Errors

None of these files define or use `revert("...")` string error messages. Arithmetic errors (overflow, underflow, division by zero) are generated by the Solidity compiler's built-in checked arithmetic, which uses `Panic(uint256)` error codes. No custom errors are needed in these simple math libraries.

### External Calls and Reentrancy

- `LibOpExponentialGrowth.run` is `view` (not `pure`) because `LibDecimalFloat.pow` calls `LOG_TABLES_ADDRESS` via `staticcall`. This is a precomputed lookup table at a deterministic address and cannot cause reentrancy because `staticcall` prevents state modifications.
- All other `run` functions are `pure` -- no external calls, no reentrancy risk.

### Operand Parsing

The operand input count is extracted via `uint256(OperandV2.unwrap(operand) >> 0x10) & 0x0F`, which reads bits 16-19 (a 4-bit field, range 0-15). The clamping `inputs > 1 ? inputs : 2` ensures a minimum of 2 inputs. The growth ops ignore the operand entirely, using a fixed 3 inputs. No invalid operand values can cause misbehavior.

---

## Findings

### Finding 1: Growth opcodes read stack slots in non-obvious order

**Severity:** INFO

**File:** `src/lib/op/math/growth/LibOpExponentialGrowth.sol` (lines 28-33), `src/lib/op/math/growth/LibOpLinearGrowth.sol` (lines 28-33)

**Description:** Both growth opcodes read `base` from `stackTop`, `rate` from `stackTop + 0x20`, then advance `stackTop` by `0x40` before reading `t` from the new `stackTop`. This means `base` is at the top of the stack, `rate` is at position 2, and `t` is at position 3. The read pattern is correct but potentially confusing to reviewers because the pointer is advanced mid-read, making it appear as though `t` is read from a different relative offset than `base` and `rate`.

**Impact:** No functional impact. The `referenceFn` confirms the order: `inputs[0]` = base, `inputs[1]` = rate, `inputs[2]` = t, and both the assembly and reference implementations produce identical results.

---

### Finding 2: No finding -- all security checks pass

After thorough review, no CRITICAL, HIGH, MEDIUM, or LOW severity findings were identified in these 8 files. Specifically:

- Assembly memory safety: All blocks correctly operate within pre-allocated stack memory.
- Stack underflow/overflow: Integrity declarations match run behavior for all operand values (0-15).
- Unchecked arithmetic: Only used for safe loop counter increments and intentionally in test reference functions.
- Custom errors: No string reverts. Arithmetic panics are compiler-generated.
- External calls: Only `staticcall` to a deterministic read-only address (log tables) in exponential growth.
- Operand parsing: 4-bit mask with minimum clamping prevents out-of-range behavior.
