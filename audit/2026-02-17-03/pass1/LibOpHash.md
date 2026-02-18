# Pass 1 (Security) -- LibOpHash.sol

## File

`src/lib/op/crypto/LibOpHash.sol`

## Evidence of Thorough Reading

### Library Name

`LibOpHash` (line 12)

### Functions

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `integrity` | 14 | `internal` | `pure` |
| `run` | 22 | `internal` | `pure` |
| `referenceFn` | 33 | `internal` | `pure` |

### Errors / Events / Structs

None defined in this file.

### Imports

- `Pointer` from `rain.solmem/lib/LibPointer.sol` (line 5)
- `OperandV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 6)
- `InterpreterState` from `../../state/LibInterpreterState.sol` (line 7)
- `IntegrityCheckState` from `../../integrity/LibIntegrityCheck.sol` (line 8)

## Analysis

### Operand Extraction

Both `integrity` (line 17) and `run` (line 24) extract the input count from the operand using the same mask and shift: bits 16-19 of the operand, yielding a value from 0 to 15. The Solidity expression `uint256(OperandV2.unwrap(operand) >> 0x10) & 0x0F` and the assembly expression `and(shr(0x10, operand), 0x0F)` are equivalent because `OperandV2` is a user-defined value type wrapping `bytes32` and is passed as a raw stack value to assembly.

### Integrity vs Run Consistency

- `integrity` returns `(inputs, 1)` where `inputs` ranges from 0 to 15.
- `run` consumes `inputs` stack items and produces 1 output.

Tracing through the `run` assembly for each case:

- **0 inputs**: `length = 0`, `keccak256(stackTop, 0)` produces hash of empty bytes, `stackTop = stackTop - 0x20` (pushes 1 output). Net: 0 consumed, 1 produced. Matches integrity `(0, 1)`.
- **1 input**: `length = 0x20`, hash of 1 item, `stackTop` unchanged, output overwrites input. Net: 1 consumed, 1 produced. Matches integrity `(1, 1)`.
- **N inputs (N > 1)**: `length = N * 0x20`, hash of N items, `stackTop = stackTop + (N-1)*0x20`, output overwrites last consumed slot. Net: N consumed, 1 produced. Matches integrity `(N, 1)`.

### Assembly Memory Safety

The assembly block (lines 23-28):
1. Reads `operand` (stack variable) -- safe.
2. `keccak256(stackTop, length)` reads from the interpreter's managed stack region -- read-only, within bounds guaranteed by integrity check.
3. Computes new `stackTop` arithmetically -- no memory access.
4. `mstore(stackTop, value)` writes to a slot within (or immediately below) the consumed stack region -- within bounds.

The block does not modify the free memory pointer or allocate memory. All memory access is within the interpreter's stack region, which is managed externally.

### Reference Function Consistency

`referenceFn` (line 33) computes `keccak256(abi.encodePacked(inputs))` where `inputs` is `StackItem[] memory`. Since `StackItem` is `bytes32`, `abi.encodePacked` concatenates the elements without length prefix, producing the same byte sequence that `keccak256(stackTop, length)` hashes in `run`. The two are semantically equivalent.

### Unchecked Arithmetic

The assembly block uses `mul`, `add`, and `sub` without overflow checks (assembly has no overflow checking). The critical computation is:
- `length = mul(and(shr(0x10, operand), 0x0F), 0x20)` -- max value is `15 * 32 = 480`, no overflow risk.
- `stackTop = sub(add(stackTop, length), 0x20)` -- `add(stackTop, length)` could theoretically overflow if `stackTop` is near `2^256`, but memory pointers in the EVM are bounded well below that. No practical overflow risk.

## Findings

No CRITICAL, HIGH, MEDIUM, or LOW findings.

### INFO-01: Zero-Input Hash Produces Non-Zero Output From No Stack Consumption

**Severity**: INFO

**Location**: Lines 16-17 (integrity), lines 24-26 (run)

**Description**: When the operand specifies 0 inputs, the `hash` opcode produces `keccak256("")` (the hash of empty bytes, `0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfae0609e36159`) as output while consuming nothing from the stack. The integrity function correctly reports `(0, 1)` for this case, and `run` correctly pushes one new value. This is explicitly documented in the comment on line 16 ("0 inputs will be the hash of empty (0 length) bytes."). This is noted purely for completeness -- the behavior is intentional and consistent.

### INFO-02: Maximum Input Count Limited to 15

**Severity**: INFO

**Location**: Line 17, line 24

**Description**: The 4-bit mask `0x0F` limits the hash opcode to at most 15 inputs (480 bytes). This is a design constraint shared with all multi-input opcodes in the codebase (e.g., `LibOpAdd`, `LibOpEvery`, `LibOpDiv`, etc.), not specific to `LibOpHash`. For hashing larger data, users would need to use multiple hash operations or different approaches.
