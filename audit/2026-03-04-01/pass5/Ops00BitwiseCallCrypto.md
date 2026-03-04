# Pass 5: Correctness/Intent Verification -- Ops 00, Bitwise, Call, Crypto

Audit of A30-A43: `LibOpConstant`, `LibOpContext`, `LibOpExtern`, `LibOpStack`, `LibAllStandardOps`, `LibOpBitwiseAnd`, `LibOpBitwiseCountOnes`, `LibOpBitwiseDecode`, `LibOpBitwiseEncode`, `LibOpBitwiseOr`, `LibOpBitwiseShiftLeft`, `LibOpBitwiseShiftRight`, `LibOpCall`, `LibOpHash`.

## Evidence

### A30: LibOpConstant (`src/lib/op/00/LibOpConstant.sol`)

- **Library:** `LibOpConstant`
- **Functions:**
  - `integrity` (line 21): checks constant index in bounds, returns (0, 1)
  - `run` (line 37): reads `constants[operand & 0xFFFF]` via assembly, pushes to stack
  - `referenceFn` (line 52): reads `state.constants[index]` via Solidity, returns 1 output

**Integrity inputs/outputs:** 0 inputs, 1 output. Correct -- constant pushes one value, consumes nothing.

**Run vs NatSpec:** NatSpec says "Copies a constant from the constants array to the stack." Assembly reads `constants[(operand & 0xFFFF) + 1] * 0x20` which is standard memory array indexing. Matches.

**Run vs referenceFn:** Both extract index as `operand & 0xFFFF`, both read from `constants[index]`. `run` uses assembly, `referenceFn` uses Solidity bounds-checked access. Consistent.

**Operand extraction:** `run` uses `and(operand, 0xFFFF)` in assembly; `integrity` and `referenceFn` use `uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)))`. Since `OperandV2 is bytes32` and `bytes32`/`uint256` have identical EVM representation, these are equivalent.

No findings.

### A31: LibOpContext (`src/lib/op/00/LibOpContext.sol`)

- **Library:** `LibOpContext`
- **Functions:**
  - `integrity` (line 16): returns (0, 1), no operand validation (context shape unknown at integrity time)
  - `run` (line 28): reads `state.context[i][j]` where `i = operand & 0xFF`, `j = (operand >> 8) & 0xFF`, pushes to stack
  - `referenceFn` (line 47): same extraction and read, returns 1 output

**Integrity inputs/outputs:** 0 inputs, 1 output. Correct.

**Run vs referenceFn:** Identical operand extraction and context access. Consistent.

**NatSpec vs code:** See finding A31-P5-1 below.

### A32: LibOpExtern (`src/lib/op/00/LibOpExtern.sol`)

- **Library:** `LibOpExtern`
- **Errors used:** `NotAnExternContract`, `BadOutputsLength`
- **Functions:**
  - `integrity` (line 29): decodes extern dispatch from constants, checks ERC165, delegates to `extern.externIntegrity`
  - `run` (line 49): decodes dispatch, builds inputs array from stack, calls `extern.extern`, validates outputs length, copies outputs to stack in reverse order
  - `referenceFn` (line 102): same decode/call pattern, validates outputs, reverses outputs array

**Integrity:** Delegates to extern contract's `externIntegrity` which returns (inputs, outputs). Correct.

**Operand layout:** bits [0,15] = extern dispatch index, bits [16,19] = inputs count, bits [20,23] = outputs count. Consistent across `integrity` and `run`.

**Run stack manipulation:** Inputs are constructed by treating the word before stackTop as an array length. After extern call, inputs are popped (`stackTop += inputsLength * 0x20`), then outputs are pushed in forward-array/reverse-stack order so that `outputs[0]` ends up lowest on the stack. The saved `head` value is correctly restored.

**Run vs referenceFn:** Both decode the dispatch the same way. Both call `extern.extern` with the same inputs. Both validate outputs length. Both arrange outputs so `outputs[0]` is lowest on stack (`run` via push loop, `referenceFn` via `LibBytes32Array.reverse`). Consistent.

No findings.

### A33: LibOpStack (`src/lib/op/00/LibOpStack.sol`)

- **Library:** `LibOpStack`
- **Error used:** `OutOfBoundsStackRead`
- **Functions:**
  - `integrity` (line 21): validates read index < stackIndex, updates readHighwater, returns (0, 1)
  - `run` (line 41): reads `stackBottoms[sourceIndex]`, then reads value at `stackBottom - (readIndex + 1) * 0x20`, pushes to stack
  - `referenceFn` (line 58): same calculation using Solidity bounds-checked array access

**Integrity inputs/outputs:** 0 inputs, 1 output. Correct -- copies a value without consuming.

**Run assembly:** `mload(state)` gives `stackBottoms` pointer (first struct field). `stackBottoms[sourceIndex]` accessed as `mload(add(stackBottoms, mul(add(sourceIndex, 1), 0x20)))`. Value at read index accessed as `mload(sub(stackBottom, mul(0x20, add(readIndex, 1))))`. Both are standard memory layout calculations. Correct.

**Run vs referenceFn:** `referenceFn` computes `stackBottom - (readIndex + 1) * 0x20` via Solidity arithmetic, then reads via assembly. Same computation. Consistent.

No findings.

### A34: LibAllStandardOps (`src/lib/op/LibAllStandardOps.sol`)

- **Library:** `LibAllStandardOps`
- **Constant:** `ALL_STANDARD_OPS_LENGTH = 72`
- **Functions:**
  - `authoringMetaV2` (line 120): builds authoring meta array
  - `literalParserFunctionPointers` (line 344): builds literal parser pointers
  - `operandHandlerFunctionPointers` (line 377): builds operand handler pointers
  - `integrityFunctionPointers` (line 549): builds integrity check pointers
  - `opcodeFunctionPointers` (line 653): builds opcode run pointers

**Parallel array verification:** All four opcode arrays (authoring meta, operand handlers, integrity pointers, opcode pointers) have 72 entries each. The ordering across all four arrays is consistent:

| Index | Authoring Meta | Operand Handler | Integrity | Opcode |
|-------|---------------|-----------------|-----------|--------|
| 0 | stack | handleOperandSingleFull | LibOpStack.integrity | LibOpStack.run |
| 1 | constant | handleOperandSingleFull | LibOpConstant.integrity | LibOpConstant.run |
| 2 | extern | handleOperandSingleFull | LibOpExtern.integrity | LibOpExtern.run |
| 3 | context | handleOperandDoublePerByteNoDefault | LibOpContext.integrity | LibOpContext.run |
| 4 | bitwise-and | handleOperandDisallowed | LibOpBitwiseAnd.integrity | LibOpBitwiseAnd.run |
| 5 | bitwise-count-ones | handleOperandDisallowed | LibOpBitwiseCountOnes.integrity | LibOpBitwiseCountOnes.run |
| 6 | bitwise-decode | handleOperandDoublePerByteNoDefault | LibOpBitwiseDecode.integrity | LibOpBitwiseDecode.run |
| 7 | bitwise-encode | handleOperandDoublePerByteNoDefault | LibOpBitwiseEncode.integrity | LibOpBitwiseEncode.run |
| 8 | bitwise-or | handleOperandDisallowed | LibOpBitwiseOr.integrity | LibOpBitwiseOr.run |
| 9 | bitwise-shift-left | handleOperandSingleFull | LibOpBitwiseShiftLeft.integrity | LibOpBitwiseShiftLeft.run |
| 10 | bitwise-shift-right | handleOperandSingleFull | LibOpBitwiseShiftRight.integrity | LibOpBitwiseShiftRight.run |
| 11 | call | handleOperandSingleFull | LibOpCall.integrity | LibOpCall.run |
| 12 | hash | handleOperandDisallowed | LibOpHash.integrity | LibOpHash.run |
| 13-25 | (erc20, erc5313, erc721, evm ops) | (matching handlers) | (matching integrity) | (matching run) |
| 25 | now | handleOperandDisallowed | LibOpBlockTimestamp.integrity | LibOpBlockTimestamp.run |
| 26-71 | (logic, math, growth, uint256, store ops) | (matching handlers) | (matching integrity) | (matching run) |

The `now` alias at index 25 correctly maps to `LibOpBlockTimestamp` for both integrity and opcode pointers. All entries verified consistent.

No findings.

### A35: LibOpBitwiseAnd (`src/lib/op/bitwise/LibOpBitwiseAnd.sol`)

- **Library:** `LibOpBitwiseAnd`
- **Functions:**
  - `integrity` (line 16): returns (2, 1)
  - `run` (line 24): ANDs top two stack items, stores result, returns new top
  - `referenceFn` (line 36): ANDs inputs[0] and inputs[1], returns 1 output

**Integrity:** 2 inputs, 1 output. Correct.

**Run assembly:** `stackTopAfter = stackTop + 0x20` (second item). Stores `and(mload(stackTop), mload(stackTopAfter))` at stackTopAfter. Returns stackTopAfter. Net: consumes 2 words, produces 1. Correct.

**Run vs referenceFn:** Both compute `inputs[0] & inputs[1]`. `inputs[0]` in the reference corresponds to the top of stack (`mload(stackTop)`) in `run`. Consistent.

No findings.

### A36: LibOpBitwiseCountOnes (`src/lib/op/bitwise/LibOpBitwiseCountOnes.sol`)

- **Library:** `LibOpBitwiseCountOnes`
- **Functions:**
  - `integrity` (line 19): returns (1, 1)
  - `run` (line 27): reads top, applies `LibCtPop.ctpop`, writes back
  - `referenceFn` (line 44): applies `LibCtPop.ctpopSlow` to inputs[0], returns in place

**Integrity:** 1 input, 1 output. Correct.

**Run vs referenceFn:** `run` uses `ctpop` (optimized), `referenceFn` uses `ctpopSlow` (reference). Both should return identical popcount results. This is the standard pattern of using an independent reference implementation for testing. Consistent.

No findings.

### A37: LibOpBitwiseDecode (`src/lib/op/bitwise/LibOpBitwiseDecode.sol`)

- **Library:** `LibOpBitwiseDecode`
- **Functions:**
  - `integrity` (line 20): delegates to `LibOpBitwiseEncode.integrity` for validation, returns (1, 1)
  - `run` (line 33): extracts startBit and length from operand, computes `(value >> startBit) & ((1 << length) - 1)`
  - `referenceFn` (line 65): same computation using `(2 ** length) - 1` for mask

**Integrity:** 1 input, 1 output. Correct -- decodes a field from one value.

**Operand extraction:** `startBit = operand & 0xFF` (low byte), `length = (operand >> 8) & 0xFF` (second byte). Consistent across `run` and `referenceFn`.

**Mask computation:** `(1 << length) - 1` in `run` vs `(2 ** length) - 1` in `referenceFn`. These are equivalent for all valid length values [1, 255].

**Run vs referenceFn:** Both compute `(value >> startBit) & mask`. Consistent.

No findings.

### A38: LibOpBitwiseEncode (`src/lib/op/bitwise/LibOpBitwiseEncode.sol`)

- **Library:** `LibOpBitwiseEncode`
- **Errors used:** `ZeroLengthBitwiseEncoding`, `TruncatedBitwiseEncoding`
- **Functions:**
  - `integrity` (line 19): validates length != 0 and startBit + length <= 256, returns (2, 1)
  - `run` (line 36): reads source and target from stack, builds mask, clears target bits, ORs in masked source bits
  - `referenceFn` (line 76): same encoding logic in Solidity

**Integrity:** 2 inputs (source, target), 1 output (encoded target). Correct.

**Run stack order:** `source = mload(stackTop)` (top), `target = mload(stackTop + 0x20)` (second). Result written at second position. Net: 2 consumed, 1 produced. Correct.

**Encoding logic:** `target &= ~(mask << startBit); target |= (source & mask) << startBit;`. Clears the target field, then fills with masked source bits. Correct.

**Run vs referenceFn:** Both extract `source = inputs[0]`, `target = inputs[1]`, apply identical mask/clear/fill logic. Mask computed as `(1 << length) - 1` in `run` vs `(2 ** length - 1)` in `referenceFn`. Equivalent. Consistent.

No findings.

### A39: LibOpBitwiseOr (`src/lib/op/bitwise/LibOpBitwiseOr.sol`)

- **Library:** `LibOpBitwiseOr`
- **Functions:**
  - `integrity` (line 16): returns (2, 1)
  - `run` (line 24): ORs top two stack items
  - `referenceFn` (line 36): ORs inputs[0] and inputs[1]

**Integrity:** 2 inputs, 1 output. Correct.

**Run vs referenceFn:** Both compute `inputs[0] | inputs[1]`. Same pattern as bitwise-and. Consistent.

No findings.

### A40: LibOpBitwiseShiftLeft (`src/lib/op/bitwise/LibOpBitwiseShiftLeft.sol`)

- **Library:** `LibOpBitwiseShiftLeft`
- **Error used:** `UnsupportedBitwiseShiftAmount`
- **Functions:**
  - `integrity` (line 19): validates shiftAmount in [1, 255], returns (1, 1)
  - `run` (line 38): `shl(operand & 0xFFFF, mload(stackTop))`
  - `referenceFn` (line 49): `uint256(StackItem.unwrap(inputs[0])) << shiftAmount`

**Integrity:** 1 input, 1 output. Correct.

**Shift amount validation:** Rejects 0 (noop) and > 255 (always zero). Valid range [1, 255].

**Run vs referenceFn:** Both shift left by the same amount extracted from the operand. `shl` in EVM and `<<` in Solidity are equivalent for uint256. Consistent.

No findings.

### A41: LibOpBitwiseShiftRight (`src/lib/op/bitwise/LibOpBitwiseShiftRight.sol`)

- **Library:** `LibOpBitwiseShiftRight`
- **Error used:** `UnsupportedBitwiseShiftAmount`
- **Functions:**
  - `integrity` (line 19): validates shiftAmount in [1, 255], returns (1, 1)
  - `run` (line 38): `shr(operand & 0xFFFF, mload(stackTop))`
  - `referenceFn` (line 49): `uint256(StackItem.unwrap(inputs[0])) >> shiftAmount`

**Integrity:** 1 input, 1 output. Correct.

**Run vs referenceFn:** Both shift right by the same amount. `shr` and `>>` are equivalent for uint256. Consistent.

No findings.

### A42: LibOpCall (`src/lib/op/call/LibOpCall.sol`)

- **Library:** `LibOpCall`
- **Error used:** `CallOutputsExceedSource`
- **Functions:**
  - `integrity` (line 85): extracts sourceIndex and outputs from operand, validates against bytecode, returns (sourceInputs, outputs)
  - `run` (line 122): extracts sourceIndex/inputs/outputs, copies inputs to callee stack (reversed), calls evalLoop, copies outputs back

**Integrity:** Returns `(sourceInputs, outputs)` where `sourceInputs` comes from bytecode metadata and `outputs` from operand bits [20+]. The callee's declared inputs determine how many values the caller must provide. Correct.

**Operand layout:**
- bits [0,15]: sourceIndex (used in both integrity and run)
- bits [16,19]: inputs count (used in run only; integrity gets this from bytecode)
- bits [20+]: outputs count (used in both; no mask needed because operand is only 24 bits wide in practice)

**Run input copy:** Iterates `stackTop` forward (popping inputs from caller), writes to callee stack growing downward from `evalStackBottom`. This reverses the order so that the first argument to `call` becomes the bottom-most item on the callee's stack. Correct per the documented design.

**Run output copy:** Copies `outputs` words from callee stack top to caller stack, preserving relative order. Correct.

**Source index swap:** Saves `currentSourceIndex`, sets `state.sourceIndex = sourceIndex`, passes `currentSourceIndex` to `evalLoop` as `parentSourceIndex`, then restores. Correct.

No findings.

### A43: LibOpHash (`src/lib/op/crypto/LibOpHash.sol`)

- **Library:** `LibOpHash`
- **Functions:**
  - `integrity` (line 17): extracts inputs from operand bits [16,19], returns (inputs, 1)
  - `run` (line 28): computes `keccak256(stackTop, inputs * 0x20)`, stores result
  - `referenceFn` (line 41): computes `keccak256(abi.encodePacked(inputs))`

**Integrity:** Variable inputs (0-15), 1 output. Correct.

**Run stack math:** `length = inputs * 0x20`. Hash computed over `length` bytes from `stackTop`. New stackTop = `stackTop + length - 0x20`. Net: consumes `inputs` words, produces 1. Correct even for 0 inputs (produces hash of empty bytes, pushes one word).

**Run vs referenceFn:** `run` hashes raw stack memory (contiguous 32-byte words). `referenceFn` hashes `abi.encodePacked(inputs)` where `inputs` is `StackItem[] memory` (array of `bytes32`). `abi.encodePacked` on a `bytes32[]` concatenates the elements as 32-byte words with no padding, which is identical to the raw memory layout. The element ordering matches because the test framework copies `inputs[0]` to `stackTop`, `inputs[1]` to `stackTop + 0x20`, etc. Consistent.

No findings.

---

## Findings

### A31-P5-1: NatSpec contradicts interface convention for context operand labels (INFO)

**File:** `src/lib/op/00/LibOpContext.sol`, lines 25 and 45
**Also:** `src/lib/op/LibAllStandardOps.sol`, line 133 (authoring meta -- this one is CORRECT)

**Description:**

The NatSpec on `run` (line 25) and `referenceFn` (line 45) says:
```
/// @param operand Encodes the row (low byte) and column (second byte) indices.
```

This labels the low byte (`i`) as "row" and the second byte (`j`) as "column".

However, the interface-level convention (in `rain.interpreter.interface/src/lib/caller/LibContext.sol`) defines `CONTEXT_BASE_COLUMN = 0` as the first index and `CONTEXT_BASE_ROW_SENDER = 0`, `CONTEXT_BASE_ROW_CALLING_CONTRACT = 1` as the second index. This means the first index (`i`) is the column and the second index (`j`) is the row.

The authoring meta in `LibAllStandardOps` (line 133) correctly says "The first operand is the context column and second is the context row," which matches the interface convention.

The NatSpec on `run` and `referenceFn` has the labels reversed relative to the interface convention and the authoring meta.

**Impact:** Documentation-only. The code behavior is self-consistent; only the NatSpec labels are swapped. This could confuse developers reading the source who rely on the NatSpec to understand operand layout.
