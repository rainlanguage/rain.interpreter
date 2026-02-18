# Pass 2 (Test Coverage) -- Error Definitions

## Evidence of Thorough Reading

### ErrBitwise.sol
- Contract: `ErrBitwise` (line 6, workaround stub)
- `UnsupportedBitwiseShiftAmount(uint256 shiftAmount)` -- line 13
- `TruncatedBitwiseEncoding(uint256 startBit, uint256 length)` -- line 19
- `ZeroLengthBitwiseEncoding()` -- line 23

### ErrDeploy.sol
- Contract: `ErrDeploy` (line 6, workaround stub)
- `UnknownDeploymentSuite(bytes32 suite)` -- line 11

### ErrEval.sol
- Contract: `ErrEval` (line 6, workaround stub)
- `InputsLengthMismatch(uint256 expected, uint256 actual)` -- line 11
- `ZeroFunctionPointers()` -- line 15

### ErrExtern.sol
- Contract: `ErrExtern` (line 8, workaround stub)
- Import: `NotAnExternContract` from `rain.interpreter.interface/error/ErrExtern.sol` (line 5)
- `ExternOpcodeOutOfRange(uint256 opcode, uint256 fsCount)` -- line 14
- `ExternPointersMismatch(uint256 opcodeCount, uint256 integrityCount)` -- line 20
- `BadOutputsLength(uint256 expectedLength, uint256 actualLength)` -- line 23
- `ExternOpcodePointersEmpty()` -- line 26

### ErrIntegrity.sol
- Contract: `ErrIntegrity` (line 6, workaround stub)
- `StackUnderflow(uint256 opIndex, uint256 stackIndex, uint256 calculatedInputs)` -- line 12
- `StackUnderflowHighwater(uint256 opIndex, uint256 stackIndex, uint256 stackHighwater)` -- line 18
- `StackAllocationMismatch(uint256 stackMaxIndex, uint256 bytecodeAllocation)` -- line 24
- `StackOutputsMismatch(uint256 stackIndex, uint256 bytecodeOutputs)` -- line 29
- `OutOfBoundsConstantRead(uint256 opIndex, uint256 constantsLength, uint256 constantRead)` -- line 35
- `OutOfBoundsStackRead(uint256 opIndex, uint256 stackTopIndex, uint256 stackRead)` -- line 41
- `CallOutputsExceedSource(uint256 sourceOutputs, uint256 outputs)` -- line 47
- `OpcodeOutOfRange(uint256 opIndex, uint256 opcodeIndex, uint256 fsCount)` -- line 53

### ErrOpList.sol
- Contract: `ErrOpList` (line 6, workaround stub)
- `BadDynamicLength(uint256 dynamicLength, uint256 standardOpsLength)` -- line 12

### ErrParse.sol
- Contract: `ErrParse` (line 6, workaround stub)
- `UnexpectedOperand()` -- line 10
- `UnexpectedOperandValue()` -- line 14
- `ExpectedOperand()` -- line 18
- `OperandValuesOverflow(uint256 offset)` -- line 23
- `UnclosedOperand(uint256 offset)` -- line 27
- `UnsupportedLiteralType(uint256 offset)` -- line 30
- `StringTooLong(uint256 offset)` -- line 33
- `UnclosedStringLiteral(uint256 offset)` -- line 37
- `HexLiteralOverflow(uint256 offset)` -- line 40
- `ZeroLengthHexLiteral(uint256 offset)` -- line 43
- `OddLengthHexLiteral(uint256 offset)` -- line 46
- `MalformedHexLiteral(uint256 offset)` -- line 49
- `MalformedExponentDigits(uint256 offset)` -- line 53
- `MalformedDecimalPoint(uint256 offset)` -- line 56
- `MissingFinalSemi(uint256 offset)` -- line 59
- `UnexpectedLHSChar(uint256 offset)` -- line 62
- `UnexpectedRHSChar(uint256 offset)` -- line 65
- `ExpectedLeftParen(uint256 offset)` -- line 69
- `UnexpectedRightParen(uint256 offset)` -- line 72
- `UnclosedLeftParen(uint256 offset)` -- line 75
- `UnexpectedComment(uint256 offset)` -- line 78
- `UnclosedComment(uint256 offset)` -- line 81
- `MalformedCommentStart(uint256 offset)` -- line 84
- `DuplicateLHSItem(uint256 offset)` -- line 89
- `ExcessLHSItems(uint256 offset)` -- line 92
- `NotAcceptingInputs(uint256 offset)` -- line 95
- `ExcessRHSItems(uint256 offset)` -- line 98
- `WordSize(string word)` -- line 101
- `UnknownWord(string word)` -- line 104
- `MaxSources()` -- line 107
- `DanglingSource()` -- line 110
- `ParserOutOfBounds()` -- line 113
- `ParseStackOverflow()` -- line 117
- `ParseStackUnderflow()` -- line 120
- `ParenOverflow()` -- line 124
- `NoWhitespaceAfterUsingWordsFrom(uint256 offset)` -- line 127
- `InvalidSubParser(uint256 offset)` -- line 130
- `UnclosedSubParseableLiteral(uint256 offset)` -- line 133
- `SubParseableMissingDispatch(uint256 offset)` -- line 136
- `BadSubParserResult(bytes bytecode)` -- line 140
- `OpcodeIOOverflow(uint256 offset)` -- line 143
- `OperandOverflow()` -- line 146
- `ParseMemoryOverflow(uint256 freeMemoryPointer)` -- line 151
- `SourceItemOpsOverflow()` -- line 155
- `ParenInputOverflow()` -- line 159
- `LineRHSItemsOverflow()` -- line 163

### ErrStore.sol
- Contract: `ErrStore` (line 6, workaround stub)
- `OddSetLength(uint256 length)` -- line 10

### ErrSubParse.sol
- Contract: `ErrSubParse` (line 6, workaround stub)
- `ExternDispatchConstantsHeightOverflow(uint256 constantsHeight)` -- line 10
- `ConstantOpcodeConstantsHeightOverflow(uint256 constantsHeight)` -- line 14
- `ContextGridOverflow(uint256 column, uint256 row)` -- line 17

## Findings

### A03-1: No test coverage for `StackUnderflow` error

**Severity:** MEDIUM

**File:** `src/error/ErrIntegrity.sol` line 12

**Description:** The `StackUnderflow` error is defined and used in `LibIntegrityCheck.sol` (line 154) but no test in `test/` triggers this revert path. The integrity check should reject bytecode that consumes more stack values than are available, but this is never verified by a test. If a regression broke this check, stack underflow during runtime could go undetected at deploy time.

### A03-2: No test coverage for `StackUnderflowHighwater` error

**Severity:** MEDIUM

**File:** `src/error/ErrIntegrity.sol` line 18

**Description:** The `StackUnderflowHighwater` error is defined and used in `LibIntegrityCheck.sol` (line 160) but no test in `test/` triggers this revert path. This error prevents reading below the highwater mark (values consumed by earlier operations that are no longer safe to read). Without test coverage, a regression could allow unsafe stack reads to pass integrity checking.

### A03-3: No test coverage for `StackAllocationMismatch` error

**Severity:** MEDIUM

**File:** `src/error/ErrIntegrity.sol` line 24

**Description:** The `StackAllocationMismatch` error is defined and used in `LibIntegrityCheck.sol` (line 183) but no test in `test/` triggers this revert path. This error catches mismatches between the integrity-calculated stack size and the bytecode-declared allocation. Without coverage, a bug in allocation checking could lead to out-of-bounds memory access at runtime.

### A03-4: No test coverage for `StackOutputsMismatch` error

**Severity:** MEDIUM

**File:** `src/error/ErrIntegrity.sol` line 29

**Description:** The `StackOutputsMismatch` error is defined and used in `LibIntegrityCheck.sol` (line 188) but no test in `test/` triggers this revert path. This verifies that the final stack index after integrity checking matches the declared number of outputs. Without coverage, incorrect output counts could pass integrity and cause eval to return wrong data.

### A03-5: No test coverage for `HexLiteralOverflow` error

**Severity:** LOW

**File:** `src/error/ErrParse.sol` line 40

**Description:** The `HexLiteralOverflow` error is defined and used in `LibParseLiteralHex.sol` but no test in `test/` triggers this revert. The existing hex literal tests (`LibParseLiteralHex.boundHex.t.sol` and `LibParseLiteralHex.parseHex.t.sol`) only test happy-path scenarios. There are no tests for hex literals exceeding 32 bytes (256 bits).

### A03-6: No test coverage for `ZeroLengthHexLiteral` error

**Severity:** LOW

**File:** `src/error/ErrParse.sol` line 43

**Description:** The `ZeroLengthHexLiteral` error is defined and used in `LibParseLiteralHex.sol` but no test in `test/` triggers this revert. Parsing `0x` without any hex digits should revert with this error, but this case is never tested.

### A03-7: No test coverage for `OddLengthHexLiteral` error

**Severity:** LOW

**File:** `src/error/ErrParse.sol` line 46

**Description:** The `OddLengthHexLiteral` error is defined and used in `LibParseLiteralHex.sol` but no test in `test/` triggers this revert. Parsing a hex literal with an odd number of hex digits (e.g., `0x123`) should revert with this error, but this case is never tested.

### A03-8: No test coverage for `MalformedHexLiteral` error

**Severity:** LOW

**File:** `src/error/ErrParse.sol` line 49

**Description:** The `MalformedHexLiteral` error is defined and used in `LibParseLiteralHex.sol` but no test in `test/` triggers this revert. Hex literals containing non-hex characters should be rejected, but this is never tested.

### A03-9: No test coverage for `MalformedCommentStart` error

**Severity:** LOW

**File:** `src/error/ErrParse.sol` line 84

**Description:** The `MalformedCommentStart` error is defined and used in `LibParseInterstitial.sol` (line 49) but no test in `test/` triggers this revert. The comment tests (`LibParse.comments.t.sol`) test `UnexpectedComment` and `UnclosedComment` but never `MalformedCommentStart`, which catches a `/` not followed by `*` (i.e., an incomplete comment start sequence).

### A03-10: No test coverage for `NotAcceptingInputs` error

**Severity:** LOW

**File:** `src/error/ErrParse.sol` line 95

**Description:** The `NotAcceptingInputs` error is defined and used in `LibParseState.sol` (line 417) but no test in `test/` triggers this revert. This error prevents providing inputs to words that don't accept them. Without coverage, a regression could allow invalid input specifications to be silently accepted.

### A03-11: No test coverage for `DanglingSource` error

**Severity:** LOW

**File:** `src/error/ErrParse.sol` line 110

**Description:** The `DanglingSource` error is defined and used in `LibParseState.sol` (line 895) but no test in `test/` triggers this revert. The NatSpec describes this as a parser bug ("This is a bug in the parser"), which makes it a defensive check. While triggering it from outside the parser may be difficult, having no test means the defensive check itself is unverified.

### A03-12: No test coverage for `ParseStackOverflow` error

**Severity:** LOW

**File:** `src/error/ErrParse.sol` line 117

**Description:** The `ParseStackOverflow` error is defined and used in multiple locations (`LibParseState.sol` line 515, `LibParseStackTracker.sol` lines 25 and 48) but no test in `test/` triggers this revert. This error prevents the parser from processing stacks deeper than memory allows. Without coverage, a regression could lead to memory corruption in the parse system.

### A03-13: No test coverage for `ParseStackUnderflow` error

**Severity:** LOW

**File:** `src/error/ErrParse.sol` line 120

**Description:** The `ParseStackUnderflow` error is defined and used in `LibParseStackTracker.sol` (line 72) but no test in `test/` triggers this revert. This error prevents the stack tracker from underflowing, which would corrupt parse state.

### A03-14: No test coverage for `ParenOverflow` error

**Severity:** LOW

**File:** `src/error/ErrParse.sol` line 124

**Description:** The `ParenOverflow` error is defined and used in `LibParse.sol` (line 338) but no test in `test/` triggers this revert. This error prevents deeply nested parenthesis groups from exceeding the memory region allocated for paren tracking.

### A03-15: No test coverage for `OpcodeIOOverflow` error

**Severity:** LOW

**File:** `src/error/ErrParse.sol` line 143

**Description:** The `OpcodeIOOverflow` error is defined and used in `LibParseState.sol` (line 479) but no test in `test/` triggers this revert. This error prevents opcodes from having more than 16 inputs or outputs, which would overflow the 4-bit encoding.

### A03-16: No test coverage for `ParenInputOverflow` error

**Severity:** LOW

**File:** `src/error/ErrParse.sol` line 159

**Description:** The `ParenInputOverflow` error is defined and used in `LibParseState.sol` (line 711) but no test in `test/` triggers this revert. This error prevents a paren group from exceeding 255 inputs, which would cause the per-paren byte counter to silently wrap and corrupt operand data.

### A03-17: No test coverage for `BadDynamicLength` error

**Severity:** LOW

**File:** `src/error/ErrOpList.sol` line 12

**Description:** The `BadDynamicLength` error is defined and used extensively in `LibAllStandardOps.sol` (line 353, 525, 630, 734) and `RainterpreterReferenceExtern.sol` (lines 225, 302, 343, 375, 407) but no test in `test/` triggers this revert. The NatSpec states this "Should never happen outside a major breaking change to memory layouts," making it a defensive invariant check. While unlikely to be triggered in practice, this means the guard itself is unverified.

### A03-18: No test coverage for `UnknownDeploymentSuite` error

**Severity:** INFO

**File:** `src/error/ErrDeploy.sol` line 11

**Description:** The `UnknownDeploymentSuite` error is defined and used in `script/Deploy.sol` (line 114) but no test in `test/` triggers this revert. This error is only used in deployment scripts (not runtime contracts), so the impact is limited to deployment tooling. It would only trigger if the `DEPLOYMENT_SUITE` environment variable is set to an unrecognized value.
