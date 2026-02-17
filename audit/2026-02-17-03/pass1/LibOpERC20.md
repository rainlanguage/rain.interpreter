# Pass 1 (Security) — ERC20 Opcode Libraries

## Files Reviewed

1. `src/lib/op/erc20/LibOpERC20Allowance.sol`
2. `src/lib/op/erc20/LibOpERC20BalanceOf.sol`
3. `src/lib/op/erc20/LibOpERC20TotalSupply.sol`
4. `src/lib/op/erc20/uint256/LibOpUint256ERC20Allowance.sol`
5. `src/lib/op/erc20/uint256/LibOpUint256ERC20BalanceOf.sol`
6. `src/lib/op/erc20/uint256/LibOpUint256ERC20TotalSupply.sol`

---

## Evidence of Thorough Reading

### 1. LibOpERC20Allowance.sol

- **Library name**: `LibOpERC20Allowance` (line 16)
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 18, returns `(3, 1)`
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 25, `internal view`
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 64, `internal view`
- **Errors/Events/Structs**: None defined in this file

### 2. LibOpERC20BalanceOf.sol

- **Library name**: `LibOpERC20BalanceOf` (line 16)
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 18, returns `(2, 1)`
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 25, `internal view`
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 51, `internal view`
- **Errors/Events/Structs**: None defined in this file

### 3. LibOpERC20TotalSupply.sol

- **Library name**: `LibOpERC20TotalSupply` (line 16)
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 18, returns `(1, 1)`
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 25, `internal view`
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 48, `internal view`
- **Errors/Events/Structs**: None defined in this file

### 4. LibOpUint256ERC20Allowance.sol

- **Library name**: `LibOpUint256ERC20Allowance` (line 13)
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 15, returns `(3, 1)`
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 22, `internal view`
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 44, `internal view`
- **Errors/Events/Structs**: None defined in this file

### 5. LibOpUint256ERC20BalanceOf.sol

- **Library name**: `LibOpUint256ERC20BalanceOf` (line 13)
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 15, returns `(2, 1)`
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 22, `internal view`
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 41, `internal view`
- **Errors/Events/Structs**: None defined in this file

### 6. LibOpUint256ERC20TotalSupply.sol

- **Library name**: `LibOpUint256ERC20TotalSupply` (line 13)
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 15, returns `(1, 1)`
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 22, `internal view`
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 38, `internal view`
- **Errors/Events/Structs**: None defined in this file

---

## Security Findings

### Finding 1 — INFO: External calls to untrusted token addresses are by design

**Files**: All six files

**Description**: Every `run` function makes external calls (`allowance`, `balanceOf`, `totalSupply`, `decimals`) to addresses supplied by the Rainlang author on the stack. A malicious or nonstandard token contract could return arbitrary values or revert in unexpected ways. However, because the `eval4` entry point is `view`, reentrancy resulting in state mutation is not possible. The external calls cannot modify the interpreter's state. The code comments explicitly acknowledge this as the Rainlang author's responsibility. No action needed.

**Severity**: INFO

---

### Finding 2 — LOW: `decimals()` call can revert for ERC20 tokens that do not implement ERC20Metadata

**Files**: `LibOpERC20Allowance.sol` (line 43), `LibOpERC20BalanceOf.sol` (line 40), `LibOpERC20TotalSupply.sol` (line 37)

**Description**: The float-converting variants (`erc20-allowance`, `erc20-balance-of`, `erc20-total-supply`) call `IERC20Metadata(token).decimals()` to determine the number of decimals for float conversion. The `decimals()` function is an OPTIONAL extension of the ERC20 standard (EIP-20 explicitly states it is optional). Tokens that do not implement it (e.g., MKR, SAI) will cause an unconditional revert. The code acknowledges this with the comment "This can fail as `decimals` is an OPTIONAL part of the ERC20 standard." The uint256 variants do not have this issue, as they return raw values without float conversion. This is a design decision, not a bug — the uint256 variants exist as alternatives for such tokens.

**Severity**: LOW

---

### Finding 3 — INFO: Lossy float conversion for allowance is intentional

**File**: `LibOpERC20Allowance.sol` (line 55)

**Description**: `erc20-allowance` uses `fromFixedDecimalLossyPacked` while `erc20-balance-of` and `erc20-total-supply` use `fromFixedDecimalLosslessPacked`. The lossy variant is explicitly chosen for allowance because `type(uint256).max` (infinite approval) cannot be represented losslessly in a decimal float. The code contains a detailed comment (lines 45-53) explaining this design decision. This is correct behavior: using the lossless variant would brick evaluations that read infinite approvals. No action needed.

**Severity**: INFO

---

### Finding 4 — INFO: Assembly blocks are memory-safe and stack pointer arithmetic is correct

**Files**: All six files

**Description**: All assembly blocks are annotated `("memory-safe")`. Verification of correctness:

- **3-input opcodes** (Allowance variants): Read from `stackTop`, `stackTop+0x20`, and `stackTop+0x40`. Advance `stackTop` by `0x40` (2 slots). Write 1 output at the new `stackTop`. Net: 3 consumed, 1 produced = net -2 slots. `stackTop` advances by `0x40`. Matches integrity `(3, 1)`.

- **2-input opcodes** (BalanceOf variants): Read from `stackTop` and `stackTop+0x20`. Advance `stackTop` by `0x20` (1 slot). Write 1 output at the new `stackTop`. Net: 2 consumed, 1 produced = net -1 slot. `stackTop` advances by `0x20`. Matches integrity `(2, 1)`.

- **1-input opcodes** (TotalSupply variants): Read from `stackTop`. No `stackTop` change. Write 1 output at `stackTop`. Net: 1 consumed, 1 produced = net 0. `stackTop` unchanged. Matches integrity `(1, 1)`.

All assembly blocks only read from and write to stack memory owned by the opcode (the consumed input slots and the output slot). No out-of-bounds access. The `memory-safe` annotation is correct.

**Severity**: INFO

---

### Finding 5 — INFO: Integrity inputs/outputs correctly match `run` behavior in all six files

**Files**: All six files

**Description**: Verified that every `integrity` function declares the exact number of inputs consumed and outputs produced by its corresponding `run` function. See Finding 4 for the detailed arithmetic. No mismatches found.

**Severity**: INFO

---

### Finding 6 — INFO: No unchecked arithmetic issues

**Files**: All six files

**Description**: The only arithmetic in these files is stack pointer manipulation inside `assembly` blocks (which is inherently unchecked but correct — see Finding 4). The `uint160` truncations are intentional address narrowing. The float conversion functions (`fromFixedDecimalLosslessPacked`, `fromFixedDecimalLossyPacked`) are provided by the `rain.math.float` library and handle overflow internally. No unchecked Solidity arithmetic is present.

**Severity**: INFO

---

### Finding 7 — INFO: No custom errors or string reverts in these files

**Files**: All six files

**Description**: None of the six files define or use any `revert` statements (neither custom errors nor string messages). Reverts can only occur from the external ERC20 calls themselves or from the `LibDecimalFloat` conversion functions. This is correct — there are no conditions in these opcodes that warrant custom error handling beyond what the external calls and library functions already provide.

**Severity**: INFO

---

### Finding 8 — INFO: NatSpec title mismatch in LibOpUint256ERC20BalanceOf.sol

**File**: `src/lib/op/erc20/uint256/LibOpUint256ERC20BalanceOf.sol` (line 12)

**Description**: The `@title` NatSpec says `OpUint256ERC20BalanceOf` but the actual library name is `LibOpUint256ERC20BalanceOf` (missing the `Lib` prefix). This is a documentation inconsistency, not a security issue. All other files in this group have the correct `@title` matching the library name.

**Severity**: INFO

---

## Summary

No CRITICAL, HIGH, or MEDIUM findings were identified in these six files. The ERC20 opcode libraries follow a consistent, well-structured pattern. The key security properties are:

1. **Reentrancy**: Not exploitable because the entire eval chain is `view`, preventing state mutation.
2. **Stack safety**: All assembly pointer arithmetic is correct and matches declared integrity.
3. **Memory safety**: All assembly blocks correctly stay within owned stack memory.
4. **External call trust**: Delegated to the Rainlang author by design, with uint256 variants available for tokens lacking `decimals()`.
5. **Float conversion**: Lossy conversion for allowance is a deliberate, well-documented design choice to handle infinite approvals.
