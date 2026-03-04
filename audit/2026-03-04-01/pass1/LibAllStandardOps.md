# Pass 1 (Security) -- LibAllStandardOps.sol

**File:** `src/lib/op/LibAllStandardOps.sol`
**Auditor:** A34
**Date:** 2026-03-04

---

## Evidence of Thorough Reading

### Library

- `LibAllStandardOps` (library, line 110)

### Constants

- `ALL_STANDARD_OPS_LENGTH = 72` (line 105)

### Functions

| Function | Line | Visibility |
|---|---|---|
| `authoringMetaV2()` | 120 | `internal pure` |
| `literalParserFunctionPointers()` | 344 | `internal pure` |
| `operandHandlerFunctionPointers()` | 377 | `internal pure` |
| `integrityFunctionPointers()` | 549 | `internal pure` |
| `opcodeFunctionPointers()` | 653 | `internal pure` |

### Errors Imported

- `BadDynamicLength(uint256 dynamicLength, uint256 standardOpsLength)` from `../../error/ErrOpList.sol` (line 5)

### Types Imported

- `Pointer` from `rain.solmem/lib/LibPointer.sol`
- `OperandV2` from `rain.interpreter.interface/interface/IInterpreterV4.sol`
- `AuthoringMetaV2` from `rain.interpreter.interface/interface/IParserV2.sol`
- `IntegrityCheckState` from `../integrity/LibIntegrityCheck.sol`
- `InterpreterState` from `../state/LibInterpreterState.sol`
- `ParseState`, `LITERAL_PARSERS_LENGTH` from `../parse/literal/LibParseLiteral.sol`

### External Dependencies

- `LibConvert.unsafeTo16BitBytes` from `rain.lib.typecast/LibConvert.sol`
- `LibParseOperand` from `../parse/LibParseOperand.sol`
- 66 opcode libraries (4 in `00/`, 7 in `bitwise/`, 1 in `call/`, 1 in `crypto/`, 3+3 in `erc20/`, 1 in `erc5313/`, 2+1 in `erc721/`, 3 in `evm/`, 12 in `logic/`, 23 in `math/`, 2 in `math/growth/`, 6 in `math/uint256/`, 2 in `store/`)
- 4 literal parser libraries

---

## Parallel Array Consistency Verification

All four parallel arrays were counted entry-by-entry. Each has exactly 72 entries matching `ALL_STANDARD_OPS_LENGTH = 72`. The ordering is consistent across all four arrays:

| Pos | authoringMetaV2 word | operandHandler | integrity | opcode (run) |
|-----|---------------------|----------------|-----------|--------------|
| 0 | `stack` | `handleOperandSingleFull` | `LibOpStack.integrity` | `LibOpStack.run` |
| 1 | `constant` | `handleOperandSingleFull` | `LibOpConstant.integrity` | `LibOpConstant.run` |
| 2 | `extern` | `handleOperandSingleFull` | `LibOpExtern.integrity` | `LibOpExtern.run` |
| 3 | `context` | `handleOperandDoublePerByteNoDefault` | `LibOpContext.integrity` | `LibOpContext.run` |
| 4 | `bitwise-and` | `handleOperandDisallowed` | `LibOpBitwiseAnd.integrity` | `LibOpBitwiseAnd.run` |
| 5 | `bitwise-count-ones` | `handleOperandDisallowed` | `LibOpBitwiseCountOnes.integrity` | `LibOpBitwiseCountOnes.run` |
| 6 | `bitwise-decode` | `handleOperandDoublePerByteNoDefault` | `LibOpBitwiseDecode.integrity` | `LibOpBitwiseDecode.run` |
| 7 | `bitwise-encode` | `handleOperandDoublePerByteNoDefault` | `LibOpBitwiseEncode.integrity` | `LibOpBitwiseEncode.run` |
| 8 | `bitwise-or` | `handleOperandDisallowed` | `LibOpBitwiseOr.integrity` | `LibOpBitwiseOr.run` |
| 9 | `bitwise-shift-left` | `handleOperandSingleFull` | `LibOpBitwiseShiftLeft.integrity` | `LibOpBitwiseShiftLeft.run` |
| 10 | `bitwise-shift-right` | `handleOperandSingleFull` | `LibOpBitwiseShiftRight.integrity` | `LibOpBitwiseShiftRight.run` |
| 11 | `call` | `handleOperandSingleFull` | `LibOpCall.integrity` | `LibOpCall.run` |
| 12 | `hash` | `handleOperandDisallowed` | `LibOpHash.integrity` | `LibOpHash.run` |
| 13 | `erc20-allowance` | `handleOperandDisallowed` | `LibOpERC20Allowance.integrity` | `LibOpERC20Allowance.run` |
| 14 | `erc20-balance-of` | `handleOperandDisallowed` | `LibOpERC20BalanceOf.integrity` | `LibOpERC20BalanceOf.run` |
| 15 | `erc20-total-supply` | `handleOperandDisallowed` | `LibOpERC20TotalSupply.integrity` | `LibOpERC20TotalSupply.run` |
| 16 | `uint256-erc20-allowance` | `handleOperandDisallowed` | `LibOpUint256ERC20Allowance.integrity` | `LibOpUint256ERC20Allowance.run` |
| 17 | `uint256-erc20-balance-of` | `handleOperandDisallowed` | `LibOpUint256ERC20BalanceOf.integrity` | `LibOpUint256ERC20BalanceOf.run` |
| 18 | `uint256-erc20-total-supply` | `handleOperandDisallowed` | `LibOpUint256ERC20TotalSupply.integrity` | `LibOpUint256ERC20TotalSupply.run` |
| 19 | `erc5313-owner` | `handleOperandDisallowed` | `LibOpERC5313Owner.integrity` | `LibOpERC5313Owner.run` |
| 20 | `erc721-balance-of` | `handleOperandDisallowed` | `LibOpERC721BalanceOf.integrity` | `LibOpERC721BalanceOf.run` |
| 21 | `erc721-owner-of` | `handleOperandDisallowed` | `LibOpERC721OwnerOf.integrity` | `LibOpERC721OwnerOf.run` |
| 22 | `uint256-erc721-balance-of` | `handleOperandDisallowed` | `LibOpUint256ERC721BalanceOf.integrity` | `LibOpUint256ERC721BalanceOf.run` |
| 23 | `block-number` | `handleOperandDisallowed` | `LibOpBlockNumber.integrity` | `LibOpBlockNumber.run` |
| 24 | `block-timestamp` | `handleOperandDisallowed` | `LibOpBlockTimestamp.integrity` | `LibOpBlockTimestamp.run` |
| 25 | `now` | `handleOperandDisallowed` | `LibOpBlockTimestamp.integrity` | `LibOpBlockTimestamp.run` |
| 26 | `chain-id` | `handleOperandDisallowed` | `LibOpChainId.integrity` | `LibOpChainId.run` |
| 27 | `any` | `handleOperandDisallowed` | `LibOpAny.integrity` | `LibOpAny.run` |
| 28 | `binary-equal-to` | `handleOperandDisallowed` | `LibOpBinaryEqualTo.integrity` | `LibOpBinaryEqualTo.run` |
| 29 | `conditions` | `handleOperandDisallowed` | `LibOpConditions.integrity` | `LibOpConditions.run` |
| 30 | `ensure` | `handleOperandDisallowed` | `LibOpEnsure.integrity` | `LibOpEnsure.run` |
| 31 | `equal-to` | `handleOperandDisallowed` | `LibOpEqualTo.integrity` | `LibOpEqualTo.run` |
| 32 | `every` | `handleOperandDisallowed` | `LibOpEvery.integrity` | `LibOpEvery.run` |
| 33 | `greater-than` | `handleOperandDisallowed` | `LibOpGreaterThan.integrity` | `LibOpGreaterThan.run` |
| 34 | `greater-than-or-equal-to` | `handleOperandDisallowed` | `LibOpGreaterThanOrEqualTo.integrity` | `LibOpGreaterThanOrEqualTo.run` |
| 35 | `if` | `handleOperandDisallowed` | `LibOpIf.integrity` | `LibOpIf.run` |
| 36 | `is-zero` | `handleOperandDisallowed` | `LibOpIsZero.integrity` | `LibOpIsZero.run` |
| 37 | `less-than` | `handleOperandDisallowed` | `LibOpLessThan.integrity` | `LibOpLessThan.run` |
| 38 | `less-than-or-equal-to` | `handleOperandDisallowed` | `LibOpLessThanOrEqualTo.integrity` | `LibOpLessThanOrEqualTo.run` |
| 39 | `abs` | `handleOperandDisallowed` | `LibOpAbs.integrity` | `LibOpAbs.run` |
| 40 | `add` | `handleOperandDisallowed` | `LibOpAdd.integrity` | `LibOpAdd.run` |
| 41 | `avg` | `handleOperandDisallowed` | `LibOpAvg.integrity` | `LibOpAvg.run` |
| 42 | `ceil` | `handleOperandDisallowed` | `LibOpCeil.integrity` | `LibOpCeil.run` |
| 43 | `div` | `handleOperandDisallowed` | `LibOpDiv.integrity` | `LibOpDiv.run` |
| 44 | `e` | `handleOperandDisallowed` | `LibOpE.integrity` | `LibOpE.run` |
| 45 | `exp` | `handleOperandDisallowed` | `LibOpExp.integrity` | `LibOpExp.run` |
| 46 | `exp2` | `handleOperandDisallowed` | `LibOpExp2.integrity` | `LibOpExp2.run` |
| 47 | `floor` | `handleOperandDisallowed` | `LibOpFloor.integrity` | `LibOpFloor.run` |
| 48 | `frac` | `handleOperandDisallowed` | `LibOpFrac.integrity` | `LibOpFrac.run` |
| 49 | `gm` | `handleOperandDisallowed` | `LibOpGm.integrity` | `LibOpGm.run` |
| 50 | `headroom` | `handleOperandDisallowed` | `LibOpHeadroom.integrity` | `LibOpHeadroom.run` |
| 51 | `inv` | `handleOperandDisallowed` | `LibOpInv.integrity` | `LibOpInv.run` |
| 52 | `max` | `handleOperandDisallowed` | `LibOpMax.integrity` | `LibOpMax.run` |
| 53 | `max-negative-value` | `handleOperandDisallowed` | `LibOpMaxNegativeValue.integrity` | `LibOpMaxNegativeValue.run` |
| 54 | `max-positive-value` | `handleOperandDisallowed` | `LibOpMaxPositiveValue.integrity` | `LibOpMaxPositiveValue.run` |
| 55 | `min` | `handleOperandDisallowed` | `LibOpMin.integrity` | `LibOpMin.run` |
| 56 | `min-negative-value` | `handleOperandDisallowed` | `LibOpMinNegativeValue.integrity` | `LibOpMinNegativeValue.run` |
| 57 | `min-positive-value` | `handleOperandDisallowed` | `LibOpMinPositiveValue.integrity` | `LibOpMinPositiveValue.run` |
| 58 | `mul` | `handleOperandDisallowed` | `LibOpMul.integrity` | `LibOpMul.run` |
| 59 | `power` | `handleOperandDisallowed` | `LibOpPower.integrity` | `LibOpPower.run` |
| 60 | `sqrt` | `handleOperandDisallowed` | `LibOpSqrt.integrity` | `LibOpSqrt.run` |
| 61 | `sub` | `handleOperandDisallowed` | `LibOpSub.integrity` | `LibOpSub.run` |
| 62 | `exponential-growth` | `handleOperandDisallowed` | `LibOpExponentialGrowth.integrity` | `LibOpExponentialGrowth.run` |
| 63 | `linear-growth` | `handleOperandDisallowed` | `LibOpLinearGrowth.integrity` | `LibOpLinearGrowth.run` |
| 64 | `uint256-add` | `handleOperandDisallowed` | `LibOpUint256Add.integrity` | `LibOpUint256Add.run` |
| 65 | `uint256-div` | `handleOperandDisallowed` | `LibOpUint256Div.integrity` | `LibOpUint256Div.run` |
| 66 | `uint256-max-value` | `handleOperandDisallowed` | `LibOpUint256MaxValue.integrity` | `LibOpUint256MaxValue.run` |
| 67 | `uint256-mul` | `handleOperandDisallowed` | `LibOpUint256Mul.integrity` | `LibOpUint256Mul.run` |
| 68 | `uint256-power` | `handleOperandDisallowed` | `LibOpUint256Power.integrity` | `LibOpUint256Power.run` |
| 69 | `uint256-sub` | `handleOperandDisallowed` | `LibOpUint256Sub.integrity` | `LibOpUint256Sub.run` |
| 70 | `get` | `handleOperandDisallowed` | `LibOpGet.integrity` | `LibOpGet.run` |
| 71 | `set` | `handleOperandDisallowed` | `LibOpSet.integrity` | `LibOpSet.run` |

Position 25 (`now`) is an alias for `block-timestamp` at position 24. Both integrity and opcode arrays correctly reference `LibOpBlockTimestamp.integrity` and `LibOpBlockTimestamp.run` respectively.

The `literalParserFunctionPointers()` array has 4 entries matching `LITERAL_PARSERS_LENGTH = 4`: `parseHex`, `parseDecimalFloatPacked`, `parseString`, `parseSubParseable`.

---

## Assembly Analysis

### Fixed-to-dynamic array conversion pattern

All five functions use the same pattern: allocate a fixed array of size `N+1`, place a length value at index 0, then alias the fixed array pointer as a dynamic array pointer via `assembly ("memory-safe") { dynamicArray := fixedArray }`.

Two variants exist:

1. **`authoringMetaV2()`**: Uses a zero-initialized struct placeholder, then overwrites with `mstore(wordsDynamic, length)` after aliasing. This is necessary because `AuthoringMetaV2` is a struct and cannot be set to an integer in Solidity.

2. **Other four functions**: Set a function pointer variable to the length value via assembly (`lengthPointer := length`), then use it as the first element. When aliased, the stored integer becomes the length word directly. No post-alias `mstore` needed.

Both variants produce correct dynamic array memory layout. The `memory-safe` annotation is valid: no memory is allocated or freed, the free memory pointer is not modified, and the aliased memory region was allocated by Solidity.

### `unsafeTo16BitBytes` truncation safety

Each function passes the dynamic array to `LibConvert.unsafeTo16BitBytes`, which truncates each `uint256` to 16 bits. Internal function pointers are bytecode offsets. EIP-170 limits contract size to 24,576 bytes (0x6000), which fits within `type(uint16).max` (65,535 = 0xFFFF). The truncation is safe under current EVM rules.

### Defensive length checks

Each function (except `authoringMetaV2`) checks `pointersDynamic.length != ALL_STANDARD_OPS_LENGTH` after the alias and reverts with `BadDynamicLength` if mismatched. These are unreachable under the current Solidity memory layout but serve as guards against future compiler changes. The `authoringMetaV2` function does not have this check because it explicitly writes the length via `mstore`.

---

## Test Coverage

The file has dedicated tests in:

- `test/src/lib/op/LibAllStandardOps.t.sol` -- Verifies all four parallel arrays have consistent length, verifies `authoringMetaV2` decodes to 72 entries, checks the first four word names match the required parsing order, and verifies every word name at every position.
- `test/src/lib/op/LibAllStandardOps.filesystemOrdering.t.sol` -- Uses FFI to verify that word names (positions 4+) match the filesystem ordering of `LibOp*.sol` files, automatically detecting ordering drift. Alias words (e.g., `now`) are correctly skipped.

---

## Findings

No CRITICAL, HIGH, MEDIUM, or LOW findings.

### INFO-01: Assembly `memory-safe` annotation is technically sound

**Severity:** INFO

**Location:** Lines 334-337, 348-350, 381-383/533-534, 553-554/638-639, 657-658/742-743

The `memory-safe` annotation on the assembly blocks is correct. No memory is allocated, freed, or written outside of already-allocated regions. The pattern reinterprets an existing memory region (a fixed-size array) as a dynamic array, which is a well-established Solidity pattern. The compiler uses this annotation only for stack optimization (Yul optimizer), and the invariant holds.

### INFO-02: Defensive `BadDynamicLength` checks are unreachable under current compiler

**Severity:** INFO

**Location:** Lines 366-368, 538-539, 643-644, 747-748

Each pointer-building function checks `pointersDynamic.length != ALL_STANDARD_OPS_LENGTH` (or `LITERAL_PARSERS_LENGTH`) after the fixed-to-dynamic conversion. Under the current Solidity 0.8.25 memory layout, these checks are unreachable because the fixed array always has exactly `N+1` elements and element 0 is always set to `N`. The checks are appropriate defensive guards using a custom error.

### INFO-03: `unsafeTo16BitBytes` truncation is safe given EIP-170

**Severity:** INFO

**Location:** Lines 369, 541, 646, 750

The `unsafeTo16BitBytes` function truncates each `uint256` to 16 bits without overflow checking. Internal function pointers are bytecode offsets bounded by EIP-170's 24,576-byte contract size limit, which fits within `uint16`.

---

## Summary

No security findings were identified in `LibAllStandardOps.sol`.

The file is a wiring/registry library that constructs four parallel arrays of function pointers (authoring meta, operand handlers, integrity checks, opcode runtime) plus a literal parser function pointer array. The core security property -- that all four opcode arrays are consistently ordered and have the correct length of 72 -- has been verified by manual entry-by-entry comparison across all four arrays. The `now` alias at position 25 correctly shares `LibOpBlockTimestamp`'s implementations with `block-timestamp` at position 24.

The assembly patterns are well-known and correct. All reverts use the custom `BadDynamicLength` error. The `unsafeTo16BitBytes` truncation is safe under EIP-170. Defensive length checks are appropriate guards against future compiler changes. Existing tests verify array lengths, word-name ordering, and filesystem consistency.
