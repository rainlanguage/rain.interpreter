# Pass 1 — Security: LibParseOperand (A105)

**File:** `src/lib/parse/LibParseOperand.sol`

## Evidence

### Library
- `LibParseOperand` (line 24)

### Functions
| Function | Line | Visibility |
|---|---|---|
| `parseOperand(ParseState memory, uint256, uint256)` | 38 | internal view |
| `handleOperand(ParseState memory, uint256)` | 139 | internal pure |
| `handleOperandDisallowed(bytes32[] memory)` | 156 | internal pure |
| `handleOperandDisallowedAlwaysOne(bytes32[] memory)` | 167 | internal pure |
| `handleOperandSingleFull(bytes32[] memory)` | 180 | internal pure |
| `handleOperandSingleFullNoDefault(bytes32[] memory)` | 204 | internal pure |
| `handleOperandDoublePerByteNoDefault(bytes32[] memory)` | 228 | internal pure |
| `handleOperand8M1M1(bytes32[] memory)` | 261 | internal pure |
| `handleOperandM1M1(bytes32[] memory)` | 313 | internal pure |

### Types / Errors / Constants
- Imports: `ExpectedOperand`, `UnclosedOperand`, `OperandValuesOverflow`, `UnexpectedOperand`, `UnexpectedOperandValue`, `OperandOverflow`, `CMASK_OPERAND_END`, `CMASK_WHITESPACE`, `CMASK_OPERAND_START`, `OPERAND_VALUES_LENGTH`, `FSM_YANG_MASK`

## Assembly Review

### `parseOperand` — character reads (lines 40-42, 60-63, 68-71)
```solidity
assembly ("memory-safe") {
    char := shl(byte(0, mload(cursor)), 1)
}
```
- Standard single-byte read at cursor. At line 40, this is the first character read before any loop guard. If the caller provides a valid `cursor < end`, this is safe. The function is only called from `LibParse.parseRHS` where cursor validity is maintained.
- At lines 60-63, this reads immediately after `++cursor` (line 55). If the operand opening `<` is the last character before `end`, this reads at `cursor == end`, which reads memory beyond the parse data. However: (a) `mload` at any address is defined behavior in EVM (reads zero-initialized or previously-written memory), (b) the value is only used if the `while (cursor < end)` loop at line 66 is entered, which it won't be when `cursor >= end`. So the read is harmless.
- Inside the loop (lines 68-71), the `while (cursor < end)` guard at line 66 ensures bounds.

### `parseOperand` — operandValues length reset (lines 48-50)
```solidity
assembly ("memory-safe") {
    mstore(operandValues, 0)
}
```
- Writes the length word of the existing `operandValues` array to zero. This is within the allocated array. Correct.

### `parseOperand` — operandValues element write (lines 102-104)
```solidity
assembly ("memory-safe") {
    mstore(add(operandValues, add(0x20, mul(i, 0x20))), value)
}
```
- Writes to `operandValues[i]` bypassing Solidity bounds checking. The bounds are enforced by the `if (i == OPERAND_VALUES_LENGTH)` check at line 90, which reverts before any write at index 4 or beyond. `OPERAND_VALUES_LENGTH` is 4, and the array was allocated with length 4. This is safe.

### `parseOperand` — operandValues length update (lines 120-122)
```solidity
assembly ("memory-safe") {
    mstore(operandValues, i)
}
```
- Sets the final length of the operandValues array. `i` is at most `OPERAND_VALUES_LENGTH` (4), which matches the allocated capacity. Correct.

### `handleOperand` — function pointer lookup (lines 142-148)
```solidity
assembly ("memory-safe") {
    handler := and(mload(add(handlers, add(2, mul(wordIndex, 2)))), 0xFFFF)
}
```
- Loads a 2-byte function pointer from the `handlers` byte array at offset `wordIndex * 2`. The comment explains there is no bounds check because `wordIndex` comes from the parser's word lookup (not user input). This is confirmed: callers (`LibParse.sol:245`, `BaseRainterpreterSubParser.sol:198`) only call `handleOperand` after a successful `lookupWord` that returns a valid index within the known meta. Correct.

### `handleOperandSingleFull` / `handleOperandSingleFullNoDefault` — value reads (lines 183-185, 207-209)
```solidity
assembly ("memory-safe") {
    operand := mload(add(values, 0x20))
}
```
- Reads `values[0]`. Protected by `values.length == 1` check. Correct.

### `handleOperandDoublePerByteNoDefault` — value reads (lines 233-236)
```solidity
assembly ("memory-safe") {
    a := mload(add(values, 0x20))
    b := mload(add(values, 0x40))
}
```
- Reads `values[0]` and `values[1]`. Protected by `values.length == 2` check. Correct.

### `handleOperand8M1M1` — value reads (lines 268-269, 273-274, 281-282)
- Reads `values[0]`, `values[1]`, `values[2]` conditionally based on `length >= 1/2/3`. Each read is guarded by the appropriate length check. Correct.

### `handleOperandM1M1` — value reads (lines 321-323, 329-331)
- Reads `values[0]` and `values[1]` conditionally. Guarded by `length >= 1` and `length == 2` respectively. The outer check `length < 3` ensures at most 2 elements are accessed. Correct.

## Security Assessment

### Overflow checks
- All operand value handlers validate ranges before packing: `uint16` max for single-full, `uint8` max for double-per-byte, `uint8` + 1-bit flags for 8M1M1, 1-bit flags for M1M1. Overflow reverts with `OperandOverflow`.
- `OperandValuesOverflow` prevents writing beyond the 4-element array.

### Input validation
- Every handler covers all length cases (expected, too few, too many) with appropriate error reverts.
- `handleOperandDisallowed` and `handleOperandDisallowedAlwaysOne` reject any non-zero length.

No findings.
