# Pass 3: Documentation Audit -- LibEval, LibIntegrityCheck, LibInterpreterState, LibInterpreterStateDataContract, LibInterpreterDeploy, LibExtern

Agent: A03
Date: 2026-03-07

## File 1: `src/lib/eval/LibEval.sol`

### Evidence

- **Library**: `LibEval` (line 15) -- no library-level NatSpec
- **Function `evalLoop`** (line 41): `@notice` (line 18), `@param state` (line 34), `@param parentSourceIndex` (line 36), `@param stackTop` (line 38), `@param stackBottom` (line 39), `@return` (line 40). All explicit tags present. TRUST block (lines 25-33) documents unbounded source index assumption.
- **Function `eval4`** (line 191): `@notice` (line 179), `@param state` (line 183), `@param inputs` (line 185), `@param maxOutputs` (line 187), `@return` x2 (lines 188-190). All explicit tags present.

### Checks

- `evalLoop`: NatSpec matches implementation. Describes the 8-opcode-per-word unrolled loop, remainder loop, and stack trace emission. Parameters and return documented. Trust assumptions documented.
- `eval4`: NatSpec matches implementation. Describes input validation, stack copy, evalLoop call, output construction, and KV flush. Both return values documented.
- Library `LibEval` lacks `@title`/`@notice` at the library level.

### Findings

**A03-INFO-1**: `LibEval` (line 15) has no library-level NatSpec (`@title`/`@notice`). All other libraries in this audit batch that serve a comparable role (`LibExtern`, `LibInterpreterDeploy`) have library-level doc blocks. Severity: INFO.

---

## File 2: `src/lib/integrity/LibIntegrityCheck.sol`

### Evidence

- **Struct `IntegrityCheckState`** (line 35): doc block starts at line 18. Line 18 has NO explicit tag ("Tracks the state of the integrity check walk over a single source."). Lines 19-34 use `@param` tags for all six fields.
- **Library**: `LibIntegrityCheck` (line 44) -- no library-level NatSpec
- **Function `newState`** (line 56): `@notice` (line 47), `@param bytecode` (line 51), `@param stackIndex` (line 52), `@param constants` (line 54), `@return` (line 55). All explicit tags present.
- **Function `integrityCheck2`** (line 91): `@notice` (line 77), `@param fPointers` (line 84), `@param bytecode` (line 86), `@param constants` (line 87), `@return io` (line 88). All explicit tags present.

### Checks

- `IntegrityCheckState` struct: six fields (`stackIndex`, `stackMaxIndex`, `readHighwater`, `constants`, `opIndex`, `bytecode`), all have `@param` docs. Field descriptions match usage in `integrityCheck2`. The `readHighwater` description correctly explains the multi-output advancement rule (line 190-192 of impl).
- `newState`: NatSpec says initial stack index, max, and highwater are all set to `stackIndex` (the source input count). Implementation (lines 61-74) confirms all three are set to `stackIndex`. Accurate.
- `integrityCheck2`: NatSpec describes walking all sources, calling integrity functions, and validating IO. Implementation matches. Return type `bytes memory io` with "two bytes per source" is confirmed by `new bytes(sourceCount * 2)` and the `mstore8` pairs at lines 129-131.
- Line 18: Implicit `@notice` in a block that uses `@param` tags violates the NatSpec convention.
- Library `LibIntegrityCheck` lacks `@title`/`@notice` at the library level.

### Findings

**A03-LOW-1**: `IntegrityCheckState` struct NatSpec (line 18) has an untagged leading line in a doc block that contains `@param` tags. Per NatSpec convention, when any explicit tag is present, all entries must be explicitly tagged. The line "Tracks the state of the integrity check walk over a single source." should have an explicit `@notice` tag.

**A03-INFO-2**: `LibIntegrityCheck` (line 44) has no library-level NatSpec. Severity: INFO.

---

## File 3: `src/lib/state/LibInterpreterState.sol`

### Evidence

- **Constant `STACK_TRACER`** (line 17): `@dev` tag (line 13). Single tag type, all content under `@dev`. Correct.
- **Struct `InterpreterState`** (line 42): `@notice` (line 19), `@param stackBottoms` (line 22), `@param constants` (line 25), `@param sourceIndex` (line 26), `@param stateKV` (line 27), `@param namespace` (line 30), `@param store` (line 32), `@param context` (line 34), `@param bytecode` (line 36), `@param fs` (line 39). All nine fields documented with explicit tags.
- **Library**: `LibInterpreterState` (line 55) -- no library-level NatSpec
- **Function `stackBottoms`** (line 62): `@notice` (line 56), `@param stacks` (line 60), `@return` (line 61). All explicit tags present.
- **Function `stackTrace`** (line 126): `@notice` (line 81), `@param parentSourceIndex` (line 122), `@param sourceIndex` (line 123), `@param stackTop` (line 124), `@param stackBottom` (line 125). All explicit tags present. No `@return` (function is void). Correct.

### Checks

- `STACK_TRACER`: NatSpec explains derivation from domain-specific keccak hash and that the call always fails (no code at address). Implementation matches: `address(uint160(uint256(keccak256("rain.interpreter.stack-tracer.0"))))`.
- `InterpreterState` struct: all nine fields documented. Descriptions match usage in `LibEval.evalLoop` and `LibEval.eval4`.
- `stackBottoms`: NatSpec says "address just past its last element, i.e. `array + 0x20 * (length + 1)`." Implementation: `add(stack, mul(0x20, add(mload(stack), 1)))`. Matches.
- `stackTrace`: NatSpec describes the staticcall tracing mechanism with cost analysis. The `@notice` opening line ("Does something that a full node can easily track in its traces that isn't an event") is vague but the extensive body clarifies the mechanism. The description of the memory layout (2-byte parent source index + 2-byte source index + stack items) matches the assembly at line 136-138.
- Library `LibInterpreterState` lacks `@title`/`@notice` at the library level.

### Findings

**A03-INFO-3**: `LibInterpreterState` (line 55) has no library-level NatSpec. Severity: INFO.

**A03-INFO-4**: `stackTrace` `@notice` (line 81) opens with a vague description ("Does something that a full node can easily track in its traces that isn't an event"). A more direct description such as "Emits a stack trace via a no-op staticcall to a deterministic tracer address, visible in full-node traces without the cost of an event" would be clearer. The body of the doc block is thorough. Severity: INFO.

---

## File 4: `src/lib/state/LibInterpreterStateDataContract.sol`

### Evidence

- **Library**: `LibInterpreterStateDataContract` (line 14) -- no library-level NatSpec
- **Function `serializeSize`** (line 26): `@notice` (line 17), `@param bytecode` (line 23), `@param constants` (line 24), `@return size` (line 25). All explicit tags present.
- **Function `unsafeSerialize`** (line 39): `@notice` (line 33), `@param cursor` (line 36), `@param bytecode` (line 37), `@param constants` (line 38). No `@return` (function is void). Correct.
- **Function `unsafeDeserialize`** (line 69): `@notice` (line 56), `@param serialized` (line 61), `@param sourceIndex` (line 63), `@param namespace` (line 64), `@param store` (line 65), `@param context` (line 66), `@param fs` (line 67), `@return` (line 68). All explicit tags present.

### Checks

- `serializeSize`: NatSpec describes layout as `[constants length][constants data...][bytecode length][bytecode data...]`. The formula `bytecode.length + constants.length * 0x20 + 0x40` = `(constants.length * 0x20 + 0x20) + (bytecode.length + 0x20)`, which is constants with length prefix + bytecode with length prefix. Matches.
- `unsafeSerialize`: NatSpec says "Writes constants (with length prefix) then bytecode (with length prefix)." Implementation copies constants array (including length word) via assembly loop, then copies bytecode (including length word) via `unsafeCopyBytesTo`. Matches.
- `unsafeDeserialize`: NatSpec says "References the constants and bytecode arrays in-place (no copy)." Implementation uses `constants := cursor` and `bytecode := cursor` (no memcpy). Allocates fresh stacks per source. Matches.
- Library `LibInterpreterStateDataContract` lacks `@title`/`@notice` at the library level.

### Findings

**A03-INFO-5**: `LibInterpreterStateDataContract` (line 14) has no library-level NatSpec. Severity: INFO.

---

## File 5: `src/lib/deploy/LibInterpreterDeploy.sol`

### Evidence

- **Library**: `LibInterpreterDeploy` (line 39): `@title` (line 33), `@notice` (line 34). Both explicit tags present.
- **Constants** (lines 42-88): 10 constants, each with a `///` doc block. None use explicit tags; all text is implicit `@notice`. Since no explicit tags are used within each individual constant's doc block, implicit `@notice` is acceptable.
  - `PARSER_DEPLOYED_ADDRESS` (line 42)
  - `PARSER_DEPLOYED_CODEHASH` (line 48)
  - `STORE_DEPLOYED_ADDRESS` (line 50)
  - `STORE_DEPLOYED_CODEHASH` (line 58)
  - `INTERPRETER_DEPLOYED_ADDRESS` (line 60)
  - `INTERPRETER_DEPLOYED_CODEHASH` (line 68)
  - `EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS` (line 72)
  - `EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH` (line 78)
  - `DISPAIR_REGISTRY_DEPLOYED_ADDRESS` (line 80)
  - `DISPAIR_REGISTRY_DEPLOYED_CODEHASH` (line 88)
- **Function `etchDISPaiR`** (line 95): `@notice` (line 90), `@param vm` (line 94). No `@return` (function is void). Correct.

### Checks

- Library-level NatSpec is present and accurate. Describes the purpose (deterministic deployment addresses and code hashes) and use case (idempotent deployments and automated verification).
- All 10 constants have NatSpec describing which contract they reference and the deployment mechanism (zoltu deployer). Descriptions are accurate and consistent.
- `etchDISPaiR`: NatSpec says "Etches the runtime bytecode of the parser, store, interpreter, expression deployer, and DISPair registry at their expected deterministic addresses. Skips any contract whose codehash already matches." Implementation checks `codehash` before each `vm.etch`. Matches.

### Findings

No findings.

---

## File 6: `src/lib/extern/LibExtern.sol`

### Evidence

- **Library**: `LibExtern` (line 17): `@title` (line 14), `@notice` (line 15). Both explicit tags present.
- **Function `encodeExternDispatch`** (line 27): `@notice` (line 18), `@param opcode` (line 24), `@param operand` (line 25), `@return` (line 26). All explicit tags present.
- **Function `decodeExternDispatch`** (line 35): `@notice` (line 31), `@param dispatch` (line 32), `@return` x2 (lines 33-34). All explicit tags present.
- **Function `encodeExternCall`** (line 56): `@notice` (line 42), `@param extern` (line 53), `@param dispatch` (line 54), `@return` (line 55). All explicit tags present.
- **Function `decodeExternCall`** (line 70): `@notice` (line 66), `@param dispatch` (line 67), `@return` x2 (lines 68-69). All explicit tags present.

### Checks

- `encodeExternDispatch`: NatSpec describes bit layout as operand in [0,16) and opcode in [16,32). Implementation: `bytes32(opcode) << 0x10 | OperandV2.unwrap(operand)`. Left-shifting by 0x10 (16 bits) places opcode at bits [16,...). The NatSpec documents the intended 16-bit ranges with an explicit caveat that the caller must ensure values fit. Acceptable.
- `decodeExternDispatch`: NatSpec says "Inverse of encodeExternDispatch." Implementation: right-shifts by 0x10 to get opcode, masks low 16 bits to get operand. Consistent inverse of `encodeExternDispatch`.
- `encodeExternCall`: NatSpec describes bit layout as address in [0,160), operand in [160,176), opcode in [176,192). Implementation: `bytes32(uint256(uint160(address(extern)))) | ExternDispatchV2.unwrap(dispatch) << 160`. Address goes to low 160 bits, dispatch is shifted left by 160 bits. Within the dispatch, operand is at [0,16) and opcode at [16,32), so after the shift they land at [160,176) and [176,192) respectively. Matches.
- `decodeExternCall`: NatSpec says "Inverse of encodeExternCall." Implementation: extracts low 160 bits as address, right-shifts by 160 to get dispatch. Consistent inverse.
- All four functions have complete `@param` and `@return` tags.

### Findings

No findings.

---

## Summary

| ID | File | Line | Severity | Description |
|---|---|---|---|---|
| A03-LOW-1 | LibIntegrityCheck.sol | 18 | LOW | `IntegrityCheckState` struct NatSpec has untagged leading line in a block with `@param` tags |
| A03-INFO-1 | LibEval.sol | 15 | INFO | Library `LibEval` has no library-level NatSpec |
| A03-INFO-2 | LibIntegrityCheck.sol | 44 | INFO | Library `LibIntegrityCheck` has no library-level NatSpec |
| A03-INFO-3 | LibInterpreterState.sol | 55 | INFO | Library `LibInterpreterState` has no library-level NatSpec |
| A03-INFO-4 | LibInterpreterState.sol | 81 | INFO | `stackTrace` `@notice` opening is vague |
| A03-INFO-5 | LibInterpreterStateDataContract.sol | 14 | INFO | Library `LibInterpreterStateDataContract` has no library-level NatSpec |
