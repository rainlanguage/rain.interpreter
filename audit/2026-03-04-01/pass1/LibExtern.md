# Pass 1 (Security) -- LibExtern.sol

Agent: A22

## File

`src/lib/extern/LibExtern.sol` (81 lines)

## Evidence of Thorough Reading

**Library:** `library LibExtern` (line 17)

**Functions:**

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `encodeExternDispatch(uint256 opcode, OperandV2 operand) -> ExternDispatchV2` | 27 | `internal` | `pure` |
| `decodeExternDispatch(ExternDispatchV2 dispatch) -> (uint256, OperandV2)` | 35 | `internal` | `pure` |
| `encodeExternCall(IInterpreterExternV4 extern, ExternDispatchV2 dispatch) -> EncodedExternDispatchV2` | 56 | `internal` | `pure` |
| `decodeExternCall(EncodedExternDispatchV2 dispatch) -> (IInterpreterExternV4, ExternDispatchV2)` | 70 | `internal` | `pure` |

**Errors/Events/Structs/Constants:** None defined.

**Imports:**
- `IInterpreterExternV4`, `ExternDispatchV2`, `EncodedExternDispatchV2` from `rain.interpreter.interface/interface/IInterpreterExternV4.sol` (lines 5-9)
- `OperandV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 12)
- `StackItem` is re-exported for convenience; lint suppression on line 11

**User-defined types (from interface):**
- `ExternDispatchV2 is bytes32`
- `EncodedExternDispatchV2 is bytes32`
- `OperandV2 is bytes32`

## Security Analysis

### Encoding/Decoding Correctness

#### `encodeExternDispatch` (line 27-29)

Formula: `ExternDispatchV2.wrap(bytes32(opcode) << 0x10 | OperandV2.unwrap(operand))`

- `bytes32(opcode)`: casts `uint256` to `bytes32`. Since `bytes32` and `uint256` have identical 256-bit EVM stack representation, this is a no-op at the EVM level.
- `<< 0x10`: shifts left by 16 bits, placing opcode starting at bit 16.
- `OperandV2.unwrap(operand)`: returns full `bytes32`. No mask to 16 bits.
- `|`: bitwise OR merges the two.

Documented layout:
- bits [0,16): operand
- bits [16,32): opcode

No validation that opcode fits in 16 bits or that operand only uses low 16 bits. Documented as caller responsibility (lines 22-23).

#### `decodeExternDispatch` (lines 35-40)

- Opcode: `uint256(ExternDispatchV2.unwrap(dispatch) >> 0x10)` -- right-shifts 16 bits, returns all remaining 240 bits as `uint256`. Not masked to 16 bits.
- Operand: `OperandV2.wrap(ExternDispatchV2.unwrap(dispatch) & bytes32(uint256(type(uint16).max)))` -- masked to low 16 bits.

Roundtrip correctness: when inputs respect 16-bit constraints, encode-then-decode recovers original values. Verified by fuzz tests in `test/src/lib/extern/LibExtern.codec.t.sol` (lines 14-21) and standalone decode tests (lines 41-46).

#### `encodeExternCall` (lines 56-64)

Formula: `EncodedExternDispatchV2.wrap(bytes32(uint256(uint160(address(extern)))) | ExternDispatchV2.unwrap(dispatch) << 160)`

- Address occupies bits [0,160) via `uint160` truncation (enforced by Solidity type system).
- Dispatch shifted left 160 bits into bits [160,256). A properly encoded `ExternDispatchV2` uses only bits [0,32), so after shift it occupies bits [160,192), fitting within the 96 available high bits.
- No overlap possible when dispatch is correctly encoded.

#### `decodeExternCall` (lines 70-79)

- Address: `address(uint160(uint256(EncodedExternDispatchV2.unwrap(dispatch))))` -- extracts low 160 bits via `uint160` truncation.
- Dispatch: `ExternDispatchV2.wrap(EncodedExternDispatchV2.unwrap(dispatch) >> 160)` -- right-shifts 160, recovering bits [160,256) into bits [0,96).

Roundtrip correctness: verified by fuzz tests (lines 24-36) and standalone decode tests (lines 50-57) in the test file.

### No Assembly Blocks

All operations are pure Solidity bitwise operations on `bytes32` user-defined value types. No inline assembly, no memory manipulation, no pointer arithmetic.

### No Unchecked Arithmetic

The library uses only bitwise operations (`<<`, `>>`, `|`, `&`) and Solidity type conversions. No arithmetic operations that could overflow or underflow.

### No Revert Paths

Pure encoding/decoding utility with no error conditions. No custom errors defined, which is appropriate -- validation is delegated to callers (`LibOpExtern` validates ERC165 support and output lengths; `LibSubParse` validates `constantsHeight`).

### Input Validation

Both encoding functions document that they do not validate input widths (lines 22-23 for `encodeExternDispatch`, lines 49-52 for `encodeExternCall`). The production caller is `LibSubParse.subParserExtern` (line 197), which:
- Validates `constantsHeight` against `type(uint16).max` (line 172)
- Documents that `opcodeIndex` "MUST fit in 16 bits" but does not enforce it (line 156-158)
- Passes `operand` directly from the parser, which constrains operands at parse time

The `opcodeIndex` value in practice comes from `OP_INDEX_INCREMENT` or similar small constants in extern implementations, so the lack of range validation does not create a practical vulnerability.

### Caller Security Context

`LibExtern` functions are called from:
1. `LibSubParse.subParserExtern` (line 197): encoding path during parsing. Pure context.
2. `LibOpExtern.integrity` (line 34): decoding path during integrity check. View context with ERC165 validation.
3. `LibOpExtern.run` (line 56): decoding path during eval. View/staticcall context.
4. `LibOpExtern.referenceFn` (line 112): decoding path in reference implementation.

All callers are internal library functions. No external entry point directly exposes these encode/decode functions.

## Change History

No changes since last audit (commit `441e9b5b`, 2026-03-01 merge). File is identical to the version reviewed in audit `2026-03-01-01` (agent A06) and `2026-02-17-03`.

## Findings

No findings at LOW severity or above. The file is a minimal, pure Solidity bitwise encoding/decoding library with no assembly, no arithmetic, no revert paths, and no external interactions. All prior findings from previous audits remain valid and have been triaged.

### A22-INFO-1: No assembly -- no memory safety concerns

All four functions are pure Solidity bitwise operations on `bytes32` user-defined value types. No inline assembly, no `memory-safe` annotations needed, no pointer arithmetic.

### A22-INFO-2: Encoding functions do not validate input widths (by design)

`encodeExternDispatch` and `encodeExternCall` explicitly document that input width validation is the caller's responsibility. The sole production caller (`LibSubParse.subParserExtern`) provides values constrained at parse time. This is a deliberate design choice, not a defect.

### A22-INFO-3: `decodeExternDispatch` returns unmasked opcode (by design)

The opcode return from `decodeExternDispatch` is `uint256(dispatch >> 0x10)` without a 16-bit mask. This is self-consistent with encoding: whatever was placed above bit 16 is faithfully returned. The actual consumer in `BaseRainterpreterExtern.extern()` applies its own 16-bit mask. No silent corruption occurs.

### A22-INFO-4: Roundtrip correctness verified by fuzz tests

Both encode/decode pairs have fuzz tests in `test/src/lib/extern/LibExtern.codec.t.sol` that verify roundtrip correctness with bounded inputs. Standalone decode tests (lines 41-57) independently construct raw words to guard against symmetric encode/decode bugs.

## Summary

`LibExtern.sol` is unchanged since the prior audit. It is a clean, minimal library with no security vulnerabilities. All operations are pure bitwise transformations on typed `bytes32` values with no assembly, no arithmetic, and no revert paths. The encode/decode roundtrips are mathematically correct when inputs respect documented bit-width constraints, which is enforced by the parser and integrity check layers.
