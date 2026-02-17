# Pass 1 (Security) -- LibAllStandardOps.sol

**File:** `src/lib/op/LibAllStandardOps.sol`
**Auditor:** Claude Opus 4.6
**Date:** 2026-02-17

---

## Evidence of Thorough Reading

### Contract/Library

- `LibAllStandardOps` (library, line 111)

### Constants

- `ALL_STANDARD_OPS_LENGTH = 72` (line 106)

### Functions

| Function | Line |
|---|---|
| `authoringMetaV2()` | 121 |
| `literalParserFunctionPointers()` | 330 |
| `operandHandlerFunctionPointers()` | 363 |
| `integrityFunctionPointers()` | 535 |
| `opcodeFunctionPointers()` | 639 |

### Errors/Events/Structs Defined in File

None defined in this file. The file imports:

- `BadDynamicLength(uint256, uint256)` from `../../error/ErrOpList.sol` (line 5)

### Imports

The file imports 66 opcode libraries, 4 literal parser libraries, `LibParseOperand`, `LibConvert`, `ParseState`, `LITERAL_PARSERS_LENGTH`, core types (`Pointer`, `OperandV2`, `AuthoringMetaV2`, `IntegrityCheckState`, `InterpreterState`), and the `BadDynamicLength` error.

---

## Parallel Array Consistency Verification

All four parallel arrays were counted entry-by-entry. Each has exactly 72 entries (matching `ALL_STANDARD_OPS_LENGTH = 72`). The ordering is consistent across all four arrays:

- **Positions 1-4:** stack, constant, extern, context (fixed well-known indexes)
- **Positions 5-11:** bitwise ops (and, or, ctpop, decode, encode, shift-left, shift-right)
- **Position 12:** call
- **Position 13:** hash
- **Positions 14-16:** uint256-erc20 (allowance, balance-of, total-supply)
- **Positions 17-19:** erc20 (allowance, balance-of, total-supply)
- **Positions 20-22:** erc721 (uint256-balance-of, balance-of, owner-of)
- **Position 23:** erc5313-owner
- **Positions 24-27:** evm (block-number, chain-id, block-timestamp, now)
- **Positions 28-39:** logic ops (any, conditions, ensure, equal-to, binary-equal-to, every, greater-than, greater-than-or-equal-to, if, is-zero, less-than, less-than-or-equal-to)
- **Positions 40-41:** growth (exponential, linear)
- **Positions 42-47:** uint256 math (max-value, add, div, mul, power, sub)
- **Positions 48-70:** signed/float math (abs through sub)
- **Positions 71-72:** store (get, set)

Position 27 ("now") correctly uses `LibOpTimestamp.integrity` and `LibOpTimestamp.run` as an alias for "block-timestamp" at position 26. Both integrity and opcode arrays share the same function references for these two positions, which is intentional.

The `literalParserFunctionPointers()` array has 4 entries matching `LITERAL_PARSERS_LENGTH = 4`: parseHex, parseDecimalFloatPacked, parseString, parseSubParseable.

---

## Findings

### INFO-01: Assembly pattern for fixed-to-dynamic array conversion is sound but technically misannotated as `memory-safe`

**Severity:** INFO

**Location:** Lines 320-323, 334-336/347-349, 367-368/519-521, 539-540/624-626, 643-644/728-730

**Description:** All five functions use the same assembly pattern to convert a fixed-size array to a dynamic array: the fixed array is allocated with `N+1` elements where position 0 is a dummy placeholder, then `pointersDynamic := pointersFixed` aliases them, and `mstore(pointersDynamic, length)` overwrites the placeholder with the actual length.

This pattern is correct and widely used. The `"memory-safe"` annotation is technically debatable since the assembly reinterprets the memory layout of a fixed-size array as a dynamic array, but this is a cosmetic annotation concern. The compiler uses this annotation only for stack-too-deep optimizations, and the code is behaviorally correct:
1. The fixed array is never used after the conversion
2. The dynamic array has correct length and data layout
3. No free memory pointer manipulation occurs

**Risk:** None. The pattern is correct.

---

### INFO-02: `BadDynamicLength` sanity checks are defensive guards against compiler memory layout changes

**Severity:** INFO

**Location:** Lines 352-353 (literal parsers), 524-525 (operand handlers), 629-630 (integrity), 733-734 (opcode)

**Description:** Each function checks `pointersDynamic.length != ALL_STANDARD_OPS_LENGTH` (or `LITERAL_PARSERS_LENGTH` for literal parsers) after the fixed-to-dynamic conversion. These guard against a hypothetical change in how Solidity lays out fixed-size arrays in memory. Under current Solidity (0.8.25), these checks are unreachable because the fixed array is always `N+1` elements and the length is always set to `N`. The checks correctly use the custom error `BadDynamicLength` rather than string reverts.

**Risk:** None. These are appropriate defensive checks.

---

### INFO-03: `unsafeTo16BitBytes` truncation is safe given that function pointers fit in 16 bits

**Severity:** INFO

**Location:** Lines 355, 527, 632, 736 (calls to `LibConvert.unsafeTo16BitBytes`)

**Description:** The `unsafeTo16BitBytes` function truncates each `uint256` to its low 16 bits. The values being truncated are Solidity internal function pointers. In the EVM, internal function pointers within a single contract are bytecode offsets that fit well within 16 bits (contract size limit is 24576 bytes = 0x6000, which fits in 16 bits since `type(uint16).max = 0xFFFF = 65535`). The EIP-170 contract size limit ensures these values will never exceed 16 bits.

The function is named `unsafe` to signal that it does not check for overflow, and the caller is responsible for ensuring the values fit. In this context, the safety invariant holds by virtue of EVM contract size limits.

**Risk:** None under current EVM rules. If EIP-170 were ever removed or the limit raised above 65535 bytes, this would silently truncate, but that is an extremely unlikely scenario.

---

### INFO-04: `sub` operand handler differs from other math ops

**Severity:** INFO

**Location:** Line 512

**Description:** The `sub` opcode (position 70) uses `handleOperandSingleFull` while all other math opcodes use `handleOperandDisallowed`. This is intentional: `LibOpSub.run` reads the operand to determine additional behavior (specifically, bits 16-19 of the operand encode additional input count), confirmed by inspecting `LibOpSub.sol` where `uint256(OperandV2.unwrap(operand) >> 0x10) & 0x0F` is used in both `integrity` and `run`.

**Risk:** None. This is correctly differentiated.

---

## Summary

No CRITICAL, HIGH, MEDIUM, or LOW findings were identified in `LibAllStandardOps.sol`.

The file is a registry/wiring file that constructs four parallel arrays of function pointers (authoring meta, operand handlers, integrity checks, opcode runtime). The core security property -- that all four arrays are consistently ordered and have the correct length -- has been verified by manual counting. All 72 entries across all four arrays are in the same order and reference the correct library functions.

The assembly patterns used are well-known and correct. All reverts use the custom error `BadDynamicLength`. The `unsafeTo16BitBytes` truncation is safe given EVM contract size limits. The defensive length checks after array conversion are appropriate guards.

The actual bounds-checking of opcode indexes during evaluation is the responsibility of the eval loop (in `LibEval.sol`), not this file.
