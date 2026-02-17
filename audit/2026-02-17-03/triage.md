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
