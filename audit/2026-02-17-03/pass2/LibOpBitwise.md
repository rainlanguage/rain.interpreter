# Pass 2 (Test Coverage) -- Bitwise Operations

## Evidence of Thorough Reading

### Source Files

#### LibOpBitwiseAnd.sol
- **Library:** `LibOpBitwiseAnd`
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 14 -- returns (2, 1)
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 20 -- bitwise AND via assembly
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 30 -- reference impl
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed` (from LibAllStandardOps line 382)

#### LibOpBitwiseOr.sol
- **Library:** `LibOpBitwiseOr`
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 14 -- returns (2, 1)
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 20 -- bitwise OR via assembly
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 30 -- reference impl
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed` (from LibAllStandardOps line 384)

#### LibOpCtPop.sol
- **Library:** `LibOpCtPop`
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 20 -- returns (1, 1)
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 26 -- delegates to LibCtPop.ctpop
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 41 -- uses LibCtPop.ctpopSlow
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed` (from LibAllStandardOps line 386)

#### LibOpDecodeBits.sol
- **Library:** `LibOpDecodeBits`
- `integrity(IntegrityCheckState memory state, OperandV2 operand)` -- line 16 -- delegates to LibOpEncodeBits.integrity for validation, returns (1, 1)
- `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` -- line 26 -- decodes bits from operand start/length
- `referenceFn(InterpreterState memory, OperandV2 operand, StackItem[] memory inputs)` -- line 55 -- reference impl
- No errors/events/structs defined directly (uses ZeroLengthBitwiseEncoding, TruncatedBitwiseEncoding via LibOpEncodeBits)
- Operand handler: `handleOperandDoublePerByteNoDefault` (from LibAllStandardOps line 388)

#### LibOpEncodeBits.sol
- **Library:** `LibOpEncodeBits`
- `integrity(IntegrityCheckState memory, OperandV2 operand)` -- line 16 -- validates startBit+length<=256 and length!=0, returns (2, 1)
- `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` -- line 30 -- encodes source bits into target
- `referenceFn(InterpreterState memory, OperandV2 operand, StackItem[] memory inputs)` -- line 66 -- reference impl
- Errors used: `ZeroLengthBitwiseEncoding` (line 21), `TruncatedBitwiseEncoding` (line 24)
- Operand handler: `handleOperandDoublePerByteNoDefault` (from LibAllStandardOps line 390)

#### LibOpShiftBitsLeft.sol
- **Library:** `LibOpShiftBitsLeft`
- `integrity(IntegrityCheckState memory, OperandV2 operand)` -- line 16 -- validates shiftAmount in [1,255], returns (1, 1)
- `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` -- line 32 -- SHL via assembly
- `referenceFn(InterpreterState memory, OperandV2 operand, StackItem[] memory inputs)` -- line 40 -- reference impl
- Error used: `UnsupportedBitwiseShiftAmount` (line 24)
- Operand handler: `handleOperandSingleFull` (from LibAllStandardOps line 392)

#### LibOpShiftBitsRight.sol
- **Library:** `LibOpShiftBitsRight`
- `integrity(IntegrityCheckState memory, OperandV2 operand)` -- line 16 -- validates shiftAmount in [1,255], returns (1, 1)
- `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` -- line 32 -- SHR via assembly
- `referenceFn(InterpreterState memory, OperandV2 operand, StackItem[] memory inputs)` -- line 40 -- reference impl
- Error used: `UnsupportedBitwiseShiftAmount` (line 24)
- Operand handler: `handleOperandSingleFull` (from LibAllStandardOps line 394)

### Error File: ErrBitwise.sol
- `UnsupportedBitwiseShiftAmount(uint256 shiftAmount)` -- line 13
- `TruncatedBitwiseEncoding(uint256 startBit, uint256 length)` -- line 19
- `ZeroLengthBitwiseEncoding()` -- line 23
- Workaround contract `ErrBitwise` -- line 6 (for foundry issue 6572)

### Test Files

#### LibOpBitwiseAnd.t.sol
- **Contract:** `LibOpBitwiseAndTest is OpTest`
- `testOpBitwiseAndIntegrity(IntegrityCheckState, OperandV2)` -- line 16 -- fuzz integrity
- `testOpBitwiseAndRun(StackItem, StackItem)` -- line 24 -- fuzz run via opReferenceCheck
- `testOpBitwiseAndEvalHappy()` -- line 36 -- 16 checkHappy cases for eval from string
- `testOpBitwiseOREvalZeroInputs()` -- line 56 -- checkBadInputs (0 inputs)
- `testOpBitwiseOREvalOneInput()` -- line 60 -- checkBadInputs (1 input)
- `testOpBitwiseOREvalThreeInputs()` -- line 64 -- checkBadInputs (3 inputs)
- `testOpBitwiseOREvalZeroOutputs()` -- line 68 -- checkBadOutputs (0 outputs)
- `testOpBitwiseOREvalTwoOutputs()` -- line 72 -- checkBadOutputs (2 outputs)
- `testOpBitwiseOREvalBadOperand()` -- line 77 -- checkUnhappyParse for disallowed operand

#### LibOpBitwiseOr.t.sol
- **Contract:** `LibOpBitwiseOrTest is OpTest`
- `testOpBitwiseORIntegrity(IntegrityCheckState, OperandV2)` -- line 16 -- fuzz integrity
- `testOpBitwiseORRun(StackItem, StackItem)` -- line 24 -- fuzz run via opReferenceCheck
- `testOpBitwiseOREval()` -- line 36 -- 16 checkHappy cases
- `testOpBitwiseOREvalZeroInputs()` -- line 56 -- checkBadInputs
- `testOpBitwiseOREvalOneInput()` -- line 60 -- checkBadInputs
- `testOpBitwiseOREvalThreeInputs()` -- line 64 -- checkBadInputs
- `testOpBitwiseOREvalZeroOutputs()` -- line 68 -- checkBadOutputs
- `testOpBitwiseOREvalTwoOutputs()` -- line 72 -- checkBadOutputs
- `testOpBitwiseOREvalBadOperand()` -- line 77 -- checkUnhappyParse for disallowed operand

#### LibOpCtPop.t.sol
- **Contract:** `LibOpCtPopTest is OpTest`
- `testOpCtPopIntegrity(IntegrityCheckState, OperandV2)` -- line 18 -- fuzz integrity
- `testOpCtPopRun(StackItem)` -- line 26 -- fuzz run via opReferenceCheck
- `testOpCtPopEval(StackItem)` -- line 35 -- fuzz eval from string
- `testOpCtPopZeroInputs()` -- line 46 -- checkBadInputs
- `testOpCtPopTwoInputs()` -- line 50 -- checkBadInputs
- `testOpCtPopZeroOutputs()` -- line 54 -- checkBadOutputs
- `testOpCtPopTwoOutputs()` -- line 58 -- checkBadOutputs

#### LibOpDecodeBits.t.sol
- **Contract:** `LibOpDecodeBitsTest is OpTest`
- `integrityExternal(IntegrityCheckState, OperandV2)` -- line 14 -- helper for vm.expectRevert
- `testOpDecodeBitsIntegrity(IntegrityCheckState, uint8, uint8, uint8, uint8)` -- line 26 -- fuzz integrity happy path
- `testOpDecodeBitsIntegrityFail(IntegrityCheckState, uint8, uint8)` -- line 49 -- fuzz TruncatedBitwiseEncoding
- `testOpDecodeBitsIntegrityFailZeroLength(IntegrityCheckState, uint8)` -- line 63 -- fuzz ZeroLengthBitwiseEncoding
- `testOpDecodeBitsRun(StackItem, uint8, uint8)` -- line 72 -- fuzz run via opReferenceCheck
- `testOpDecodeBitsEvalHappy()` -- line 88 -- 14 checkHappy cases with various start/length combos
- `testOpDecodeBitsEvalZeroInputs()` -- line 118 -- checkBadInputs
- `testOpDecodeBitsEvalTwoInputs()` -- line 122 -- checkBadInputs
- `testOpDecodeBitsEvalZeroOutputs()` -- line 126 -- checkBadOutputs
- `testOpDecodeBitsEvalTwoOutputs()` -- line 130 -- checkBadOutputs

#### LibOpEncodeBits.t.sol
- **Contract:** `LibOpEncodeBitsTest is OpTest`
- `integrityExternal(IntegrityCheckState, OperandV2)` -- line 14 -- helper for vm.expectRevert
- `testOpEncodeBitsIntegrity(IntegrityCheckState, uint8, uint8)` -- line 26 -- fuzz integrity happy path
- `testOpEncodeBitsIntegrityFail(IntegrityCheckState, uint8, uint8)` -- line 44 -- fuzz TruncatedBitwiseEncoding
- `testOpEncodeBitsIntegrityFailZeroLength(IntegrityCheckState, uint8)` -- line 60 -- fuzz ZeroLengthBitwiseEncoding
- `testOpEncodeBitsRun(StackItem, StackItem, uint8, uint8)` -- line 69 -- fuzz run via opReferenceCheck
- `testOpEncodeBitsEvalHappy()` -- line 87 -- 16 checkHappy cases
- `testOpEncodeBitsEvalZeroInputs()` -- line 115 -- checkBadInputs
- `testOpEncodeBitsEvalOneInput()` -- line 119 -- checkBadInputs
- `testOpEncodeBitsEvalThreeInputs()` -- line 123 -- checkBadInputs
- `testOpEncodeBitsEvalZeroOutputs()` -- line 127 -- checkBadOutputs
- `testOpEncodeBitsEvalTwoOutputs()` -- line 131 -- checkBadOutputs

#### LibOpShiftBitsLeft.t.sol
- **Contract:** `LibOpShiftBitsLeftTest is OpTest`
- `integrityExternal(IntegrityCheckState, OperandV2)` -- line 15 -- helper for vm.expectRevert
- `testOpShiftBitsLeftIntegrityHappy(IntegrityCheckState, uint8, uint8, uint8)` -- line 26 -- fuzz integrity happy path
- `testOpShiftBitsLeftIntegrityZero(IntegrityCheckState, uint8, uint16)` -- line 44 -- fuzz shift >255 error
- `testOpShiftBitsLeftIntegrityNoop(IntegrityCheckState, uint8)` -- line 60 -- fuzz shift == 0 error
- `testOpShiftBitsLeftRun(StackItem, uint8)` -- line 69 -- fuzz run via opReferenceCheck
- `testOpShiftBitsLeftEval()` -- line 81 -- 22 checkHappy cases
- `testOpShiftBitsLeftIntegrityFailZeroInputs()` -- line 114 -- checkBadInputs
- `testOpShiftBitsLeftIntegrityFailTwoInputs()` -- line 118 -- checkBadInputs
- `testOpShiftBitsLeftIntegrityFailZeroOutputs()` -- line 122 -- checkBadOutputs
- `testOpShiftBitsLeftIntegrityFailTwoOutputs()` -- line 126 -- checkBadOutputs
- `testOpShiftBitsLeftIntegrityFailBadShiftAmount()` -- line 131 -- tests shift 0, 256, 65535, 65536

#### LibOpShiftBitsRight.t.sol
- **Contract:** `LibOpShiftBitsRightTest is OpTest`
- `integrityExternal(IntegrityCheckState, OperandV2)` -- line 15 -- helper for vm.expectRevert
- `testOpShiftBitsRightIntegrityHappy(IntegrityCheckState, uint8, uint8, uint8)` -- line 27 -- fuzz integrity happy path
- `testOpShiftBitsRightIntegrityZero(IntegrityCheckState, uint8, uint16)` -- line 46 -- fuzz shift >255 error
- `testOpShiftBitsRightIntegrityNoop(IntegrityCheckState, uint8)` -- line 60 -- fuzz shift == 0 error
- `testOpShiftBitsRightRun(StackItem, uint8)` -- line 69 -- fuzz run via opReferenceCheck
- `testOpShiftBitsRightEval()` -- line 86 -- 24 checkHappy cases
- `testOpShiftBitsRightZeroInputs()` -- line 119 -- checkBadInputs
- `testOpShiftBitsRightTwoInputs()` -- line 123 -- checkBadInputs
- `testOpShiftBitsRightZeroOutputs()` -- line 127 -- checkBadOutputs
- `testOpShiftBitsRightTwoOutputs()` -- line 131 -- checkBadOutputs
- `testOpShiftBitsRightIntegrityFailBadShiftAmount()` -- line 136 -- tests shift 0, 256, 65535, 65536

## Findings

### A16-1: LibOpCtPop missing test for disallowed operand
**Severity:** LOW

`LibOpCtPop` uses `handleOperandDisallowed` as its operand handler (LibAllStandardOps line 386). Both `LibOpBitwiseAnd` and `LibOpBitwiseOr` test this path with `checkUnhappyParse` verifying that `UnexpectedOperand` is thrown when an operand is supplied (e.g., `"_: bitwise-and<0>(0 0);"`). The `LibOpCtPop.t.sol` test file has no equivalent test for parsing `bitwise-count-ones<0>(0)` with an unexpected operand.

**Location:** `test/src/lib/op/bitwise/LibOpCtPop.t.sol`

### A16-2: LibOpDecodeBits missing test for disallowed operand format
**Severity:** INFO

`LibOpDecodeBits` uses `handleOperandDoublePerByteNoDefault` as its operand handler. The test file exercises the integrity error paths (`TruncatedBitwiseEncoding`, `ZeroLengthBitwiseEncoding`) and various valid operands, but does not test what happens when an operand is provided in an invalid format (e.g., wrong number of operand values, single value instead of two). The `handleOperandDoublePerByteNoDefault` handler itself is tested elsewhere (in `LibParseOperand` tests), so this is informational rather than a coverage gap per se.

**Location:** `test/src/lib/op/bitwise/LibOpDecodeBits.t.sol`

### A16-3: LibOpEncodeBits missing test for disallowed operand format
**Severity:** INFO

Same as A16-2 but for `LibOpEncodeBits`. The `handleOperandDoublePerByteNoDefault` handler is used but not tested at the parse level for malformed operands (e.g., missing operand, single-value operand, three-value operand). The handler's own tests exist elsewhere.

**Location:** `test/src/lib/op/bitwise/LibOpEncodeBits.t.sol`

### A16-4: LibOpBitwiseAnd and LibOpBitwiseOr eval tests lack max-value edge cases
**Severity:** INFO

The `testOpBitwiseAndEvalHappy` and `testOpBitwiseOREval` functions test small literal values (0x00 through 0x03). Neither test includes `uint256-max-value()` as an input, unlike the shift and encode/decode tests which do. While the fuzz tests (`testOpBitwiseAndRun`, `testOpBitwiseORRun`) cover the full input range via `opReferenceCheck`, the deterministic eval-from-string tests do not verify that the full end-to-end parse-eval pipeline handles max values for AND and OR.

**Location:** `test/src/lib/op/bitwise/LibOpBitwiseAnd.t.sol` (line 36), `test/src/lib/op/bitwise/LibOpBitwiseOr.t.sol` (line 36)

### A16-5: LibOpDecodeBits and LibOpEncodeBits missing roundtrip test
**Severity:** INFO

There is no test that verifies encode followed by decode produces the original value (or vice versa). A roundtrip property test such as `decode(encode(source, target, start, len), start, len) == source & mask` would provide stronger confidence that the two operations are correctly inverse. The individual `opReferenceCheck` fuzz tests verify each operation independently but not the compositional correctness.

**Location:** `test/src/lib/op/bitwise/LibOpDecodeBits.t.sol`, `test/src/lib/op/bitwise/LibOpEncodeBits.t.sol`

### A16-6: LibOpBitwiseAnd test function naming inconsistency
**Severity:** INFO

In `LibOpBitwiseAnd.t.sol`, the bad-input/bad-output test functions are named `testOpBitwiseOREval*` (e.g., `testOpBitwiseOREvalZeroInputs`, `testOpBitwiseOREvalOneInput`, `testOpBitwiseOREvalBadOperand`) despite testing `bitwise-and`. This appears to be a copy-paste artifact from the BitwiseOr test file. While the tests themselves exercise the correct expressions (they parse `bitwise-and(...)` strings), the function names are misleading and could cause confusion when filtering test results.

**Location:** `test/src/lib/op/bitwise/LibOpBitwiseAnd.t.sol` -- lines 56, 60, 64, 68, 72, 77
