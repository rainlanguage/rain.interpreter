# Pass 1: Security Review -- EVM, Store, Crypto, and uint256 Math Opcodes

**Agent:** A22
**Files reviewed:** 12

---

## Evidence of Thorough Reading

### 1. LibOpBlockNumber (`src/lib/op/evm/LibOpBlockNumber.sol`)

- **Library:** `LibOpBlockNumber` (line 13)
- **Functions:**
  - `integrity` (line 19) -- returns (0, 1)
  - `run` (line 26) -- pushes `number()` onto stack via assembly
  - `referenceFn` (line 39) -- uses `LibDecimalFloat.fromFixedDecimalLosslessPacked(block.number, 0)`
- **Types/errors/constants:** none

### 2. LibOpBlockTimestamp (`src/lib/op/evm/LibOpBlockTimestamp.sol`)

- **Library:** `LibOpBlockTimestamp` (line 13)
- **Functions:**
  - `integrity` (line 19) -- returns (0, 1)
  - `run` (line 26) -- pushes `timestamp()` onto stack via assembly
  - `referenceFn` (line 39) -- uses `LibDecimalFloat.fromFixedDecimalLosslessPacked(block.timestamp, 0)`
- **Types/errors/constants:** none

### 3. LibOpChainId (`src/lib/op/evm/LibOpChainId.sol`)

- **Library:** `LibOpChainId` (line 13)
- **Functions:**
  - `integrity` (line 19) -- returns (0, 1)
  - `run` (line 26) -- pushes `chainid()` onto stack via assembly
  - `referenceFn` (line 39) -- uses `LibDecimalFloat.fromFixedDecimalLosslessPacked(block.chainid, 0)`
- **Types/errors/constants:** none

### 4. LibOpGet (`src/lib/op/store/LibOpGet.sol`)

- **Library:** `LibOpGet` (line 13)
- **Functions:**
  - `integrity` (line 19) -- returns (1, 1)
  - `run` (line 32) -- reads key from stack, checks memory KV cache, falls back to external store; writes value in-place
  - `referenceFn` (line 68) -- same logic using StackItem arrays
- **Types/errors/constants:** none
- **Note:** read-only key persistence is a known false positive per `audit/known-false-positives.md`

### 5. LibOpSet (`src/lib/op/store/LibOpSet.sol`)

- **Library:** `LibOpSet` (line 13)
- **Functions:**
  - `integrity` (line 19) -- returns (2, 0)
  - `run` (line 29) -- reads key and value from stack, advances stackTop by 0x40, sets in memory KV
  - `referenceFn` (line 46) -- same logic using StackItem arrays
- **Types/errors/constants:** none

### 6. LibOpHash (`src/lib/op/crypto/LibOpHash.sol`)

- **Library:** `LibOpHash` (line 12)
- **Functions:**
  - `integrity` (line 17) -- inputs from operand bits `(operand >> 0x10) & 0x0F`, returns (inputs, 1)
  - `run` (line 28) -- computes `keccak256(stackTop, length)` where length = inputs * 0x20; adjusts stack
  - `referenceFn` (line 41) -- uses `keccak256(abi.encodePacked(inputs))`
- **Types/errors/constants:** none

### 7. LibOpUint256Add (`src/lib/op/math/uint256/LibOpUint256Add.sol`)

- **Library:** `LibOpUint256Add` (line 12)
- **Functions:**
  - `integrity` (line 17) -- inputs from operand bits, minimum 2; returns (inputs, 1)
  - `run` (line 30) -- reads first two values, accumulates via checked `+=` in loop
  - `referenceFn` (line 64) -- unchecked accumulation for testing
- **Types/errors/constants:** none

### 8. LibOpUint256Div (`src/lib/op/math/uint256/LibOpUint256Div.sol`)

- **Library:** `LibOpUint256Div` (line 13)
- **Functions:**
  - `integrity` (line 18) -- inputs from operand bits, minimum 2; returns (inputs, 1)
  - `run` (line 30) -- reads first two values, accumulates via checked `/=` in loop
  - `referenceFn` (line 65) -- unchecked accumulation for testing
- **Types/errors/constants:** none

### 9. LibOpUint256MaxValue (`src/lib/op/math/uint256/LibOpUint256MaxValue.sol`)

- **Library:** `LibOpUint256MaxValue` (line 12)
- **Functions:**
  - `integrity` (line 16) -- returns (0, 1)
  - `run` (line 23) -- pushes `type(uint256).max` onto stack
  - `referenceFn` (line 34) -- returns `StackItem.wrap(bytes32(type(uint256).max))`
- **Types/errors/constants:** none

### 10. LibOpUint256Mul (`src/lib/op/math/uint256/LibOpUint256Mul.sol`)

- **Library:** `LibOpUint256Mul` (line 12)
- **Functions:**
  - `integrity` (line 17) -- inputs from operand bits, minimum 2; returns (inputs, 1)
  - `run` (line 30) -- reads first two values, accumulates via checked `*=` in loop
  - `referenceFn` (line 64) -- unchecked accumulation for testing
- **Types/errors/constants:** none

### 11. LibOpUint256Power (`src/lib/op/math/uint256/LibOpUint256Power.sol`)

- **Library:** `LibOpUint256Power` (line 13)
- **Functions:**
  - `integrity` (line 18) -- inputs from operand bits, minimum 2; returns (inputs, 1)
  - `run` (line 31) -- reads first two values, accumulates via checked `**` in loop
  - `referenceFn` (line 65) -- unchecked accumulation for testing
- **Types/errors/constants:** none

### 12. LibOpUint256Sub (`src/lib/op/math/uint256/LibOpUint256Sub.sol`)

- **Library:** `LibOpUint256Sub` (line 12)
- **Functions:**
  - `integrity` (line 17) -- inputs from operand bits, minimum 2; returns (inputs, 1)
  - `run` (line 30) -- reads first two values, accumulates via checked `-=` in loop
  - `referenceFn` (line 64) -- unchecked accumulation for testing
- **Types/errors/constants:** none

---

## Security Analysis Summary

### Memory safety in assembly

All assembly blocks across all 12 files are correctly annotated `"memory-safe"`. Each block operates exclusively on the pre-allocated interpreter stack (reading from and writing to `stackTop` and adjacent offsets). No out-of-bounds writes or reads beyond the stack region are possible given correct integrity checks.

### Stack underflow/overflow: integrity matching run

Every opcode's `integrity` function correctly declares the number of stack items consumed (inputs) and produced (outputs) to match what `run` actually does:

- **EVM ops (block-number, block-timestamp, chain-id) and uint256-max-value:** integrity (0, 1), run pushes one value via `sub(stackTop, 0x20)` + `mstore`. Correct.
- **LibOpGet:** integrity (1, 1), run reads one value from `stackTop` and writes one value back in-place (no pointer movement). Correct.
- **LibOpSet:** integrity (2, 0), run reads two values and advances `stackTop` by 0x40 (consuming 2 slots). Correct.
- **LibOpHash:** integrity (N, 1) where N = `(operand >> 0x10) & 0x0F`. Run: `length = N * 0x20`, consumes N items and produces 1 via `stackTop = sub(add(stackTop, length), 0x20)`. For N=0: pushes 1. For N=1: in-place replacement. For N>1: consumes N, produces 1. Correct.
- **Multi-input math ops (add, sub, mul, div, power):** integrity enforces minimum 2 inputs via `inputs > 1 ? inputs : 2`. Run unconditionally reads 2 values then loops for additional inputs using the same operand mask `(operand >> 0x10) & 0x0F`. Stack pointer accounting is consistent. Correct.

### Operand validation

The operand extraction pattern `uint256(OperandV2.unwrap(operand) >> 0x10) & 0x0F` is used consistently in both `integrity` and `run` for variable-input opcodes. The 4-bit mask limits inputs to 0-15. The multi-input math ops clamp minimum to 2 in integrity. If the operand encodes 0 or 1 for a math op, integrity reports 2 inputs, and run reads exactly 2 (the loop condition `i < inputs` with `inputs` being 0 or 1 means the while loop never executes after the initial 2-value read). This is consistent.

### Arithmetic safety

- `+=`, `-=`, `*=`, `/=`, and `**` are all in checked arithmetic contexts (Solidity 0.8.x default). Overflow, underflow, and division-by-zero all revert automatically.
- The `unchecked { i++; }` in the while loops is safe because `i` starts at 2 and is bounded by `inputs <= 15`.
- The `referenceFn` functions intentionally use `unchecked` blocks so test assertions can distinguish between the real function's revert and the reference function's behavior.

### Custom errors

No string revert errors (`revert("...")`) appear in any of the 12 reviewed files.

### External call safety (LibOpGet)

`LibOpGet.run()` makes an external call to `state.store.get(state.namespace, key)` on cache miss. This is a `view` call that cannot modify state. The function itself is marked `view`. No reentrancy risk exists because the store call is read-only and no state mutation occurs after it (only memory-level caching via `stateKV`).

### Known false positives

LibOpGet's read-only key persistence to storage is documented in `audit/known-false-positives.md` and is not flagged.

---

## Findings

No findings. All 12 files pass security review with no issues identified.
