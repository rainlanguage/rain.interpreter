# Pass 1 — Security: LibOpExtern (A32)

**File:** `src/lib/op/00/LibOpExtern.sol`

## Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpExtern` | library | 23 |
| `integrity` | internal view function | 29 |
| `run` | internal view function | 49 |
| `referenceFn` | internal view function | 102 |

**Imports:**
- `NotAnExternContract` (custom error)
- `BadOutputsLength` (custom error)
- `IntegrityCheckState` (struct)
- `OperandV2`, `StackItem` (user-defined value types)
- `InterpreterState` (struct)
- `Pointer` (user-defined value type)
- `IInterpreterExternV4`, `ExternDispatchV2`, `EncodedExternDispatchV2` (interface + types)
- `LibExtern` (library)
- `LibBytes32Array` (library)
- `ERC165Checker` (OpenZeppelin)

## Analysis

### Operand extraction

All three functions extract `encodedExternDispatchIndex = operand & 0xFFFF` (low
16 bits). `integrity()` and `run()` both extract:
- `inputsLength = (operand >> 0x10) & 0x0F` (4 bits at position 16-19)
- `outputsLength = (operand >> 0x14) & 0x0F` (4 bits at position 20-23)

`referenceFn()` only extracts `outputsLength` since inputs come from the
`inputs` parameter. Consistent.

### Constants array access

Line 33: `state.constants[encodedExternDispatchIndex]` — Solidity bounds-checked
array access. Reverts on OOB. Note that unlike `LibOpConstant`, there is no
explicit integrity bounds check against `state.constants.length`. However, this
is Solidity-level array access so it will revert with a panic if OOB. The
integrity function is `view` (not `pure`) because it makes an external call, and
the Solidity bounds check provides safety here.

### ERC165 interface check

Line 35: `ERC165Checker.supportsInterface(address(extern), type(IInterpreterExternV4).interfaceId)`
validates the extern contract supports the expected interface before calling
`externIntegrity`. This is correct defensive programming.

### Integrity inputs/outputs

Returns the values from `extern.externIntegrity(dispatch, expectedInputsLength, expectedOutputsLength)`. The extern contract is trusted to return correct I/O
counts. The integrity framework then validates these against the bytecode-declared
values. This is correct — the extern is responsible for its own I/O declaration.

### Memory manipulation in run()

Lines 59-70: The assembly creates a pseudo-array by:
1. Setting `inputs` to `stackTop - 0x20` (the word before the stack top).
2. Saving the original value at that location (`head`).
3. Writing `inputsLength` as the array length word.

This is a well-documented pattern that avoids memory allocation. The original
value is restored at line 79 (`mstore(inputs, head)`).

Lines 76-93: After the extern call:
1. Restores the saved `head` value.
2. Adjusts `stackTop` upward by `inputsLength * 0x20` (consuming inputs).
3. Copies outputs onto the stack in reverse order (so 0th output is lowest).

The reverse copy loop uses `sourceCursor` starting at `outputs + 0x20` and
ending at `outputs + 0x20 + outputsLength * 0x20`. The loop decrements
`stackTop` by 0x20 per iteration and stores each output. This is correct.

### Output length validation

Line 72-74: `if (outputsLength != outputs.length) revert BadOutputsLength(...)`.
This validates that the extern returned exactly the expected number of outputs.
This is critical for stack safety and is correctly implemented.

### Assembly memory safety

First assembly block (lines 59-70): Mutates a word that is either in the unused
stack region or the stack array's length word. The save/restore pattern makes
this safe. The `memory-safe` annotation is acceptable because the mutation is
temporary and fully restored.

Second assembly block (lines 76-93): Writes to the stack region and restores
the saved head. The stack writes are within pre-allocated space (integrity
check ensures sufficient allocation). `memory-safe` annotation is correct.

### Stack underflow/overflow

Inputs: `(operand >> 0x10) & 0x0F` — max 15 inputs.
Outputs: `(operand >> 0x14) & 0x0F` — max 15 outputs.
The integrity framework validates these against `stackIndex` before allowing
the opcode to execute at runtime.

### Extern re-entrancy

`run()` makes an external call to `extern.extern(dispatch, inputs)`. This is a
`view` function call, so it cannot modify state. The interpreter's `eval4` is
also `view`, so the entire call chain is read-only. No re-entrancy risk.

## Findings

No findings. The implementation correctly validates extern interface support,
output lengths, and uses safe memory manipulation patterns with save/restore
semantics.
