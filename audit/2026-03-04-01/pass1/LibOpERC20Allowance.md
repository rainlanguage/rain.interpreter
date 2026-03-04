# Pass 1 (Security) -- LibOpERC20Allowance.sol

Agent: A44

## File

`src/lib/op/erc20/LibOpERC20Allowance.sol` (123 lines)

## Evidence of Thorough Reading

**Library:** `library LibOpERC20Allowance` (line 17)

**Functions:**

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `integrity(IntegrityCheckState memory, OperandV2) -> (uint256, uint256)` | 21 | `internal` | `pure` |
| `run(InterpreterState memory, OperandV2, Pointer stackTop) -> Pointer` | 30 | `internal` | `view` |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs) -> StackItem[] memory` | 83 | `internal` | `view` |

**Errors/Events/Structs/Constants:** None defined locally.

**Imported errors:** `NotAnAddress(uint256)` from `src/error/ErrRainType.sol`

**Imports:**
- `IERC20` from openzeppelin-contracts (line 4)
- `Pointer` from rain.solmem (line 6)
- `IntegrityCheckState` from LibIntegrityCheck (line 7)
- `OperandV2` from IInterpreterV4 (line 8)
- `InterpreterState` from LibInterpreterState (line 9)
- `LibDecimalFloat`, `Float` from rain.math.float (line 10)
- `LibTOFUTokenDecimals` from rain.tofu.erc20-decimals (line 11)
- `StackItem` from IInterpreterV4 (line 12)
- `NotAnAddress` from ErrRainType (line 13)

## Security Analysis

### Integrity / Run Consistency

`integrity()` returns `(3, 1)` -- 3 inputs, 1 output.

`run()` stack arithmetic:
- Reads `token` at `stackTop` (line 35)
- Reads `owner` at `stackTop + 0x20` (line 36)
- Advances `stackTop` by `0x40` (line 37)
- Reads `spender` at new `stackTop` (line 38)
- Writes result at `stackTop` (line 75)

Net effect: 3 values consumed, 1 value written. The stack pointer moves up by 2 slots (0x40), converting 3 inputs into 1 output. This matches integrity's `(3, 1)`.

### Address Validation

All three inputs (`token`, `owner`, `spender`) are validated against `uint160` range at lines 44, 47, 50. Values with non-zero upper 96 bits revert with `NotAnAddress`. This prevents truncation of non-address values.

### External Calls

1. `IERC20(token).allowance(owner, spender)` (line 55) -- `view` staticcall to arbitrary address. Cannot modify state due to `view` modifier on `run()`. Malicious token could revert or return unexpected data, but ABI decoding will revert on malformed return data.

2. `LibTOFUTokenDecimals.safeDecimalsForTokenReadOnly(token)` (line 60) -- `view` call to the TOFU singleton. The singleton's `ensureDeployed()` check validates the deployment exists with expected codehash before calling. This is a `view` call, so no TOFU storage writes occur. See known false positive: non-compliant tokens without `decimals()` will revert here, which is by design.

3. `LibDecimalFloat.fromFixedDecimalLossyPacked(tokenAllowance, tokenDecimals)` (line 72) -- pure conversion. The lossy variant is used intentionally because infinite approvals (`type(uint256).max`) cannot be represented losslessly. The discarded boolean return is documented (lines 63-70) and suppressed with `//slither-disable-next-line unused-return`.

### Reentrancy

`run()` is `view`, so all external calls are `staticcall`. No state changes are possible. No reentrancy risk.

### Assembly Safety

Two `assembly ("memory-safe")` blocks:
- Lines 34-39: reads 3 values from stack, advances pointer. Only `mload` and pointer arithmetic. No memory writes. Correct.
- Lines 74-76: writes result to stack position. Single `mstore` at the correct position. Correct.

### Operand Usage

The operand parameter is unused, which is correct for a fixed-arity opcode with no configuration.

### referenceFn Consistency

`referenceFn()` (lines 83-122) performs the same logic: validates all 3 addresses, calls `allowance`, calls `safeDecimalsForTokenReadOnly`, uses `fromFixedDecimalLossyPacked`. Returns `StackItem[]` of length 1. Consistent with `run()`.

## Findings

No findings at LOW severity or above.

### A44-INFO-1: Lossy float conversion for allowance is intentional and documented

The `fromFixedDecimalLossyPacked` function is used instead of the lossless variant. This is explicitly documented in lines 63-70: infinite approvals (`type(uint256).max`) are extremely common and cannot be represented losslessly. The discarded boolean (lossless flag) is a deliberate design choice, not an oversight.

### A44-INFO-2: External calls to arbitrary token addresses

The opcode calls `allowance()` and `decimals()` (via TOFU) on user-provided token addresses. Malicious tokens could revert, consume gas, or return unexpected values. This is inherent to any opcode that queries external contracts and is mitigated by the `view` context (no state changes) and ABI return data decoding (malformed returns revert).

## Summary

`LibOpERC20Allowance.sol` is a well-structured ERC20 allowance opcode. Stack arithmetic matches integrity (3 inputs, 1 output). All address inputs are validated. External calls are in `view` context (staticcall only). The lossy float conversion is an intentional design choice for handling infinite approvals. The `decimals()` call on non-compliant tokens is a known false positive documented in `audit/known-false-positives.md`. No security vulnerabilities found.
