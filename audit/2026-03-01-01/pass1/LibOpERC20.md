# Pass 1 (Security) -- ERC20 Opcode Libraries

Agent: A20

## Files Reviewed

1. `src/lib/op/erc20/LibOpERC20Allowance.sol`
2. `src/lib/op/erc20/LibOpERC20BalanceOf.sol`
3. `src/lib/op/erc20/LibOpERC20TotalSupply.sol`
4. `src/lib/op/erc20/uint256/LibOpUint256ERC20Allowance.sol`
5. `src/lib/op/erc20/uint256/LibOpUint256ERC20BalanceOf.sol`
6. `src/lib/op/erc20/uint256/LibOpUint256ERC20TotalSupply.sol`

---

## Evidence of Thorough Reading

### 1. LibOpERC20Allowance.sol (124 lines)

- **Library name**: `LibOpERC20Allowance` (line 17)
- **Imports**: `IERC20`, `Pointer`, `IntegrityCheckState`, `OperandV2`, `InterpreterState`, `LibDecimalFloat`/`Float`, `LibTOFUTokenDecimals`, `StackItem`, `NotAnAddress` (lines 5-13)
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` -- line 21, `internal pure`, returns `(3, 1)`
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 30, `internal view`
    - Reads 3 stack values: `token`, `owner`, `spender` (lines 34-38)
    - Validates all three via `NotAnAddress` (lines 44, 47, 50)
    - Calls `IERC20.allowance` (line 55), then `safeDecimalsForTokenReadOnly` (line 60)
    - Uses `fromFixedDecimalLossyPacked` (line 72) -- lossy, with comment explaining infinite approvals (lines 62-70)
    - Stack pointer advances by 0x40 (line 37), writes result at new `stackTop` (line 75)
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 83, `internal view`
    - Same address validations (lines 88-99)
    - Calls `safeDecimalsForTokenReadOnly` first (line 113), then `allowance` (line 114) -- **different order from `run`**
    - Uses same `fromFixedDecimalLossyPacked` (line 117)
- **NatSpec**: `@title`, `@notice`, `@param`, `@return` all present where appropriate

### 2. LibOpERC20BalanceOf.sol (99 lines)

- **Library name**: `LibOpERC20BalanceOf` (line 17)
- **Imports**: Same set as Allowance minus one StackItem re-import (lines 5-13)
- **Functions**:
  - `integrity` -- line 21, returns `(2, 1)`
  - `run` -- line 30, `internal view`
    - Reads 2 stack values: `token`, `account` (lines 33-36)
    - Validates both via `NotAnAddress` (lines 42, 45)
    - Calls `IERC20.balanceOf` (line 49), then `safeDecimalsForTokenReadOnly` (line 54)
    - Uses `fromFixedDecimalLosslessPacked` (line 56)
    - Stack pointer advances by 0x20 (line 35), writes at new `stackTop` (line 59)
  - `referenceFn` -- line 67, `internal view`
    - Same validations (lines 72-79)
    - Calls `balanceOf` first (line 89), then `safeDecimalsForTokenReadOnly` (line 91) -- **same order as `run`**
- **NatSpec**: Complete with `@notice`, `@param`, `@return`

### 3. LibOpERC20TotalSupply.sol (84 lines)

- **Library name**: `LibOpERC20TotalSupply` (line 17)
- **Functions**:
  - `integrity` -- line 21, returns `(1, 1)`
  - `run` -- line 30, `internal view`
    - Reads 1 stack value: `token` (lines 32-34)
    - Validates via `NotAnAddress` (line 39)
    - Calls `IERC20.totalSupply` (line 43), then `safeDecimalsForTokenReadOnly` (line 48)
    - Uses `fromFixedDecimalLosslessPacked` (line 50)
    - `stackTop` unchanged (1 in, 1 out), writes at same position (line 53)
  - `referenceFn` -- line 61, `internal view`
    - Same validation (lines 66-69)
    - Calls `totalSupply` first (line 74), then `safeDecimalsForTokenReadOnly` (line 76) -- **same order as `run`**
- **NatSpec**: Complete

### 4. LibOpUint256ERC20Allowance.sol (95 lines)

- **Library name**: `LibOpUint256ERC20Allowance` (line 14)
- **Imports**: No `LibDecimalFloat`, `LibTOFUTokenDecimals`, or `Float` (lines 5-10) -- correct, no float conversion needed
- **Functions**:
  - `integrity` -- line 16, returns `(3, 1)`. NatSpec lacks `@notice` and `@return` tags.
  - `run` -- line 25, `internal view`
    - Reads 3 stack values (lines 29-33), validates all three (lines 39-45)
    - Calls `IERC20.allowance` (line 50), stores raw uint256
    - Stack pointer advances by 0x40 (line 32), writes at new `stackTop` (line 52)
  - `referenceFn` -- line 60, `internal view`
    - Same validations (lines 65-76), calls `allowance` (line 89)
    - Wraps result as `StackItem.wrap(bytes32(tokenAllowance))` (line 91)
- **NatSpec**: `@notice` missing on `integrity`, `@return` missing on `integrity`

### 5. LibOpUint256ERC20BalanceOf.sol (81 lines)

- **Library name**: `LibOpUint256ERC20BalanceOf` (line 14)
- **Functions**:
  - `integrity` -- line 16, returns `(2, 1)`. NatSpec lacks `@notice` and `@return` tags.
  - `run` -- line 25, `internal view`
    - Reads 2 stack values (lines 28-31), validates both (lines 37, 40)
    - Calls `IERC20.balanceOf` (line 44), stores raw uint256
    - Stack pointer advances by 0x20 (line 30), writes at new `stackTop` (line 46)
  - `referenceFn` -- line 54, `internal view`
    - Same validations (lines 59-66), calls `balanceOf` (line 75)
    - Wraps result as `StackItem.wrap(bytes32(tokenBalance))` (line 77)
- **NatSpec**: `@notice` missing on `integrity`, `@return` missing on `integrity`

### 6. LibOpUint256ERC20TotalSupply.sol (67 lines)

- **Library name**: `LibOpUint256ERC20TotalSupply` (line 14)
- **Functions**:
  - `integrity` -- line 16, returns `(1, 1)`. NatSpec lacks `@notice` and `@return` tags.
  - `run` -- line 25, `internal view`
    - Reads 1 stack value (lines 27-29), validates (line 34)
    - Calls `IERC20.totalSupply` (line 38), stores raw uint256
    - `stackTop` unchanged, writes at same position (line 40)
  - `referenceFn` -- line 48, `internal view`
    - Same validation (lines 53-56), calls `totalSupply` (line 61)
    - Wraps result as `StackItem.wrap(bytes32(totalSupply))` (line 63)
- **NatSpec**: `@notice` missing on `integrity`, `@return` missing on `integrity`

---

## Security Findings

### A20-1 -- INFO: External calls to untrusted ERC20 tokens are view-only by design

**Files**: All six files

**Description**: Every `run` function makes external calls (`allowance`, `balanceOf`, `totalSupply`) to token addresses supplied by the Rainlang author on the stack. The float variants additionally call `safeDecimalsForTokenReadOnly`, which internally calls `decimals()` via `staticcall`. Since `eval4` is `external view`, all external calls are executed as `staticcall` at the EVM level, preventing state mutation. Reentrancy resulting in state changes is not possible. A malicious token can return arbitrary values or revert, but cannot alter interpreter state.

**Severity**: INFO

---

### A20-2 -- INFO: Address validation via NotAnAddress is correct

**Files**: All six files

**Description**: All six files validate that each address-typed stack input fits in 160 bits: `if (token != uint256(uint160(token))) revert NotAnAddress(token)`. This correctly detects non-address values (e.g., floats, hashes, arithmetic results) whose upper 96 bits are non-zero. The check runs before any external call, preventing calls to truncated (wrong) addresses. Both `run` and `referenceFn` apply the same validation.

**Severity**: INFO

---

### A20-3 -- INFO: Stack pointer arithmetic is correct across all six files

**Files**: All six files

**Description**: Verified stack pointer arithmetic matches declared integrity:

- **3-input opcodes** (Allowance variants): Read from `stackTop`, `stackTop+0x20`, `stackTop+0x40`. Advance `stackTop` by `0x40`. Write 1 output at new `stackTop`. Net: 3 consumed, 1 produced. Matches `(3, 1)`.
- **2-input opcodes** (BalanceOf variants): Read from `stackTop`, `stackTop+0x20`. Advance by `0x20`. Write 1 output at new `stackTop`. Net: 2 consumed, 1 produced. Matches `(2, 1)`.
- **1-input opcodes** (TotalSupply variants): Read from `stackTop`. No advance. Write 1 output at same `stackTop`. Net: 1 consumed, 1 produced. Matches `(1, 1)`.

All assembly blocks are correctly annotated `"memory-safe"` -- they only read/write within the stack region owned by the opcode.

**Severity**: INFO

---

### A20-4 -- INFO: Lossy float conversion for allowance is intentional and correctly documented

**File**: `src/lib/op/erc20/LibOpERC20Allowance.sol` (lines 62-72)

**Description**: `erc20-allowance` uses `fromFixedDecimalLossyPacked` while `erc20-balance-of` and `erc20-total-supply` use `fromFixedDecimalLosslessPacked`. The comment at lines 62-70 explains that `type(uint256).max` (infinite approval) cannot be represented losslessly in a decimal float, so the lossy variant is required to avoid bricking evaluations. The second return value (the `lossless` flag) is intentionally discarded. The `referenceFn` uses the same lossy conversion. This is correct.

**Severity**: INFO

---

### A20-5 -- INFO: `decimals()` revert on non-ERC20Metadata tokens handled by TOFU library

**Files**: `LibOpERC20Allowance.sol`, `LibOpERC20BalanceOf.sol`, `LibOpERC20TotalSupply.sol`

**Description**: The float-converting variants call `LibTOFUTokenDecimals.safeDecimalsForTokenReadOnly`, which internally calls `decimals()` via `staticcall` in the TOFU implementation. If `decimals()` is not implemented (e.g., MKR, SAI), the `staticcall` returns `success = false`, which causes `safeDecimalsForTokenReadOnly` to revert with `TokenDecimalsReadFailure`. This is a design decision: the uint256 variants exist as alternatives for tokens that do not implement `decimals()`. The TOFU library also validates that the returned value fits in `uint8` and that `returndatasize >= 0x20`.

**Severity**: INFO

---

### A20-6 -- LOW: Call order discrepancy between `run` and `referenceFn` in LibOpERC20Allowance

**File**: `src/lib/op/erc20/LibOpERC20Allowance.sol`

**Description**: In `run` (lines 51-60), the call order is:
1. `IERC20(token).allowance(owner, spender)` (line 55)
2. `LibTOFUTokenDecimals.safeDecimalsForTokenReadOnly(token)` (line 60)

In `referenceFn` (lines 113-114), the call order is reversed:
1. `LibTOFUTokenDecimals.safeDecimalsForTokenReadOnly(token)` (line 113)
2. `IERC20(token).allowance(owner, spender)` (line 114)

The other two float variants (`LibOpERC20BalanceOf`, `LibOpERC20TotalSupply`) maintain consistent call ordering between `run` and `referenceFn` (ERC20 call first, then decimals).

Because both functions are `view`, the result is identical for well-behaved tokens. However, the `referenceFn` is intended as a differential testing oracle. If a token's `decimals()` reverts, `referenceFn` will revert before calling `allowance`, while `run` will call `allowance` first and revert on `decimals()` afterward. This means the differential test may not exercise the `allowance` call path when `decimals()` fails. More importantly, the `referenceFn` should mirror the `run` implementation as closely as possible to serve its purpose as a correctness oracle.

**Severity**: LOW

---

### A20-7 -- INFO: NatSpec inconsistency on uint256 variant `integrity` functions

**Files**: `LibOpUint256ERC20Allowance.sol` (line 15), `LibOpUint256ERC20BalanceOf.sol` (line 15), `LibOpUint256ERC20TotalSupply.sol` (line 15)

**Description**: The `integrity` function NatSpec in all three uint256 variants uses a bare `///` comment without `@notice` or `@return` tags:
```
/// `uint256-erc20-allowance` integrity check. Requires 3 inputs and produces 1 output.
```

The corresponding float variants use explicit tags:
```
/// @notice `erc20-allowance` integrity check. Requires 3 inputs and produces 1 output.
/// @return The number of inputs.
/// @return The number of outputs.
```

Since the function doc block itself does not contain any explicit tags, the untagged text defaults to `@notice` per NatSpec rules. However, the `@return` tags are absent, making the return value semantics less discoverable. This is a documentation consistency issue, not a security concern.

**Severity**: INFO

---

## Summary

No CRITICAL, HIGH, or MEDIUM findings. One LOW finding:

| ID | Severity | File | Description |
|----|----------|------|-------------|
| A20-6 | LOW | LibOpERC20Allowance.sol | Call order discrepancy between `run` and `referenceFn` (decimals vs allowance) |

Key security properties verified:

1. **Reentrancy**: Not exploitable -- `eval4` is `view`, all external calls are `staticcall`.
2. **Address validation**: All address inputs checked for upper-96-bit cleanliness via `NotAnAddress` before external calls.
3. **Stack safety**: All assembly pointer arithmetic matches declared integrity counts.
4. **Memory safety**: All assembly blocks correctly annotated and stay within owned stack memory.
5. **Return value handling**: Solidity high-level calls automatically revert on failure. The TOFU library handles `decimals()` failure via manual `staticcall` with `returndatasize` and `uint8` range checks.
6. **Float conversion**: Lossy for allowance (handles infinite approvals), lossless for balance/supply.
