# Pass 1 Triage

Tracks the disposition of every LOW+ finding from pass1 audit reports.
Agent IDs assigned alphabetically by source file path.

## Agent Index

| ID | File |
|----|------|
| A01 | BaseRainterpreterExtern.md |
| A02 | BaseRainterpreterSubParser.md |
| A05 | LibEval.md |
| A06 | LibExtern.md |
| A12 | LibIntegrityCheck.md |
| A14 | LibInterpreterState.md |
| A15 | LibInterpreterStateDataContract.md |
| A17 | LibOpCall.md |
| A20 | LibOpERC20.md |
| A21 | LibOpExtern.md |
| A23 | LibOpLogic.md |
| A24 | LibOpMath1.md |
| A25 | LibOpMath2.md |
| A26 | LibOpMisc.md |
| A30 | LibParse.md |
| A32 | LibParseInterstitial.md |
| A33 | LibParseLiteral.md |
| A36 | LibParseLiteralRepeat.md |
| A37 | LibParseLiteralString.md |
| A38 | LibParseLiteralSubParseable.md |
| A39 | LibParseOperand.md |
| A41 | LibParseStackName.md |
| A42 | LibParseStackTracker.md |
| A43 | LibParseState.md |
| A44 | LibSubParse.md |
| A45 | Rainterpreter.md |
| A47 | RainterpreterExpressionDeployer.md |
| A48 | RainterpreterParser.md |
| A49 | RainterpreterReferenceExtern.md |

## Findings

- [DISMISSED] A01-3: Virtual `opcodeFunctionPointers()` construction vs runtime — theoretical; reference impl returns constants
- [DISMISSED] A02-1: Bounds check integer division truncation — child contract configuration error only
- [DISMISSED] A05-1: `sourceIndex` not bounds-checked in `evalLoop` — documented trust assumption; callers validate
- [DISMISSED] A05-2: Division-by-zero if `state.fs` is empty — constructor guard prevents deployment with empty fs
- [DISMISSED] A06-1: No input validation on encoding functions — documented as caller responsibility; all callers correct
- [DISMISSED] A12-1: Unchecked `stackIndex += calcOpOutputs` — max accumulation is 4080, well within uint256
- [DISMISSED] A12-6: Unchecked subtractions guarded by preceding checks — checks verified correct
- [DISMISSED] A12-7: `fPointers` odd-length silently truncated — not user-controlled
- [DISMISSED] A14-1: `stackTrace` memory-safety annotation — save-restore pattern is safe; no reentrancy from tracer
- [DISMISSED] A14-5: No bounds validation `stackTop` vs `stackBottom` — integrity system prevents invalid inputs
- [DISMISSED] A15-1: No bounds check on `sourceIndex` in `unsafeDeserialize` — `unsafe` prefix documents caller responsibility
- [DISMISSED] A15-2: Unchecked arithmetic in `serializeSize` — practically unreachable (parser memory limits)
- [DISMISSED] A15-3: `unsafeSerialize` trusts caller-provided `cursor` — `unsafe` prefix documents this
- [DISMISSED] A15-4: `unsafeDeserialize` does not validate `serialized` structure — trust chain is sound
- [DOCUMENTED] A17-1: No runtime bounds check on `sourceIndex` — documented in commit `031fba22`
- [DOCUMENTED] A17-2: No overflow guard on `inputs`/`outputs` in stack pointer arithmetic — documented in commit `031fba22`
- [DISMISSED] A20-2: `decimals()` optional — documented in `audit/known-false-positives.md`
- [DISMISSED] A21-1: Integrity delegates trust to extern's `externIntegrity` — bytecode IO validation catches mismatches
- [DISMISSED] A21-2: ERC165 check in integrity but not in run — `staticcall` to non-conforming contract reverts
- [DISMISSED] A23-1: `revert(string)` in conditions/ensure — intentional: user-facing revert reason feature
- [DISMISSED] A24-1: `packLossy` precision loss in Add/Div — by design for decimal float arithmetic
- [DISMISSED] A24-2: Log tables external dependency — noted
- [DISMISSED] A25-6: `packLossy` precision loss in Mul/Sub — duplicate of A24-1
- [DISMISSED] A26-1: External calls to untrusted addresses — view context prevents state mutation
- [DISMISSED] A30-9: No bounds check on `subParserBytecodeLength` — max value is 196, cannot overflow
- [DISMISSED] A30-11: `parseLHS` increments `topLevel1` without overflow check — bounded by 62 max stack items
- [DISMISSED] A30-12: `parseLHS` `lineTracker++` without overflow check — bounded by 62 max stack items
- [DISMISSED] A30-13: `parse` cursor != end check — correct defensive programming
- [DISMISSED] A32-1: `CMASK_COMMENT_END_SEQUENCE_END` naming — upstream issue in rain.string; code is correct
- [DISMISSED] A33-1: No bounds check in `selectLiteralParserByIndex` — only called with compile-time constants (0-3)
- [DOCUMENTED] A36-1: Unchecked arithmetic — documented in commit `63ec23c3`
- [DISMISSED] A37-6: Reading one byte past `end` in `finalChar` check — mitigated by `end == innerEnd` guard
- [FIXED] A38-1: Out-of-bounds memory read when no closing bracket — guard added in commit `62c550e5`
- [DISMISSED] A38-2: Entire function body in unchecked block — cursor is memory pointer, cannot wrap
- [DISMISSED] A39-6: Operand values array bypass of Solidity bounds checking — guard at line 87 is correct
- [DISMISSED] A41-4: Assembly `memory-safe` with linked-list pointer reads — pointers from allocated memory; ParseMemoryOverflow guard
- [DOCUMENTED] A42-1: `pop()` direct subtraction vs `push()` repack — documented in commit `d6ef5731`
- [DISMISSED] A42-3: Unchecked addition wrapping in `push()` — MEDIUM in report, but `n` from opcode integrity (small constants)
- [FIXED] A43-1: `highwater` off-by-one `==` vs `>=` — changed to `>=` in commit `d6ef5731`
- [DOCUMENTED] A43-2: `pushSubParser` 16-bit pointer truncation — MEDIUM in report, documented in commit `8b86dc88`
- [DISMISSED] A43-3: `exportSubParsers` unbounded write — linked list cannot be circular (monotonic allocation)
- [DISMISSED] A43-4: `endLine` unchecked subtraction — invariant maintained by construction
- [DOCUMENTED] A43-5: `pushOpToSource` operand/opcode overflow — documented in commit `8d4fb623`
- [DISMISSED] A43-11: `buildConstants` loop termination — consistent invariant with #3/#4
- [DOCUMENTED] A44-2: No validation of ioByte range in `subParserExtern` — documented in commit `f7b254be`
- [DOCUMENTED] A44-3: No validation of opcodeIndex range in `subParserExtern` — documented in commit `f7b254be`
- [DISMISSED] A45-10: Eval loop function pointer dispatch via `mod` — already documented; gas optimization over branching
- [DISMISSED] A47-3: `serializeSize` uses unchecked arithmetic — same as A15-2
- [DISMISSED] A48-1: No runtime codehash verification of parser — deterministic deployment model
- [DISMISSED] A48-4: `parsePragma1` discards remaining cursor — intentional
- [DISMISSED] A49-1: Assembly reinterprets fixed-length arrays as dynamic — established pattern with sanity checks
- [DISMISSED] A49-2: `matchSubParseLiteralDispatch` reads 32 bytes without bounds check — mask discards extra bytes
- [DISMISSED] A49-3: `matchSubParseLiteralDispatch` unchecked subtraction — `end >= cursor` guaranteed by caller

# Pass 2 Triage

Tracks the disposition of every LOW+ finding from pass2 audit reports (test coverage).

## Agent Index

| ID | File |
|----|------|
| A01 | BaseRainterpreterExtern.md |
| A02 | BaseRainterpreterSubParser.md |
| A03 | ErrAll.md |
| A04 | LibAllStandardOps.md |
| A05 | LibEval.md |
| A06 | LibExtern.md |
| A07 | LibExternOpContextCallingContract.md |
| A08 | LibExternOpContextRainlen.md |
| A09 | LibExternOpContextSender.md |
| A10 | LibExternOpIntInc.md |
| A11 | LibExternOpStackOperand.md |
| A12 | LibIntegrityCheck.md |
| A14 | LibInterpreterState.md |
| A15 | LibInterpreterStateDataContract.md |
| A16 | LibOpBitwise.md |
| A17 | LibOpCall.md |
| A18 | LibOpConstant.md |
| A19 | LibOpContext.md |
| A20 | LibOpERC20.md |
| A21 | LibOpExtern.md |
| A23 | LibOpLogic.md |
| A24 | LibOpMath1.md |
| A25 | LibOpMath2.md |
| A26 | LibOpMisc.md |
| A28 | LibOpStore.md |
| A29 | LibOpUint256Math.md |
| A30 | LibParse.md |
| A31 | LibParseError.md |
| A32 | LibParseInterstitial.md |
| A33 | LibParseLiteral.md |
| A34 | LibParseLiteralDecimal.md |
| A35 | LibParseLiteralHex.md |
| A36 | LibParseLiteralRepeat.md |
| A37 | LibParseLiteralString.md |
| A38 | LibParseLiteralSubParseable.md |
| A39 | LibParseOperand.md |
| A40 | LibParsePragma.md |
| A41 | LibParseStackName.md |
| A42 | LibParseStackTracker.md |
| A43 | LibParseState.md |
| A44 | LibSubParse.md |
| A45 | Rainterpreter.md |
| A47 | RainterpreterExpressionDeployer.md |
| A48 | RainterpreterParser.md |
| A49 | RainterpreterReferenceExtern.md |
| A50 | RainterpreterStore.md |

## Findings

- [FIXED] A01-1: (LOW) No direct test for `extern()` happy path on BaseRainterpreterExtern — added in commit `738670ca`
- [FIXED] A01-2: (MEDIUM) No test for `extern()` opcode mod-wrapping behavior — added in commit `6575278e`
- [FIXED] A01-3: (LOW) No test for `externIntegrity()` happy path on BaseRainterpreterExtern — added in commit `da2c3ef1`
- [FIXED] A01-4: (LOW) No test for `externIntegrity()` boundary at opcode == fsCount - 1 — added in commit `7f34586c`
- [DISMISSED] A01-5: (LOW) No test for dispatch encoding extraction correctness in `extern()` and `externIntegrity()` — already covered by LibExtern.codec.t.sol roundtrip tests and A01-3 fuzz test
- [FIXED] A02-1: (MEDIUM) No test for `SubParserIndexOutOfBounds` revert in `subParseWord2` — added in commit `5f84a073`
- [FIXED] A02-2: (MEDIUM) No test for `SubParserIndexOutOfBounds` revert in `subParseLiteral2` — added in commit `fc5de00d`
- [FIXED] A02-3: (LOW) No direct unit tests for `subParseLiteral2` on BaseRainterpreterSubParser — added in commit `59ce761f`
- [FIXED] A02-4: (LOW) No test for `subParseWord2` with empty/zero-length word parsers table — added in commit `9e163d06`
- [FIXED] A03-1: (MEDIUM) No test coverage for `StackUnderflow` error — added in commit `40cfbd3f`
- [FIXED] A03-2: (MEDIUM) No test coverage for `StackUnderflowHighwater` error — added in commit `fcc6ab97`
- [FIXED] A03-3: (MEDIUM) No test coverage for `StackAllocationMismatch` error — added in commit `2b4ff3e6`
- [FIXED] A03-4: (MEDIUM) No test coverage for `StackOutputsMismatch` error — added in commit `cafb9430`
- [FIXED] A03-5: (LOW) No test coverage for `HexLiteralOverflow` error — added in commit `b1a0f3ca`
- [FIXED] A03-6: (LOW) No test coverage for `ZeroLengthHexLiteral` error — added in commit `adc0f858`
- [FIXED] A03-7: (LOW) No test coverage for `OddLengthHexLiteral` error — added in commit `66f2d6f9`
- [DISMISSED] A03-8: (LOW) No test coverage for `MalformedHexLiteral` error — unreachable defensive code; `boundHex` constrains the range to valid hex characters before the loop runs
- [FIXED] A03-9: (LOW) No test coverage for `MalformedCommentStart` error — added in commit `18339c10`
- [FIXED] A03-10: (LOW) No test coverage for `NotAcceptingInputs` error — added in commit `2878c38b`
- [DISMISSED] A03-11: (LOW) No test coverage for `DanglingSource` error — unreachable defensive code; `MissingFinalSemi` fires first for any user input that leaves a source open
- [FIXED] A03-12: (LOW) No test coverage for `ParseStackOverflow` error — added in commit `9ff8560f`
- [DISMISSED] A03-13: (LOW) No test coverage for `ParseStackUnderflow` error — unreachable defensive code; parser paren-counting guarantees child ops push exactly the inputs each parent pops
- [FIXED] A03-14: (LOW) No test coverage for `ParenOverflow` error — added in commit `fe692342`
- [FIXED] A03-15: (LOW) No test coverage for `OpcodeIOOverflow` error — added in commit `4cbcff64`
- [DISMISSED] A03-16: (LOW) No test coverage for `ParenInputOverflow` error — unreachable defensive code; `SourceItemOpsOverflow` is checked first at the same threshold in `pushOpToSource`
- [DISMISSED] A03-17: (LOW) No test coverage for `BadDynamicLength` error — unreachable defensive code; guards compile-time fixed-to-dynamic array casts, code comments "Should be an unreachable error"
- [FIXED] A04-1: (LOW) No direct test for `literalParserFunctionPointers()` output length — added in commit `82389695`
- [FIXED] A04-2: (LOW) No direct test for `operandHandlerFunctionPointers()` output length — added in commit `c7e65302`
- [FIXED] A04-4: (LOW) No test verifying `authoringMetaV2()` content correctness — added in commit `efe2a7f3`
- [FIXED] A04-5: (MEDIUM) No test verifying four-array ordering consistency — added in commit `1efea00e`
- [DISMISSED] A05-1: (LOW) No direct unit test for `evalLoop` function — extensively exercised through every opcode test and eval4 integration test; standalone test would duplicate existing coverage
- [PENDING] A05-2: (MEDIUM) `InputsLengthMismatch` only tested for too-many-inputs direction
- [PENDING] A05-3: (MEDIUM) No test for `maxOutputs` truncation behavior in `eval2`
- [PENDING] A05-4: (LOW) No test for zero-opcode source in `evalLoop`
- [PENDING] A05-5: (LOW) No test for multiple sources exercised through `eval2`
- [PENDING] A05-6: (LOW) No test for `eval2` with non-zero inputs that match source expectation
- [PENDING] A05-7: (LOW) No test for exact multiple-of-8 opcode count (zero remainder)
- [PENDING] A06-1: (LOW) No test for encode/decode roundtrip with varied extern addresses
- [PENDING] A06-2: (MEDIUM) No test for overflow/truncation behavior when opcode or operand exceeds 16 bits
- [PENDING] A06-3: (LOW) `decodeExternDispatch` and `decodeExternCall` have no standalone unit tests
- [PENDING] A07-1: (LOW) No direct unit test for LibExternOpContextCallingContract.subParser
- [PENDING] A07-2: (LOW) No test for subParser with varying constantsHeight or ioByte inputs
- [PENDING] A08-1: (LOW) No direct unit test for LibExternOpContextRainlen.subParser
- [PENDING] A08-2: (LOW) No test for subParser with varying constantsHeight or ioByte inputs
- [PENDING] A08-3: (LOW) Only one end-to-end test with a single rainlang string length
- [PENDING] A09-1: (LOW) No direct unit test for LibExternOpContextSender.subParser
- [PENDING] A09-2: (LOW) No test for subParser with varying constantsHeight or ioByte inputs
- [PENDING] A09-3: (LOW) No test with different msg.sender values
- [PENDING] A10-1: (LOW) run() test bounds inputs away from float overflow region
- [PENDING] A11-1: (LOW) No direct unit test for LibExternOpStackOperand.subParser
- [PENDING] A11-2: (LOW) No test for subParser with constantsHeight > 0
- [FIXED] A12-1: (HIGH) No direct test for `StackUnderflow` revert path — testStackUnderflow() added
- [FIXED] A12-2: (HIGH) No direct test for `StackUnderflowHighwater` revert path — testStackUnderflowHighwater() added
- [FIXED] A12-3: (HIGH) No direct test for `StackAllocationMismatch` revert path — testStackAllocationMismatch() added
- [FIXED] A12-4: (HIGH) No direct test for `StackOutputsMismatch` revert path — testStackOutputsMismatch() added
- [PENDING] A12-5: (MEDIUM) No test for `newState` initialization correctness
- [PENDING] A12-6: (MEDIUM) No test for multi-output highwater advancement logic
- [PENDING] A12-7: (LOW) No test for `stackMaxIndex` tracking logic
- [PENDING] A12-8: (LOW) No test for zero-source bytecode (`sourceCount == 0`)
- [PENDING] A12-9: (LOW) No test for multi-source bytecode integrity checking
- [PENDING] A14-1: (LOW) No dedicated test for `fingerprint` function
- [PENDING] A14-2: (LOW) No dedicated test for `stackBottoms` function
- [PENDING] A14-3: (LOW) `stackTrace` test does not cover parentSourceIndex/sourceIndex encoding edge cases
- [FIXED] A15-1: (HIGH) No test file exists for LibInterpreterStateDataContract — added LibInterpreterStateDataContract.t.sol
- [PENDING] A15-2: (MEDIUM) `serializeSize` unchecked overflow not tested
- [PENDING] A15-3: (MEDIUM) `unsafeSerialize` correctness not independently tested
- [FIXED] A15-4: (HIGH) `unsafeDeserialize` complex assembly not independently tested — covered by round-trip and stack allocation tests
- [PENDING] A15-5: (MEDIUM) No test for serialize/deserialize round-trip property
- [PENDING] A16-1: (LOW) LibOpCtPop missing test for disallowed operand
- [PENDING] A17-1: (MEDIUM) No referenceFn or direct unit test for `run` function assembly logic
- [PENDING] A17-2: (LOW) No test for `run` with maximum inputs (15) and maximum outputs simultaneously
- [PENDING] A17-3: (LOW) No isolated test for operand field extraction consistency between `integrity` and `run`
- [PENDING] A18-1: (LOW) No test for `run` with a constants array at maximum operand index (65535)
- [PENDING] A19-1: (LOW) No test for context with empty inner array (context[i].length == 0, j == 0)
- [PENDING] A19-2: (LOW) No test for large context dimensions (i or j near 255)
- [PENDING] A20-1: (LOW) No test verifying `erc20-allowance` handles infinite approvals without revert
- [PENDING] A20-2: (LOW) No test for `decimals()` revert when token does not implement `IERC20Metadata`
- [PENDING] A20-4: (LOW) No test for input values with upper 96 bits set (address truncation)
- [PENDING] A21-1: (LOW) No test for `referenceFn` `BadOutputsLength` revert path
- [PENDING] A23-1: (LOW) LibOpGreaterThanOrEqualTo missing negative number and float equality eval tests
- [PENDING] A23-2: (LOW) LibOpLessThanOrEqualTo missing negative number and float equality eval tests
- [PENDING] A23-3: (LOW) LibOpConditions no test for exactly 2 inputs (minimum case)
- [PENDING] A23-4: (LOW) LibOpConditions odd-input revert path with reason string not tested via opReferenceCheck
- [PENDING] A24-1: (LOW) LibOpE missing operand disallowed test
- [PENDING] A24-2: (LOW) LibOpExp and LibOpExp2 fuzz tests restrict inputs to non-negative small values only
- [PENDING] A24-3: (LOW) LibOpGm fuzz test restricts inputs to non-negative small values only
- [PENDING] A24-4: (LOW) LibOpFloor eval tests missing negative value coverage
- [PENDING] A25-1: (LOW) LibOpInv missing test for division by zero (inv(0))
- [PENDING] A25-2: (LOW) LibOpSub missing zero outputs and two outputs tests
- [PENDING] A25-3: (LOW) LibOpSub missing operand handler test
- [PENDING] A25-4: (LOW) LibOpMin missing zero outputs and two outputs tests
- [PENDING] A25-5: (LOW) LibOpMax missing zero outputs test
- [PENDING] A25-6: (LOW) LibOpSqrt missing test for negative input error path
- [PENDING] A26-1: (LOW) Missing operand disallowed test for LibOpBlockNumber
- [PENDING] A26-2: (LOW) Missing operand disallowed test for LibOpChainId
- [PENDING] A26-3: (LOW) Missing operand disallowed test for LibOpTimestamp
- [PENDING] A28-1: (LOW) No test for get() caching side effect on read-only keys
- [PENDING] A29-1: (LOW) LibOpMaxUint256 missing operand disallowed test
- [PENDING] A30-1: (MEDIUM) No test triggers `ParenOverflow` error
- [PENDING] A30-2: (LOW) No test triggers `ParserOutOfBounds` error from `parse()`
- [PENDING] A30-3: (LOW) No test for yang-state `UnexpectedRHSChar` in `parseRHS`
- [PENDING] A30-4: (LOW) No test for stack name fallback path in `parseRHS` via `stackNameIndex`
- [PENDING] A30-5: (LOW) No test for `OPCODE_UNKNOWN` sub-parser bytecode construction boundary conditions
- [PENDING] A31-1: (LOW) No direct unit tests for `parseErrorOffset`
- [PENDING] A31-2: (LOW) No direct unit tests for `handleErrorSelector`
- [PENDING] A32-1: (LOW) No direct unit tests for `skipComment`, `skipWhitespace`, or `parseInterstitial`
- [PENDING] A32-2: (MEDIUM) `MalformedCommentStart` error path is never tested
- [PENDING] A32-3: (LOW) No test for `skipComment` when `cursor + 4 > end`
- [PENDING] A32-4: (LOW) No test for `skipWhitespace` in isolation
- [PENDING] A33-1: (MEDIUM) No direct unit test for `selectLiteralParserByIndex`
- [PENDING] A33-2: (LOW) No direct unit test for `tryParseLiteral` dispatch logic
- [PENDING] A33-3: (LOW) No test for `parseLiteral` revert path
- [PENDING] A34-1: (MEDIUM) No happy-path unit test for `parseDecimalFloatPacked`
- [PENDING] A34-2: (LOW) No fuzz test for decimal parsing round-trip
- [PENDING] A34-3: (LOW) No test for cursor position after successful parse
- [PENDING] A34-4: (LOW) No test for decimal values with fractional parts
- [PENDING] A35-1: (MEDIUM) No test for `HexLiteralOverflow` error
- [PENDING] A35-2: (MEDIUM) No test for `ZeroLengthHexLiteral` error
- [PENDING] A35-3: (MEDIUM) No test for `OddLengthHexLiteral` error
- [PENDING] A35-4: (LOW) No test for `MalformedHexLiteral` error
- [PENDING] A35-5: (LOW) No test for mixed-case hex parsing
- [PENDING] A36-1: (MEDIUM) No test for RepeatLiteralTooLong revert path
- [PENDING] A36-2: (MEDIUM) No test for parseRepeat output value correctness
- [PENDING] A36-3: (LOW) No test for zero-length literal body (cursor == end)
- [PENDING] A36-4: (LOW) No test for length = 1 (single character body)
- [PENDING] A36-5: (LOW) No test for length = 77 (maximum valid length)
- [PENDING] A36-6: (LOW) Integration tests use bare vm.expectRevert() without specifying expected error
- [PENDING] A37-1: (LOW) No explicit test for `parseString` memory snapshot restoration
- [PENDING] A37-3: (LOW) No test for `UnclosedStringLiteral` when `end == innerEnd`
- [PENDING] A38-1: (MEDIUM) No test for `subParseLiteral` returning `(false, ...)` (sub-parser rejection)
- [PENDING] A38-2: (LOW) No fuzz test for the error paths
- [PENDING] A39-1: (MEDIUM) `handleOperandDisallowedAlwaysOne` has no test file or any test coverage
- [PENDING] A39-2: (LOW) `handleOperand` (dispatch function) has no direct unit test
- [PENDING] A39-3: (LOW) `parseOperand` -- no test for `UnclosedOperand` revert from yang state
- [PENDING] A39-5: (LOW) `handleOperandM1M1` -- no test for first value overflow with two values provided
- [PENDING] A39-6: (LOW) `handleOperand8M1M1` -- no test for first value overflow with all three values provided
- [PENDING] A40-1: (LOW) No unit test for `cursor >= end` revert path after keyword
- [PENDING] A40-2: (LOW) No test for multiple pragmas in sequence
- [PENDING] A40-3: (LOW) No test for pragma with comments between addresses
- [PENDING] A41-1: (LOW) No test for bloom filter false positive path
- [PENDING] A41-2: (LOW) No test for fingerprint collision behavior
- [PENDING] A41-3: (LOW) No negative lookup test on populated list
- [PENDING] A42-1: (CRITICAL) No direct unit tests for any function in LibParseStackTracker
- [FIXED] A42-2: (HIGH) ParseStackOverflow in push() never tested — testPushOverflow added
- [FIXED] A42-3: (HIGH) ParseStackUnderflow in pop() never tested — testPopUnderflow added
- [FIXED] A42-4: (HIGH) ParseStackOverflow in pushInputs() never tested — testPushInputsOverflow added
- [PENDING] A42-5: (MEDIUM) High watermark update logic not tested
- [PENDING] A42-6: (MEDIUM) Packed representation correctness not tested
- [FIXED] A43-1: (HIGH) No direct unit test for endLine() — endLine.t.sol and endLine.OpcodeIOOverflow.t.sol exist
- [PENDING] A43-2: (MEDIUM) NotAcceptingInputs error path never tested
- [PENDING] A43-3: (MEDIUM) OpcodeIOOverflow error path never tested
- [PENDING] A43-4: (MEDIUM) DanglingSource error path never tested
- [PENDING] A43-5: (MEDIUM) ParenInputOverflow error path never tested
- [PENDING] A43-6: (MEDIUM) ParseStackOverflow in highwater() never tested
- [PENDING] A43-7: (MEDIUM) No direct unit tests for pushOpToSource()
- [PENDING] A43-8: (MEDIUM) No direct unit tests for endSource()
- [PENDING] A43-9: (MEDIUM) No direct unit tests for buildBytecode()
- [PENDING] A43-10: (LOW) No direct unit tests for buildConstants()
- [PENDING] A43-11: (LOW) No direct unit tests for pushLiteral()
- [FIXED] A44-1: (HIGH) No direct unit test for subParseWordSlice() — all paths covered by integration tests (badSubParserResult.t.sol, unknownWord.t.sol, intInc.t.sol)
- [PENDING] A44-2: (MEDIUM) UnknownWord error path tested only via integration
- [PENDING] A44-3: (MEDIUM) UnsupportedLiteralType error path in subParseLiteral() not directly tested
- [PENDING] A44-4: (LOW) No direct unit test for subParseWords()
- [PENDING] A44-5: (LOW) No direct unit test for subParseLiteral()
- [PENDING] A44-6: (LOW) No direct unit test for consumeSubParseWordInputData()
- [PENDING] A44-7: (LOW) No direct unit test for consumeSubParseLiteralInputData()
- [PENDING] A44-8: (LOW) Sub parser constant accumulation not tested
- [PENDING] A45-1: (LOW) No test for `InputsLengthMismatch` with fewer inputs than expected
- [PENDING] A45-2: (LOW) No direct test for `eval4` happy path with inputs
- [PENDING] A45-3: (LOW) No test for `eval4` with non-zero `sourceIndex`
- [PENDING] A45-5: (LOW) No test for `stateOverlay` with multiple key-value pairs
- [PENDING] A45-6: (LOW) No test for `stateOverlay` with duplicate keys
- [PENDING] A47-1: (MEDIUM) No direct test for `parse2` with invalid input
- [PENDING] A47-2: (MEDIUM) No direct test for `parsePragma1` on the expression deployer
- [PENDING] A47-3: (LOW) No test for `buildIntegrityFunctionPointers` return value consistency
- [PENDING] A47-4: (LOW) No test for `parse2` assembly block memory allocation
- [PENDING] A48-1: (MEDIUM) No direct test for `unsafeParse`
- [PENDING] A48-3: (LOW) No test for `unsafeParse` with input triggering `ParseMemoryOverflow`
- [PENDING] A48-4: (LOW) No test for `parsePragma1` with empty input
- [PENDING] A49-1: (LOW) `InvalidRepeatCount` error not directly asserted in revert tests
- [PENDING] A49-2: (LOW) `BadDynamicLength` error path never tested
- [PENDING] A49-3: (LOW) `SubParserIndexOutOfBounds` error path never tested for RainterpreterReferenceExtern
- [PENDING] A49-4: (LOW) No test for `extern()` function called directly on RainterpreterReferenceExtern
- [PENDING] A49-5: (LOW) No test for `externIntegrity()` called directly on RainterpreterReferenceExtern
- [PENDING] A50-1: (MEDIUM) No test for namespace isolation across different `msg.sender` values
- [PENDING] A50-2: (LOW) `Set` event emission never tested
- [PENDING] A50-3: (LOW) No test for `set` with empty array (zero-length `kvs`)
- [PENDING] A50-4: (LOW) No test for `get` on uninitialized key (default value)
- [PENDING] A50-5: (LOW) No test for overwriting a key with a different value in a single `set` call

# Pass 3 Triage

Tracks the disposition of every LOW+ finding from pass3 audit reports (documentation).
Agent IDs are prefixed P3- to disambiguate from other passes.

## Findings

### MEDIUM

- [UPSTREAM] P3-A04-2: (MEDIUM) `parse2` has no meaningful NatSpec -- `@inheritdoc` inherits nothing from IParserV2 — fix in rain.interpreter.interface
- [FIXED] P3-A06-9: (MEDIUM) `matchSubParseLiteralDispatch()` is entirely undocumented — added @inheritdoc BaseRainterpreterSubParser
- [PENDING] P3-A20-3: (MEDIUM) LibOpMul `integrity` missing `@param` and `@return` tags
- [PENDING] P3-A20-4: (MEDIUM) LibOpMul `run` missing `@param` and `@return` tags
- [PENDING] P3-A20-5: (MEDIUM) LibOpMul `referenceFn` missing `@param` and `@return` tags
- [PENDING] P3-A20-6: (MEDIUM) LibOpPow `integrity` missing `@param` and `@return` tags
- [PENDING] P3-A20-7: (MEDIUM) LibOpPow `run` missing `@param` and `@return` tags
- [PENDING] P3-A20-8: (MEDIUM) LibOpPow `referenceFn` missing `@param` and `@return` tags
- [PENDING] P3-A20-9: (MEDIUM) LibOpSqrt `integrity` missing `@param` and `@return` tags
- [PENDING] P3-A20-10: (MEDIUM) LibOpSqrt `run` missing `@param` and `@return` tags
- [PENDING] P3-A20-11: (MEDIUM) LibOpSqrt `referenceFn` missing `@param` and `@return` tags
- [PENDING] P3-A20-12: (MEDIUM) LibOpSub `integrity` missing `@param` and `@return` tags
- [PENDING] P3-A20-13: (MEDIUM) LibOpSub `run` missing `@param` and `@return` tags
- [PENDING] P3-A20-14: (MEDIUM) LibOpSub `referenceFn` missing `@param` and `@return` tags
- [PENDING] P3-A25-2: (MEDIUM) `ParseState` struct has stale `@param literalBloom` referencing non-existent field
- [PENDING] P3-A25-3: (MEDIUM) `ParseState` struct missing `@param` for 8 fields
- [PENDING] P3-A28-1: (MEDIUM) `InterpreterState` struct has no NatSpec documentation

### LOW (unique findings)

- [PENDING] P3-A01-1: (LOW) `opcodeFunctionPointers` missing `@return` tag
- [PENDING] P3-A01-2: (LOW) `integrityFunctionPointers` missing `@return` tag
- [PENDING] P3-A02-1: (LOW) `subParserParseMeta` missing `@return` tag
- [PENDING] P3-A02-2: (LOW) `subParserWordParsers` missing `@return` tag
- [PENDING] P3-A02-3: (LOW) `subParserOperandHandlers` missing `@return` tag
- [PENDING] P3-A02-4: (LOW) `subParserLiteralParsers` missing `@return` tag
- [PENDING] P3-A02-5: (LOW) `subParseLiteral2` `@inheritdoc` lacks implementation-specific docs
- [PENDING] P3-A02-6: (LOW) `subParseWord2` `@inheritdoc` lacks implementation-specific docs
- [PENDING] P3-A02-7: (LOW) `supportsInterface` override does not document which interfaces it supports
- [PENDING] P3-A03-1: (LOW) Rainterpreter constructor has no NatSpec
- [PENDING] P3-A03-2: (LOW) `opcodeFunctionPointers()` NatSpec lacks function description
- [PENDING] P3-A03-6: (LOW) Contract-level NatSpec uses `@notice` and is minimal
- [PENDING] P3-A03-7: (LOW) RainterpreterDISPaiRegistry all four getters lack `@return` tags
- [PENDING] P3-A04-1: (LOW) RainterpreterExpressionDeployer contract-level NatSpec is title-only
- [PENDING] P3-A04-3: (LOW) `parsePragma1` missing `@param` and `@return` tags
- [PENDING] P3-A05-1: (LOW) `unsafeParse` missing `@param` and `@return` tags
- [PENDING] P3-A05-2: (LOW) `parsePragma1` on RainterpreterParser missing `@param` and `@return` tags
- [PENDING] P3-A05-3: (LOW) `parseMeta` missing `@return` tag
- [PENDING] P3-A05-4: (LOW) `operandHandlerFunctionPointers` missing `@return` tag
- [PENDING] P3-A05-5: (LOW) `literalParserFunctionPointers` missing `@return` tag
- [PENDING] P3-A05-6: (LOW) `buildOperandHandlerFunctionPointers` missing `@return` tag
- [PENDING] P3-A05-7: (LOW) `buildLiteralParserFunctionPointers` missing `@return` tag
- [PENDING] P3-A06-1: (LOW) `authoringMetaV2()` lacks `@return` tag on RainterpreterReferenceExtern
- [PENDING] P3-A06-2: (LOW) `describedByMetaV1()` relies solely on `@inheritdoc`
- [PENDING] P3-A06-3: (LOW) `subParserParseMeta()` lacks `@return` tag on RainterpreterReferenceExtern
- [PENDING] P3-A06-4: (LOW) `subParserWordParsers()` lacks `@return` tag on RainterpreterReferenceExtern
- [PENDING] P3-A06-5: (LOW) `subParserOperandHandlers()` lacks `@return` tag on RainterpreterReferenceExtern
- [PENDING] P3-A06-6: (LOW) `subParserLiteralParsers()` lacks `@return` tag on RainterpreterReferenceExtern
- [PENDING] P3-A06-7: (LOW) `opcodeFunctionPointers()` lacks `@return` tag on RainterpreterReferenceExtern
- [PENDING] P3-A06-8: (LOW) `integrityFunctionPointers()` lacks `@return` tag on RainterpreterReferenceExtern
- [PENDING] P3-A06-10: (LOW) `buildLiteralParserFunctionPointers()` lacks `@return` tag on RainterpreterReferenceExtern
- [PENDING] P3-A06-11: (LOW) `buildOperandHandlerFunctionPointers()` lacks `@return` tag on RainterpreterReferenceExtern
- [PENDING] P3-A06-12: (LOW) `buildSubParserWordParsers()` lacks `@return` tag on RainterpreterReferenceExtern
- [PENDING] P3-A06-13: (LOW) `buildOpcodeFunctionPointers()` lacks `@return` and `@inheritdoc`
- [PENDING] P3-A06-14: (LOW) `buildIntegrityFunctionPointers()` lacks `@return` and `@inheritdoc`
- [PENDING] P3-A06-15: (LOW) `supportsInterface()` lacks `@param` tag on RainterpreterReferenceExtern
- [PENDING] P3-A07-1: (LOW) `BadOutputsLength` in ErrExtern.sol missing `@param` tags
- [PENDING] P3-A07-2..A07-30: (LOW) 29 errors in ErrParse.sol missing `@param` tags
- [PENDING] P3-A08-2: (LOW) `eval2` NatSpec "parallel arrays" is ambiguous
- [PENDING] P3-A09-1: (LOW) `encodeExternDispatch` missing `@param` and `@return` tags
- [PENDING] P3-A09-2: (LOW) `decodeExternDispatch` missing `@param` and `@return` tags
- [PENDING] P3-A09-3: (LOW) `encodeExternCall` missing `@param` and `@return` tags
- [PENDING] P3-A09-4: (LOW) `decodeExternCall` missing `@param` and `@return` tags
- [PENDING] P3-A09-5: (LOW) `LibExternOpContextCallingContract.subParser` missing `@param`/`@return`
- [PENDING] P3-A09-6: (LOW) `LibExternOpContextRainlen.subParser` missing `@param`/`@return`
- [PENDING] P3-A09-8: (LOW) `LibExternOpContextSender.subParser` missing `@param`/`@return`
- [PENDING] P3-A09-9: (LOW) `LibExternOpIntInc.run` missing `@param`/`@return`
- [PENDING] P3-A09-10: (LOW) `LibExternOpIntInc.integrity` missing `@param`/`@return`
- [PENDING] P3-A09-11: (LOW) `LibExternOpIntInc.subParser` missing `@param`/`@return`
- [PENDING] P3-A09-12: (LOW) `LibExternOpStackOperand.subParser` missing NatSpec entirely
- [PENDING] P3-A10-1: (LOW) `IntegrityCheckState` struct has no NatSpec
- [PENDING] P3-A11-1: (LOW) `authoringMetaV2()` missing `@return` tag in LibAllStandardOps
- [PENDING] P3-A11-2: (LOW) `literalParserFunctionPointers()` missing `@return` tag
- [PENDING] P3-A11-3: (LOW) `operandHandlerFunctionPointers()` missing `@return` tag
- [PENDING] P3-A11-4: (LOW) `integrityFunctionPointers()` missing `@return` tag
- [PENDING] P3-A11-5: (LOW) `opcodeFunctionPointers()` missing `@return` tag
- [PENDING] P3-A13-16: (LOW) `@title` NatSpec missing `Lib` prefix on `LibOpUint256ERC20BalanceOf`
- [PENDING] P3-A14-7: (LOW) Unnamed function parameters prevent formal `@param` tags
- [PENDING] P3-A17-21: (LOW) LibOpExp2 `referenceFn` NatSpec says "exp" instead of "exp2"
- [PENDING] P3-A18-1: (LOW) LibOpFrac library-level NatSpec uses `@notice` contrary to convention
- [PENDING] P3-A18-2: (LOW) LibOpGm library-level NatSpec uses `@notice` contrary to convention
- [PENDING] P3-A18-3: (LOW) LibOpInv library-level NatSpec uses `@notice` contrary to convention
- [PENDING] P3-A18-7: (LOW) LibOpHeadroom `run` NatSpec is inaccurate/incomplete
- [PENDING] P3-A20-1: (LOW) LibOpPow library-level NatSpec uses `@notice` contrary to convention
- [PENDING] P3-A20-2: (LOW) LibOpSqrt library-level NatSpec uses `@notice` contrary to convention
- [PENDING] P3-A20-15: (LOW) LibOpMul/LibOpSub `run` NatSpec is single word with no description
- [PENDING] P3-A23-1: (LOW) File-level constants in LibParse lack NatSpec
- [PENDING] P3-A23-3: (LOW) `parseWord` `@return` tags lack named identifiers
- [PENDING] P3-A23-4: (LOW) `parseLHS` NatSpec omits FSM transition details
- [PENDING] P3-A23-5: (LOW) `parseRHS` NatSpec omits significant implementation details
- [PENDING] P3-A24-4: (LOW) `handleOperandSingleFull` NatSpec inaccurate
- [PENDING] P3-A24-5: (LOW) `handleOperandSingleFullNoDefault` NatSpec omits conversion detail
- [PENDING] P3-A24-6: (LOW) `handleOperandDoublePerByteNoDefault` NatSpec inaccurate
- [PENDING] P3-A24-7: (LOW) `handleOperand8M1M1` NatSpec incomplete
- [PENDING] P3-A24-8: (LOW) `handleOperandM1M1` NatSpec incomplete
- [PENDING] P3-A25-1: (LOW) `ParseStackTracker` user-defined type has no NatSpec
- [PENDING] P3-A25-4: (LOW) Constants `FSM_YANG_MASK` and `FSM_WORD_END_MASK` have no NatSpec
- [PENDING] P3-A25-5: (LOW) `ParseState.fsm` NatSpec bit layout does not match constants
- [PENDING] P3-A25-6: (LOW) `endLine` function NatSpec is minimal
- [PENDING] P3-A25-8: (LOW) Offset constants do not document how values were derived
- [PENDING] P3-A27-1: (LOW) `selectLiteralParserByIndex` missing `@param`/`@return`
- [PENDING] P3-A27-2: (LOW) `parseLiteral` missing `@param`/`@return`
- [PENDING] P3-A27-3: (LOW) `tryParseLiteral` missing `@param`/`@return`
- [PENDING] P3-A27-4: (LOW) `parseDecimalFloatPacked` missing `@param`/`@return`
- [PENDING] P3-A27-5: (LOW) `boundHex` missing `@param`/`@return`
- [PENDING] P3-A27-6: (LOW) `parseHex` missing `@param`/`@return`
- [PENDING] P3-A27-7: (LOW) `boundString` missing `@param`/`@return`
- [PENDING] P3-A27-9: (LOW) `parseString` missing `@param`/`@return`
- [PENDING] P3-A27-10: (LOW) `parseSubParseable` missing `@param`/`@return`
- [PENDING] P3-A28-2: (LOW) `STACK_TRACER` constant has no NatSpec
- [PENDING] P3-A28-3: (LOW) `stackTrace` NatSpec stale
- [PENDING] P3-A28-5: (LOW) `unsafeSerialize` NatSpec doesn't document local cursor advancement

### LOW (batch: missing @param/@return on opcode functions)

- [PENDING] P3-BATCH-OPCODES: (LOW) ~150 findings for missing `@param`/`@return` tags on `integrity`/`run`/`referenceFn` across opcode libraries (LibOpConstant, LibOpContext, LibOpExtern, LibOpStack, all bitwise ops, all ERC20 ops, all ERC5313/ERC721/EVM ops, all logic ops, all math ops except Mul/Pow/Sqrt/Sub which are MEDIUM above, all growth/uint256 math ops, store ops)

# Pass 4 Triage

Tracks the disposition of every LOW+ finding from pass4 audit reports (code quality).
Agent IDs are prefixed P4- to disambiguate from other passes.
Findings duplicated from pass 3 have been removed (pass 3 version kept).

## Findings

### HIGH

- [DISMISSED] P4-A25-1: (HIGH) Duplicate short flag `-i` on both fork_url and fork_block_number — false positive, fork_url uses -i and fork_block_number uses -b

### MEDIUM

- [PENDING] P4-A21-1: (MEDIUM) Dead constants NOT_LOW_16_BIT_MASK and ACTIVE_SOURCE_MASK in LibParse.sol
- [PENDING] P4-A24-2: (MEDIUM) Function pointer mutability mismatch: selectLiteralParserByIndex returns pure but stores view pointers
- [PENDING] P4-A25-2: (MEDIUM) Unused dependencies serde and serde_bytes in CLI Cargo.toml
- [PENDING] P4-A26-1: (MEDIUM) unwrap() on traces in From<ForkTypedReturn> will panic if traces are None
- [PENDING] P4-A26-4: (MEDIUM) search_trace_by_path has logic bug in parent tracking
- [PENDING] P4-A27-3: (MEDIUM) Edition inconsistency: parser and dispair hardcode edition 2021 instead of workspace 2024
- [PENDING] P4-A27-5: (MEDIUM) Duplicated Parser2 trait definition for wasm vs non-wasm
- [PENDING] P4-A27-13: (MEDIUM) parse_pragma_text is inherent method while parse_text is trait method

### LOW

- [PENDING] P4-A01-1: (LOW) Dead `using` directives and unused imports in BaseRainterpreterExtern
- [PENDING] P4-A01-2: (LOW) Inconsistent assembly idioms for function pointer extraction
- [PENDING] P4-A01-4: (LOW) Error SubParserIndexOutOfBounds defined inline instead of in src/error/
- [PENDING] P4-A01-5: (LOW) Inconsistent mutability: opcodeFunctionPointers view vs integrityFunctionPointers pure
- [PENDING] P4-A02-2: (LOW) Rainterpreter constructor lacks NatSpec
- [PENDING] P4-A02-7: (LOW) NatSpec /// used for inline code comment inside function body
- [PENDING] P4-A02-8: (LOW) type(uint256).max as "no limit" without named constant
- [PENDING] P4-A02-10: (LOW) build* functions missing override keyword
- [PENDING] P4-A03-1: (LOW) @inheritdoc IERC165 inconsistent with ERC165
- [PENDING] P4-A03-2: (LOW) Redundant NatSpec before @inheritdoc on buildIntegrityFunctionPointers
- [PENDING] P4-A03-3: (LOW) RainterpreterDISPaiRegistry does not implement ERC165
- [PENDING] P4-A04-1: (LOW) Error InvalidRepeatCount defined inline instead of in src/error/
- [PENDING] P4-A04-3: (LOW) Variable named float shadows type name Float
- [PENDING] P4-A04-7: (LOW) matchSubParseLiteralDispatch narrowed from view to pure
- [PENDING] P4-A05-1: (LOW) MalformedExponentDigits and MalformedDecimalPoint are dead code
- [PENDING] P4-A05-2: (LOW) Inconsistent NatSpec @dev usage across error files
- [PENDING] P4-A05-7: (LOW) DuplicateLHSItem uses @dev while adjacent errors do not
- [PENDING] P4-A06-1: (LOW) Magic numbers throughout evalLoop assembly
- [PENDING] P4-A06-3: (LOW) Stale reference to "tail" in NatSpec comment in LibEval
- [PENDING] P4-A07-1: (LOW) Inconsistent constant sourcing for context ops
- [PENDING] P4-A07-2: (LOW) Inconsistent function mutability across subParser functions
- [PENDING] P4-A07-3: (LOW) Magic number in LibExternOpIntInc.run for float value 1
- [PENDING] P4-A07-4: (LOW) Magic number 78 in LibParseLiteralRepeat boundary check
- [PENDING] P4-A08-1: (LOW) Magic number 0x18 for cursor alignment lacks explanation
- [PENDING] P4-A09-1: (LOW) Unused variable success in stackTrace assembly
- [PENDING] P4-A09-2: (LOW) Incorrect arithmetic in stackTrace NatSpec cost analysis
- [PENDING] P4-A10-1: (LOW) LibOpCall is missing referenceFn unlike all other opcode libraries
- [PENDING] P4-A10-2: (LOW) Unused using LibPointer and import in LibOpCall
- [PENDING] P4-A11-1: (LOW) Inconsistent referenceFn return pattern across bitwise ops
- [PENDING] P4-A11-2: (LOW) Inconsistent uint256 cast on type(uint8).max between shift ops
- [PENDING] P4-A11-3: (LOW) Inconsistent lint suppression comments between DecodeBits and EncodeBits
- [PENDING] P4-A11-4: (LOW) Repeated operand parsing logic in DecodeBits and EncodeBits
- [PENDING] P4-A12-3: (LOW) Inconsistent forge-lint comment formatting
- [PENDING] P4-A13-1: (LOW) @title NatSpec missing Lib prefix in LibOpUint256ERC721BalanceOf
- [PENDING] P4-A13-2: (LOW) Unused using LibDecimalFloat for Float in EVM ops
- [PENDING] P4-A14-1: (LOW) Commented-out require statement in LibOpConditions.sol
- [PENDING] P4-A14-2: (LOW) require(false, ...) with string messages in referenceFn
- [PENDING] P4-A17-4: (LOW) using LibDecimalFloat for Float unused in MaxNegativeValue/MaxPositiveValue
- [PENDING] P4-A17-8: (LOW) Missing "decimal" in NatSpec: says "floating point" not "decimal floating point"
- [PENDING] P4-A17-9: (LOW) Misleading unchecked block with overflow comment on max operation
- [PENDING] P4-A19-2: (LOW) Misleading comment says "overflow" for div/sub referenceFn
- [PENDING] P4-A19-3: (LOW) NatSpec references wrong variable names in linear growth formula
- [PENDING] P4-A20-2: (LOW) Unnecessary unchecked block wrapping entire run body in LibOpSet
- [PENDING] P4-A21-2: (LOW) Potentially unused using LibBytes32Array in LibParse
- [PENDING] P4-A21-3: (LOW) Magic numbers in paren tracking logic
- [PENDING] P4-A21-4: (LOW) parseRHS function length (~210 lines)
- [PENDING] P4-A22-4: (LOW) Magic numbers in LibParseStackName linked-list encoding
- [PENDING] P4-A22-5: (LOW) Magic number 0xf0 for comment sequence shift
- [PENDING] P4-A22-6: (LOW) Duplicated Float-to-uint conversion pattern across 5 operand handlers
- [PENDING] P4-A22-11: (LOW) Tight coupling between LibParseStackName and ParseState layout
- [PENDING] P4-A22-12: (LOW) Different fingerprint representations in pushStackName vs stackNameIndex
- [PENDING] P4-A23-1: (LOW) Incorrect inline comments in newState constructor
- [PENDING] P4-A23-2: (LOW) Stale function name newActiveSource in comment
- [PENDING] P4-A23-4: (LOW) Magic number 0x3f for max stack items
- [PENDING] P4-A24-1: (LOW) Unused using directives in LibParseLiteral
- [PENDING] P4-A24-3: (LOW) Parameter naming inconsistency: start instead of cursor
- [PENDING] P4-A24-4: (LOW) Unnamed ParseState memory parameter in boundHex
- [PENDING] P4-A24-6: (LOW) Magic number 0x40 in hex overflow check
- [PENDING] P4-A24-7: (LOW) Inconsistent unchecked block usage across parse functions
- [PENDING] P4-A25-3: (LOW) Incorrect homepage URL points to rain.orderbook
- [PENDING] P4-A25-4: (LOW) Inconsistent error handling: anyhow loses error chain
- [PENDING] P4-A25-5: (LOW) Eval output uses Debug formatting labeled as Binary encoding
- [PENDING] P4-A25-6: (LOW) Execute trait uses async fn without Send bound
- [PENDING] P4-A26-2: (LOW) Redundant .clone() and .deref() chain in trace extraction
- [PENDING] P4-A26-3: (LOW) Inconsistent trace ordering approach
- [PENDING] P4-A26-5: (LOW) CreateNamespace is an empty struct used only as function namespace
- [PENDING] P4-A26-6: (LOW) Typo "commiting" should be "committing"
- [PENDING] P4-A26-7: (LOW) #[allow(clippy::for_kv_map)] suppresses valid lint
- [PENDING] P4-A26-8: (LOW) Inconsistent error handling: unwrap() vs ?
- [PENDING] P4-A26-11: (LOW) TryFrom<RawCallResult> always produces empty stack and writes
- [PENDING] P4-A26-13: (LOW) Inconsistent #[derive] placement relative to doc comments
- [PENDING] P4-A26-15: (LOW) roll_fork uses unwrap() after is_none() check
- [PENDING] P4-A27-1: (LOW) Unused dependencies serde and serde_json in parser crate
- [PENDING] P4-A27-2: (LOW) Unused dependency serde_json in test_fixtures crate
- [PENDING] P4-A27-4: (LOW) Homepage URL inconsistency: rainlanguage vs rainprotocol
- [PENDING] P4-A27-6: (LOW) DISPaiR doc comment mentions "Registry" but struct has no registry field
- [PENDING] P4-A27-7: (LOW) Excessive unwrap() in LocalEvm::new()
- [PENDING] P4-A27-11: (LOW) Cargo.toml metadata inconsistency
- [PENDING] P4-A27-14: (LOW) DISPaiR struct lacks Debug derive
- [PENDING] P4-A28-1: (LOW) Inconsistent import path style in script files
- [PENDING] P4-A28-2: (LOW) Deploy.sol NatSpec omits "dispair-registry" as valid suite value
