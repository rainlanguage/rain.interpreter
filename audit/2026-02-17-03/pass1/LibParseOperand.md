# Pass 1 (Security) — LibParseOperand.sol

## Evidence of Thorough Reading

**Library name:** `LibParseOperand`

**Functions and line numbers:**

| Function | Line |
|---|---|
| `parseOperand(ParseState memory, uint256, uint256) returns (uint256)` | 35 |
| `handleOperand(ParseState memory, uint256) returns (OperandV2)` | 136 |
| `handleOperandDisallowed(bytes32[] memory) returns (OperandV2)` | 153 |
| `handleOperandDisallowedAlwaysOne(bytes32[] memory) returns (OperandV2)` | 164 |
| `handleOperandSingleFull(bytes32[] memory) returns (OperandV2)` | 177 |
| `handleOperandSingleFullNoDefault(bytes32[] memory) returns (OperandV2)` | 199 |
| `handleOperandDoublePerByteNoDefault(bytes32[] memory) returns (OperandV2)` | 222 |
| `handleOperand8M1M1(bytes32[] memory) returns (OperandV2)` | 255 |
| `handleOperandM1M1(bytes32[] memory) returns (OperandV2)` | 306 |

**Errors/events/structs defined in this file:** None. All errors are imported from `src/error/ErrParse.sol`:
- `ExpectedOperand()`
- `UnclosedOperand(uint256 offset)`
- `OperandValuesOverflow(uint256 offset)`
- `UnexpectedOperand()`
- `UnexpectedOperandValue()`
- `OperandOverflow()`

**Imports:**
- `OperandV2` from `rain.interpreter.interface`
- `LibParseLiteral` for literal parsing
- `CMASK_OPERAND_END`, `CMASK_WHITESPACE`, `CMASK_OPERAND_START` from `rain.string`
- `ParseState`, `OPERAND_VALUES_LENGTH`, `FSM_YANG_MASK` from `LibParseState`
- `LibParseError`, `LibParseInterstitial`
- `LibDecimalFloat`, `Float` from `rain.math.float`

---

## Security Findings

### 1. No bounds check on `wordIndex` in `handleOperand` — INFO

**Location:** Line 139-145

```solidity
assembly ("memory-safe") {
    handler := and(mload(add(handlers, add(2, mul(wordIndex, 2)))), 0xFFFF)
}
```

**Analysis:** The code loads a 2-byte function pointer from the `operandHandlers` byte array using `wordIndex` without validating that `wordIndex < handlers.length / 2`. The inline comment at lines 140-143 acknowledges this by design: the index is computed by the parser itself, not user-supplied. If `wordIndex` exceeds the handlers array, `mload` would read from adjacent memory (whatever follows the handlers bytes in the ParseState struct), yielding a garbage function pointer. The subsequent call `handler(state.operandValues)` would then jump to an arbitrary internal function pointer.

However, since `wordIndex` originates from the parser's own word lookup (bloom filter + fingerprint table), not from user input, exploitation would require a separate bug in the parser's word resolution. The comment correctly identifies this constraint and notes the reliance on test coverage.

**Classification:** INFO — By-design trust assumption with documented rationale. The risk is bounded by the parser's internal correctness.

---

### 2. Assembly blocks are correctly marked `memory-safe` — INFO

**Location:** Lines 37, 45, 57, 65, 99, 117, 139, 180, 202, 227, 262, 267, 275, 314, 322

**Analysis:** All 15 assembly blocks in the file are marked `"memory-safe"`. I reviewed each one:

- **Lines 37-40, 57-60, 65-68:** Read a single byte from `cursor` via `mload(cursor)` and compute a character mask via `shl(byte(0, ...), 1)`. These are pure reads with no writes. Memory-safe.

- **Lines 45-47:** `mstore(operandValues, 0)` — writes to the length slot of a Solidity-allocated array. The array was allocated by `new bytes32[](OPERAND_VALUES_LENGTH)` in `newState`. Writing zero to the length slot is within bounds. Memory-safe.

- **Lines 99-101:** `mstore(add(operandValues, add(0x20, mul(i, 0x20))), value)` — writes a value into the operand values array at index `i`. The guard at line 87 ensures `i < OPERAND_VALUES_LENGTH` (which is 4), so the write offset is at most `operandValues + 0x20 + 3*0x20 = operandValues + 0x80`, which is within the originally-allocated 4-element array. Memory-safe.

- **Lines 117-119:** `mstore(operandValues, i)` — writes the final length back to the operand values array. `i` is at most `OPERAND_VALUES_LENGTH` (4), which is the allocated capacity. Memory-safe.

- **Lines 139-145:** Read from `handlers` bytes array. No writes. Memory-safe (no memory modification).

- **Lines 180-182, 202-204:** Read from `values` array at offset `0x20` (first element). These are in the `values.length == 1` branch, so the element exists. Memory-safe.

- **Lines 227-230:** Read two elements from `values` array at offsets `0x20` and `0x40`. In the `values.length == 2` branch. Memory-safe.

- **Lines 262-264, 267-269, 275-277:** Read from `values` array at offsets `0x20`, `0x40`, `0x60` respectively. The function requires `length >= 1 && length <= 3`, and each read is guarded by the corresponding `length >=` check. Memory-safe.

- **Lines 314-316, 322-325:** Read from `values` array at offsets `0x20` and `0x40` respectively. The function checks `length < 3` and each read is conditional on `length >= 1` or `length == 2`. Memory-safe.

**Classification:** INFO — All assembly blocks reviewed; no memory safety violations found.

---

### 3. Operand parsing correctly rejects all invalid operand values — INFO

**Location:** Lines 153-343 (all handler functions)

**Analysis:** Each operand handler validates incoming values thoroughly:

- **`handleOperandDisallowed` (line 153):** Reverts `UnexpectedOperand()` if any values provided. Returns 0.
- **`handleOperandDisallowedAlwaysOne` (line 164):** Same validation, returns 1.
- **`handleOperandSingleFull` (line 177):** Accepts 0 or 1 values. Reverts `UnexpectedOperandValue()` for >1. Converts via `toFixedDecimalLossless` (reverts on fractional/negative values). Checks `> type(uint16).max` and reverts `OperandOverflow()`.
- **`handleOperandSingleFullNoDefault` (line 199):** Requires exactly 1 value. Reverts `ExpectedOperand()` for 0, `UnexpectedOperandValue()` for >1. Same overflow check.
- **`handleOperandDoublePerByteNoDefault` (line 222):** Requires exactly 2 values. Reverts `ExpectedOperand()` for <2, `UnexpectedOperandValue()` for >2. Each value checked `> type(uint8).max`.
- **`handleOperand8M1M1` (line 255):** Requires 1-3 values. Reverts `ExpectedOperand()` for 0, `UnexpectedOperandValue()` for >3. First value checked `> type(uint8).max`, second and third checked `> 1`.
- **`handleOperandM1M1` (line 306):** Accepts 0-2 values. Reverts `UnexpectedOperandValue()` for >2. Both checked `> 1`.

All handlers reject negative values (via `toFixedDecimalLossless` which calls `toFixedDecimalLossy`, which reverts `NegativeFixedDecimalConversion` for negative coefficients). All handlers reject fractional values (via `toFixedDecimalLossless` with `decimals=0`). All handlers check overflow against the target bit width.

**Classification:** INFO — No silent misinterpretation of invalid operand values found.

---

### 4. All reverts use custom errors — INFO

**Location:** Entire file

**Analysis:** Every revert in the file uses a custom error type:
- `OperandValuesOverflow(offset)` — line 88
- `UnclosedOperand(offset)` — lines 111, 115
- `UnexpectedOperand()` — lines 155, 165
- `UnexpectedOperandValue()` — lines 192, 214, 245, 298, 341
- `ExpectedOperand()` — lines 212, 243, 296
- `OperandOverflow()` — lines 186, 207, 238, 291, 336

No string revert messages (`revert("...")`) are used anywhere.

**Classification:** INFO — Compliant with project conventions.

---

### 5. No unchecked arithmetic in user-facing code paths — INFO

**Location:** Lines 35-123 (parseOperand), lines 153-343 (handlers)

**Analysis:** The `parseOperand` function does not use `unchecked` blocks. The `++cursor` (lines 52, 79, 105) and `++i` (line 105) increments are checked by default in Solidity 0.8.25. Since `cursor` is bounded by `end` (line 63) and `i` is bounded by `OPERAND_VALUES_LENGTH` (line 87), overflow is not possible in practice, but the compiler-provided checks provide defense-in-depth.

The operand handler functions also do not use `unchecked`. The bitwise operations (`aUint | (bUint << 8)` etc.) are safe because the constituent values are already validated to fit within their target ranges before the shift/or operations.

**Classification:** INFO — No unchecked arithmetic concerns.

---

### 6. Operand values array bypass of Solidity bounds checking — LOW

**Location:** Lines 93-101

```solidity
assembly ("memory-safe") {
    mstore(add(operandValues, add(0x20, mul(i, 0x20))), value)
}
```

**Analysis:** The code deliberately bypasses Solidity's array bounds checking for the `operandValues` array. The comment at lines 92-98 explains this: the array's Solidity-visible length is set to whatever the previous operand's count was (since line 46 sets it to 0, and line 118 sets it to `i` after parsing). The actual memory allocation is always `OPERAND_VALUES_LENGTH` (4) elements (allocated in `newState` at `LibParseState.sol:246`).

The guard at line 87 (`if (i == OPERAND_VALUES_LENGTH)`) ensures `i` never exceeds 3 when writing, so the write at line 100 is always within the originally-allocated 4 slots (`operandValues + 0x20` through `operandValues + 0x80`).

This pattern is safe but fragile: if `OPERAND_VALUES_LENGTH` were ever changed without updating this code, or if the guard were accidentally removed, the assembly write could corrupt adjacent memory. The pattern is documented but relies on the invariant that the initial allocation size matches `OPERAND_VALUES_LENGTH`.

**Classification:** LOW — The bounds are correctly enforced by the guard at line 87, but the pattern of bypassing Solidity's bounds checking and relying on a separate guard introduces fragility if the code is modified in the future.

---

### 7. Char mask equality vs. bitwise-AND inconsistency in `parseOperand` — INFO

**Location:** Lines 50, 72, 77

```solidity
// Line 50: equality check
if (char == CMASK_OPERAND_START) {

// Line 72: bitwise AND check
if (char & CMASK_WHITESPACE != 0) {

// Line 77: bitwise AND check
else if (char & CMASK_OPERAND_END != 0) {
```

**Analysis:** The initial check at line 50 uses `==` against `CMASK_OPERAND_START`, while lines 72 and 77 use `&` (bitwise AND). Both approaches are correct here because `char` is computed as `shl(byte(0, mload(cursor)), 1)` which produces exactly one set bit (a single-character mask). For a single-bit `char`:
- `char == CMASK_X` is true only when the character is exactly `X`
- `char & CMASK_X != 0` is true when the character is any character in the mask set `X`

Since `CMASK_OPERAND_START` and `CMASK_OPERAND_END` are both single-character masks (`<` and `>` respectively), the `==` and `&` approaches are equivalent for them. The `CMASK_WHITESPACE` mask covers multiple characters (space, tab, newline, carriage return), so `&` is the correct choice there. The code is correct.

**Classification:** INFO — Stylistic observation; no functional issue.

---

## Summary

No CRITICAL, HIGH, or MEDIUM findings. One LOW finding regarding the fragility of the assembly-based array write that bypasses Solidity bounds checking (mitigated by a correct guard). The file demonstrates thorough input validation across all operand handlers, correct memory-safe assembly, exclusive use of custom errors, and proper bounds enforcement.
