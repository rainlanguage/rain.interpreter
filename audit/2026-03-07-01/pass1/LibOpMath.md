# Pass 1: Security Review of Math Opcode Libraries

**Reviewer:** A20
**Date:** 2026-03-07
**Scope:** 25 files in `src/lib/op/math/` and `src/lib/op/math/growth/`

## Evidence of Thorough Reading

### 1. LibOpAbs.sol
- Library: `LibOpAbs` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 19
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 28
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 44

### 2. LibOpAdd.sol
- Library: `LibOpAdd` (line 15)
- `integrity(IntegrityCheckState memory, OperandV2 operand)` -- line 22
- `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` -- line 33
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 76

### 3. LibOpAvg.sol
- Library: `LibOpAvg` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 19
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 28
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 47

### 4. LibOpCeil.sol
- Library: `LibOpCeil` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 19
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 28
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 44

### 5. LibOpDiv.sol
- Library: `LibOpDiv` (line 14)
- `integrity(IntegrityCheckState memory, OperandV2 operand)` -- line 21
- `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` -- line 33
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 74

### 6. LibOpE.sol
- Library: `LibOpE` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 17
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 24
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 35

### 7. LibOpExp.sol
- Library: `LibOpExp` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 19
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 28
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 44

### 8. LibOpExp2.sol
- Library: `LibOpExp2` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 19
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 28
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 45

### 9. LibOpFloor.sol
- Library: `LibOpFloor` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 19
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 28
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 44

### 10. LibOpFrac.sol
- Library: `LibOpFrac` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 19
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 28
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 44

### 11. LibOpGm.sol
- Library: `LibOpGm` (line 15)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 21
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 31
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 55

### 12. LibOpHeadroom.sol
- Library: `LibOpHeadroom` (line 14)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 20
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 30
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 49

### 13. LibOpInv.sol
- Library: `LibOpInv` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 19
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 28
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 44

### 14. LibOpMax.sol
- Library: `LibOpMax` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2 operand)` -- line 20
- `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` -- line 32
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 67

### 15. LibOpMaxNegativeValue.sol
- Library: `LibOpMaxNegativeValue` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 19
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 26
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 37

### 16. LibOpMaxPositiveValue.sol
- Library: `LibOpMaxPositiveValue` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 19
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 26
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 37

### 17. LibOpMin.sol
- Library: `LibOpMin` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2 operand)` -- line 20
- `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` -- line 32
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 68

### 18. LibOpMinNegativeValue.sol
- Library: `LibOpMinNegativeValue` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 19
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 26
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 37

### 19. LibOpMinPositiveValue.sol
- Library: `LibOpMinPositiveValue` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 19
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 26
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 37

### 20. LibOpMul.sol
- Library: `LibOpMul` (line 14)
- `integrity(IntegrityCheckState memory, OperandV2 operand)` -- line 21
- `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` -- line 32
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 74

### 21. LibOpPower.sol
- Library: `LibOpPower` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 19
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 28
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 47

### 22. LibOpSqrt.sol
- Library: `LibOpSqrt` (line 13)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 19
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 28
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 44

### 23. LibOpSub.sol
- Library: `LibOpSub` (line 14)
- `integrity(IntegrityCheckState memory, OperandV2 operand)` -- line 21
- `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` -- line 33
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 75

### 24. LibOpExponentialGrowth.sol
- Library: `LibOpExponentialGrowth` (line 14)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 20
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 28
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 49

### 25. LibOpLinearGrowth.sol
- Library: `LibOpLinearGrowth` (line 14)
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 20
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 28
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 50

## Security Review Checklist

### Memory Safety in Assembly
All 25 files use `assembly ("memory-safe")` blocks exclusively. The assembly operations are limited to:
- `mload(stackTop)` / `mload(add(stackTop, 0x20))` -- reading from the interpreter's pre-allocated stack
- `mstore(stackTop, value)` -- writing results back to the stack
- `stackTop := add(stackTop, 0x20)` / `stackTop := sub(stackTop, 0x20)` -- pointer arithmetic within the stack

No free memory pointer manipulation, no `sstore`, no `call`/`delegatecall`, no `create`. The `memory-safe` annotations are correct.

### Stack Pointer Arithmetic (run vs integrity consistency)

**Unary ops** (abs, ceil, floor, frac, headroom, inv, exp, exp2, sqrt): integrity=(1,1), run reads from stackTop and writes back to stackTop, returns stackTop. Net stack change: 0. Consistent.

**Binary ops** (avg, gm, power): integrity=(2,1), run reads 2 values, advances stackTop by 0x20, writes result to new stackTop. Net stack change: +1 slot consumed. Consistent.

**Constant ops** (e, max-positive-value, max-negative-value, min-positive-value, min-negative-value): integrity=(0,1), run decrements stackTop by 0x20 and writes. Net: 1 slot produced. Consistent.

**Variable-arity ops** (add, sub, mul, div, max, min): integrity reads `(operand >> 0x10) & 0x0F`, clamps to minimum 2. run always reads first 2 values (0x40 advance), then loops for additional values. After loop, decrements stackTop by 0x20 and writes result. Net consumption = inputs - 1 slots. The while loop guard `i < inputs` with `i` starting at 2 ensures that when operand encodes 0 or 1, no extra reads occur, matching the clamped integrity value of 2.

**Growth ops** (linear-growth, exponential-growth): integrity=(3,1), run reads 3 values (0x60 total stack consumed), writes 1 result. Advance is 0x40 (for first two), then read third at new stackTop, write result at same location. Net: 2 slots consumed. Consistent.

### Operand Validation
Variable-arity opcodes extract input count via `(operand >> 0x10) & 0x0F`, which is a 4-bit field (range 0-15). The clamping `inputs > 1 ? inputs : 2` handles the lower bound. The upper bound of 15 is enforced by the bit mask. No unchecked operand values.

Fixed-arity opcodes ignore the operand entirely. No validation needed.

### Arithmetic Safety
All math operations delegate to `LibDecimalFloat` / `LibDecimalFloatImplementation` which handle overflow/underflow internally with reverts (no NaN or Infinity -- division by zero reverts). The `unchecked { i++; }` in variable-arity loops is safe because `i` is bounded by `inputs <= 15` and starts at 2.

### Custom Errors
No string-based reverts in any of the 25 files. All error conditions are delegated to the `LibDecimalFloat` library which uses custom error types (`ExponentOverflow`, `CoefficientOverflow`, `ZeroNegativePower`, `PowNegativeBase`, etc.).

### Reference Function Consistency
All `referenceFn` implementations mirror the logic in `run()` using the same library calls, ensuring differential testing validity.

## Findings

No findings.

All 25 math opcode files follow consistent, well-structured patterns:
- Integrity declarations match actual stack consumption in run()
- Assembly blocks are minimal and correctly annotated as memory-safe
- Arithmetic safety is delegated to the audited LibDecimalFloat library
- Variable-arity operand decoding is correctly bounded (4-bit mask, minimum clamp)
- No custom error or revert-string violations
- Stack pointer arithmetic is verified correct for all arity patterns (unary, binary, ternary, variable, constant)
