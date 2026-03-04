# Pass 2: Test Coverage -- BaseRainterpreterExtern

**Audit:** 2026-03-04-01
**Source:** `src/abstract/BaseRainterpreterExtern.sol`
**Agent ID:** A01

## Evidence

### Functions and line numbers

| Function | Line | Tested |
|---|---|---|
| `constructor()` | 34 | Empty pointers, mismatch (both directions) |
| `extern()` | 46 | Indirect via ReferenceExtern (direct, mod-wrap) |
| `externIntegrity()` | 83 | Out-of-range, boundary valid opcode |
| `supportsInterface()` | 112 | Fuzz tested |
| `opcodeFunctionPointers()` | 121 | Virtual default, tested via overrides |
| `integrityFunctionPointers()` | 128 | Virtual default, tested via overrides |

### Test files

- `test/src/abstract/BaseRainterpreterExtern.construction.t.sol`
- `test/src/abstract/BaseRainterpreterExtern.ierc165.t.sol`
- `test/src/abstract/BaseRainterpreterExtern.integrityOpcodeRange.t.sol`

### Errors

| Error | Tested |
|---|---|
| `ExternOpcodePointersEmpty` | Yes |
| `ExternPointersMismatch` (more opcodes) | Yes |
| `ExternPointersMismatch` (more integrity) | Yes |
| `ExternOpcodeOutOfRange` | Yes (fuzz + boundary) |

## Findings

### P2-A01-01 (INFO) `extern()` mod-wrap not tested at base level with multiple opcodes

The `extern()` function at line 76 uses `mod(opcode, fsCount)` to wrap out-of-range opcodes to a valid function pointer index. This is tested only through `RainterpreterReferenceExtern` which has exactly 1 opcode (so every opcode mods to 0). No base-level test uses a multi-opcode extern to verify that:

1. In-range opcodes 0 and 1 dispatch to distinct functions.
2. An out-of-range opcode wraps to the correct function via mod.

The `TwoOpExtern` contract exists in the test suite but is only used for `externIntegrity` range tests, not for `extern()` dispatch tests.

Carryover from audit `2026-03-01-01` finding `P2-EAD-03`.
