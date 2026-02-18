# Pass 1 (Security) - LibOpExtern.sol

## File

`src/lib/op/00/LibOpExtern.sol`

## Evidence of Thorough Reading

### Contract/Library

- `library LibOpExtern` (line 23)

### Functions

| Function | Line | Visibility | Mutability |
|----------|------|-----------|------------|
| `integrity(IntegrityCheckState memory, OperandV2)` | 25 | `internal` | `view` |
| `run(InterpreterState memory, OperandV2, Pointer)` | 41 | `internal` | `view` |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` | 90 | `internal` | `view` |

### Errors/Events/Structs Defined

None defined in this file. Errors are imported:
- `NotAnExternContract` (imported from `src/error/ErrExtern.sol`, originally from `rain.interpreter.interface/error/ErrExtern.sol`)
- `BadOutputsLength` (imported from `src/error/ErrExtern.sol`)

### Imports

- `NotAnExternContract` from `../../../error/ErrExtern.sol` (line 5)
- `IntegrityCheckState` from `../../integrity/LibIntegrityCheck.sol` (line 6)
- `OperandV2` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 7)
- `InterpreterState` from `../../state/LibInterpreterState.sol` (line 8)
- `Pointer` from `rain.solmem/lib/LibPointer.sol` (line 9)
- `IInterpreterExternV4`, `ExternDispatchV2`, `EncodedExternDispatchV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterExternV4.sol` (lines 10-15)
- `LibExtern` from `../../extern/LibExtern.sol` (line 16)
- `LibBytes32Array` from `rain.solmem/lib/LibBytes32Array.sol` (line 17)
- `ERC165Checker` from `openzeppelin-contracts/contracts/utils/introspection/ERC165Checker.sol` (line 18)
- `BadOutputsLength` from `../../../error/ErrExtern.sol` (line 19)

## Findings

### LOW-1: Integrity function delegates trust to external contract's `externIntegrity` return values without constraining them to 4-bit range

**Location**: Line 37

**Description**: The `integrity` function extracts `expectedInputsLength` and `expectedOutputsLength` from the operand using 4-bit masks (lines 34-35), giving them a max value of 15. These are passed to `extern.externIntegrity()`, whose return values are then returned directly as the integrity function's inputs/outputs.

However, a malicious or buggy extern could return values larger than 15 from `externIntegrity`. The caller (`LibIntegrityCheck.integrityCheck2`) compares these return values against the bytecode-declared IO, which is also bounded (4 bits for inputs, 4 bits for outputs at the bytecode level). So if the extern returns a large value, the integrity check would fail because it wouldn't match the bytecode declaration.

Additionally, the `run` function uses the operand-extracted values (4-bit bounded) directly, so even if integrity somehow passed, `run` would only ever consume/produce 0-15 items.

The mitigation is that `LibIntegrityCheck.integrityCheck2` validates the returned values against bytecodeOpInputs/bytecodeOpOutputs, which are inherently small values. So the pass-through is safe in practice. However, a defensive check clamping or validating the extern's return values would add defense-in-depth.

**Impact**: Minimal in practice due to the bytecode IO validation in `LibIntegrityCheck`. A mismatch would cause a revert, not an exploit.

### LOW-2: ERC165 interface check in integrity but not in run

**Location**: Lines 31-33 (integrity), lines 47-48 (run)

**Description**: The `integrity` function checks that the extern contract supports `IInterpreterExternV4` via ERC165 (line 31). The `run` function does not repeat this check. This is by design -- the integrity check runs at deploy time, and runtime re-checking would waste gas. However, if a proxy-based extern contract were to change its implementation between deploy time and evaluation time, the ERC165 check at integrity time would be stale. In practice, the call to `extern.extern()` would simply revert if the contract no longer implements the expected interface, so this is not exploitable.

**Impact**: No exploit path. The `staticcall` to a non-conforming contract would revert rather than produce incorrect results.

### INFO-1: Assembly memory safety annotations are correct

**Location**: Lines 51, 68, 107

All three assembly blocks are annotated `"memory-safe"` and the analysis confirms they only read/write within previously allocated memory regions:

1. **Block 1 (lines 51-62)**: Writes to `sub(stackTop, 0x20)`, which is either unused stack memory or the stack array's length field. The original value is saved in `head` and restored in Block 2. The mutation is only visible during the `extern.extern()` call, which is an external `staticcall` and thus isolated from the caller's memory.

2. **Block 2 (lines 68-85)**: Restores `head`, adjusts `stackTop` within the allocated stack region, and copies outputs from the ABI-decoded `outputs` array (allocated by Solidity at the free memory pointer) into the stack region. All writes are within bounds of the pre-allocated stack.

3. **Block 3 (lines 107-109)**: A type-punning cast (`outputsBytes32 := outputs`) that does not read or write memory.

### INFO-2: No reentrancy risk due to view/staticcall context

**Location**: Lines 63, 101

Both `extern.extern()` calls (in `run` at line 63 and `referenceFn` at line 101) are within `internal view` functions. The top-level `eval4()` is `external view`, so all external calls are `staticcall`. State modifications are impossible, eliminating reentrancy as a concern. The extern cannot call back into the interpreter to modify state because the entire execution context is read-only.

### INFO-3: Operand bit layout consistency between integrity and run

**Location**: Lines 26, 34-35 (integrity) and lines 42-44 (run)

Both functions extract the same three fields from the operand using identical bit operations:
- `encodedExternDispatchIndex`: `operand & 0xFFFF` (16 bits, max 65535)
- `inputsLength`: `(operand >> 0x10) & 0x0F` (4 bits at position 16-19, max 15)
- `outputsLength`: `(operand >> 0x14) & 0x0F` (4 bits at position 20-23, max 15)

This consistency ensures that integrity checks and runtime execution agree on stack consumption/production.

### INFO-4: Custom errors used correctly, no string reverts

**Location**: Lines 32, 65, 103

All error paths use custom errors:
- `NotAnExternContract(address(extern))` at line 32
- `BadOutputsLength(outputsLength, outputs.length)` at lines 65 and 103

No string revert messages are present. All custom errors are defined in `src/error/ErrExtern.sol` (or imported from `rain.interpreter.interface`).

### INFO-5: Constants array access is bounds-checked by Solidity

**Location**: Lines 29, 46, 98

The `state.constants[encodedExternDispatchIndex]` access in all three functions uses standard Solidity array indexing, which includes automatic bounds checking. If `encodedExternDispatchIndex` (max value 65535 from the 16-bit mask) exceeds the constants array length, Solidity will revert with a panic. This is correct behavior -- the parser is responsible for ensuring valid indices at parse time.

### INFO-6: Stack pointer manipulation in run is correct but relies on integrity guarantees

**Location**: Lines 51-85

The `run` function's stack manipulation assumes:
1. There are at least `inputsLength` items on the stack above `stackTop`.
2. The word at `sub(stackTop, 0x20)` is safe to temporarily overwrite.
3. There is room to push `outputsLength` items after popping `inputsLength` items.

All three assumptions are guaranteed by the integrity check:
1. The integrity checker ensures sufficient stack depth before consuming inputs.
2. The integrity checker's highwater mechanism prevents reading below the last multi-output point, ensuring the word below the stack top is either the stack array length or unused stack space.
3. Stack allocation is pre-computed based on the maximum stack depth observed during integrity walking.

Without the integrity check (i.e., if someone constructs raw bytecode bypassing the expression deployer), these assumptions could be violated. However, the expression deployer's bytecode hash verification prevents this.
