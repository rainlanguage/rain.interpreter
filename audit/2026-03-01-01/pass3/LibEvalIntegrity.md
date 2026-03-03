# Pass 3: NatSpec Documentation Review — LibEval, LibIntegrityCheck, LibInterpreterState, LibInterpreterStateDataContract, LibInterpreterDeploy

## Scope

Files reviewed:
1. `src/lib/eval/LibEval.sol` (251 lines)
2. `src/lib/integrity/LibIntegrityCheck.sol` (207 lines)
3. `src/lib/state/LibInterpreterState.sol` (143 lines)
4. `src/lib/state/LibInterpreterStateDataContract.sol` (143 lines)
5. `src/lib/deploy/LibInterpreterDeploy.sol` (67 lines)

## Evidence of Thorough Reading

### LibEval.sol
- Library: `LibEval` (line 15)
- Functions:
  - `evalLoop` (line 41) — internal view, 4 params, 1 return
  - `eval2` (line 191) — internal view, 3 params, 2 returns
- Imports: `LibInterpreterState`, `InterpreterState`, `LibMemCpy`, `LibMemoryKV`, `MemoryKV`, `LibBytecode`, `Pointer`, `OperandV2`, `StackItem`, `InputsLengthMismatch`
- No errors, structs, events, or constants defined in this file

### LibIntegrityCheck.sol
- Struct: `IntegrityCheckState` (line 31) — 6 fields: `stackIndex`, `stackMaxIndex`, `readHighwater`, `constants`, `opIndex`, `bytecode`
- Library: `LibIntegrityCheck` (line 40)
- Functions:
  - `newState` (line 52) — internal pure, 3 params, 1 return
  - `integrityCheck2` (line 87) — internal view, 3 params, 1 return
- Imports: `Pointer`, `OpcodeOutOfRange`, `StackAllocationMismatch`, `StackOutputsMismatch`, `StackUnderflow`, `StackUnderflowHighwater`, `BadOpInputsLength`, `BadOpOutputsLength`, `LibBytecode`, `OperandV2`

### LibInterpreterState.sol
- Constant: `STACK_TRACER` (line 17)
- Struct: `InterpreterState` (line 42) — 9 fields: `stackBottoms`, `constants`, `sourceIndex`, `stateKV`, `namespace`, `store`, `context`, `bytecode`, `fs`
- Library: `LibInterpreterState` (line 55)
- Functions:
  - `stackBottoms` (line 62) — internal pure, 1 param, 1 return
  - `stackTrace` (line 126) — internal view, 4 params, 0 returns
- Imports: `Pointer`, `MemoryKV`, `FullyQualifiedNamespace`, `IInterpreterStoreV3`, `StackItem`

### LibInterpreterStateDataContract.sol
- Library: `LibInterpreterStateDataContract` (line 14)
- Functions:
  - `serializeSize` (line 26) — internal pure, 2 params, 1 return
  - `unsafeSerialize` (line 39) — internal pure, 3 params, 0 returns
  - `unsafeDeserialize` (line 69) — internal pure, 6 params, 1 return
- Imports: `MemoryKV`, `Pointer`, `LibMemCpy`, `LibBytes`, `FullyQualifiedNamespace`, `IInterpreterStoreV3`, `InterpreterState`

### LibInterpreterDeploy.sol
- Library: `LibInterpreterDeploy` (line 11) — has `@title` and `@notice`
- Constants (10 total):
  - `PARSER_DEPLOYED_ADDRESS` (line 14)
  - `PARSER_DEPLOYED_CODEHASH` (line 20)
  - `STORE_DEPLOYED_ADDRESS` (line 25)
  - `STORE_DEPLOYED_CODEHASH` (line 31)
  - `INTERPRETER_DEPLOYED_ADDRESS` (line 36)
  - `INTERPRETER_DEPLOYED_CODEHASH` (line 42)
  - `EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS` (line 47)
  - `EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH` (line 53)
  - `DISPAIR_REGISTRY_DEPLOYED_ADDRESS` (line 58)
  - `DISPAIR_REGISTRY_DEPLOYED_CODEHASH` (line 64)
- No functions, errors, structs, or events

## NatSpec Completeness Checklist

| File | Item | Type | @notice | @param | @return | Complete |
|------|------|------|---------|--------|---------|----------|
| LibEval.sol | `evalLoop` | function | Yes (line 18) | 4/4 (lines 34-39) | 1/1 (line 40) | Yes |
| LibEval.sol | `eval2` | function | Yes (line 179) | 3/3 (lines 183-187) | 2/2 (lines 188-190) | Yes |
| LibIntegrityCheck.sol | `IntegrityCheckState` | struct | Yes (line 18) | 6/6 (lines 19-37) | N/A | Yes |
| LibIntegrityCheck.sol | `newState` | function | Yes (line 43) | 3/3 (lines 47-50) | 1/1 (line 51) | Yes |
| LibIntegrityCheck.sol | `integrityCheck2` | function | Yes (line 73) | 3/3 (lines 80-83) | 1/1 (line 84) | Yes |
| LibInterpreterState.sol | `STACK_TRACER` | constant | @dev (line 13) | N/A | N/A | Yes |
| LibInterpreterState.sol | `InterpreterState` | struct | Yes (line 19) | 9/9 (lines 22-41) | N/A | Yes |
| LibInterpreterState.sol | `stackBottoms` | function | Yes (line 56) | 1/1 (line 60) | 1/1 (line 61) | Yes |
| LibInterpreterState.sol | `stackTrace` | function | Yes (line 81) | 4/4 (lines 122-125) | 0/0 | Yes |
| LibInterpreterStateDataContract.sol | `serializeSize` | function | Yes (line 17) | 2/2 (lines 23-24) | 1/1 (line 25) | Yes |
| LibInterpreterStateDataContract.sol | `unsafeSerialize` | function | Yes (line 33) | 3/3 (lines 36-38) | 0/0 | Yes |
| LibInterpreterStateDataContract.sol | `unsafeDeserialize` | function | Yes (line 56) | 6/6 (lines 61-67) | 1/1 (line 68) | Yes |
| LibInterpreterDeploy.sol | library | library | Yes (line 7) | N/A | N/A | Yes |
| LibInterpreterDeploy.sol | all 10 constants | constant | Implicit (untagged) | N/A | N/A | Yes |

## Documentation Accuracy Review

### LibEval.sol
- `evalLoop` doc (line 18-40): Claims "up to 8 packed 4-byte opcodes (1 byte opcode index + 3 bytes operand)" -- confirmed in assembly at lines 99-102: `byte(0, word)` extracts the opcode index, `and(shr(0xe0, word), 0xFFFFFF)` extracts 3 bytes as the operand. Note: from the eval loop's perspective the 3 bytes include the IO byte, which is only semantically meaningful during integrity checking but is harmlessly passed as part of the operand to the runtime opcode function. The doc accurately describes the eval loop's view.
- Claims "bounded by modulo" -- confirmed at line 100: `mod(byte(0, word), fsCount)`.
- Claims "Emits a stack trace via `STACK_TRACER` after execution" -- confirmed at line 174: `LibInterpreterState.stackTrace(...)`.
- TRUST block (lines 25-33): Claims `eval2` validates via `LibBytecode.sourceInputsOutputsLength` which reverts with `SourceIndexOutOfBounds` -- confirmed at line 200-201.
- `eval2` doc (line 179-190): Claims inputs length validation, stack construction, output truncation -- all confirmed in implementation (lines 212, 225-226, 240, 243-244).

### LibIntegrityCheck.sol
- `IntegrityCheckState` struct doc: `readHighwater` described as "Lowest stack index that opcodes are allowed to read from" -- confirmed at line 172: `state.stackIndex < state.readHighwater` triggers revert. "Advances past multi-output regions" -- confirmed at line 186-188.
- `newState` doc: Claims initial values set to `stackIndex` -- confirmed at lines 59-61 where all three (stackIndex, stackMaxIndex, readHighwater) are initialized to the same value.
- `integrityCheck2` doc: Claims "Returns a packed `io` byte array with two bytes per source" -- confirmed at lines 110, 124-127.

### LibInterpreterState.sol
- `STACK_TRACER` doc: Claims "Derived from a domain-specific keccak hash" -- confirmed: `keccak256("rain.interpreter.stack-tracer.0")`.
- `stackBottoms` doc: Claims "address just past its last element" -- confirmed at line 74: `add(stack, mul(0x20, add(mload(stack), 1)))`.
- `stackTrace` doc: Gas cost analysis at lines 107-115 -- verified arithmetic: tracer ~3158 gas vs events ~14679 gas for 50 items over 5 calls.
- Claims "2 bytes of parent source index followed by 2 bytes of source index" packed as function selector -- confirmed at line 136-138.

### LibInterpreterStateDataContract.sol
- `serializeSize` doc: Claims layout `[constants length][constants data...][bytecode length][bytecode data...]` -- confirmed at line 29 and in `unsafeSerialize` implementation.
- `unsafeSerialize` doc: Claims "Writes `constants` (with length prefix) then `bytecode` (with length prefix)" -- confirmed at lines 42-52.
- `unsafeDeserialize` doc: Claims "References the constants and bytecode arrays in-place (no copy)" -- confirmed at lines 86 and 93 where assembly sets pointers directly into the serialized buffer.

### LibInterpreterDeploy.sol
- All constant docs accurately describe what each constant represents (deployed address or code hash for each of the 5 contracts via Zoltu deployer).
- No behavioral claims to verify (pure data).

## Findings

### P3-LEI-01 [INFO]: Missing library-level NatSpec on four libraries

**Files:**
- `src/lib/eval/LibEval.sol` line 15
- `src/lib/integrity/LibIntegrityCheck.sol` line 40
- `src/lib/state/LibInterpreterState.sol` line 55
- `src/lib/state/LibInterpreterStateDataContract.sol` line 14

**Description:** Four of the five libraries lack `@title` and/or `@notice` NatSpec at the library declaration level. Only `LibInterpreterDeploy` (line 5-10) has library-level documentation with `@title` and `@notice`. While all individual functions and types within these libraries are well-documented, the library declarations themselves have no doc blocks. This makes it harder for documentation generators and readers to understand the library's purpose at a glance.

**Impact:** Cosmetic. Does not affect correctness or security. All functions within these libraries have thorough NatSpec.

### P3-LEI-02 [INFO]: Vague opening line in stackTrace NatSpec

**File:** `src/lib/state/LibInterpreterState.sol` line 81

**Description:** The `@notice` for `stackTrace` opens with "Does something that a full node can easily track in its traces that isn't an event." The phrase "Does something" is imprecise for an API-facing doc tag. A more descriptive opening such as "Emits a stack trace via a staticcall to a deterministic no-code address" would immediately communicate the function's purpose. The rest of the doc block (lines 82-121) is thorough and accurate.

**Impact:** Cosmetic. The detailed explanation that follows is comprehensive and correct.

## Summary

All five files have thorough and accurate NatSpec documentation. Every function has `@notice`, `@param` (for all parameters), and `@return` (for all return values) tags. Both structs (`IntegrityCheckState` and `InterpreterState`) have complete `@param` documentation for all fields. The `STACK_TRACER` constant is documented with `@dev`. All documentation claims verified against their implementations are accurate.

No CRITICAL, HIGH, MEDIUM, or LOW findings. Two INFO-level observations about missing library-level NatSpec and a vague opening line.
