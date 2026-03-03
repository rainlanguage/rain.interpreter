# Pass 5: Correctness / Intent Verification -- Math Opcodes

**Audit agent**: A01
**Date**: 2026-03-03

Reviewed all 31 math opcode source files in `src/lib/op/math/` and their corresponding test files in `test/src/lib/op/math/`.

## Methodology

For each opcode library, verified:
1. The `run` function implements the mathematical operation its name claims.
2. The `referenceFn` matches the `run` behavior (same math library calls, same logic).
3. The `integrity` function correctly declares (inputs, outputs) matching what `run` actually consumes/produces.
4. Constants and formulas used are mathematically correct.
5. NatSpec matches actual behavior.
6. Test assertions verify the correct mathematical relationship.

All float opcodes use `rain.math.float/lib/LibDecimalFloat.sol` and `LibDecimalFloatImplementation` for decimal floating-point arithmetic. The uint256 opcodes use native Solidity arithmetic with overflow checks.

## Summary of Findings

| ID | Severity | File(s) | Description |
|----|----------|---------|-------------|
| P5-HEADROOM-01 | Informational | `src/lib/op/math/LibOpHeadroom.sol` | Headroom semantics for negative non-integers may be surprising to users (returns distance-to-ceiling, not distance-to-nearest-integer-toward-zero). Implementation is correct per NatSpec. |
| P5-EXPGROWTH-01 | Informational | `src/lib/op/math/growth/LibOpExponentialGrowth.sol`, `src/lib/op/math/growth/LibOpLinearGrowth.sol`, `src/lib/op/math/uint256/LibOpMaxUint256.sol` | `integrity` function NatSpec uses inline code style without explicit `@notice` tag. Per project convention, when other tags are present in the same library block, all entries should be explicitly tagged. |
| P5-UINT256POW-01 | Informational | `src/lib/op/math/uint256/LibOpUint256Pow.sol` | N-ary `uint256-power` applies left-to-right `((a**b)**c)` which is correct and tested but the NatSpec "raise x successively to N integers" could be clearer about associativity. |

## Per-Opcode Review

**All 31 opcodes verified correct.** For each:

- **LibOpAbs**: `run` calls `a.abs()`. Integrity (1,1). Correct.
- **LibOpAdd**: `run` calls `LibDecimalFloatImplementation.add` in loop. Integrity (max(operand,2),1). Correct.
- **LibOpAvg**: `run` computes `a.add(b).div(FLOAT_TWO)`. Integrity (2,1). Correct.
- **LibOpCeil**: `run` calls `a.ceil()`. Integrity (1,1). Correct.
- **LibOpDiv**: `run` calls `LibDecimalFloatImplementation.div` in loop. Integrity (max(operand,2),1). Correct.
- **LibOpE**: `run` pushes `FLOAT_E` (Euler's number). Integrity (0,1). Correct.
- **LibOpExp**: `run` computes `FLOAT_E.pow(a, LOG_TABLES_ADDRESS)` = e^a. Integrity (1,1). Correct.
- **LibOpExp2**: `run` computes `FLOAT_TWO.pow(a, LOG_TABLES_ADDRESS)` = 2^a. Integrity (1,1). Correct.
- **LibOpFloor**: `run` calls `a.floor()`. Integrity (1,1). Correct.
- **LibOpFrac**: `run` calls `a.frac()`. Integrity (1,1). Correct.
- **LibOpGm**: `run` computes `sign * sqrt(|a| * |b|)` via `a.abs().mul(b.abs()).pow(FLOAT_HALF, ...)`. Integrity (2,1). Correct.
- **LibOpHeadroom**: `run` computes `ceil(x) - x`, returns 1 if zero. Integrity (1,1). Correct per NatSpec. See P5-HEADROOM-01.
- **LibOpInv**: `run` calls `a.inv()` = 1/x. Integrity (1,1). Correct.
- **LibOpMax**: `run` calls `a.max(b)` in loop. Integrity (max(operand,2),1). Correct.
- **LibOpMin**: `run` calls `a.min(b)` in loop. Integrity (max(operand,2),1). Correct.
- **LibOpMul**: `run` calls `LibDecimalFloatImplementation.mul` in loop. Integrity (max(operand,2),1). Correct.
- **LibOpPow**: `run` computes `a.pow(b, LOG_TABLES_ADDRESS)`. Integrity (2,1). Correct.
- **LibOpSqrt**: `run` calls `a.sqrt(LOG_TABLES_ADDRESS)` = `a^0.5`. Integrity (1,1). Correct.
- **LibOpSub**: `run` calls `LibDecimalFloatImplementation.sub` in loop. Integrity (max(operand,2),1). Correct.
- **LibOpMaxNegativeValue**: `run` pushes `FLOAT_MAX_NEGATIVE_VALUE` = (-1, int32.min). Integrity (0,1). Correct.
- **LibOpMaxPositiveValue**: `run` pushes `FLOAT_MAX_POSITIVE_VALUE` = (int224.max, int32.max). Integrity (0,1). Correct.
- **LibOpMinNegativeValue**: `run` pushes `FLOAT_MIN_NEGATIVE_VALUE` = (int224.min, int32.max). Integrity (0,1). Correct.
- **LibOpMinPositiveValue**: `run` pushes `FLOAT_MIN_POSITIVE_VALUE` = (1, int32.min). Integrity (0,1). Correct.
- **LibOpExponentialGrowth**: `run` computes `base * (1 + rate)^t`. Integrity (3,1). Correct. See P5-EXPGROWTH-01.
- **LibOpLinearGrowth**: `run` computes `base + rate * t`. Integrity (3,1). Correct. See P5-EXPGROWTH-01.
- **LibOpMaxUint256**: `run` pushes `type(uint256).max`. Integrity (0,1). Correct. See P5-EXPGROWTH-01.
- **LibOpUint256Add**: `run` uses checked `+=`. Integrity (max(operand,2),1). Correct.
- **LibOpUint256Div**: `run` uses checked `/=`. Integrity (max(operand,2),1). Correct.
- **LibOpUint256Mul**: `run` uses checked `*=`. Integrity (max(operand,2),1). Correct.
- **LibOpUint256Pow**: `run` uses checked `**`. Integrity (max(operand,2),1). Left-to-right associativity. Correct. See P5-UINT256POW-01.
- **LibOpUint256Sub**: `run` uses checked `-=`. Integrity (max(operand,2),1). Correct.

## Cross-Cutting Observations

1. **All `run` / `referenceFn` pairs are consistent.** In every opcode, the `referenceFn` uses the same mathematical operations as `run`.

2. **All `integrity` functions correctly declare inputs/outputs.** The N-ary opcodes read the input count from operand bits [16:20] and enforce a minimum of 2.

3. **Float opcodes use `LibDecimalFloat` / `LibDecimalFloatImplementation` correctly.** The N-ary arithmetic opcodes unpack to coefficient/exponent, perform operations at extended precision, and repack with `packLossy`. None of the float opcodes use raw Solidity arithmetic on the Float type.

4. **Uint256 opcodes use native Solidity checked arithmetic.** The `run` functions use checked operators while `referenceFn` functions use `unchecked` blocks, correctly enabling the test harness to detect overflow/underflow errors.

5. **No PRBMath usage found.** The codebase uses `rain.math.float` for floating-point arithmetic, not PRBMath. The decimal float library uses a signed coefficient + exponent representation, not SD59x18/UD60x18 fixed-point.

6. **Test coverage is thorough.** Every opcode has: integrity fuzz test, runtime fuzz test via `opReferenceCheck`, concrete eval examples, bad-input tests, bad-output tests, and operand-disallowed tests.
