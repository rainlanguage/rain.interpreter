# Pass 2 (Test Coverage) -- BaseRainterpreterExtern.sol

## Evidence of Thorough Reading

### Source File: `src/abstract/BaseRainterpreterExtern.sol`

**Contract:** `BaseRainterpreterExtern` (abstract, line 33)
Inherits: `IInterpreterExternV4`, `IIntegrityToolingV1`, `IOpcodeToolingV1`, `ERC165`

**Functions:**
- `constructor()` -- line 43
- `extern(ExternDispatchV2, StackItem[])` -- line 55, external view
- `externIntegrity(ExternDispatchV2, uint256, uint256)` -- line 92, external pure
- `supportsInterface(bytes4)` -- line 121, public view
- `opcodeFunctionPointers()` -- line 130, internal view virtual
- `integrityFunctionPointers()` -- line 137, internal pure virtual

**Errors (imported from `src/error/ErrExtern.sol`):**
- `ExternOpcodeOutOfRange(uint256 opcode, uint256 fsCount)`
- `ExternPointersMismatch(uint256 opcodeCount, uint256 integrityCount)`
- `ExternOpcodePointersEmpty()`
- `BadOutputsLength(uint256 expectedLength, uint256 actualLength)`

### Test Files
- `test/src/abstract/BaseRainterpreterExtern.construction.t.sol`
- `test/src/abstract/BaseRainterpreterExtern.ierc165.t.sol`
- `test/src/abstract/BaseRainterpreterExtern.integrityOpcodeRange.t.sol`

## Findings

### A01-1: No direct test for `extern()` happy path on BaseRainterpreterExtern
**Severity:** LOW

The `extern()` function (line 55) has no direct test in the `BaseRainterpreterExtern` test files. Its coverage comes only indirectly through the `RainterpreterReferenceExtern` integration tests and `LibOpExtern.t.sol` (which uses mocks).

### A01-2: No test for `extern()` opcode mod-wrapping behavior
**Severity:** MEDIUM

The `extern()` function (line 85) uses `mod(opcode, fsCount)` to wrap out-of-range opcodes rather than reverting. This differs from `externIntegrity()` which reverts with `ExternOpcodeOutOfRange`. No test verifies this mod-wrapping behavior — specifically that calling `extern()` with an opcode >= fsCount silently wraps to `opcode % fsCount` and dispatches to the wrapped function.

### A01-3: No test for `externIntegrity()` happy path on BaseRainterpreterExtern
**Severity:** LOW

The `externIntegrity()` function (line 92) has a test for the out-of-range revert path but no direct test for the happy path where opcode < fsCount.

### A01-4: No test for `externIntegrity()` boundary at opcode == fsCount - 1
**Severity:** LOW

The out-of-range test uses `vm.assume(opcode >= 2)` for a `TwoOpExtern` with 2 pointers. There is no test that exercises the boundary case where `opcode == fsCount - 1` (the maximum valid opcode).

### A01-5: No test for dispatch encoding extraction correctness in `extern()` and `externIntegrity()`
**Severity:** LOW

Both functions extract `opcode` and `operand` from `ExternDispatchV2` using inline bit shifting and masking rather than calling `LibExtern`. No test verifies that these inline extractions agree with `LibExtern`'s codec.

### A01-6: Construction test uses byte-length counts rather than pointer counts in revert assertions
**Severity:** INFO

The constructor uses `.length` which returns byte length, not pointer count. The error reports byte lengths rather than logical pointer counts, which could be confusing. This is an observation, not a coverage gap.
