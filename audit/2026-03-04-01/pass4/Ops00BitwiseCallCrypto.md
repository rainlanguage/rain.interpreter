# Pass 4 Findings: Ops 00 / Bitwise / Call / Crypto

## Evidence Inventory

### A30: `src/lib/op/00/LibOpConstant.sol`
- Library: `LibOpConstant`
- Functions: `integrity` (L21), `run` (L37), `referenceFn` (L52)
- Imports: `OutOfBoundsConstantRead`, `IntegrityCheckState`, `OperandV2`, `StackItem`, `InterpreterState`, `Pointer`

### A31: `src/lib/op/00/LibOpContext.sol`
- Library: `LibOpContext`
- Functions: `integrity` (L16), `run` (L28), `referenceFn` (L47)
- Imports: `Pointer`, `OperandV2`, `StackItem`, `InterpreterState`, `IntegrityCheckState`

### A32: `src/lib/op/00/LibOpExtern.sol`
- Library: `LibOpExtern`
- Functions: `integrity` (L29), `run` (L49), `referenceFn` (L102)
- Errors used: `NotAnExternContract`, `BadOutputsLength`
- Imports: `NotAnExternContract`, `IntegrityCheckState`, `OperandV2`, `InterpreterState`, `Pointer`, `IInterpreterExternV4`, `ExternDispatchV2`, `EncodedExternDispatchV2`, `StackItem`, `LibExtern`, `LibBytes32Array`, `ERC165Checker`, `BadOutputsLength`

### A33: `src/lib/op/00/LibOpStack.sol`
- Library: `LibOpStack`
- Functions: `integrity` (L21), `run` (L41), `referenceFn` (L58)
- Errors used: `OutOfBoundsStackRead`
- Imports: `Pointer`, `InterpreterState`, `IntegrityCheckState`, `OperandV2`, `StackItem`, `OutOfBoundsStackRead`

### A34: `src/lib/op/LibAllStandardOps.sol`
- Library: `LibAllStandardOps`
- Constants: `ALL_STANDARD_OPS_LENGTH = 72` (L105)
- Functions: `authoringMetaV2` (L120), `literalParserFunctionPointers` (L344), `operandHandlerFunctionPointers` (L377), `integrityFunctionPointers` (L549), `opcodeFunctionPointers` (L653)
- Error used: `BadDynamicLength`

### A35: `src/lib/op/bitwise/LibOpBitwiseAnd.sol`
- Library: `LibOpBitwiseAnd`
- Functions: `integrity` (L16), `run` (L24), `referenceFn` (L36)

### A36: `src/lib/op/bitwise/LibOpBitwiseCountOnes.sol`
- Library: `LibOpBitwiseCountOnes`
- Functions: `integrity` (L19), `run` (L27), `referenceFn` (L44)
- Imports: `LibCtPop`

### A37: `src/lib/op/bitwise/LibOpBitwiseDecode.sol`
- Library: `LibOpBitwiseDecode`
- Functions: `integrity` (L20), `run` (L33), `referenceFn` (L65)
- Imports: `LibOpBitwiseEncode`

### A38: `src/lib/op/bitwise/LibOpBitwiseEncode.sol`
- Library: `LibOpBitwiseEncode`
- Functions: `integrity` (L19), `run` (L36), `referenceFn` (L76)
- Errors used: `ZeroLengthBitwiseEncoding`, `TruncatedBitwiseEncoding`

### A39: `src/lib/op/bitwise/LibOpBitwiseOr.sol`
- Library: `LibOpBitwiseOr`
- Functions: `integrity` (L16), `run` (L24), `referenceFn` (L36)

### A40: `src/lib/op/bitwise/LibOpBitwiseShiftLeft.sol`
- Library: `LibOpBitwiseShiftLeft`
- Functions: `integrity` (L19), `run` (L38), `referenceFn` (L49)
- Errors used: `UnsupportedBitwiseShiftAmount`

### A41: `src/lib/op/bitwise/LibOpBitwiseShiftRight.sol`
- Library: `LibOpBitwiseShiftRight`
- Functions: `integrity` (L19), `run` (L38), `referenceFn` (L49)
- Errors used: `UnsupportedBitwiseShiftAmount`

### A42: `src/lib/op/call/LibOpCall.sol`
- Library: `LibOpCall`
- Functions: `integrity` (L85), `run` (L122)
- Errors used: `CallOutputsExceedSource`
- Imports: `OperandV2`, `InterpreterState`, `IntegrityCheckState`, `Pointer`, `LibBytecode`, `LibEval`, `CallOutputsExceedSource`

### A43: `src/lib/op/crypto/LibOpHash.sol`
- Library: `LibOpHash`
- Functions: `integrity` (L17), `run` (L28), `referenceFn` (L41)

---

## Findings

### A42-P4-1 (LOW) -- `LibOpCall` does not mask `outputs` field from operand

**File:** `src/lib/op/call/LibOpCall.sol`, lines 87, 126

In both `integrity()` and `run()`, the `outputs` value is extracted as:
```solidity
uint256 outputs = uint256(OperandV2.unwrap(operand) >> 0x14);
```

This does not apply the `& 0x0F` mask that the analogous code in `LibOpExtern` uses at the same bit position (lines 39, 52, 108 of `LibOpExtern.sol`). Similarly, `inputs` in `LibOpCall.run()` at line 125 applies `& 0x0F`, but `outputs` at line 126 does not.

In practice this is safe because the eval loop (`LibEval.evalLoop`) masks the entire operand to `0xFFFFFF` (24 bits), so shifting right by 20 leaves at most 4 bits. However, the missing mask is a defensive-coding gap and a style inconsistency with `LibOpExtern`. If the operand source ever changes, this could silently accept garbage bits as a large `outputs` count.

### A42-P4-2 (INFO) -- `LibOpCall.integrity` NatSpec uses single `@return` for two return values

**File:** `src/lib/op/call/LibOpCall.sol`, line 84

The NatSpec for `integrity()` has:
```solidity
/// @return The number of inputs and outputs for stack tracking.
```

Every other `integrity()` function across this batch uses two separate `@return` tags:
```solidity
/// @return The number of inputs.
/// @return The number of outputs.
```

This is a NatSpec consistency issue. The compiler will associate the single `@return` only with the first return value, leaving the second undocumented.

### A32-P4-1 (INFO) -- Duplicate import path for `NotAnExternContract` and `BadOutputsLength`

**File:** `src/lib/op/00/LibOpExtern.sol`, lines 5, 19

Both `NotAnExternContract` and `BadOutputsLength` are imported from `"../../../error/ErrExtern.sol"` in separate import statements. These could be consolidated into a single import for consistency:
```solidity
import {NotAnExternContract, BadOutputsLength} from "../../../error/ErrExtern.sol";
```

### A31-P4-1 (INFO) -- Redundant explicit return in `LibOpContext.referenceFn`

**File:** `src/lib/op/00/LibOpContext.sol`, line 61

`referenceFn` declares a named return variable `outputs` and then explicitly returns it with `return outputs;` at line 61. Other `referenceFn` implementations that use named return variables (e.g., `LibOpConstant`, `LibOpExtern`, `LibOpStack`, `LibOpBitwiseEncode`, `LibOpHash`) omit the explicit `return` statement. The explicit return is redundant and inconsistent with the rest of the codebase.
