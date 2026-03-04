# Pass 5: Correctness/Intent Verification - Math, Growth, Uint256, Store Ops

## Scope

- A69: `src/lib/op/math/LibOpAbs.sol`
- A70: `src/lib/op/math/LibOpAdd.sol`
- A71: `src/lib/op/math/LibOpAvg.sol`
- A72: `src/lib/op/math/LibOpCeil.sol`
- A73: `src/lib/op/math/LibOpDiv.sol`
- A74: `src/lib/op/math/LibOpE.sol`
- A75: `src/lib/op/math/LibOpExp.sol`
- A76: `src/lib/op/math/LibOpExp2.sol`
- A77: `src/lib/op/math/LibOpFloor.sol`
- A78: `src/lib/op/math/LibOpFrac.sol`
- A79: `src/lib/op/math/LibOpGm.sol`
- A80: `src/lib/op/math/LibOpHeadroom.sol`
- A81: `src/lib/op/math/LibOpInv.sol`
- A82: `src/lib/op/math/LibOpMax.sol`
- A83: `src/lib/op/math/LibOpMaxNegativeValue.sol`
- A84: `src/lib/op/math/LibOpMaxPositiveValue.sol`
- A85: `src/lib/op/math/LibOpMin.sol`
- A86: `src/lib/op/math/LibOpMinNegativeValue.sol`
- A87: `src/lib/op/math/LibOpMinPositiveValue.sol`
- A88: `src/lib/op/math/LibOpMul.sol`
- A89: `src/lib/op/math/LibOpPower.sol`
- A90: `src/lib/op/math/LibOpSqrt.sol`
- A91: `src/lib/op/math/LibOpSub.sol`
- A92: `src/lib/op/math/growth/LibOpExponentialGrowth.sol`
- A93: `src/lib/op/math/growth/LibOpLinearGrowth.sol`
- A94: `src/lib/op/math/uint256/LibOpUint256Add.sol`
- A95: `src/lib/op/math/uint256/LibOpUint256Div.sol`
- A96: `src/lib/op/math/uint256/LibOpUint256Mul.sol`
- A97: `src/lib/op/math/uint256/LibOpUint256Sub.sol`
- A98: `src/lib/op/math/uint256/LibOpUint256MaxValue.sol`
- A99: `src/lib/op/math/uint256/LibOpUint256Power.sol`
- A100: `src/lib/op/store/LibOpGet.sol`
- A101: `src/lib/op/store/LibOpSet.sol`

## Verification Summary

### Integrity Functions

All integrity functions correctly declare inputs and outputs:

- 1-input, 1-output: abs, ceil, exp, exp2, floor, frac, headroom, inv, sqrt (all return (1,1))
- 2-input, 1-output (fixed): avg, gm, pow (all return (2,1))
- N-ary (min 2 inputs), 1-output: add, div, max, min, mul, sub, uint256-add, uint256-div, uint256-mul, uint256-sub, uint256-pow (all decode operand and floor to 2)
- 0-input, 1-output (constants): e, max-negative-value, max-positive-value, min-negative-value, min-positive-value, uint256-max-value (all return (0,1))
- 3-input, 1-output: exponential-growth, linear-growth (both return (3,1))
- 2-input, 0-output: set (returns (2,0))
- 1-input, 1-output: get (returns (1,1))

### Stack Pointer Arithmetic

All `run` functions correctly advance and rewind the stack pointer:

- 1-input/1-output ops: read from stackTop, write back to stackTop. No pointer movement. Correct.
- 2-input/1-output (fixed) ops: read at stackTop and stackTop+0x20, advance by 0x20, write at new stackTop. Net: -1 input slot. Correct.
- N-ary ops: read first two, advance by 0x40, loop reads advance by 0x20 each, then rewind by 0x20 for the single output. Net: consumes N slots, produces 1. Correct.
- 0-input/1-output ops: rewind stackTop by 0x20, write value. Correct.
- 3-input/1-output ops: read at 0, 0x20, advance by 0x40, read at new stackTop (3rd item). Write at current position. Net: 3 consumed, 1 produced. Correct.
- set (2-input/0-output): read at 0 and 0x20, advance by 0x40. No write back. Correct.
- get (1-input/1-output): read at stackTop, write at stackTop. Correct.

### Math Operations

- **abs**: calls `LibDecimalFloat.abs()`. Correct.
- **add/sub/mul/div**: use `LibDecimalFloatImplementation.add/sub/mul/div` with unpacked coefficients/exponents, then `packLossy`. Correct.
- **avg**: `(a + b) / 2` using `FLOAT_TWO`. Correct.
- **ceil/floor/frac**: delegate to corresponding `LibDecimalFloat` methods. Correct.
- **e**: pushes `FLOAT_E` constant. Correct.
- **exp**: computes `e^x` via `FLOAT_E.pow(x)`. Correct.
- **exp2**: computes `2^x` via `FLOAT_TWO.pow(x)`. Correct.
- **headroom**: computes `ceil(x) - x`, returns 1 when result is zero (i.e., x is integer). Matches NatSpec. Correct.
- **inv**: calls `LibDecimalFloat.inv()` (1/x). Correct.
- **max/min**: N-ary, use `LibDecimalFloat.max/min`. Correct.
- **gm**: `sign * sqrt(|a| * |b|)` where sign is negative when exactly one input is negative. Uses `aNeg != bNeg` for XOR check. Correct.
- **pow**: `a.pow(b)`. Correct.
- **sqrt**: `a.sqrt()` using log tables. Correct.

### Growth Formulas

- **exponential-growth**: NatSpec says `base(1 + rate)^t`. Implementation: `base.mul(rate.add(FLOAT_ONE).pow(t))` = `base * (1 + rate)^t`. Correct.
- **linear-growth**: NatSpec says `base + rate * t`. Implementation: `base.add(rate.mul(t))`. Correct.

### Uint256 Operations

- **uint256-add/sub/mul/div/pow**: use Solidity 0.8.x checked arithmetic (`+=`, `-=`, `*=`, `/=`, `**`). Correct.
- **uint256-max-value**: pushes `type(uint256).max`. Correct.

### Boundary Value Constants

Verified reference implementations match library constants:

- `FLOAT_MAX_POSITIVE_VALUE` = `packLossless(type(int224).max, type(int32).max)`: constant `0x7fffffff7fff...ffff`. Verified.
- `FLOAT_MIN_POSITIVE_VALUE` = `packLossless(1, type(int32).min)`: constant `0x8000000000...0001`. Verified.
- `FLOAT_MAX_NEGATIVE_VALUE` = `packLossless(-1, type(int32).min)`: constant `0x80000000ffff...ffff`. Verified.
- `FLOAT_MIN_NEGATIVE_VALUE` = `packLossless(type(int224).min, type(int32).max)`: constant `0x7fffffff8000...0000`. Verified.

### Reference Functions

All `referenceFn` implementations use the same mathematical operations as their corresponding `run` functions.

### Store Operations

- **get**: checks memory KV cache first, falls back to external store on cache miss. Caches fetched values. Reference matches run.
- **set**: writes key/value to memory KV store. Reference matches run.

## Findings

### A73-P5-1: INFO - LibOpDiv referenceFn sentinel value is overwritten

**File**: `src/lib/op/math/LibOpDiv.sol`, lines 92-101

The `referenceFn` attempts to set a collision-resistant sentinel value when a divisor is zero (`a = Float.wrap(bytes32(keccak256(...)))`), then `break`s out of the loop. However, after the loop, the code unconditionally runs `(a, lossless) = LibDecimalFloat.packLossy(signedCoefficient, exponent)`, which overwrites the sentinel. The comment at line 90-91 says "We don't want the real implementation to fail to throw its own error and also produce the same result, so a needs to have some collision resistant value" -- but this intent is defeated by the overwrite.

This is test-only code. In practice, the float library's `div` will revert on divide-by-zero, so the test harness catches the revert before comparing return values. The sentinel logic is dead code.

### A80-P5-1: INFO - LibOpHeadroom referenceFn comment mismatch

**File**: `src/lib/op/math/LibOpHeadroom.sol`, line 54

The comment says "The headroom is 1 - frac(x)" but the code implements `ceil(x).sub(x)`. While these are mathematically equivalent for all values, the comment does not describe what the code literally does. This could be confusing for future readers.
