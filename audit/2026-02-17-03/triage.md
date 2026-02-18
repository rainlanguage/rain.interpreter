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
- [FIXED] A05-2: (MEDIUM) `InputsLengthMismatch` only tested for too-many-inputs direction — fuzzed testInputsLengthMismatchTooFew added
- [FIXED] A05-3: (MEDIUM) No test for `maxOutputs` truncation behavior in `eval2` — fuzzed maxOutputs 0-2 against 3-output source with parser-generated bytecode
- [FIXED] A05-4: (LOW) No test for zero-opcode source in `evalLoop` — added 2 tests: zero inputs/zero ops, fuzzed inputs passthrough with zero ops
- [FIXED] A05-5: (LOW) No test for multiple sources exercised through `eval2` — added 2 tests: sourceIndex 1 eval and source 0 vs source 1 value independence
- [FIXED] A05-6: (LOW) No test for `eval2` with non-zero inputs that match source expectation — added fuzz test with 2 inputs consumed by add op in Rainterpreter.eval.t.sol
- [FIXED] A05-7: (LOW) No test for exact multiple-of-8 opcode count (zero remainder) — cb7e0e68
- [FIXED] A06-1: (LOW) No test for encode/decode roundtrip with varied extern addresses — d44b4d6a
- [DISMISSED] A06-2: (MEDIUM) No test for overflow/truncation behavior when opcode or operand exceeds 16 bits — only caller passes compile-time constant 0, NatSpec documents precondition
- [FIXED] A06-3: (LOW) `decodeExternDispatch` and `decodeExternCall` have no standalone unit tests — 7a09fc12
- [FIXED] A07-1: (LOW) No direct unit test for LibExternOpContextCallingContract.subParser — 6cc2a9a3
- [FIXED] A07-2: (LOW) No test for subParser with varying constantsHeight or ioByte inputs — 6cc2a9a3
- [FIXED] A08-1: (LOW) No direct unit test for LibExternOpContextRainlen.subParser — 6825e95d
- [FIXED] A08-2: (LOW) No test for subParser with varying constantsHeight or ioByte inputs — 6825e95d
- [DISMISSED] A08-3: (LOW) Only one end-to-end test with a single rainlang string length — length is a caller-provided context value, different lengths exercise the same code path
- [FIXED] A09-1: (LOW) No direct unit test for LibExternOpContextSender.subParser — 67be7726
- [FIXED] A09-2: (LOW) No test for subParser with varying constantsHeight or ioByte inputs — 67be7726
- [DISMISSED] A09-3: (LOW) No test with different msg.sender values — sender is a caller-provided context value, different values exercise the same code path
- [DISMISSED] A10-1: (LOW) run() test bounds inputs away from float overflow region — add(x, 1) cannot overflow for any valid Float; adding 1 to a huge value is a lossy noop, not an error
- [FIXED] A11-1: (LOW) No direct unit test for LibExternOpStackOperand.subParser — 7a4c7846
- [FIXED] A11-2: (LOW) No test for subParser with constantsHeight > 0 — 7a4c7846
- [FIXED] A12-1: (HIGH) No direct test for `StackUnderflow` revert path — testStackUnderflow() added
- [FIXED] A12-2: (HIGH) No direct test for `StackUnderflowHighwater` revert path — testStackUnderflowHighwater() added
- [FIXED] A12-3: (HIGH) No direct test for `StackAllocationMismatch` revert path — testStackAllocationMismatch() added
- [FIXED] A12-4: (HIGH) No direct test for `StackOutputsMismatch` revert path — testStackOutputsMismatch() added
- [FIXED] A12-5: (MEDIUM) No test for `newState` initialization correctness — fuzzed all struct fields
- [FIXED] A12-6: (MEDIUM) No test for multi-output highwater advancement logic — multi-output call passes integrity via parse2
- [FIXED] A12-7: (LOW) No test for `stackMaxIndex` tracking logic — parse add(1 2) and assert stackAllocation (peak=2) > outputs (final=1)
- [FIXED] A12-8: (LOW) No test for zero-source bytecode (`sourceCount == 0`) — empty and comment-only inputs both produce sourceCount=0 bytecode
- [FIXED] A12-9: (LOW) No test for multi-source bytecode integrity checking — 2 and 3 source expressions with different shapes
- [FIXED] A14-1: (LOW) No dedicated test for `fingerprint` function — moved to test library, added determinism and field-sensitivity tests
- [FIXED] A14-2: (LOW) No dedicated test for `stackBottoms` function — added 3 fuzz tests: empty stacks, single stack pointer math, multiple stacks of different sizes
- [FIXED] A14-3: (LOW) `stackTrace` test does not cover parentSourceIndex/sourceIndex encoding edge cases — masked both parentSourceIndex and sourceIndex to 16 bits in stackTrace; added fuzz test that verifies upper bits are stripped
- [FIXED] A15-1: (HIGH) No test file exists for LibInterpreterStateDataContract — added LibInterpreterStateDataContract.t.sol
- [DISMISSED] A15-2: (MEDIUM) `serializeSize` unchecked overflow not tested — constants.length near 2^256/0x20 is unreachable, memory allocation fails first
- [FIXED] A15-3: (MEDIUM) `unsafeSerialize` correctness not independently tested — fuzzed round-trip tests added
- [FIXED] A15-4: (HIGH) `unsafeDeserialize` complex assembly not independently tested — covered by round-trip and stack allocation tests
- [FIXED] A15-5: (MEDIUM) No test for serialize/deserialize round-trip property — fuzzed single and two-source round-trips added
- [PENDING] A16-1: (LOW) LibOpCtPop missing test for disallowed operand
- [DISMISSED] A17-1: (MEDIUM) No referenceFn or direct unit test for `run` function assembly logic — call opcode is a control flow instruction, referenceFn would share evalLoop making it not truly independent; E2E tests cover the copy logic
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
- [FIXED] A30-1: (MEDIUM) No test triggers `ParenOverflow` error — testParenOverflow and testParenMaxNesting boundary tests added
- [PENDING] A30-2: (LOW) No test triggers `ParserOutOfBounds` error from `parse()`
- [PENDING] A30-3: (LOW) No test for yang-state `UnexpectedRHSChar` in `parseRHS`
- [PENDING] A30-4: (LOW) No test for stack name fallback path in `parseRHS` via `stackNameIndex`
- [PENDING] A30-5: (LOW) No test for `OPCODE_UNKNOWN` sub-parser bytecode construction boundary conditions
- [PENDING] A31-1: (LOW) No direct unit tests for `parseErrorOffset`
- [PENDING] A31-2: (LOW) No direct unit tests for `handleErrorSelector`
- [PENDING] A32-1: (LOW) No direct unit tests for `skipComment`, `skipWhitespace`, or `parseInterstitial`
- [FIXED] A32-2: (MEDIUM) `MalformedCommentStart` error path is never tested — fuzzed over all non-'*' second bytes
- [PENDING] A32-3: (LOW) No test for `skipComment` when `cursor + 4 > end`
- [PENDING] A32-4: (LOW) No test for `skipWhitespace` in isolation
- [FIXED] A33-1: (MEDIUM) No direct unit test for `selectLiteralParserByIndex` — added direct test calling returned function pointer for hex, decimal, and string indices
- [PENDING] A33-2: (LOW) No direct unit test for `tryParseLiteral` dispatch logic
- [PENDING] A33-3: (LOW) No test for `parseLiteral` revert path
- [FIXED] A34-1: (MEDIUM) No happy-path unit test for `parseDecimalFloatPacked` — added 52 happy-path cases covering zero, integers, negatives, positive/negative exponents, decimal points, no exponent, and large coefficients using float eq
- [PENDING] A34-2: (LOW) No fuzz test for decimal parsing round-trip
- [PENDING] A34-3: (LOW) No test for cursor position after successful parse
- [PENDING] A34-4: (LOW) No test for decimal values with fractional parts
- [FIXED] A35-1: (MEDIUM) No test for `HexLiteralOverflow` error — testParseHexOverflow with boundary at 65 digits
- [FIXED] A35-2: (MEDIUM) No test for `ZeroLengthHexLiteral` error — fuzzed over non-hex trailing bytes
- [FIXED] A35-3: (MEDIUM) No test for `OddLengthHexLiteral` error — fuzzed over odd lengths 1-63
- [PENDING] A35-4: (LOW) No test for `MalformedHexLiteral` error
- [PENDING] A35-5: (LOW) No test for mixed-case hex parsing
- [FIXED] A36-1: (MEDIUM) No test for RepeatLiteralTooLong revert path — added fuzz test for length >= 78
- [FIXED] A36-2: (MEDIUM) No test for parseRepeat output value correctness — added fuzz test asserting output against reference sum
- [PENDING] A36-3: (LOW) No test for zero-length literal body (cursor == end)
- [PENDING] A36-4: (LOW) No test for length = 1 (single character body)
- [PENDING] A36-5: (LOW) No test for length = 77 (maximum valid length)
- [PENDING] A36-6: (LOW) Integration tests use bare vm.expectRevert() without specifying expected error
- [PENDING] A37-1: (LOW) No explicit test for `parseString` memory snapshot restoration
- [PENDING] A37-3: (LOW) No test for `UnclosedStringLiteral` when `end == innerEnd`
- [FIXED] A38-1: (MEDIUM) No test for `subParseLiteral` returning `(false, ...)` (sub-parser rejection) — added fuzz tests for first-rejects-second-accepts and all-reject paths
- [PENDING] A38-2: (LOW) No fuzz test for the error paths
- [FIXED] A39-1: (MEDIUM) `handleOperandDisallowedAlwaysOne` has no test file or any test coverage — added tests for empty values returning 1 and non-empty values reverting
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
- [FIXED] A42-1: (CRITICAL) No direct unit tests for any function in LibParseStackTracker — LibParseStackTracker.t.sol added with 12 tests
- [FIXED] A42-2: (HIGH) ParseStackOverflow in push() never tested — testPushOverflow added
- [FIXED] A42-3: (HIGH) ParseStackUnderflow in pop() never tested — testPopUnderflow added
- [FIXED] A42-4: (HIGH) ParseStackOverflow in pushInputs() never tested — testPushInputsOverflow added
- [FIXED] A42-5: (MEDIUM) High watermark update logic not tested — testPushUpdatesHighWatermark and testPushPreservesHighWatermark added
- [FIXED] A42-6: (MEDIUM) Packed representation correctness not tested — testPopPreservesInputsAndMax, testPushPreservesInputs, testPushZero, testPopZero added
- [FIXED] A43-1: (HIGH) No direct unit test for endLine() — endLine.t.sol and endLine.OpcodeIOOverflow.t.sol exist
- [FIXED] A43-2: (MEDIUM) NotAcceptingInputs error path never tested — testNotAcceptingInputs in endLine.t.sol
- [FIXED] A43-3: (MEDIUM) OpcodeIOOverflow error path never tested — testOpcodeIOOverflowInputs and testOpcodeIOOverflowOutputs added
- [FIXED] A43-4: (MEDIUM) DanglingSource error path never tested — added test that pushes op without ending source then calls buildBytecode
- [FIXED] A43-5: (MEDIUM) ParenInputOverflow error path never tested — added direct test setting paren counter to 0xFF then pushing one more op
- [FIXED] A43-6: (MEDIUM) ParseStackOverflow in highwater() never tested — added direct test setting RHS offset to 0x3e then calling highwater()
- [FIXED] A43-7: (MEDIUM) No direct unit tests for pushOpToSource() — added 5 tests: encoding fuzz, FSM flags, two-op encoding, slot overflow linked list, SourceItemOpsOverflow
- [FIXED] A43-8: (MEDIUM) No direct unit tests for endSource() — added 5 tests: single-op source, state reset, two sources, byte length fuzz, MaxSources revert
- [FIXED] A43-9: (MEDIUM) No direct unit tests for buildBytecode() — added 3 tests: single source, two sources, fuzz source count and ops per source
- [PENDING] A43-10: (LOW) No direct unit tests for buildConstants()
- [PENDING] A43-11: (LOW) No direct unit tests for pushLiteral()
- [FIXED] A44-1: (HIGH) No direct unit test for subParseWordSlice() — all paths covered by integration tests (badSubParserResult.t.sol, unknownWord.t.sol, intInc.t.sol)
- [FIXED] A44-2: (MEDIUM) UnknownWord error path tested only via integration — added direct test with mock sub-parser rejection and fuzzed address
- [FIXED] A44-3: (MEDIUM) UnsupportedLiteralType error path in subParseLiteral() not directly tested — already covered by A38-1 testSubParseLiteralAllReject in commit `66644c8d`
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
- [FIXED] A47-1: (MEDIUM) No direct test for `parse2` with invalid input — added 3 tests: empty input, parse error propagation, integrity error propagation
- [FIXED] A47-2: (MEDIUM) No direct test for `parsePragma1` on the expression deployer — added 4 tests: no pragma, single address, two addresses, error propagation
- [PENDING] A47-3: (LOW) No test for `buildIntegrityFunctionPointers` return value consistency
- [PENDING] A47-4: (LOW) No test for `parse2` assembly block memory allocation
- [FIXED] A48-1: (MEDIUM) No direct test for `unsafeParse` — happy path and empty input tests using LibBytecode inspection
- [PENDING] A48-3: (LOW) No test for `unsafeParse` with input triggering `ParseMemoryOverflow`
- [PENDING] A48-4: (LOW) No test for `parsePragma1` with empty input
- [PENDING] A49-1: (LOW) `InvalidRepeatCount` error not directly asserted in revert tests
- [PENDING] A49-2: (LOW) `BadDynamicLength` error path never tested
- [PENDING] A49-3: (LOW) `SubParserIndexOutOfBounds` error path never tested for RainterpreterReferenceExtern
- [PENDING] A49-4: (LOW) No test for `extern()` function called directly on RainterpreterReferenceExtern
- [PENDING] A49-5: (LOW) No test for `externIntegrity()` called directly on RainterpreterReferenceExtern
- [FIXED] A50-1: (MEDIUM) No test for namespace isolation across different `msg.sender` values — added 2 fuzz tests: unidirectional isolation and bidirectional write isolation
- [PENDING] A50-2: (LOW) `Set` event emission never tested
- [PENDING] A50-3: (LOW) No test for `set` with empty array (zero-length `kvs`)
- [PENDING] A50-4: (LOW) No test for `get` on uninitialized key (default value)
- [PENDING] A50-5: (LOW) No test for overwriting a key with a different value in a single `set` call

# Pass 3 Triage

Tracks the disposition of every LOW+ finding from pass3 audit reports (documentation).
Agent IDs assigned by source file, matching the agent index from Pass 1/Pass 2.

## Agent Index

| ID | File |
|----|------|
| A01 | BaseRainterpreterExtern.md |
| A02 | BaseRainterpreterSubParser.md |
| A03 | ErrAll.md |
| A04 | LibAllStandardOps.md |
| A05 | LibEval.md |
| A06 | LibExtern.md |
| A12 | LibIntegrityCheck.md |
| A14 | LibInterpreterState.md |
| A16 | LibOpBitwise.md |
| A20 | LibOpERC20.md (includes Hash, ERC20, Uint256ERC20 ops) |
| A22 | LibOpERC721EVM.md |
| A23a | LibOpLogic1.md |
| A23b | LibOpLogic2.md |
| A24a | LibOpMath1.md |
| A24b | LibOpMath2.md (Frac, Gm, Inv, Headroom) |
| A25a | LibOpMath3.md |
| A25b | LibOpMath4.md |
| A28 | LibOpStore.md |
| A29 | LibOpMathUint256.md |
| A30 | LibParse.md |
| A33 | LibParseLiteral.md |
| A39 | LibParseOperand.md |
| A43 | LibParseState.md |
| A45 | Rainterpreter.md (includes RainterpreterStore, RainterpreterDISPaiRegistry) |
| A47 | RainterpreterExpressionDeployer.md |
| A48 | RainterpreterParserStore.md |
| A49 | RainterpreterReferenceExtern.md |

## Findings

- [PENDING] A01-1: (LOW) `opcodeFunctionPointers` missing `@return` tag
- [PENDING] A01-2: (LOW) `integrityFunctionPointers` missing `@return` tag
- [PENDING] A02-1: (LOW) `subParserParseMeta` missing `@return` tag
- [PENDING] A02-2: (LOW) `subParserWordParsers` missing `@return` tag
- [PENDING] A02-3: (LOW) `subParserOperandHandlers` missing `@return` tag
- [PENDING] A02-4: (LOW) `subParserLiteralParsers` missing `@return` tag
- [PENDING] A02-5: (LOW) `subParseLiteral2` `@inheritdoc` lacks implementation-specific param/return docs
- [PENDING] A02-6: (LOW) `subParseWord2` `@inheritdoc` lacks implementation-specific param/return docs
- [PENDING] A02-7: (LOW) `supportsInterface` override does not document which additional interfaces it supports
- [PENDING] A03-1: (LOW) `BadOutputsLength` in ErrExtern.sol missing `@param` tags
- [PENDING] A03-2: (LOW) `UnsupportedLiteralType` in ErrParse.sol missing `@param` tags
- [PENDING] A03-3: (LOW) `StringTooLong` in ErrParse.sol missing `@param` tags
- [PENDING] A03-4: (LOW) `UnclosedStringLiteral` in ErrParse.sol missing `@param` tags
- [PENDING] A03-5: (LOW) `HexLiteralOverflow` in ErrParse.sol missing `@param` tags
- [PENDING] A03-6: (LOW) `ZeroLengthHexLiteral` in ErrParse.sol missing `@param` tags
- [PENDING] A03-7: (LOW) `OddLengthHexLiteral` in ErrParse.sol missing `@param` tags
- [PENDING] A03-8: (LOW) `MalformedHexLiteral` in ErrParse.sol missing `@param` tags
- [PENDING] A03-9: (LOW) `MalformedExponentDigits` in ErrParse.sol missing `@param` tags
- [PENDING] A03-10: (LOW) `MalformedDecimalPoint` in ErrParse.sol missing `@param` tags
- [PENDING] A03-11: (LOW) `MissingFinalSemi` in ErrParse.sol missing `@param` tags
- [PENDING] A03-12: (LOW) `UnexpectedLHSChar` in ErrParse.sol missing `@param` tags
- [PENDING] A03-13: (LOW) `UnexpectedRHSChar` in ErrParse.sol missing `@param` tags
- [PENDING] A03-14: (LOW) `ExpectedLeftParen` in ErrParse.sol missing `@param` tags
- [PENDING] A03-15: (LOW) `UnexpectedRightParen` in ErrParse.sol missing `@param` tags
- [PENDING] A03-16: (LOW) `UnclosedLeftParen` in ErrParse.sol missing `@param` tags
- [PENDING] A03-17: (LOW) `UnexpectedComment` in ErrParse.sol missing `@param` tags
- [PENDING] A03-18: (LOW) `UnclosedComment` in ErrParse.sol missing `@param` tags
- [PENDING] A03-19: (LOW) `MalformedCommentStart` in ErrParse.sol missing `@param` tags
- [PENDING] A03-20: (LOW) `ExcessLHSItems` in ErrParse.sol missing `@param` tags
- [PENDING] A03-21: (LOW) `NotAcceptingInputs` in ErrParse.sol missing `@param` tags
- [PENDING] A03-22: (LOW) `ExcessRHSItems` in ErrParse.sol missing `@param` tags
- [PENDING] A03-23: (LOW) `WordSize` in ErrParse.sol missing `@param word` tag
- [PENDING] A03-24: (LOW) `UnknownWord` in ErrParse.sol missing `@param word` tag
- [PENDING] A03-25: (LOW) `NoWhitespaceAfterUsingWordsFrom` in ErrParse.sol missing `@param` tags
- [PENDING] A03-26: (LOW) `InvalidSubParser` in ErrParse.sol missing `@param` tags
- [PENDING] A03-27: (LOW) `UnclosedSubParseableLiteral` in ErrParse.sol missing `@param` tags
- [PENDING] A03-28: (LOW) `SubParseableMissingDispatch` in ErrParse.sol missing `@param` tags
- [PENDING] A03-29: (LOW) `BadSubParserResult` in ErrParse.sol missing `@param bytecode` tag
- [PENDING] A03-30: (LOW) `OpcodeIOOverflow` in ErrParse.sol missing `@param` tags
- [PENDING] A04-1: (LOW) `authoringMetaV2()` missing `@return` tag
- [PENDING] A04-2: (LOW) `literalParserFunctionPointers()` missing `@return` tag
- [PENDING] A04-3: (LOW) `operandHandlerFunctionPointers()` missing `@return` tag
- [PENDING] A04-4: (LOW) `integrityFunctionPointers()` missing `@return` tag
- [PENDING] A04-5: (LOW) `opcodeFunctionPointers()` missing `@return` tag
- [PENDING] A04-6: (LOW) `LibOpConstant.integrity()` missing `@param` and `@return` tags
- [PENDING] A04-7: (LOW) `LibOpConstant.run()` missing `@param` and `@return` tags
- [PENDING] A04-8: (LOW) `LibOpConstant.referenceFn()` missing `@param` and `@return` tags
- [PENDING] A04-9: (LOW) `LibOpContext` library-level NatSpec lacks description
- [PENDING] A04-10: (LOW) `LibOpContext.integrity()` missing `@param` and `@return` tags
- [PENDING] A04-11: (LOW) `LibOpContext.run()` missing `@param` and `@return` tags
- [PENDING] A04-12: (LOW) `LibOpContext.referenceFn()` missing `@param` and `@return` tags
- [PENDING] A04-13: (LOW) `LibOpExtern.integrity()` missing `@param` and `@return` tags
- [PENDING] A04-14: (LOW) `LibOpExtern.run()` missing `@param` and `@return` tags
- [PENDING] A04-15: (LOW) `LibOpExtern.referenceFn()` missing `@param` and `@return` tags
- [PENDING] A04-16: (LOW) `LibOpStack.integrity()` missing `@param` and `@return` tags
- [PENDING] A04-17: (LOW) `LibOpStack.run()` missing `@param` and `@return` tags
- [PENDING] A04-18: (LOW) `LibOpStack.referenceFn()` missing `@param` and `@return` tags
- [FIXED] A05-1: (LOW) `eval2` NatSpec "parallel arrays of keys and values" is ambiguous — rewritten to describe outputs truncation and flat interleaved KV array
- [PENDING] A06-1: (LOW) `encodeExternDispatch` missing `@param` and `@return` tags
- [PENDING] A06-2: (LOW) `decodeExternDispatch` missing `@param` and `@return` tags
- [PENDING] A06-3: (LOW) `encodeExternCall` missing `@param` and `@return` tags
- [PENDING] A06-4: (LOW) `decodeExternCall` missing `@param` and `@return` tags
- [PENDING] A06-5: (LOW) `LibExternOpContextCallingContract.subParser` missing `@param` and `@return` tags
- [PENDING] A06-6: (LOW) `LibExternOpContextRainlen.subParser` missing `@param` and `@return` tags
- [PENDING] A06-7: (LOW) `LibExternOpContextSender.subParser` missing `@param` and `@return` tags
- [PENDING] A06-8: (LOW) `LibExternOpIntInc.run` missing `@param` and `@return` tags
- [PENDING] A06-9: (LOW) `LibExternOpIntInc.integrity` missing `@param` and `@return` tags
- [PENDING] A06-10: (LOW) `LibExternOpIntInc.subParser` missing `@param` and `@return` tags
- [PENDING] A06-11: (LOW) `LibExternOpStackOperand.subParser` missing NatSpec entirely
- [PENDING] A12-1: (LOW) `IntegrityCheckState` struct has no NatSpec documentation
- [FIXED] A14-1: (MEDIUM) `InterpreterState` struct has no NatSpec documentation — added struct-level and per-field NatSpec
- [PENDING] A14-2: (LOW) `STACK_TRACER` constant has no NatSpec documentation
- [FIXED] A14-3: (LOW) `stackTrace` NatSpec inaccurately describes the 4-byte prefix content — corrected to describe 2-byte parentSourceIndex + 2-byte sourceIndex encoding
- [PENDING] A14-4: (LOW) `unsafeSerialize` missing `@return` tag and cursor side-effect not documented
- [PENDING] A16-1: (LOW) LibOpBitwiseAnd integrity missing `@param` and `@return` NatSpec tags
- [PENDING] A16-2: (LOW) LibOpBitwiseAnd run missing `@param` and `@return` NatSpec tags
- [PENDING] A16-3: (LOW) LibOpBitwiseAnd referenceFn missing `@param` and `@return` NatSpec tags
- [PENDING] A16-4: (LOW) LibOpBitwiseOr integrity missing `@param` and `@return` NatSpec tags
- [PENDING] A16-5: (LOW) LibOpBitwiseOr run missing `@param` and `@return` NatSpec tags
- [PENDING] A16-6: (LOW) LibOpBitwiseOr referenceFn missing `@param` and `@return` NatSpec tags
- [PENDING] A16-7: (LOW) LibOpCtPop integrity missing `@param` and `@return` NatSpec tags
- [PENDING] A16-8: (LOW) LibOpCtPop run missing `@param` and `@return` NatSpec tags
- [PENDING] A16-9: (LOW) LibOpCtPop referenceFn missing `@param` and `@return` NatSpec tags
- [PENDING] A16-10: (LOW) LibOpDecodeBits integrity missing `@param` and `@return` NatSpec tags
- [PENDING] A16-11: (LOW) LibOpDecodeBits run missing `@param` and `@return` NatSpec tags
- [PENDING] A16-12: (LOW) LibOpDecodeBits referenceFn missing `@param` and `@return` NatSpec tags
- [PENDING] A16-13: (LOW) LibOpEncodeBits integrity missing `@param` and `@return` NatSpec tags
- [PENDING] A16-14: (LOW) LibOpEncodeBits run missing `@param` and `@return` NatSpec tags
- [PENDING] A16-15: (LOW) LibOpEncodeBits referenceFn missing `@param` and `@return` NatSpec tags
- [PENDING] A16-16: (LOW) LibOpShiftBitsLeft integrity missing `@param` and `@return` NatSpec tags
- [PENDING] A16-17: (LOW) LibOpShiftBitsLeft run missing `@param` and `@return` NatSpec tags
- [PENDING] A16-18: (LOW) LibOpShiftBitsLeft referenceFn missing `@param` and `@return` NatSpec tags
- [PENDING] A16-19: (LOW) LibOpShiftBitsRight integrity missing `@param` and `@return` NatSpec tags
- [PENDING] A16-20: (LOW) LibOpShiftBitsRight run missing `@param` and `@return` NatSpec tags
- [PENDING] A16-21: (LOW) LibOpShiftBitsRight referenceFn missing `@param` and `@return` NatSpec tags
- [PENDING] A20-1: (LOW) LibOpHash integrity missing `@param` and `@return` NatSpec
- [PENDING] A20-2: (LOW) LibOpHash run missing `@param` and `@return` NatSpec
- [PENDING] A20-3: (LOW) LibOpHash referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A20-4: (LOW) LibOpERC20Allowance integrity missing `@param` and `@return` NatSpec
- [PENDING] A20-5: (LOW) LibOpERC20Allowance run missing `@param` and `@return` NatSpec
- [PENDING] A20-6: (LOW) LibOpERC20Allowance referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A20-7: (LOW) LibOpERC20BalanceOf integrity missing `@param` and `@return` NatSpec
- [PENDING] A20-8: (LOW) LibOpERC20BalanceOf run missing `@param` and `@return` NatSpec
- [PENDING] A20-9: (LOW) LibOpERC20BalanceOf referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A20-10: (LOW) LibOpERC20TotalSupply integrity missing `@param` and `@return` NatSpec
- [PENDING] A20-11: (LOW) LibOpERC20TotalSupply run missing `@param` and `@return` NatSpec
- [PENDING] A20-12: (LOW) LibOpERC20TotalSupply referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A20-13: (LOW) LibOpUint256ERC20Allowance integrity missing `@param` and `@return` NatSpec
- [PENDING] A20-14: (LOW) LibOpUint256ERC20Allowance run missing `@param` and `@return` NatSpec
- [PENDING] A20-15: (LOW) LibOpUint256ERC20Allowance referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A20-16: (LOW) LibOpUint256ERC20BalanceOf `@title` missing Lib prefix vs library name
- [PENDING] A20-17: (LOW) LibOpUint256ERC20BalanceOf integrity missing `@param` and `@return` NatSpec
- [PENDING] A20-18: (LOW) LibOpUint256ERC20BalanceOf run missing `@param` and `@return` NatSpec
- [PENDING] A20-19: (LOW) LibOpUint256ERC20BalanceOf referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A20-20: (LOW) LibOpUint256ERC20TotalSupply integrity missing `@param` and `@return` NatSpec
- [PENDING] A20-21: (LOW) LibOpUint256ERC20TotalSupply run missing `@param` and `@return` NatSpec
- [PENDING] A20-22: (LOW) LibOpUint256ERC20TotalSupply referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A22-1: (LOW) All ERC721/ERC5313/EVM integrity functions missing `@param` and `@return` tags
- [PENDING] A22-2: (LOW) All ERC721/ERC5313/EVM run functions missing `@param` and `@return` tags
- [PENDING] A22-3: (LOW) All ERC721/ERC5313/EVM referenceFn functions missing `@param` and `@return` tags
- [PENDING] A22-4: (LOW) All ERC721/ERC5313/EVM unnamed function parameters prevent formal `@param` tags
- [PENDING] A23a-1: (LOW) LibOpAny integrity missing `@param` and `@return` NatSpec
- [PENDING] A23a-2: (LOW) LibOpAny run missing `@param` and `@return` NatSpec
- [PENDING] A23a-3: (LOW) LibOpAny referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A23a-4: (LOW) LibOpBinaryEqualTo integrity missing NatSpec entirely
- [PENDING] A23a-5: (LOW) LibOpBinaryEqualTo run missing `@param` and `@return` NatSpec
- [PENDING] A23a-6: (LOW) LibOpBinaryEqualTo referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A23a-7: (LOW) LibOpConditions integrity missing NatSpec entirely
- [PENDING] A23a-8: (LOW) LibOpConditions run missing `@param` and `@return` NatSpec
- [PENDING] A23a-9: (LOW) LibOpConditions referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A23a-10: (LOW) LibOpEnsure integrity missing NatSpec entirely
- [PENDING] A23a-11: (LOW) LibOpEnsure run missing `@param` and `@return` NatSpec
- [PENDING] A23a-12: (LOW) LibOpEnsure referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A23a-13: (LOW) LibOpEqualTo integrity missing `@param` and `@return` NatSpec
- [PENDING] A23a-14: (LOW) LibOpEqualTo run missing `@param` and `@return` NatSpec
- [PENDING] A23a-15: (LOW) LibOpEqualTo referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A23a-16: (LOW) LibOpEvery integrity missing `@param` and `@return` NatSpec
- [PENDING] A23a-17: (LOW) LibOpEvery run missing `@param` and `@return` NatSpec
- [PENDING] A23a-18: (LOW) LibOpEvery referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A23b-1: (LOW) LibOpGreaterThan integrity missing `@param` and `@return` tags
- [PENDING] A23b-2: (LOW) LibOpGreaterThan run missing `@param` and `@return` tags
- [PENDING] A23b-3: (LOW) LibOpGreaterThan referenceFn missing `@param` and `@return` tags
- [PENDING] A23b-4: (LOW) LibOpGreaterThanOrEqualTo integrity missing `@param` and `@return` tags
- [PENDING] A23b-5: (LOW) LibOpGreaterThanOrEqualTo run missing `@param` and `@return` tags
- [PENDING] A23b-6: (LOW) LibOpGreaterThanOrEqualTo referenceFn missing `@param` and `@return` tags
- [PENDING] A23b-7: (LOW) LibOpIf integrity completely missing NatSpec
- [PENDING] A23b-8: (LOW) LibOpIf run missing `@param` and `@return` tags
- [PENDING] A23b-9: (LOW) LibOpIf referenceFn missing `@param` and `@return` tags
- [PENDING] A23b-10: (LOW) LibOpIsZero integrity missing `@param` and `@return` tags
- [PENDING] A23b-11: (LOW) LibOpIsZero run missing `@param` and `@return` tags
- [PENDING] A23b-12: (LOW) LibOpIsZero referenceFn missing `@param` and `@return` tags
- [PENDING] A23b-13: (LOW) LibOpLessThan integrity missing `@param` and `@return` tags
- [PENDING] A23b-14: (LOW) LibOpLessThan run missing `@param` and `@return` tags
- [PENDING] A23b-15: (LOW) LibOpLessThan referenceFn missing `@param` and `@return` tags
- [PENDING] A23b-16: (LOW) LibOpLessThanOrEqualTo integrity missing `@param` and `@return` tags
- [PENDING] A23b-17: (LOW) LibOpLessThanOrEqualTo run missing `@param` and `@return` tags
- [PENDING] A23b-18: (LOW) LibOpLessThanOrEqualTo referenceFn missing `@param` and `@return` tags
- [PENDING] A24a-1: (LOW) LibOpAbs integrity missing `@param` and `@return` NatSpec
- [PENDING] A24a-2: (LOW) LibOpAbs run missing `@param` and `@return` NatSpec
- [PENDING] A24a-3: (LOW) LibOpAbs referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A24a-4: (LOW) LibOpAdd integrity missing `@param` and `@return` NatSpec
- [PENDING] A24a-5: (LOW) LibOpAdd run missing `@param` and `@return` NatSpec
- [PENDING] A24a-6: (LOW) LibOpAdd referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A24a-7: (LOW) LibOpAvg integrity missing `@param` and `@return` NatSpec
- [PENDING] A24a-8: (LOW) LibOpAvg run missing `@param` and `@return` NatSpec
- [PENDING] A24a-9: (LOW) LibOpAvg referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A24a-10: (LOW) LibOpCeil integrity missing `@param` and `@return` NatSpec
- [PENDING] A24a-11: (LOW) LibOpCeil run missing `@param` and `@return` NatSpec
- [PENDING] A24a-12: (LOW) LibOpCeil referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A24a-13: (LOW) LibOpDiv integrity missing `@param` and `@return` NatSpec
- [PENDING] A24a-14: (LOW) LibOpDiv run missing `@param` and `@return` NatSpec
- [PENDING] A24a-15: (LOW) LibOpDiv referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A24a-16: (LOW) LibOpE integrity missing `@param` and `@return` NatSpec
- [PENDING] A24a-17: (LOW) LibOpE run missing `@param` and `@return` NatSpec
- [PENDING] A24a-18: (LOW) LibOpE referenceFn missing `@param` and `@return` NatSpec
- [FIXED] A24a-19: (LOW) LibOpExp2 referenceFn NatSpec says "exp" instead of "exp2" — corrected to "exp2"
- [PENDING] A24a-20: (LOW) LibOpExp2 integrity missing `@param` and `@return` NatSpec
- [PENDING] A24a-21: (LOW) LibOpExp2 run missing `@param` and `@return` NatSpec
- [PENDING] A24a-22: (LOW) LibOpExp2 referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A24a-23: (LOW) LibOpExp integrity missing `@param` and `@return` NatSpec
- [PENDING] A24a-24: (LOW) LibOpExp run missing `@param` and `@return` NatSpec
- [PENDING] A24a-25: (LOW) LibOpExp referenceFn missing `@param` and `@return` NatSpec
- [FIXED] A24b-1: (LOW) LibOpFrac library-level NatSpec uses `@notice` — removed `@notice` tag
- [FIXED] A24b-2: (LOW) LibOpGm library-level NatSpec uses `@notice` — removed `@notice` tag
- [FIXED] A24b-3: (LOW) LibOpInv library-level NatSpec uses `@notice` — removed `@notice` tag, also added missing "decimal"
- [FIXED] A24b-4: (LOW) LibOpHeadroom run NatSpec is inaccurate — missing "point" and undocumented special-case behavior for integer inputs returning 1 — rewritten with correct terminology and special case documented
- [PENDING] A25a-1: (LOW) LibOpMax integrity missing `@param` and `@return` NatSpec
- [PENDING] A25a-2: (LOW) LibOpMax run missing `@param` and `@return` NatSpec
- [PENDING] A25a-3: (LOW) LibOpMax referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A25a-4: (LOW) LibOpMaxNegativeValue integrity missing `@param` and `@return` NatSpec
- [PENDING] A25a-5: (LOW) LibOpMaxNegativeValue run missing `@param` and `@return` NatSpec
- [PENDING] A25a-6: (LOW) LibOpMaxNegativeValue referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A25a-7: (LOW) LibOpMaxPositiveValue integrity missing `@param` and `@return` NatSpec
- [PENDING] A25a-8: (LOW) LibOpMaxPositiveValue run missing `@param` and `@return` NatSpec
- [PENDING] A25a-9: (LOW) LibOpMaxPositiveValue referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A25a-10: (LOW) LibOpMin integrity missing `@param` and `@return` NatSpec
- [PENDING] A25a-11: (LOW) LibOpMin run missing `@param` and `@return` NatSpec
- [PENDING] A25a-12: (LOW) LibOpMin referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A25a-13: (LOW) LibOpMinNegativeValue integrity missing `@param` and `@return` NatSpec
- [PENDING] A25a-14: (LOW) LibOpMinNegativeValue run missing `@param` and `@return` NatSpec
- [PENDING] A25a-15: (LOW) LibOpMinNegativeValue referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A25a-16: (LOW) LibOpMinPositiveValue integrity missing `@param` and `@return` NatSpec
- [PENDING] A25a-17: (LOW) LibOpMinPositiveValue run missing `@param` and `@return` NatSpec
- [PENDING] A25a-18: (LOW) LibOpMinPositiveValue referenceFn missing `@param` and `@return` NatSpec
- [FIXED] A25b-1: (LOW) LibOpPow `@notice` tag used in library-level NatSpec — removed `@notice` tag
- [FIXED] A25b-2: (LOW) LibOpSqrt `@notice` tag used in library-level NatSpec — removed `@notice` tag
- [FIXED] A25b-3: (MEDIUM) LibOpMul integrity missing `@param` and `@return` tags — added
- [FIXED] A25b-4: (MEDIUM) LibOpMul run missing `@param` and `@return` tags — added
- [FIXED] A25b-5: (MEDIUM) LibOpMul referenceFn missing `@param` and `@return` tags — added
- [FIXED] A25b-6: (MEDIUM) LibOpPow integrity missing `@param` and `@return` tags — added
- [FIXED] A25b-7: (MEDIUM) LibOpPow run missing `@param` and `@return` tags — added
- [FIXED] A25b-8: (MEDIUM) LibOpPow referenceFn missing `@param` and `@return` tags — added
- [FIXED] A25b-9: (MEDIUM) LibOpSqrt integrity missing `@param` and `@return` tags — added
- [FIXED] A25b-10: (MEDIUM) LibOpSqrt run missing `@param` and `@return` tags — added
- [FIXED] A25b-11: (MEDIUM) LibOpSqrt referenceFn missing `@param` and `@return` tags — added
- [FIXED] A25b-12: (MEDIUM) LibOpSub integrity missing `@param` and `@return` tags — added
- [FIXED] A25b-13: (MEDIUM) LibOpSub run missing `@param` and `@return` tags — added
- [FIXED] A25b-14: (MEDIUM) LibOpSub referenceFn missing `@param` and `@return` tags — added
- [PENDING] A25b-15: (LOW) LibOpMul run and LibOpSub run NatSpec is a single word with no behavioral description
- [PENDING] A28-1: (LOW) LibOpGet integrity missing `@param` and `@return` NatSpec
- [PENDING] A28-2: (LOW) LibOpGet run missing `@param` for OperandV2 and `@return` NatSpec
- [PENDING] A28-3: (LOW) LibOpGet referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A28-4: (LOW) LibOpSet integrity missing `@param` and `@return` NatSpec
- [PENDING] A28-5: (LOW) LibOpSet run missing `@param` and `@return` NatSpec
- [PENDING] A28-6: (LOW) LibOpSet referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A29-1: (LOW) LibOpExponentialGrowth integrity missing `@param` and `@return` NatSpec
- [PENDING] A29-2: (LOW) LibOpExponentialGrowth run missing `@param` and `@return` NatSpec
- [PENDING] A29-3: (LOW) LibOpExponentialGrowth referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A29-4: (LOW) LibOpLinearGrowth integrity missing `@param` and `@return` NatSpec
- [PENDING] A29-5: (LOW) LibOpLinearGrowth run missing `@param` and `@return` NatSpec
- [PENDING] A29-6: (LOW) LibOpLinearGrowth referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A29-7: (LOW) LibOpMaxUint256 integrity missing `@param` and `@return` NatSpec
- [PENDING] A29-8: (LOW) LibOpMaxUint256 run missing `@param` and `@return` NatSpec
- [PENDING] A29-9: (LOW) LibOpMaxUint256 referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A29-10: (LOW) LibOpUint256Add integrity missing `@param` and `@return` NatSpec
- [PENDING] A29-11: (LOW) LibOpUint256Add run missing `@param` and `@return` NatSpec
- [PENDING] A29-12: (LOW) LibOpUint256Add referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A29-13: (LOW) LibOpUint256Div integrity missing `@param` and `@return` NatSpec
- [PENDING] A29-14: (LOW) LibOpUint256Div run missing `@param` and `@return` NatSpec
- [PENDING] A29-15: (LOW) LibOpUint256Div referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A29-16: (LOW) LibOpUint256Mul integrity missing `@param` and `@return` NatSpec
- [PENDING] A29-17: (LOW) LibOpUint256Mul run missing `@param` and `@return` NatSpec
- [PENDING] A29-18: (LOW) LibOpUint256Mul referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A29-19: (LOW) LibOpUint256Pow integrity missing `@param` and `@return` NatSpec
- [PENDING] A29-20: (LOW) LibOpUint256Pow run missing `@param` and `@return` NatSpec
- [PENDING] A29-21: (LOW) LibOpUint256Pow referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A29-22: (LOW) LibOpUint256Sub integrity missing `@param` and `@return` NatSpec
- [PENDING] A29-23: (LOW) LibOpUint256Sub run missing `@param` and `@return` NatSpec
- [PENDING] A29-24: (LOW) LibOpUint256Sub referenceFn missing `@param` and `@return` NatSpec
- [PENDING] A30-1: (LOW) File-level constants `NOT_LOW_16_BIT_MASK`, `ACTIVE_SOURCE_MASK`, and `SUB_PARSER_BYTECODE_HEADER_SIZE` lack NatSpec
- [PENDING] A30-2: (LOW) `LibParse.parseWord` NatSpec describes `@return` as two separate values but does not name them
- [PENDING] A30-3: (LOW) `LibParse.parseLHS` NatSpec does not document the yang/yin FSM transitions or the `CMASK_COMMENT_HEAD` special-case revert
- [PENDING] A30-4: (LOW) `LibParse.parseRHS` NatSpec does not describe FSM state transitions or the paren-tracking mechanism
- [PENDING] A33-1: (LOW) `selectLiteralParserByIndex` missing `@param` and `@return` tags
- [PENDING] A33-2: (LOW) `parseLiteral` missing `@param` and `@return` tags
- [PENDING] A33-3: (LOW) `tryParseLiteral` missing `@param` and `@return` tags
- [PENDING] A33-4: (LOW) `parseDecimalFloatPacked` missing `@param` and `@return` tags
- [PENDING] A33-5: (LOW) `boundHex` missing `@param` and `@return` tags
- [PENDING] A33-6: (LOW) `parseHex` missing `@param` and `@return` tags
- [PENDING] A33-7: (LOW) `boundString` missing `@param` and `@return` tags
- [PENDING] A33-8: (LOW) `parseString` missing `@param` and `@return` tags
- [PENDING] A33-9: (LOW) `parseSubParseable` missing `@param` and `@return` tags
- [FIXED] A39-1: (LOW) `LibParseOperand.handleOperandSingleFull` NatSpec description is partially inaccurate — corrected "used as is" to describe Float-to-integer conversion
- [FIXED] A39-2: (LOW) `LibParseOperand.handleOperandSingleFullNoDefault` NatSpec description is incomplete — added Float-to-integer conversion and uint16 constraint
- [FIXED] A39-3: (LOW) `LibParseOperand.handleOperandDoublePerByteNoDefault` NatSpec description is partially inaccurate — corrected "used as is" and added bit layout
- [FIXED] A39-4: (LOW) `LibParseOperand.handleOperand8M1M1` NatSpec incomplete for bit layout — added `a | (b << 8) | (c << 9)`
- [FIXED] A39-5: (LOW) `LibParseOperand.handleOperandM1M1` NatSpec incomplete for bit layout — added `a | (b << 1)`
- [FIXED] A43-1: (MEDIUM) `ParseState` struct has stale `@param literalBloom` referencing non-existent field — removed stale param, added correct docs
- [FIXED] A43-2: (MEDIUM) `ParseState` struct missing `@param` for 8 fields — added NatSpec for subParsers, stackNameBloom, constantsBloom, operandHandlers, operandValues, stackTracker, data, meta
- [PENDING] A43-3: (LOW) Constants `FSM_YANG_MASK` and `FSM_WORD_END_MASK` have no NatSpec
- [PENDING] A43-4: (LOW) `ParseState.fsm` NatSpec describes bit layout that does not match implemented constants
- [PENDING] A43-5: (LOW) `endLine` function NatSpec is minimal — missing `@param cursor` description
- [PENDING] A43-6: (LOW) `PARSE_STATE_TOP_LEVEL0_OFFSET` and sibling constants document offsets but not how they were derived
- [PENDING] A45-1: (LOW) Constructor has no NatSpec documentation
- [PENDING] A45-2: (LOW) `opcodeFunctionPointers()` NatSpec lacks a function description line
- [FIXED] A45-3: (LOW) Contract-level NatSpec uses `@notice` and is minimal — removed `@notice` tag from Rainterpreter
- [PENDING] A45-4: (LOW) All four getter functions in `RainterpreterDISPaiRegistry` lack `@return` tags
- [PENDING] A47-1: (LOW) Contract-level NatSpec is title-only, no description
- [DISMISSED] A47-2: (MEDIUM) `parse2` has no meaningful NatSpec — `@inheritdoc` inherits nothing — upstream issue in rain.interpreter.interface; IParserV2 has no NatSpec
- [PENDING] A47-3: (LOW) `parsePragma1` missing `@param` and `@return` tags
- [PENDING] A48-1: (LOW) `unsafeParse` missing `@param` and `@return` tags
- [PENDING] A48-2: (LOW) `parsePragma1` missing `@param` and `@return` tags
- [PENDING] A48-3: (LOW) `parseMeta` missing `@return` tag
- [PENDING] A48-4: (LOW) `operandHandlerFunctionPointers` missing `@return` tag
- [PENDING] A48-5: (LOW) `literalParserFunctionPointers` missing `@return` tag
- [PENDING] A48-6: (LOW) `buildOperandHandlerFunctionPointers` missing `@return` tag
- [PENDING] A48-7: (LOW) `buildLiteralParserFunctionPointers` missing `@return` tag
- [PENDING] A49-1: (LOW) `authoringMetaV2()` lacks `@return` tag
- [PENDING] A49-2: (LOW) `describedByMetaV1()` relies solely on `@inheritdoc` with no supplementary documentation
- [PENDING] A49-3: (LOW) `subParserParseMeta()` lacks `@return` tag
- [PENDING] A49-4: (LOW) `subParserWordParsers()` lacks `@return` tag
- [PENDING] A49-5: (LOW) `subParserOperandHandlers()` lacks `@return` tag
- [PENDING] A49-6: (LOW) `subParserLiteralParsers()` lacks `@return` tag
- [PENDING] A49-7: (LOW) `opcodeFunctionPointers()` lacks `@return` tag
- [PENDING] A49-8: (LOW) `integrityFunctionPointers()` lacks `@return` tag
- [FIXED] A49-9: (MEDIUM) `matchSubParseLiteralDispatch()` is entirely undocumented — added `@inheritdoc BaseRainterpreterSubParser`
- [PENDING] A49-10: (LOW) `buildLiteralParserFunctionPointers()` lacks `@return` tag
- [PENDING] A49-11: (LOW) `buildOperandHandlerFunctionPointers()` lacks `@return` tag
- [PENDING] A49-12: (LOW) `buildSubParserWordParsers()` lacks `@return` tag
- [PENDING] A49-13: (LOW) `buildOpcodeFunctionPointers()` lacks `@return` and `@inheritdoc`
- [PENDING] A49-14: (LOW) `buildIntegrityFunctionPointers()` lacks `@return` and `@inheritdoc`
- [PENDING] A49-15: (LOW) `supportsInterface()` lacks `@param` tag

# Pass 4 Triage

Tracks the disposition of every LOW+ finding from pass4 audit reports (code quality and consistency).

## Agent Index

| ID | File |
|----|------|
| A01 | AbstractContracts.md |
| A03 | ErrorFiles.md |
| A04 | AllStdOps00Call.md |
| A05 | LibEval.md |
| A06 | ExternLibs.md |
| A12 | LibIntegrityCheck.md |
| A14 | DeployStateLibs.md |
| A16 | BitwiseOps.md |
| A20 | HashERC20Ops.md |
| A22 | ERC5313_721_EVMOps.md |
| A23a | LogicOps1.md |
| A23b | LogicOps2.md |
| A24 | MathOps1.md |
| A25a | MathOps2.md |
| A28 | StoreOps.md |
| A29 | GrowthUint256Math.md |
| A30 | LibParse.md |
| A33 | LiteralParseLibs.md |
| A39 | ParseUtilities.md |
| A43 | ParseStateLibs.md |
| A45 | CoreConcrete.md |
| A47 | DeployerRegistry.md |
| A49 | ReferenceExtern.md |
| R01 | RustCLI.md |
| R02 | RustEval.md |
| R03 | RustParserMisc.md |

## Findings

- [FIXED] A01-1: (LOW) Dead `using` directives and unused imports (LibStackPointer, LibUint256Array, Pointer) in BaseRainterpreterExtern — removed all 4 using directives and 3 imports
- [PENDING] A01-2: (LOW) Inconsistent assembly idioms for function pointer extraction (`shr(0xf0,...)` vs `and(..., 0xFFFF)`) across BaseRainterpreterExtern and BaseRainterpreterSubParser
- [PENDING] A01-3: (LOW) Error `SubParserIndexOutOfBounds` defined inline in BaseRainterpreterSubParser instead of in `src/error/ErrSubParse.sol`
- [PENDING] A01-4: (LOW) Inconsistent mutability between `opcodeFunctionPointers` (view) and `integrityFunctionPointers` (pure) in BaseRainterpreterExtern
- [FIXED] A03-1: (LOW) `MalformedExponentDigits` and `MalformedDecimalPoint` errors are unused dead code in ErrParse.sol — removed both
- [FIXED] A03-2: (LOW) Inconsistent NatSpec `@dev` usage across error files; ErrSubParse uses `@dev` while others use plain `///` — removed `@dev` from all 3 errors
- [PENDING] A03-3: (LOW) Missing `@param` tags on 28 parameterized errors in ErrParse.sol
- [PENDING] A03-4: (LOW) Missing `@param` tags on `BadOutputsLength` in ErrExtern.sol
- [PENDING] A03-5: (LOW) Missing `@param` tags on all 3 errors in ErrSubParse.sol
- [FIXED] A03-6: (LOW) `DuplicateLHSItem` is the only error in ErrParse.sol using `@dev` prefix, inconsistent with all other errors in the file — removed `@dev`
- [PENDING] A04-1: (LOW) `LibOpCall` is missing `referenceFn` unlike all other opcode libraries
- [FIXED] A04-2: (LOW) Unused `using LibPointer for Pointer` declaration and import in LibOpCall — removed using directive and LibPointer import
- [PENDING] A05-1: (LOW) Magic numbers throughout `evalLoop` assembly shared with LibIntegrityCheck should be named constants
- [FIXED] A05-2: (LOW) Stale reference to variable name `tail` instead of `stack` in `eval2` NatSpec comment in LibEval — corrected to `stack`
- [PENDING] A06-1: (LOW) Inconsistent constant sourcing for context ops; LibExternOpContextRainlen defines inline constants while siblings import from LibContext.sol
- [PENDING] A06-2: (LOW) Inconsistent function mutability across subParser functions; LibExternOpIntInc is `view` while others are `pure`
- [PENDING] A06-3: (LOW) Magic number in LibExternOpIntInc.run for decimal float value 1 should use named constant
- [PENDING] A06-4: (LOW) Magic number 78 in LibParseLiteralRepeat bound check should use named constant
- [PENDING] A12-1: (LOW) Magic number `0x18` for cursor alignment in `integrityCheck2` lacks derivation explanation
- [FIXED] A14-1: (LOW) Unused variable `success` from `staticcall` in `stackTrace` assembly should use `pop()` idiom in LibInterpreterState — changed to `pop(staticcall(...))`
- [FIXED] A14-2: (LOW) Incorrect arithmetic in `stackTrace` NatSpec gas cost analysis in LibInterpreterState — fixed division denominator and included memory term
- [PENDING] A16-1: (LOW) Inconsistent `referenceFn` return pattern (new array vs mutate-in-place) across bitwise ops; LibOpDecodeBits is 1-input/1-output but allocates new array unlike other 1-in/1-out ops
- [FIXED] A16-2: (LOW) Inconsistent `uint256` cast on `type(uint8).max` between LibOpShiftBitsLeft and LibOpShiftBitsRight — removed unnecessary cast from ShiftBitsLeft
- [FIXED] A16-3: (LOW) Inconsistent lint suppression comments between LibOpDecodeBits and LibOpEncodeBits for identical shift operation — added slither suppression to EncodeBits to match DecodeBits
- [PENDING] A16-4: (LOW) Repeated operand parsing logic for `startBit` and `length` duplicated 6 times across LibOpDecodeBits and LibOpEncodeBits
- [PENDING] A20-1: (LOW) `@title` NatSpec mismatch in `LibOpUint256ERC20BalanceOf.sol` missing `Lib` prefix
- [FIXED] A20-2: (LOW) Inconsistent `forge-lint` comment formatting in `LibOpUint256ERC20TotalSupply.sol` (space after `//` vs no space) — removed space to match other files
- [PENDING] A22-1: (LOW) `@title` NatSpec missing `Lib` prefix in `LibOpUint256ERC721BalanceOf`
- [DISMISSED] A22-2: (LOW) Unused `using LibDecimalFloat for Float` directive in all three EVM opcode libraries (LibOpBlockNumber, LibOpChainId, LibOpTimestamp) — false positive; all three use LibDecimalFloat in referenceFn
- [FIXED] A23a-1: (LOW) Commented-out code in LibOpConditions.sol line 68 — removed
- [FIXED] A23a-2: (LOW) `require(false, ...)` with string messages in `referenceFn` of LibOpConditions.sol instead of custom errors — replaced with `revert(...)` to match run()
- [PENDING] A23b-1: (LOW) Missing NatSpec on `integrity` function in LibOpIf
- [FIXED] A24-1: (LOW) `referenceFn` NatSpec in LibOpExp2 says "exp" instead of "exp2" (copy-paste documentation error) — fixed in earlier commit
- [DISMISSED] A25a-1: (LOW) `using LibDecimalFloat for Float` declared but unused in LibOpMaxNegativeValue and LibOpMaxPositiveValue — false positive; both use LibDecimalFloat constants and methods
- [FIXED] A25a-2: (LOW) Missing "point" in LibOpHeadroom run NatSpec ("decimal floating headroom" should be "decimal floating point headroom") — fixed in earlier commit
- [FIXED] A25a-3: (LOW) Missing "decimal" in LibOpInv run NatSpec (says "floating point" instead of "decimal floating point") — fixed as part of @notice removal
- [FIXED] A25a-4: (LOW) Misleading `unchecked` block with overflow comment in LibOpMax.referenceFn irrelevant to `max` operation — removed unnecessary unchecked block and comment
- [PENDING] A28-1: (LOW) Unnecessary `unchecked` block wrapping entire `run` body in LibOpSet has no semantic effect on assembly-only arithmetic
- [FIXED] A29-1: (LOW) Misleading comment in `referenceFn` for LibOpUint256Div and LibOpUint256Sub says "overflow" but Div reverts on divide-by-zero and Sub reverts on underflow — corrected both
- [FIXED] A29-2: (LOW) Inconsistent NatSpec description in LibOpLinearGrowth references wrong variable names ("a" and "r" instead of "base" and "rate") — corrected to "base" and "rate", also removed `@notice`
- [DISMISSED] A30-1: (MEDIUM) Dead constants `NOT_LOW_16_BIT_MASK` and `ACTIVE_SOURCE_MASK` defined but never referenced anywhere in the codebase — false positive; neither constant exists in the codebase
- [DISMISSED] A30-2: (LOW) Potentially unused `using LibBytes32Array` declaration in LibParse.sol — false positive; used for `.startPointer()` on operandValues
- [PENDING] A30-3: (LOW) Magic numbers in paren tracking logic (group size 3, reserved bytes 2, max offset 59, shift 0xf0)
- [PENDING] A30-4: (LOW) `parseRHS` function length (~210 lines) makes it harder to review and audit
- [FIXED] A33-1: (LOW) Unused `using` directives (`LibParseInterstitial`, `LibSubParse`) and corresponding unused imports in LibParseLiteral.sol — removed both using directives and imports
- [PENDING] A33-2: (MEDIUM) Function pointer mutability mismatch: `selectLiteralParserByIndex` returns `pure` typed pointer but literal parsers array stores `view` typed pointers, bypassing Solidity mutability checking via raw assembly
- [PENDING] A33-3: (LOW) Parameter naming inconsistency: `parseDecimalFloatPacked` uses `start` instead of `cursor` unlike all other parse functions
- [PENDING] A33-4: (LOW) Unnamed `ParseState memory` parameter in `boundHex` inconsistent with named `state` parameter in `boundString`
- [PENDING] A33-5: (LOW) Magic number `0x40` in hex overflow check represents max hex literal length (64 nybbles) without named constant
- [PENDING] A33-6: (LOW) Inconsistent `unchecked` block usage across parse functions: some wrap entire body, others do not use it at all
- [PENDING] A39-1: (LOW) Magic numbers in LibParseStackName linked-list encoding without named constants
- [PENDING] A39-2: (LOW) Magic number `0xf0` in comment sequence parsing in LibParseInterstitial
- [PENDING] A39-3: (LOW) Duplicated Float-to-uint conversion pattern across five operand handlers in LibParseOperand
- [PENDING] A39-4: (LOW) Tight coupling between LibParseStackName and ParseState internal layout via direct `topLevel1` access
- [PENDING] A39-5: (LOW) Different fingerprint representations in `pushStackName` vs `stackNameIndex` is confusing
- [FIXED] A43-1: (LOW) Incorrect inline comments in `newState` constructor misaligned with struct field order — corrected "literalBloom" to "constantsBuilder" and "constantsBuilder" to "constantsBloom"
- [FIXED] A43-2: (LOW) Stale function name `newActiveSource` in comment should be `newActiveSourcePointer` — corrected to `resetSource` which is the actual caller
- [DISMISSED] A43-3: (MEDIUM) FSM NatSpec does not match defined constants (bit positions shifted, missing/extra fields) — false positive; NatSpec bits 0-3 match FSM_YANG_MASK(1), FSM_WORD_END_MASK(1<<1), FSM_ACCEPTING_INPUTS_MASK(1<<2), FSM_ACTIVE_SOURCE_MASK(1<<3) exactly
- [PENDING] A43-4: (LOW) Magic number `0x3f` in `highwater` should be a named constant
- [PENDING] A45-1: (LOW) Constructor lacks NatSpec documentation in Rainterpreter.sol
- [FIXED] A45-2: (LOW) NatSpec triple-slash used for inline code comment inside RainterpreterStore.set function body — changed `///` to `//`
- [PENDING] A45-3: (LOW) `type(uint256).max` used as `maxOutputs` parameter without named constant in Rainterpreter.eval4
- [PENDING] A45-4: (LOW) `buildOperandHandlerFunctionPointers` and `buildLiteralParserFunctionPointers` missing `override` keyword in RainterpreterParser, inconsistent with Rainterpreter
- [FIXED] A47-1: (LOW) `@inheritdoc IERC165` inconsistent with other concrete contracts that use `@inheritdoc ERC165` in RainterpreterExpressionDeployer — changed to `@inheritdoc ERC165`
- [FIXED] A47-2: (LOW) Redundant NatSpec before `@inheritdoc` on `buildIntegrityFunctionPointers` is dead documentation in RainterpreterExpressionDeployer — removed dead NatSpec
- [PENDING] A47-3: (LOW) RainterpreterDISPaiRegistry does not implement ERC165 unlike all other concrete contracts
- [PENDING] A49-1: (LOW) Error `InvalidRepeatCount` defined inline instead of in `src/error/` directory per codebase convention
- [FIXED] A49-2: (LOW) Variable named `float` shadows its type name `Float` differing only in case — renamed to `repeatCount`
- [PENDING] A49-3: (LOW) `matchSubParseLiteralDispatch` narrows from `view` to `pure virtual override` constraining future subclass override chain
- [PENDING] R01-1: (HIGH) Duplicate short flag `-i` on both `fork_url` and `fork_block_number` in fork.rs causes clap runtime panic
- [PENDING] R01-2: (MEDIUM) Unused dependencies `serde` and `serde_bytes` in CLI crate Cargo.toml
- [PENDING] R01-3: (LOW) Incorrect `homepage` URL in CLI Cargo.toml points to `rain.orderbook` instead of `rain.interpreter`
- [PENDING] R01-4: (LOW) Inconsistent error handling pattern between eval.rs and parse.rs wraps errors with `anyhow!` losing original error chain
- [PENDING] R01-5: (LOW) Eval output uses Debug formatting `{:#?}` labeled as Binary encoding, inconsistent with Parse subcommand
- [PENDING] R01-6: (LOW) `Execute` trait uses native async fn in trait producing non-Send futures limiting future flexibility
- [PENDING] R02-1: (MEDIUM) `unwrap()` on `traces` in `From<ForkTypedReturn<eval4Call>>` for `RainEvalResult` will panic if traces are None
- [PENDING] R02-2: (LOW) Redundant `.to_owned()`, `.deref()`, `.clone()` chain in trace extraction creates multiple unnecessary copies
- [PENDING] R02-3: (LOW) Inconsistent trace ordering approach between `From<ForkTypedReturn>` and `TryFrom<RawCallResult>` implementations
- [PENDING] R02-4: (MEDIUM) `search_trace_by_path` has logic bug in parent tracking — sets `current_parent_index` to `trace.parent_source_index` instead of current source index
- [PENDING] R02-5: (LOW) `CreateNamespace` is an empty struct used only as function namespace; should be a free function
- [PENDING] R02-6: (LOW) Typo "commiting" should be "committing" in doc comments for `alloy_call` and `call`
- [PENDING] R02-7: (LOW) `#[allow(clippy::for_kv_map)]` suppresses valid lint; should use `.values()` instead
- [PENDING] R02-8: (LOW) `add_or_select` uses `unwrap()` on `fork_evm_env` where `new_with_fork` uses `?` for same call
- [PENDING] R02-9: (LOW) `TryFrom<RawCallResult>` for `RainEvalResult` always produces empty `stack` and `writes` without documenting this limitation
- [PENDING] R02-10: (LOW) `#[derive]` placed before doc comments in `ForkEvalArgs` and `ForkParseArgs` is unconventional
- [PENDING] R02-11: (LOW) `roll_fork` uses `unwrap()` after `is_none()` check instead of idiomatic `if let Some`
- [PENDING] R03-1: (LOW) Unused dependencies `serde` and `serde_json` in parser crate Cargo.toml
- [PENDING] R03-2: (LOW) Unused dependency `serde_json` in test_fixtures crate Cargo.toml
- [PENDING] R03-3: (MEDIUM) Edition inconsistency — parser and dispair crates hardcode edition 2021 instead of workspace 2024
- [PENDING] R03-4: (LOW) Homepage URL inconsistency — parser and dispair use `rainlanguage` org instead of workspace `rainprotocol`
- [PENDING] R03-5: (MEDIUM) Duplicated `Parser2` trait definition for wasm vs non-wasm targets violates DRY
- [PENDING] R03-6: (LOW) `DISPaiR` doc comment mentions "Registry" but struct has no registry field
- [PENDING] R03-7: (LOW) Excessive `unwrap()` in `LocalEvm::new()` and `deploy_new_token()` produces unhelpful panic messages
- [PENDING] R03-8: (MEDIUM) `parse_pragma_text` is an inherent method while `parse_text` is a trait method creating asymmetry
- [PENDING] R03-9: (LOW) `DISPaiR` struct lacks `Debug` derive which is unusual for data-carrying struct
- [PENDING] R03-10: (LOW) Cargo.toml metadata inconsistency — parser and dispair hardcode license instead of using workspace
