# Pass 3 -- NatSpec Documentation Audit: All Opcode Libraries (`src/lib/op/`)

Audit date: 2026-03-01
Auditor: Claude Opus 4.6
Scope: All 68 `.sol` files under `src/lib/op/`

## Methodology

Every file under `src/lib/op/` was read in full. For each file, every library
and every function was identified. Each was checked for:

1. Presence of NatSpec (`@title`, `@notice`, `@param`, `@return`)
2. Completeness of `@param` and `@return` tags against function signatures
3. Accuracy of documentation vs. implementation
4. Conformance to the project NatSpec convention: when a doc block contains any
   explicit tag (e.g. `@title`), all entries must be explicitly tagged.

## Summary

The overall quality of NatSpec documentation across the opcode libraries is high.
Most files follow a consistent pattern: `@title`/`@notice` on the library,
`@notice` on each function, and `@param`/`@return` tags on function parameters.

The findings below are deviations from this established pattern.

---

## Findings

### P3-OPALL-01 [LOW] Missing `@notice` tag on `integrity` in several uint256 / growth files

**Files and locations:**
- `src/lib/op/erc20/uint256/LibOpUint256ERC20Allowance.sol` line 15: `/// \`uint256-erc20-allowance\` integrity check...`
- `src/lib/op/erc20/uint256/LibOpUint256ERC20BalanceOf.sol` line 15: `/// \`uint256-erc20-balance-of\` integrity check...`
- `src/lib/op/erc20/uint256/LibOpUint256ERC20TotalSupply.sol` line 15: `/// \`uint256-erc20-total-supply\` integrity check...`
- `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol` line 15: `/// \`uint256-erc721-balance-of\` integrity check...`
- `src/lib/op/math/growth/LibOpExponentialGrowth.sol` line 17: `/// \`exponential-growth\` integrity check...`
- `src/lib/op/math/growth/LibOpLinearGrowth.sol` line 17: `/// \`linear-growth\` integrity check...`
- `src/lib/op/math/uint256/LibOpMaxUint256.sol` line 13: `/// \`max-uint256\` integrity check...`

**Description:**
These `integrity` functions have a doc comment starting with `///` but without
the `@notice` tag. In files where no explicit tags are used at all in a doc
block, this is acceptable (untagged lines become implicit `@notice`). However,
the pattern established across the entire opcode library set is to explicitly
use `@notice` on every function's doc block. These seven files deviate from
that pattern.

More importantly, several of these same files DO have `@return` tags on the
corresponding float-variant `integrity` functions (e.g. `LibOpERC20Allowance`),
so the inconsistency makes it unclear whether the missing tags were intentional.

**Recommendation:**
Add `@notice` tag to each of these `integrity` doc comments and add missing
`@return` tags to match the pattern used by the float-variant opcodes.

---

### P3-OPALL-02 [LOW] Missing `@return` tags on `integrity` in several uint256 / growth files

**Files and locations (same set as P3-OPALL-01):**
- `src/lib/op/erc20/uint256/LibOpUint256ERC20Allowance.sol` line 15-16
- `src/lib/op/erc20/uint256/LibOpUint256ERC20BalanceOf.sol` line 15-16
- `src/lib/op/erc20/uint256/LibOpUint256ERC20TotalSupply.sol` line 15-16
- `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol` line 15-16
- `src/lib/op/math/growth/LibOpExponentialGrowth.sol` line 17-18
- `src/lib/op/math/growth/LibOpLinearGrowth.sol` line 17-18
- `src/lib/op/math/uint256/LibOpMaxUint256.sol` line 13-14

**Description:**
These `integrity` functions return `(uint256, uint256)` representing
(inputs, outputs). Every other opcode library documents these returns with
`@return The number of inputs.` / `@return The number of outputs.` but these
seven files omit the `@return` tags entirely.

**Recommendation:**
Add `@return The number of inputs.` and `@return The number of outputs.` to
match the convention used everywhere else.

---

### P3-OPALL-03 [LOW] Missing `@notice` and NatSpec tags on `referenceFn` in `LibOpMaxUint256.sol`

**File:** `src/lib/op/math/uint256/LibOpMaxUint256.sol` line 30-31

**Description:**
The `referenceFn` function has a doc comment `/// Reference implementation of
\`max-uint256\` for testing.` but it is missing the `@notice` tag and has no
`@return` tag. Both the `run` function in the same file and `referenceFn`
functions in other opcode libraries use explicit `@notice` tags.

**Recommendation:**
Add `@notice` and `@return` tags.

---

### P3-OPALL-04 [LOW] Missing `@notice` tag on `integrity` in `LibOpEnsure.sol`

**File:** `src/lib/op/logic/LibOpEnsure.sol` line 18-19

**Description:**
The `integrity` function's doc block has `@return` tags but is missing the
`@notice` tag. This is the only logic opcode where `integrity` lacks `@notice`.
The `@return` tags without `@notice` means the first `///` line is implicitly
`@notice`, which is correct in isolation, but violates the project convention
that when any explicit tag (here `@return`) is present, all entries should be
explicitly tagged.

**Recommendation:**
Add `@notice` to be consistent: `/// @notice \`ensure\` integrity check.
Requires exactly 2 inputs and 0 outputs.`

---

### P3-OPALL-05 [INFO] `LibOpCall.sol` has no `referenceFn`

**File:** `src/lib/op/call/LibOpCall.sol`

**Description:**
`LibOpCall` does not provide a `referenceFn` like all other opcode libraries.
This is expected because `call` dispatches to another source and cannot
meaningfully be expressed as a simple stack-in/stack-out reference function.
The `run` function delegates to `LibEval.evalLoop`. Documenting the absence
of `referenceFn` is not required but noted for completeness.

No action needed.

---

### P3-OPALL-06 [INFO] `LibOpCall.integrity` return NatSpec uses single `@return` for tuple

**File:** `src/lib/op/call/LibOpCall.sol` line 84

**Description:**
The `integrity` function's `@return` documents only one tag for a function that
returns `(uint256, uint256)`: `@return The number of inputs and outputs for
stack tracking.` All other opcode libraries use two separate `@return` tags.
However, this is arguably more accurate for `call` specifically because the
return values are dynamically derived from bytecode, not fixed constants.

This is a minor inconsistency but is defensible as an intentional deviation.

No action needed.

---

### P3-OPALL-07 [INFO] `LibAllStandardOps.sol` functions lack `@return` tags

**File:** `src/lib/op/LibAllStandardOps.sol`

**Description:**
The five functions in `LibAllStandardOps` (`authoringMetaV2`, `literalParserFunctionPointers`,
`operandHandlerFunctionPointers`, `integrityFunctionPointers`, `opcodeFunctionPointers`)
all return `bytes memory` but have no `@return` tag. Their doc comments use
untagged `///` lines which become implicit `@notice` (no explicit tags are
present), so this does not violate the "explicit tag" convention.

This is an acceptable style for internal builder functions whose return values
are self-evident. Noted for completeness only.

No action needed.

---

## Evidence Index

Below is a per-file inventory of every library and function, with NatSpec status.

### `src/lib/op/LibAllStandardOps.sol`
- Library: `LibAllStandardOps` -- `@title` line 108, `@notice` line 109
- `authoringMetaV2()` line 121 -- untagged `///` (OK, no explicit tags in block)
- `literalParserFunctionPointers()` line 330 -- untagged `///` (OK)
- `operandHandlerFunctionPointers()` line 363 -- untagged `///` (OK)
- `integrityFunctionPointers()` line 535 -- untagged `///` (OK)
- `opcodeFunctionPointers()` line 639 -- untagged `///` (OK)

### `src/lib/op/00/LibOpConstant.sol`
- Library: `LibOpConstant` -- `@title` line 11, `@notice` line 12
- `integrity()` line 21 -- `@notice`, `@param`x2, `@return`x2. COMPLETE.
- `run()` line 37 -- `@notice`, `@param`x3, `@return`. COMPLETE.
- `referenceFn()` line 52 -- `@notice`, `@param`x2, `@return`. COMPLETE.

### `src/lib/op/00/LibOpContext.sol`
- Library: `LibOpContext` -- `@title` line 10, `@notice` line 11
- `integrity()` line 16 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 28 -- `@notice`, `@param`x3, `@return`. COMPLETE.
- `referenceFn()` line 47 -- `@notice`, `@param`x2, `@return`. COMPLETE.

### `src/lib/op/00/LibOpExtern.sol`
- Library: `LibOpExtern` -- `@title` line 21, `@notice` line 22
- `integrity()` line 29 -- `@notice`, `@param`x2, `@return`x2. COMPLETE.
- `run()` line 49 -- `@notice`, `@param`x3, `@return`. COMPLETE.
- `referenceFn()` line 102 -- `@notice`, `@param`x3, `@return`. COMPLETE.

### `src/lib/op/00/LibOpStack.sol`
- Library: `LibOpStack` -- `@title` line 11, `@notice` line 12
- `integrity()` line 21 -- `@notice`, `@param`x2, `@return`x2. COMPLETE.
- `run()` line 41 -- `@notice`, `@param`x3, `@return`. COMPLETE.
- `referenceFn()` line 58 -- `@notice`, `@param`x2, `@return`. COMPLETE.

### `src/lib/op/bitwise/LibOpBitwiseAnd.sol`
- Library: `LibOpBitwiseAnd` -- `@title` line 10, `@notice` line 11
- `integrity()` line 16 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 24 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 36 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/bitwise/LibOpBitwiseOr.sol`
- Library: `LibOpBitwiseOr` -- `@title` line 10, `@notice` line 11
- `integrity()` line 16 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 24 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 36 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/bitwise/LibOpCtPop.sol`
- Library: `LibOpCtPop` -- `@title` line 11, `@notice` line 12
- `integrity()` line 22 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 30 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 47 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/bitwise/LibOpDecodeBits.sol`
- Library: `LibOpDecodeBits` -- `@title` line 11, `@notice` line 12
- `integrity()` line 20 -- `@notice`, `@param`x2, `@return`x2. COMPLETE.
- `run()` line 33 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 65 -- `@notice`, `@param`x2, `@return`. COMPLETE.

### `src/lib/op/bitwise/LibOpEncodeBits.sol`
- Library: `LibOpEncodeBits` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 36 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 76 -- `@notice`, `@param`x2, `@return`. COMPLETE.

### `src/lib/op/bitwise/LibOpShiftBitsLeft.sol`
- Library: `LibOpShiftBitsLeft` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 38 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 49 -- `@notice`, `@param`x2, `@return`. COMPLETE.

### `src/lib/op/bitwise/LibOpShiftBitsRight.sol`
- Library: `LibOpShiftBitsRight` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 38 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 49 -- `@notice`, `@param`x2, `@return`. COMPLETE.

### `src/lib/op/call/LibOpCall.sol`
- Library: `LibOpCall` -- `@title` line 13, `@notice` line 14
- `integrity()` line 85 -- `@notice`, `@param`x2, `@return`x1 (single for tuple). See P3-OPALL-06.
- `run()` line 122 -- `@notice`, `@param`x3, `@return`. COMPLETE.
- No `referenceFn`. See P3-OPALL-05.

### `src/lib/op/crypto/LibOpHash.sol`
- Library: `LibOpHash` -- `@title` line 10, `@notice` line 11
- `integrity()` line 17 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 28 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 41 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/erc20/LibOpERC20Allowance.sol`
- Library: `LibOpERC20Allowance` -- `@title` line 15, `@notice` line 16
- `integrity()` line 21 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 30 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 83 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/erc20/LibOpERC20BalanceOf.sol`
- Library: `LibOpERC20BalanceOf` -- `@title` line 15, `@notice` line 16
- `integrity()` line 21 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 30 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 67 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/erc20/LibOpERC20TotalSupply.sol`
- Library: `LibOpERC20TotalSupply` -- `@title` line 15, `@notice` line 16
- `integrity()` line 21 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 30 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 61 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/erc20/uint256/LibOpUint256ERC20Allowance.sol`
- Library: `LibOpUint256ERC20Allowance` -- `@title` line 12, `@notice` line 13
- `integrity()` line 16 -- MISSING `@notice`, MISSING `@return`x2. **FINDING P3-OPALL-01/02.**
- `run()` line 25 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 60 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/erc20/uint256/LibOpUint256ERC20BalanceOf.sol`
- Library: `LibOpUint256ERC20BalanceOf` -- `@title` line 12, `@notice` line 13
- `integrity()` line 16 -- MISSING `@notice`, MISSING `@return`x2. **FINDING P3-OPALL-01/02.**
- `run()` line 25 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 54 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/erc20/uint256/LibOpUint256ERC20TotalSupply.sol`
- Library: `LibOpUint256ERC20TotalSupply` -- `@title` line 12, `@notice` line 13
- `integrity()` line 16 -- MISSING `@notice`, MISSING `@return`x2. **FINDING P3-OPALL-01/02.**
- `run()` line 25 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 48 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/erc5313/LibOpERC5313Owner.sol`
- Library: `LibOpERC5313Owner` -- `@title` line 12, `@notice` line 13
- `integrity()` line 18 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 27 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 50 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/erc721/LibOpERC721BalanceOf.sol`
- Library: `LibOpERC721BalanceOf` -- `@title` line 13, `@notice` line 14
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 28 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 60 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/erc721/LibOpERC721OwnerOf.sol`
- Library: `LibOpERC721OwnerOf` -- `@title` line 12, `@notice` line 13
- `integrity()` line 18 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 27 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 53 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol`
- Library: `LibOpUint256ERC721BalanceOf` -- `@title` line 12, `@notice` line 13
- `integrity()` line 16 -- MISSING `@notice`, MISSING `@return`x2. **FINDING P3-OPALL-01/02.**
- `run()` line 25 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 52 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/evm/LibOpBlockNumber.sol`
- Library: `LibOpBlockNumber` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 26 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 39 -- `@notice`, `@return`. COMPLETE.

### `src/lib/op/evm/LibOpChainId.sol`
- Library: `LibOpChainId` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 26 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 39 -- `@notice`, `@return`. COMPLETE.

### `src/lib/op/evm/LibOpTimestamp.sol`
- Library: `LibOpTimestamp` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 26 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 39 -- `@notice`, `@return`. COMPLETE.

### `src/lib/op/logic/LibOpAny.sol`
- Library: `LibOpAny` -- `@title` line 11, `@notice` line 12
- `integrity()` line 21 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 33 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 60 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/logic/LibOpBinaryEqualTo.sol`
- Library: `LibOpBinaryEqualTo` -- `@title` line 10, `@notice` line 11
- `integrity()` line 17 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 26 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 38 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/logic/LibOpConditions.sol`
- Library: `LibOpConditions` -- `@title` line 12, `@notice` line 13
- `integrity()` line 23 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 40 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 82 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/logic/LibOpEnsure.sol`
- Library: `LibOpEnsure` -- `@title` line 12, `@notice` line 13
- `integrity()` line 20 -- MISSING `@notice`, has `@return`x2. **FINDING P3-OPALL-04.**
- `run()` line 31 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 49 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/logic/LibOpEqualTo.sol`
- Library: `LibOpEqualTo` -- `@title` line 11, `@notice` line 12
- `integrity()` line 21 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 30 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 52 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/logic/LibOpEvery.sol`
- Library: `LibOpEvery` -- `@title` line 11, `@notice` line 12
- `integrity()` line 21 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 32 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 58 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/logic/LibOpGreaterThan.sol`
- Library: `LibOpGreaterThan` -- `@title` line 11, `@notice` line 12
- `integrity()` line 20 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 28 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 46 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/logic/LibOpGreaterThanOrEqualTo.sol`
- Library: `LibOpGreaterThanOrEqualTo` -- `@title` line 11, `@notice` line 12
- `integrity()` line 20 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 29 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 47 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/logic/LibOpIf.sol`
- Library: `LibOpIf` -- `@title` line 11, `@notice` line 12
- `integrity()` line 20 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 29 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 47 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/logic/LibOpIsZero.sol`
- Library: `LibOpIsZero` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 27 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 42 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/logic/LibOpLessThan.sol`
- Library: `LibOpLessThan` -- `@title` line 11, `@notice` line 12
- `integrity()` line 20 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 28 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 46 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/logic/LibOpLessThanOrEqualTo.sol`
- Library: `LibOpLessThanOrEqualTo` -- `@title` line 11, `@notice` line 12
- `integrity()` line 20 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 29 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 47 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/growth/LibOpExponentialGrowth.sol`
- Library: `LibOpExponentialGrowth` -- `@title` line 11, `@notice` line 12
- `integrity()` line 18 -- MISSING `@notice`, MISSING `@return`x2. **FINDING P3-OPALL-01/02.**
- `run()` line 26 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 47 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/growth/LibOpLinearGrowth.sol`
- Library: `LibOpLinearGrowth` -- `@title` line 11, `@notice` line 12
- `integrity()` line 18 -- MISSING `@notice`, MISSING `@return`x2. **FINDING P3-OPALL-01/02.**
- `run()` line 26 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 48 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/uint256/LibOpMaxUint256.sol`
- Library: `LibOpMaxUint256` -- `@title` line 10, `@notice` line 11
- `integrity()` line 14 -- MISSING `@notice`, MISSING `@return`x2. **FINDING P3-OPALL-01/02.**
- `run()` line 21 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 31 -- MISSING `@notice`, MISSING `@return`. **FINDING P3-OPALL-03.**

### `src/lib/op/math/uint256/LibOpUint256Add.sol`
- Library: `LibOpUint256Add` -- `@title` line 10, `@notice` line 11
- `integrity()` line 17 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 30 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 64 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/uint256/LibOpUint256Div.sol`
- Library: `LibOpUint256Div` -- `@title` line 10, `@notice` line 11
- `integrity()` line 18 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 30 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 65 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/uint256/LibOpUint256Mul.sol`
- Library: `LibOpUint256Mul` -- `@title` line 10, `@notice` line 11
- `integrity()` line 17 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 30 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 64 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/uint256/LibOpUint256Pow.sol`
- Library: `LibOpUint256Pow` -- `@title` line 10, `@notice` line 11
- `integrity()` line 17 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 30 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 64 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/uint256/LibOpUint256Sub.sol`
- Library: `LibOpUint256Sub` -- `@title` line 10, `@notice` line 11
- `integrity()` line 17 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 30 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 64 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpAbs.sol`
- Library: `LibOpAbs` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 28 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 44 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpAdd.sol`
- Library: `LibOpAdd` -- `@title` line 13, `@notice` line 14
- `integrity()` line 22 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 33 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 76 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpAvg.sol`
- Library: `LibOpAvg` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 28 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 47 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpCeil.sol`
- Library: `LibOpCeil` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 28 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 44 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpDiv.sol`
- Library: `LibOpDiv` -- `@title` line 12, `@notice` line 13
- `integrity()` line 21 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 33 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 74 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpE.sol`
- Library: `LibOpE` -- `@title` line 11, `@notice` line 12
- `integrity()` line 17 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 24 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 35 -- `@notice`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpExp.sol`
- Library: `LibOpExp` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 28 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 44 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpExp2.sol`
- Library: `LibOpExp2` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 28 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 45 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpFloor.sol`
- Library: `LibOpFloor` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 28 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 44 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpFrac.sol`
- Library: `LibOpFrac` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 28 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 44 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpGm.sol`
- Library: `LibOpGm` -- `@title` line 11, `@notice` line 12
- `integrity()` line 21 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 31 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 55 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpHeadroom.sol`
- Library: `LibOpHeadroom` -- `@title` line 11, `@notice` line 12
- `integrity()` line 20 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 30 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 49 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpInv.sol`
- Library: `LibOpInv` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 28 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 44 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpMax.sol`
- Library: `LibOpMax` -- `@title` line 11, `@notice` line 12
- `integrity()` line 20 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 32 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 67 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpMaxNegativeValue.sol`
- Library: `LibOpMaxNegativeValue` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 26 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 37 -- `@notice`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpMaxPositiveValue.sol`
- Library: `LibOpMaxPositiveValue` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 26 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 37 -- `@notice`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpMin.sol`
- Library: `LibOpMin` -- `@title` line 11, `@notice` line 12
- `integrity()` line 20 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 32 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 68 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpMinNegativeValue.sol`
- Library: `LibOpMinNegativeValue` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 26 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 37 -- `@notice`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpMinPositiveValue.sol`
- Library: `LibOpMinPositiveValue` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 26 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 37 -- `@notice`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpMul.sol`
- Library: `LibOpMul` -- `@title` line 12, `@notice` line 13
- `integrity()` line 21 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 32 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 74 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpPow.sol`
- Library: `LibOpPow` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 28 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 47 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpSqrt.sol`
- Library: `LibOpSqrt` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 28 -- `@notice`, `@param`, `@return`. COMPLETE.
- `referenceFn()` line 44 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/math/LibOpSub.sol`
- Library: `LibOpSub` -- `@title` line 12, `@notice` line 13
- `integrity()` line 21 -- `@notice`, `@param`, `@return`x2. COMPLETE.
- `run()` line 33 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 75 -- `@notice`, `@param`, `@return`. COMPLETE.

### `src/lib/op/store/LibOpGet.sol`
- Library: `LibOpGet` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 32 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 68 -- `@notice`, `@param`x2, `@return`. COMPLETE.

### `src/lib/op/store/LibOpSet.sol`
- Library: `LibOpSet` -- `@title` line 11, `@notice` line 12
- `integrity()` line 19 -- `@notice`, `@return`x2. COMPLETE.
- `run()` line 29 -- `@notice`, `@param`x2, `@return`. COMPLETE.
- `referenceFn()` line 46 -- `@notice`, `@param`x2, `@return`. COMPLETE.
