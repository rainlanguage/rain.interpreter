# Pass 1: Security Review -- Extern Reference Ops

**Agent:** A13
**Date:** 2026-03-07
**Branch:** 2026-03-07-audit

## Files Reviewed

### 1. LibExternOpContextCallingContract.sol

**Path:** `src/lib/extern/reference/op/LibExternOpContextCallingContract.sol`
**Library:** `LibExternOpContextCallingContract`

| Item | Type | Line |
|------|------|------|
| `subParser(uint256, uint256, OperandV2)` | function | 25 |

**Imports:** `OperandV2`, `LibSubParse`, `CONTEXT_BASE_COLUMN` (=0), `CONTEXT_BASE_ROW_CALLING_CONTRACT` (=1).

**Behavior:** Delegates to `LibSubParse.subParserContext(0, 1)` which emits a `CONTEXT` opcode with column=0, row=1. All three parameters are silenced with `(constantsHeight, ioByte, operand)`. No assembly. No arithmetic. No state mutation.

---

### 2. LibExternOpContextRainlen.sol

**Path:** `src/lib/extern/reference/op/LibExternOpContextRainlen.sol`
**Library:** `LibExternOpContextRainlen`

| Item | Type | Line |
|------|------|------|
| `CONTEXT_CALLER_CONTEXT_COLUMN` | constant (=1) | 13 |
| `CONTEXT_CALLER_CONTEXT_ROW_RAINLEN` | constant (=0) | 18 |
| `subParser(uint256, uint256, OperandV2)` | function | 33 |

**Behavior:** Delegates to `LibSubParse.subParserContext(1, 0)`. Same pattern as CallingContract. All three parameters are silenced. No assembly. No arithmetic. No state mutation.

---

### 3. LibExternOpContextSender.sol

**Path:** `src/lib/extern/reference/op/LibExternOpContextSender.sol`
**Library:** `LibExternOpContextSender`

| Item | Type | Line |
|------|------|------|
| `subParser(uint256, uint256, OperandV2)` | function | 23 |

**Imports:** `CONTEXT_BASE_COLUMN` (=0), `CONTEXT_BASE_ROW_SENDER` (=0).

**Behavior:** Delegates to `LibSubParse.subParserContext(0, 0)`. Same pattern as the other two context ops. All three parameters are silenced. No assembly. No arithmetic. No state mutation.

---

### 4. LibExternOpIntInc.sol

**Path:** `src/lib/extern/reference/op/LibExternOpIntInc.sol`
**Library:** `LibExternOpIntInc`

| Item | Type | Line |
|------|------|------|
| `OP_INDEX_INCREMENT` | constant (=0) | 13 |
| `run(OperandV2, StackItem[])` | function | 27 |
| `integrity(OperandV2, uint256, uint256)` | function | 44 |
| `subParser(uint256, uint256, OperandV2)` | function | 57 |

**`run` analysis (lines 27-36):**
- Creates Float representation of 1 via `packLossless(1e37, -37)`.
- Iterates over `inputs[]`, wrapping each `StackItem` as a `Float`, adding `one`, then wrapping back.
- `pure` function, memory-only, no assembly. Safety of addition is delegated to `LibDecimalFloat.add`, which handles overflow internally.
- Returns the same array (mutated in place). No new allocation.

**`integrity` analysis (lines 44-46):**
- Returns `(inputs, inputs)` -- outputs equal inputs. Consistent with `run` which maps 1:1.
- The third parameter (outputs hint) is ignored, which is correct since this op defines its own output count.

**`subParser` analysis (lines 57-66):**
- Marked `view` (correct, because `address(this)` is not a pure operation).
- Delegates to `LibSubParse.subParserExtern(IInterpreterExternV4(address(this)), constantsHeight, ioByte, operand, OP_INDEX_INCREMENT)`.
- `OP_INDEX_INCREMENT = 0` fits in uint16 (required by `encodeExternDispatch`).

---

### 5. LibExternOpStackOperand.sol

**Path:** `src/lib/extern/reference/op/LibExternOpStackOperand.sol`
**Library:** `LibExternOpStackOperand`

| Item | Type | Line |
|------|------|------|
| `subParser(uint256, uint256, OperandV2)` | function | 23 |

**Behavior:** Delegates to `LibSubParse.subParserConstant(constantsHeight, OperandV2.unwrap(operand))`. The second parameter is unnamed and unused (required by the function pointer signature). `OperandV2` unwraps to `bytes32`, matching the `value` parameter type of `subParserConstant`. No assembly. No arithmetic.

---

### 6. LibParseLiteralRepeat.sol

**Path:** `src/lib/extern/reference/literal/LibParseLiteralRepeat.sol`
**Library:** `LibParseLiteralRepeat`

| Item | Type | Line |
|------|------|------|
| `MAX_REPEAT_LITERAL_LENGTH` | constant (=78) | 34 |
| `RepeatLiteralTooLong(uint256)` | error | 39 |
| `RepeatDispatchNotDigit(uint256)` | error | 43 |
| `parseRepeat(uint256, uint256, uint256)` | function | 53 |

**`parseRepeat` analysis (lines 53-72):**

- **Input validation:**
  - `dispatchValue > 9` reverts with `RepeatDispatchNotDigit`. Correct.
  - `length >= MAX_REPEAT_LITERAL_LENGTH` (i.e., >= 78) reverts with `RepeatLiteralTooLong`. Correct.

- **Unchecked arithmetic safety analysis:**
  - `end - cursor` (line 60): documented as safe by parser invariant (cursor <= end). Even if violated, underflow produces a huge number that triggers the length check on line 61.
  - `10 ** i` (line 68): max i = 76, `10^76 < 2^256`. Safe.
  - `dispatchValue * 10 ** i` (line 68): max = `9 * 10^76 < 2^256`. Safe.
  - `value += ...` (line 68): accumulates at most 77 terms; max sum = `9 * sum(10^i, i=0..76) = 10^77 - 1 < 2^256 - 1` (since `2^256 ~= 1.158 * 10^77`). Safe.

- **Custom errors only:** Uses `RepeatDispatchNotDigit` and `RepeatLiteralTooLong`. No string reverts.

- **Float dispatch value correctness:** In the actual call flow through `BaseRainterpreterSubParser.subParseLiteral2`, the `dispatchValue` parameter arrives as a packed Float `bytes32` (from `matchSubParseLiteralDispatch`), which is reinterpreted as `uint256` via function pointer casting. For integer values 0-9 with exponent 0, `packLossless(N, 0)` produces `bytes32(N)` because `shl(0xe0, 0) = 0` and the coefficient is just `N` in the low bits. So the `uint256` interpretation equals `N`. The `> 9` guard in `parseRepeat` is redundant with the validation in `matchSubParseLiteralDispatch` but still correct. No issue here.

---

## Security Checklist

| Category | Result |
|----------|--------|
| Memory safety in assembly | No assembly in any of the 6 files. All assembly is in the delegate `LibSubParse`. |
| Input validation | `parseRepeat` validates dispatch range and length. Context ops use compile-time constants that fit in uint8. `subParserExtern` validates constantsHeight in the delegate. |
| Arithmetic safety | `parseRepeat` unchecked block is safe (proven above). No other arithmetic. |
| Integrity matching run behavior | `LibExternOpIntInc.integrity` returns `(inputs, inputs)`, matching `run` which maps each input 1:1 to an output. |
| Custom errors only | `RepeatDispatchNotDigit`, `RepeatLiteralTooLong` are custom errors. No string reverts. |
| Reentrancy / state mutation | All functions are `pure` or `view` (only `view` is `LibExternOpIntInc.subParser` due to `address(this)`). No storage writes. |

## Findings

No findings.

All six files are thin wrappers or simple computation libraries with correct input validation, safe arithmetic, and proper delegation to well-validated helper functions in `LibSubParse`. The `unchecked` block in `LibParseLiteralRepeat.parseRepeat` is justified by the `MAX_REPEAT_LITERAL_LENGTH` bound and the proofs documented in inline comments.
