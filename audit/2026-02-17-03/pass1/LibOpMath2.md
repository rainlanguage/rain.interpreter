# Pass 1 (Security) Audit: Float Math Opcodes Part 2

## Files Reviewed

### 1. LibOpGm.sol (`src/lib/op/math/LibOpGm.sol`)

**Library:** `LibOpGm`
**Functions:**
- `integrity` (line 18) -- returns (2, 1)
- `run` (line 25) -- `internal view`, reads 2 stack items, writes 1
- `referenceFn` (line 42) -- `internal view`, reference for testing

**Errors/Events/Structs:** None defined.

**Evidence of reading:** Uses `LibDecimalFloat` for float math. The `run` function reads two values from the stack via assembly (`mload` at `stackTop` and `stackTop + 0x20`), advances `stackTop` by `0x20` (net consumption of 1 slot since it consumes 2 and writes back to where `b` was loaded), computes `a.mul(b).pow(FLOAT_HALF, LOG_TABLES_ADDRESS)` (geometric mean = sqrt(a*b)), stores result at `stackTop`, and returns. The `referenceFn` performs the same computation using the high-level array interface.

---

### 2. LibOpHeadroom.sol (`src/lib/op/math/LibOpHeadroom.sol`)

**Library:** `LibOpHeadroom`
**Functions:**
- `integrity` (line 18) -- returns (1, 1)
- `run` (line 25) -- `internal pure`, reads 1 stack item, writes 1
- `referenceFn` (line 42) -- `internal pure`, reference for testing

**Errors/Events/Structs:** None defined.

**Evidence of reading:** The `run` function loads one value from `stackTop`, computes `a.ceil().sub(a)`, then if the result is zero replaces it with `FLOAT_ONE`. Writes the result back to the same `stackTop` position. The `referenceFn` mirrors this logic exactly. Integrity returns (1,1) matching the 1-in, 1-out behavior.

---

### 3. LibOpInv.sol (`src/lib/op/math/LibOpInv.sol`)

**Library:** `LibOpInv`
**Functions:**
- `integrity` (line 17) -- returns (1, 1)
- `run` (line 24) -- `internal pure`, reads 1 stack item, writes 1
- `referenceFn` (line 38) -- `internal pure`, reference for testing

**Errors/Events/Structs:** None defined.

**Evidence of reading:** Simple 1-in, 1-out opcode. Loads value from `stackTop`, calls `a.inv()`, stores result back. The `referenceFn` does the same via the array interface. Division by zero handling is delegated to `LibDecimalFloat.inv()`.

---

### 4. LibOpMax.sol (`src/lib/op/math/LibOpMax.sol`)

**Library:** `LibOpMax`
**Functions:**
- `integrity` (line 17) -- returns (N, 1) where N >= 2, from operand bits [20:16]
- `run` (line 26) -- `internal pure`, reads N items, writes 1
- `referenceFn` (line 59) -- `internal pure`, reference for testing

**Errors/Events/Structs:** None defined.

**Evidence of reading:** Variable-arity opcode. Extracts input count from `(operand >> 0x10) & 0x0F`. Minimum 2 inputs enforced by `inputs > 1 ? inputs : 2`. The `run` function loads first two values, advances `stackTop` by `0x40`, then loops for remaining inputs. After the loop, moves `stackTop` back by `0x20` and writes the result. The `referenceFn` uses `inputs.length` to iterate, using `acc.max()` for accumulation.

---

### 5. LibOpMaxNegativeValue.sol (`src/lib/op/math/LibOpMaxNegativeValue.sol`)

**Library:** `LibOpMaxNegativeValue`
**Functions:**
- `integrity` (line 17) -- returns (0, 1)
- `run` (line 22) -- `internal pure`, pushes 1 value onto stack
- `referenceFn` (line 32) -- `internal pure`, reference for testing

**Errors/Events/Structs:** None defined.

**Evidence of reading:** Zero-input, one-output constant opcode. Pushes `FLOAT_MAX_NEGATIVE_VALUE` onto the stack by decrementing `stackTop` by `0x20` and writing the constant. The `referenceFn` uses `packLossless(-1, type(int32).min)` to construct the same value.

---

### 6. LibOpMaxPositiveValue.sol (`src/lib/op/math/LibOpMaxPositiveValue.sol`)

**Library:** `LibOpMaxPositiveValue`
**Functions:**
- `integrity` (line 17) -- returns (0, 1)
- `run` (line 22) -- `internal pure`, pushes 1 value onto stack
- `referenceFn` (line 32) -- `internal pure`, reference for testing

**Errors/Events/Structs:** None defined.

**Evidence of reading:** Zero-input, one-output constant opcode. Pushes `FLOAT_MAX_POSITIVE_VALUE` onto the stack. Uses `sub(stackTop, 0x20)` to allocate space, then `mstore`. The `referenceFn` uses `packLossless(type(int224).max, type(int32).max)`.

---

### 7. LibOpMin.sol (`src/lib/op/math/LibOpMin.sol`)

**Library:** `LibOpMin`
**Functions:**
- `integrity` (line 17) -- returns (N, 1) where N >= 2, from operand bits [20:16]
- `run` (line 26) -- `internal pure`, reads N items, writes 1
- `referenceFn` (line 60) -- `internal pure`, reference for testing

**Errors/Events/Structs:** None defined.

**Evidence of reading:** Structurally identical to `LibOpMax` but calls `a.min(b)` instead of `a.max(b)`. Same operand extraction pattern `(operand >> 0x10) & 0x0F`, same minimum-2-input enforcement. Same stack manipulation pattern: load 2, advance by `0x40`, loop for extras, write back with `sub(stackTop, 0x20)`.

---

### 8. LibOpMinNegativeValue.sol (`src/lib/op/math/LibOpMinNegativeValue.sol`)

**Library:** `LibOpMinNegativeValue`
**Functions:**
- `integrity` (line 17) -- returns (0, 1)
- `run` (line 22) -- `internal pure`, pushes 1 value onto stack
- `referenceFn` (line 32) -- `internal pure`, reference for testing

**Errors/Events/Structs:** None defined.

**Evidence of reading:** Zero-input, one-output constant opcode. Pushes `FLOAT_MIN_NEGATIVE_VALUE` onto the stack. The `referenceFn` uses `packLossless(type(int224).min, type(int32).max)`.

---

### 9. LibOpMinPositiveValue.sol (`src/lib/op/math/LibOpMinPositiveValue.sol`)

**Library:** `LibOpMinPositiveValue`
**Functions:**
- `integrity` (line 17) -- returns (0, 1)
- `run` (line 22) -- `internal pure`, pushes 1 value onto stack
- `referenceFn` (line 32) -- `internal pure`, reference for testing

**Errors/Events/Structs:** None defined.

**Evidence of reading:** Zero-input, one-output constant opcode. Pushes `FLOAT_MIN_POSITIVE_VALUE` onto the stack. The `referenceFn` uses `packLossless(1, type(int32).min)`.

---

### 10. LibOpMul.sol (`src/lib/op/math/LibOpMul.sol`)

**Library:** `LibOpMul`
**Functions:**
- `integrity` (line 18) -- returns (N, 1) where N >= 2, from operand bits [20:16]
- `run` (line 26) -- `internal pure`, reads N items, writes 1
- `referenceFn` (line 66) -- `internal pure`, reference for testing

**Errors/Events/Structs:** None defined.

**Evidence of reading:** Variable-arity opcode using `LibDecimalFloatImplementation.mul` directly (unpacked representation for intermediate results). First two values are loaded and unpacked, then remaining values are loaded in a while loop. Final result is packed via `packLossy` (discarding lossless flag with `(a,) = ...`). The `referenceFn` mirrors this with `inputs.length`-based iteration and also discards the lossless flag `(lossless)`.

---

### 11. LibOpPow.sol (`src/lib/op/math/LibOpPow.sol`)

**Library:** `LibOpPow`
**Functions:**
- `integrity` (line 17) -- returns (2, 1)
- `run` (line 24) -- `internal view`, reads 2 stack items, writes 1
- `referenceFn` (line 41) -- `internal view`, reference for testing

**Errors/Events/Structs:** None defined.

**Evidence of reading:** Two-input, one-output opcode. Loads `a` from `stackTop`, advances by `0x20`, loads `b`. Computes `a.pow(b, LOG_TABLES_ADDRESS)`. `view` because `pow` reads from the log tables precompiled contract. Stores result at current `stackTop` position (which is where `b` was loaded). The `referenceFn` mirrors this logic.

---

### 12. LibOpSqrt.sol (`src/lib/op/math/LibOpSqrt.sol`)

**Library:** `LibOpSqrt`
**Functions:**
- `integrity` (line 17) -- returns (1, 1)
- `run` (line 24) -- `internal view`, reads 1 stack item, writes 1
- `referenceFn` (line 38) -- `internal view`, reference for testing

**Errors/Events/Structs:** None defined.

**Evidence of reading:** One-input, one-output opcode. Loads `a`, computes `a.sqrt(LOG_TABLES_ADDRESS)`, stores back. `view` because `sqrt` uses log tables. The `referenceFn` mirrors this.

---

### 13. LibOpSub.sol (`src/lib/op/math/LibOpSub.sol`)

**Library:** `LibOpSub`
**Functions:**
- `integrity` (line 18) -- returns (N, 1) where N >= 2, from operand bits [20:16]
- `run` (line 26) -- `internal pure`, reads N items, writes 1
- `referenceFn` (line 66) -- `internal pure`, reference for testing

**Errors/Events/Structs:** None defined.

**Evidence of reading:** Variable-arity opcode using `LibDecimalFloatImplementation.sub` directly. Structurally identical to `LibOpMul` and `LibOpAdd` but with subtraction. Loads and unpacks first two items, loops for remaining, packs result with `packLossy`. Same operand extraction: `(operand >> 0x10) & 0x0F` with minimum 2.

---

## Security Findings

### Finding 1: Headroom opcode returns 1.0 for already-integer values -- potential semantic surprise

**Severity:** INFO

**File:** `src/lib/op/math/LibOpHeadroom.sol`, lines 30-33

**Description:** When the input is already an integer (i.e., `ceil(x) == x`), the headroom is computed as `ceil(x) - x = 0`, but then immediately replaced with `FLOAT_ONE`. This means `headroom(5.0) = 1.0`, which is mathematically correct in a modular/periodic interpretation (headroom to the next integer above 5 is 1, because the next integer is 6), but could be surprising if a user expects the headroom of an integer to be 0. The NatSpec comment says "headroom (distance to ceil)" which for an integer is 0, not 1.

This is a design decision rather than a bug -- both the `run` and `referenceFn` agree on this behavior, so it is intentionally coded. However, the documented description ("distance to ceil") is misleading for the integer case.

---

### Finding 2: All assembly blocks correctly use `memory-safe` annotation

**Severity:** INFO

**File:** All 13 files reviewed

**Description:** Every assembly block in the reviewed files is annotated with `("memory-safe")`. The memory operations performed are:
- `mload(stackTop)` and `mload(add(stackTop, 0x20))` -- reads from known stack positions
- `mstore(stackTop, value)` -- writes to known stack positions
- `sub(stackTop, 0x20)` / `add(stackTop, 0x20)` -- pointer arithmetic within stack bounds

These operations are within the stack memory region managed by the interpreter, and the stack bounds are enforced by the integrity check system before execution. The `memory-safe` annotations are appropriate.

---

### Finding 3: Integrity inputs/outputs match run behavior for all opcodes

**Severity:** INFO

**File:** All 13 files reviewed

**Description:** Verified that each opcode's `integrity` function correctly declares the number of inputs consumed and outputs produced by `run`:

| Opcode | integrity returns | run behavior | Match |
|--------|------------------|--------------|-------|
| LibOpGm | (2, 1) | reads 2, writes 1 | Yes |
| LibOpHeadroom | (1, 1) | reads 1, writes 1 | Yes |
| LibOpInv | (1, 1) | reads 1, writes 1 | Yes |
| LibOpMax | (N>=2, 1) | reads N, writes 1 | Yes |
| LibOpMaxNegativeValue | (0, 1) | reads 0, writes 1 | Yes |
| LibOpMaxPositiveValue | (0, 1) | reads 0, writes 1 | Yes |
| LibOpMin | (N>=2, 1) | reads N, writes 1 | Yes |
| LibOpMinNegativeValue | (0, 1) | reads 0, writes 1 | Yes |
| LibOpMinPositiveValue | (0, 1) | reads 0, writes 1 | Yes |
| LibOpMul | (N>=2, 1) | reads N, writes 1 | Yes |
| LibOpPow | (2, 1) | reads 2, writes 1 | Yes |
| LibOpSqrt | (1, 1) | reads 1, writes 1 | Yes |
| LibOpSub | (N>=2, 1) | reads N, writes 1 | Yes |

---

### Finding 4: Variable-arity opcodes use `unchecked` loop counter increment safely

**Severity:** INFO

**File:** LibOpMax.sol (line 45-47), LibOpMin.sol (line 45-47), LibOpMul.sol (line 50-52), LibOpSub.sol (line 50-52)

**Description:** The `unchecked { i++; }` in the while loops is safe because `i` starts at 2 and the loop condition `i < inputs` bounds it to at most 15 (since `inputs` is masked by `& 0x0F`). Overflow of `i` is impossible.

---

### Finding 5: No custom errors or string reverts in any of the reviewed files

**Severity:** INFO

**File:** All 13 files reviewed

**Description:** None of the 13 reviewed files define or use any revert statements (neither custom errors nor string errors). All error conditions (division by zero in `inv`, overflow in math operations, negative values for `sqrt`, etc.) are handled by the underlying `LibDecimalFloat` / `LibDecimalFloatImplementation` libraries, which are outside the scope of this specific file review. This is appropriate delegation.

---

### Finding 6: `packLossy` silently discards precision loss in Mul and Sub

**Severity:** LOW

**File:** `src/lib/op/math/LibOpMul.sol` (line 57), `src/lib/op/math/LibOpSub.sol` (line 56)

**Description:** Both `LibOpMul.run()` and `LibOpSub.run()` call `LibDecimalFloat.packLossy(signedCoefficient, exponent)` and discard the boolean `lossless` return value via `(a,) = ...`. This means if an intermediate multiplication or subtraction result exceeds the coefficient precision of the float format, the result is silently truncated/rounded when packed back into a Float.

This is a known design tradeoff for decimal floating point arithmetic -- the same pattern is used by `LibOpAdd` and `LibOpDiv`. The `referenceFn` implementations also explicitly discard this flag with `(lossless);`. Since this is a consistent, intentional pattern across all N-ary float opcodes, this is informational. However, users should be aware that chaining many multiplications or subtractions may accumulate precision loss, which is inherent to the float representation.

---

### Finding 7: Variable-arity opcodes (Max, Min) use `.max()` / `.min()` directly on packed Floats rather than unpacked intermediate form

**Severity:** INFO

**File:** `src/lib/op/math/LibOpMax.sol`, `src/lib/op/math/LibOpMin.sol`

**Description:** Unlike `LibOpMul`, `LibOpAdd`, `LibOpSub`, and `LibOpDiv` which unpack Floats into (coefficient, exponent) pairs for intermediate computation and only repack at the end, `LibOpMax` and `LibOpMin` work with packed `Float` values throughout and call `a.max(b)` / `a.min(b)` directly. This is correct because comparison operations do not produce intermediate values that could exceed the Float representation range. No precision loss is possible with max/min operations.

---

### Finding 8: No reentrancy risk in `view` opcodes

**Severity:** INFO

**File:** `LibOpGm.sol`, `LibOpPow.sol`, `LibOpSqrt.sol`

**Description:** These three opcodes are `view` (not `pure`) because they call `LibDecimalFloat.pow()` or `LibDecimalFloat.sqrt()`, which internally perform a `staticcall` to `LOG_TABLES_ADDRESS` (a predeployed contract at `0x6421E8a23cdEe2E6E579b2cDebc8C2A514843593`). Since these are `staticcall` operations, there is no reentrancy risk. The called address is a constant, not user-controlled.

---

### Finding 9: Operand bits extraction is consistent and bounded

**Severity:** INFO

**File:** LibOpMax.sol (lines 19, 37), LibOpMin.sol (lines 19, 37), LibOpMul.sol (lines 20, 40), LibOpSub.sol (lines 20, 40)

**Description:** All variable-arity opcodes extract the input count using the identical pattern `uint256(OperandV2.unwrap(operand) >> 0x10) & 0x0F`, producing a value in range [0, 15]. The minimum is enforced to 2 via `inputs > 1 ? inputs : 2`. This pattern is consistent with all other variable-arity opcodes in the codebase (Add, Div, Hash, etc.). The 4-bit mask `0x0F` means a maximum of 15 inputs, which is a well-bounded stack access pattern.

---

## Summary

No CRITICAL, HIGH, or MEDIUM severity findings were identified in these 13 files. The opcodes follow consistent patterns across the codebase:

1. **Fixed-arity opcodes** (Gm, Headroom, Inv, Pow, Sqrt): 1 or 2 inputs, 1 output, with straightforward stack manipulation.
2. **Constant opcodes** (MaxNegativeValue, MaxPositiveValue, MinNegativeValue, MinPositiveValue): 0 inputs, 1 output, pushing a library-defined constant.
3. **Variable-arity opcodes** (Max, Min, Mul, Sub): Operand-driven input count (2-15), 1 output, with a while-loop pattern for extra inputs.

All assembly is correctly annotated `memory-safe`, integrity functions match runtime stack behavior, no string reverts are used, and arithmetic safety is delegated to the `LibDecimalFloat` library.
