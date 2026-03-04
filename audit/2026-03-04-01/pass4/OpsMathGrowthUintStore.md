# Pass 4 Findings: Math, Growth, Uint256, Store Ops (A69-A101)

## Evidence Summary

### Float math ops (A69-A91)

**Single-input unary ops (1 in, 1 out):** LibOpAbs (abs), LibOpCeil (ceil), LibOpExp (exp, `view`), LibOpExp2 (exp2, `view`), LibOpFloor (floor), LibOpFrac (frac), LibOpHeadroom (headroom), LibOpInv (inv), LibOpSqrt (sqrt, `view`).

**Two-input binary ops (2 in, 1 out):** LibOpAvg (avg), LibOpGm (gm, `view`), LibOpPower (pow, `view`).

**N-ary ops (2+ in, 1 out):** LibOpAdd (add), LibOpDiv (div), LibOpMax (max), LibOpMin (min), LibOpMul (mul), LibOpSub (sub).

**Zero-input constant ops (0 in, 1 out):** LibOpE (e), LibOpMaxNegativeValue, LibOpMaxPositiveValue, LibOpMinNegativeValue, LibOpMinPositiveValue.

### Growth ops (A92-A93)

LibOpExponentialGrowth (3 in, 1 out, `view`), LibOpLinearGrowth (3 in, 1 out, `pure`).

### Uint256 ops (A94-A99)

**N-ary (2+ in, 1 out):** LibOpUint256Add, LibOpUint256Div, LibOpUint256Mul, LibOpUint256Power, LibOpUint256Sub.

**Zero-input constant (0 in, 1 out):** LibOpUint256MaxValue.

### Store ops (A100-A101)

LibOpGet (1 in, 1 out, `view`), LibOpSet (2 in, 0 out, `pure`).

---

## Findings

### A83-P4-1 (INFO) Unused `using` directive in LibOpMaxNegativeValue

**File:** `src/lib/op/math/LibOpMaxNegativeValue.sol`, line 14

`using LibDecimalFloat for Float;` is declared but no method is ever called on a `Float` value through this directive. The library only accesses `LibDecimalFloat.FLOAT_MAX_NEGATIVE_VALUE` (a constant) and `LibDecimalFloat.packLossless(...)` (a static call). Neither requires the `using` directive.

### A84-P4-1 (INFO) Unused `using` directive in LibOpMaxPositiveValue

**File:** `src/lib/op/math/LibOpMaxPositiveValue.sol`, line 14

Same issue as A83-P4-1. `using LibDecimalFloat for Float;` is declared but never used. Only `LibDecimalFloat.FLOAT_MAX_POSITIVE_VALUE` and `LibDecimalFloat.packLossless(...)` are accessed.

### A86-P4-1 (INFO) Unused `using` directive in LibOpMinNegativeValue

**File:** `src/lib/op/math/LibOpMinNegativeValue.sol`, line 14

Same issue as A83-P4-1.

### A87-P4-1 (INFO) Unused `using` directive in LibOpMinPositiveValue

**File:** `src/lib/op/math/LibOpMinPositiveValue.sol`, line 14

Same issue as A83-P4-1.

### A85-P4-1 (INFO) Misleading `unchecked` block and comment in LibOpMin.referenceFn

**File:** `src/lib/op/math/LibOpMin.sol`, lines 73-82

The `referenceFn` wraps its body in `unchecked { }` with the comment "Unchecked so that when we assert that an overflow error is thrown, we see the revert from the real function and not the reference function." The `min` operation cannot overflow, so this comment is misleading and the `unchecked` block is unnecessary. By contrast, `LibOpMax.referenceFn` (A82) does not use an `unchecked` block, creating an inconsistency between the two structurally identical N-ary ops.

### A96-P4-1 (INFO) NatSpec opcode name mismatch in LibOpUint256MaxValue.run

**File:** `src/lib/op/math/uint256/LibOpUint256MaxValue.sol`, line 20

The `run` NatSpec says `` @notice `max-uint256` opcode `` but the integrity NatSpec on line 13 says `` `uint256-max-value` `` and the library is named `LibOpUint256MaxValue`. The `run` NatSpec should use `uint256-max-value` for consistency with the integrity NatSpec and library name.
