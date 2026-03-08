# Pass 3 -- NatSpec Documentation Audit: Extern Reference Ops + All Opcode Libs

**Agent:** A05
**Date:** 2026-03-07
**Scope:** All files in `src/lib/extern/reference/op/`, `src/lib/extern/reference/literal/`, `src/lib/op/**/*.sol`, and `src/lib/op/LibAllStandardOps.sol`

## Files Reviewed

### Extern reference ops (6 files)
- `src/lib/extern/reference/op/LibExternOpContextCallingContract.sol`
- `src/lib/extern/reference/op/LibExternOpContextRainlen.sol`
- `src/lib/extern/reference/op/LibExternOpContextSender.sol`
- `src/lib/extern/reference/op/LibExternOpIntInc.sol`
- `src/lib/extern/reference/op/LibExternOpStackOperand.sol`
- `src/lib/extern/reference/literal/LibParseLiteralRepeat.sol`

### Core opcodes (4 files in `src/lib/op/00/`)
- `LibOpConstant.sol`, `LibOpContext.sol`, `LibOpExtern.sol`, `LibOpStack.sol`

### Bitwise opcodes (7 files in `src/lib/op/bitwise/`)
- `LibOpBitwiseAnd.sol`, `LibOpBitwiseOr.sol`, `LibOpBitwiseCountOnes.sol`, `LibOpBitwiseDecode.sol`, `LibOpBitwiseEncode.sol`, `LibOpBitwiseShiftLeft.sol`, `LibOpBitwiseShiftRight.sol`

### Call (1 file)
- `LibOpCall.sol`

### Crypto (1 file)
- `LibOpHash.sol`

### ERC20 (6 files)
- `LibOpERC20Allowance.sol`, `LibOpERC20BalanceOf.sol`, `LibOpERC20TotalSupply.sol`
- `LibOpUint256ERC20Allowance.sol`, `LibOpUint256ERC20BalanceOf.sol`, `LibOpUint256ERC20TotalSupply.sol`

### ERC5313 (1 file)
- `LibOpERC5313Owner.sol`

### ERC721 (3 files)
- `LibOpERC721BalanceOf.sol`, `LibOpERC721OwnerOf.sol`, `LibOpUint256ERC721BalanceOf.sol`

### EVM (3 files)
- `LibOpBlockNumber.sol`, `LibOpChainId.sol`, `LibOpBlockTimestamp.sol`

### Logic (12 files)
- `LibOpAny.sol`, `LibOpBinaryEqualTo.sol`, `LibOpConditions.sol`, `LibOpEnsure.sol`, `LibOpEqualTo.sol`, `LibOpEvery.sol`, `LibOpGreaterThan.sol`, `LibOpGreaterThanOrEqualTo.sol`, `LibOpIf.sol`, `LibOpIsZero.sol`, `LibOpLessThan.sol`, `LibOpLessThanOrEqualTo.sol`

### Math (23 files + 2 growth + 6 uint256)
- `LibOpAbs.sol`, `LibOpAdd.sol`, `LibOpAvg.sol`, `LibOpCeil.sol`, `LibOpDiv.sol`, `LibOpE.sol`, `LibOpExp.sol`, `LibOpExp2.sol`, `LibOpFloor.sol`, `LibOpFrac.sol`, `LibOpGm.sol`, `LibOpHeadroom.sol`, `LibOpInv.sol`, `LibOpMax.sol`, `LibOpMaxNegativeValue.sol`, `LibOpMaxPositiveValue.sol`, `LibOpMin.sol`, `LibOpMinNegativeValue.sol`, `LibOpMinPositiveValue.sol`, `LibOpMul.sol`, `LibOpPower.sol`, `LibOpSqrt.sol`, `LibOpSub.sol`
- `LibOpExponentialGrowth.sol`, `LibOpLinearGrowth.sol`
- `LibOpUint256Add.sol`, `LibOpUint256Div.sol`, `LibOpUint256MaxValue.sol`, `LibOpUint256Mul.sol`, `LibOpUint256Power.sol`, `LibOpUint256Sub.sol`

### Store (2 files)
- `LibOpGet.sol`, `LibOpSet.sol`

### Registry
- `LibAllStandardOps.sol`

## Summary

NatSpec quality across all opcode libraries is consistently high. Every file has `@title` and `@notice` on the library-level doc block. Every function has `@notice`. Functions with named parameters have `@param` tags. Functions with return values have `@return` tags. The `@notice` tag is explicit wherever `@title` or other tags are present.

## Findings

### A05-P3-01 (INFO): LibAllStandardOps -- five builder functions missing `@return` tags

**File:** `src/lib/op/LibAllStandardOps.sol`
**Lines:** 120, 344, 377, 549, 653

The five builder functions (`authoringMetaV2`, `literalParserFunctionPointers`, `operandHandlerFunctionPointers`, `integrityFunctionPointers`, `opcodeFunctionPointers`) each return `bytes memory` but have no `@return` tag. They do have `///` NatSpec comment blocks (no explicit tags, so the text is implicit `@notice`), which is valid per the convention. However, the missing `@return` is an omission relative to the pattern used elsewhere in the codebase.

**Severity:** INFO -- the functions are internal build helpers, not user-facing.

### A05-P3-02 (INFO): LibOpCall.integrity -- single `@return` tag for two return values

**File:** `src/lib/op/call/LibOpCall.sol`
**Line:** 84

```solidity
/// @return The number of inputs and outputs for stack tracking.
function integrity(...) internal pure returns (uint256, uint256) {
```

Every other opcode's `integrity` function documents two separate `@return` tags (one for inputs, one for outputs). `LibOpCall.integrity` merges them into a single tag. This is technically valid NatSpec (multiple returns can share one tag), but inconsistent with the codebase pattern.

**Severity:** INFO -- no tooling breakage, purely a consistency matter.

### A05-P3-03 (INFO): LibExternOpStackOperand.subParser -- missing `@param` for unnamed second parameter

**File:** `src/lib/extern/reference/op/LibExternOpStackOperand.sol`
**Lines:** 15-21

The `subParser` function signature has three parameters: `constantsHeight`, an unnamed `uint256`, and `operand`. The NatSpec documents `@param constantsHeight` and `@param operand` but omits any `@param` for the second parameter. The sibling files (`LibExternOpContextCallingContract`, `LibExternOpContextRainlen`, `LibExternOpContextSender`) all include `@param ioByte The IO byte encoding inputs and outputs (unused).` for the same position.

**Severity:** INFO -- unnamed parameter, so no tooling impact, but inconsistent with siblings.

## Evidence of Thorough Review

- All 72+ files were read in full.
- Every `integrity`, `run`, and `referenceFn` function was checked for `@notice`, `@param`, and `@return`.
- Library-level `@title`/`@notice` blocks were verified on every file.
- The four parallel arrays in `LibAllStandardOps` were checked for consistent ordering against the authoring meta.
- File-level constants (`@dev` tags) were checked in `LibParseLiteralRepeat.sol`, `LibExternOpContextRainlen.sol`, `LibExternOpIntInc.sol`, and error definitions.
- No HIGH or MEDIUM findings. All three findings are INFO-level consistency observations.
