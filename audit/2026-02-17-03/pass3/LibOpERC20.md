# Pass 3: Documentation — LibOpHash, LibOpERC20*, LibOpUint256ERC20*

Agent: A13

---

## File 1: `src/lib/op/crypto/LibOpHash.sol`

### Evidence of reading

- **Library**: `LibOpHash` (line 12)
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2 operand)` — line 14
  - `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` — line 22
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 33
- **Errors/Events/Structs**: None

### Findings

**A13-1 [LOW]** — `integrity` missing `@param` and `@return` NatSpec

`integrity` (line 14) has a `///` description but no `@param` tags for its two parameters (`IntegrityCheckState`, `OperandV2 operand`) and no `@return` tags for its two return values (inputs count, outputs count).

**A13-2 [LOW]** — `run` missing `@param` and `@return` NatSpec

`run` (line 22) has a `///` description but no `@param` tags for its three parameters (`InterpreterState`, `OperandV2 operand`, `Pointer stackTop`) and no `@return` tag for its return value (`Pointer`).

**A13-3 [LOW]** — `referenceFn` missing `@param` and `@return` NatSpec

`referenceFn` (line 33) has a `///` description but no `@param` tags for its three parameters and no `@return` tag for its return value.

---

## File 2: `src/lib/op/erc20/LibOpERC20Allowance.sol`

### Evidence of reading

- **Library**: `LibOpERC20Allowance` (line 16)
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 18
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 25
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 64
- **Errors/Events/Structs**: None

### Findings

**A13-4 [LOW]** — `integrity` missing `@param` and `@return` NatSpec

`integrity` (line 18) has a `///` description but no `@param` tags for its two parameters and no `@return` tags for its two return values.

**A13-5 [LOW]** — `run` missing `@param` and `@return` NatSpec

`run` (line 25) has a `///` description but no `@param` tags for its three parameters and no `@return` tag for its return value.

**A13-6 [LOW]** — `referenceFn` missing `@param` and `@return` NatSpec

`referenceFn` (line 64) has a `///` description but no `@param` tags for its three parameters and no `@return` tag for its return value.

---

## File 3: `src/lib/op/erc20/LibOpERC20BalanceOf.sol`

### Evidence of reading

- **Library**: `LibOpERC20BalanceOf` (line 16)
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 18
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 25
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 51
- **Errors/Events/Structs**: None

### Findings

**A13-7 [LOW]** — `integrity` missing `@param` and `@return` NatSpec

`integrity` (line 18) has a `///` description but no `@param` tags for its two parameters and no `@return` tags for its two return values.

**A13-8 [LOW]** — `run` missing `@param` and `@return` NatSpec

`run` (line 25) has a `///` description but no `@param` tags for its three parameters and no `@return` tag for its return value.

**A13-9 [LOW]** — `referenceFn` missing `@param` and `@return` NatSpec

`referenceFn` (line 51) has a `///` description but no `@param` tags for its three parameters and no `@return` tag for its return value.

---

## File 4: `src/lib/op/erc20/LibOpERC20TotalSupply.sol`

### Evidence of reading

- **Library**: `LibOpERC20TotalSupply` (line 16)
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 18
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 25
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 48
- **Errors/Events/Structs**: None

### Findings

**A13-10 [LOW]** — `integrity` missing `@param` and `@return` NatSpec

`integrity` (line 18) has a `///` description but no `@param` tags for its two parameters and no `@return` tags for its two return values.

**A13-11 [LOW]** — `run` missing `@param` and `@return` NatSpec

`run` (line 25) has a `///` description but no `@param` tags for its three parameters and no `@return` tag for its return value.

**A13-12 [LOW]** — `referenceFn` missing `@param` and `@return` NatSpec

`referenceFn` (line 48) has a `///` description but no `@param` tags for its three parameters and no `@return` tag for its return value.

---

## File 5: `src/lib/op/erc20/uint256/LibOpUint256ERC20Allowance.sol`

### Evidence of reading

- **Library**: `LibOpUint256ERC20Allowance` (line 13)
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 15
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 22
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 44
- **Errors/Events/Structs**: None

### Findings

**A13-13 [LOW]** — `integrity` missing `@param` and `@return` NatSpec

`integrity` (line 15) has a `///` description but no `@param` tags for its two parameters and no `@return` tags for its two return values.

**A13-14 [LOW]** — `run` missing `@param` and `@return` NatSpec

`run` (line 22) has a `///` description but no `@param` tags for its three parameters and no `@return` tag for its return value.

**A13-15 [LOW]** — `referenceFn` missing `@param` and `@return` NatSpec

`referenceFn` (line 44) has a `///` description but no `@param` tags for its three parameters and no `@return` tag for its return value.

---

## File 6: `src/lib/op/erc20/uint256/LibOpUint256ERC20BalanceOf.sol`

### Evidence of reading

- **Library**: `LibOpUint256ERC20BalanceOf` (line 13)
- **Title NatSpec**: `@title OpUint256ERC20BalanceOf` (line 11) — mismatch with actual library name `LibOpUint256ERC20BalanceOf`
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 15
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 22
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 41
- **Errors/Events/Structs**: None

### Findings

**A13-16 [LOW]** — `@title` NatSpec does not match library name

Line 11: `@title OpUint256ERC20BalanceOf` but the library name is `LibOpUint256ERC20BalanceOf` (line 13). The `Lib` prefix is missing from the `@title` tag. All other files in this set correctly include the `Lib` prefix in their `@title`.

**A13-17 [LOW]** — `integrity` missing `@param` and `@return` NatSpec

`integrity` (line 15) has a `///` description but no `@param` tags for its two parameters and no `@return` tags for its two return values.

**A13-18 [LOW]** — `run` missing `@param` and `@return` NatSpec

`run` (line 22) has a `///` description but no `@param` tags for its three parameters and no `@return` tag for its return value.

**A13-19 [LOW]** — `referenceFn` missing `@param` and `@return` NatSpec

`referenceFn` (line 41) has a `///` description but no `@param` tags for its three parameters and no `@return` tag for its return value.

---

## File 7: `src/lib/op/erc20/uint256/LibOpUint256ERC20TotalSupply.sol`

### Evidence of reading

- **Library**: `LibOpUint256ERC20TotalSupply` (line 13)
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 15
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 22
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 38
- **Errors/Events/Structs**: None

### Findings

**A13-20 [LOW]** — `integrity` missing `@param` and `@return` NatSpec

`integrity` (line 15) has a `///` description but no `@param` tags for its two parameters and no `@return` tags for its two return values.

**A13-21 [LOW]** — `run` missing `@param` and `@return` NatSpec

`run` (line 22) has a `///` description but no `@param` tags for its three parameters and no `@return` tag for its return value.

**A13-22 [LOW]** — `referenceFn` missing `@param` and `@return` NatSpec

`referenceFn` (line 38) has a `///` description but no `@param` tags for its three parameters and no `@return` tag for its return value.

---

## Summary

| ID | Severity | File | Description |
|---|---|---|---|
| A13-1 | LOW | LibOpHash.sol | `integrity` missing `@param`/`@return` |
| A13-2 | LOW | LibOpHash.sol | `run` missing `@param`/`@return` |
| A13-3 | LOW | LibOpHash.sol | `referenceFn` missing `@param`/`@return` |
| A13-4 | LOW | LibOpERC20Allowance.sol | `integrity` missing `@param`/`@return` |
| A13-5 | LOW | LibOpERC20Allowance.sol | `run` missing `@param`/`@return` |
| A13-6 | LOW | LibOpERC20Allowance.sol | `referenceFn` missing `@param`/`@return` |
| A13-7 | LOW | LibOpERC20BalanceOf.sol | `integrity` missing `@param`/`@return` |
| A13-8 | LOW | LibOpERC20BalanceOf.sol | `run` missing `@param`/`@return` |
| A13-9 | LOW | LibOpERC20BalanceOf.sol | `referenceFn` missing `@param`/`@return` |
| A13-10 | LOW | LibOpERC20TotalSupply.sol | `integrity` missing `@param`/`@return` |
| A13-11 | LOW | LibOpERC20TotalSupply.sol | `run` missing `@param`/`@return` |
| A13-12 | LOW | LibOpERC20TotalSupply.sol | `referenceFn` missing `@param`/`@return` |
| A13-13 | LOW | LibOpUint256ERC20Allowance.sol | `integrity` missing `@param`/`@return` |
| A13-14 | LOW | LibOpUint256ERC20Allowance.sol | `run` missing `@param`/`@return` |
| A13-15 | LOW | LibOpUint256ERC20Allowance.sol | `referenceFn` missing `@param`/`@return` |
| A13-16 | LOW | LibOpUint256ERC20BalanceOf.sol | `@title` missing `Lib` prefix vs library name |
| A13-17 | LOW | LibOpUint256ERC20BalanceOf.sol | `integrity` missing `@param`/`@return` |
| A13-18 | LOW | LibOpUint256ERC20BalanceOf.sol | `run` missing `@param`/`@return` |
| A13-19 | LOW | LibOpUint256ERC20BalanceOf.sol | `referenceFn` missing `@param`/`@return` |
| A13-20 | LOW | LibOpUint256ERC20TotalSupply.sol | `integrity` missing `@param`/`@return` |
| A13-21 | LOW | LibOpUint256ERC20TotalSupply.sol | `run` missing `@param`/`@return` |
| A13-22 | LOW | LibOpUint256ERC20TotalSupply.sol | `referenceFn` missing `@param`/`@return` |

Total findings: 22 (all LOW)

Note: All seven files follow a consistent pattern where every function has a `///` description line that accurately describes the function's purpose, but none include `@param` or `@return` tags. The descriptions themselves are accurate to the implementations. The one non-parameter finding (A13-16) is a `@title` tag inconsistency.
