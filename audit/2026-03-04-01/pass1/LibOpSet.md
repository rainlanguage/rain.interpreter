# A101 — Pass 1 (Security) — LibOpSet.sol

**File:** `src/lib/op/store/LibOpSet.sol`

## Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpSet` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal pure function | 29 |
| `referenceFn` | internal pure function | 46 |

**Imports:**
- `MemoryKV`, `MemoryKVKey`, `MemoryKVVal`, `LibMemoryKV` (from `rain.lib.memkv`)
- `IntegrityCheckState` (struct)
- `OperandV2`, `StackItem` (user-defined value types)
- `InterpreterState` (struct)
- `Pointer` (user-defined value type from `rain.solmem`)

**Using declarations:**
- `LibMemoryKV for MemoryKV` (line 14)

**No custom errors, events, or constants defined.**

## Analysis

### Integrity inputs/outputs vs run behavior

`integrity()` returns `(2, 0)` -- two inputs consumed (key, value), zero outputs produced.

`run()` behavior:
- Reads 2 words from the stack (lines 33-34): key at `stackTop`, value at `stackTop + 0x20`.
- Advances `stackTop` by `0x40` (line 35), consuming both inputs.
- Returns the advanced `stackTop` (line 39).

This is correct for a (2, 0) opcode. Two items are consumed, none produced. The stack shrinks by 2 words.

### Assembly memory safety

One assembly block in `run` (lines 32-36):

- `key := mload(stackTop)`: Read from stack. Memory-safe.
- `value := mload(add(stackTop, 0x20))`: Read from stack at offset +0x20. The integrity check ensures at least 2 items are on the stack, so this is within bounds. Memory-safe.
- `stackTop := add(stackTop, 0x40)`: Pointer arithmetic only, no memory access. Memory-safe.

The block is correctly annotated as `memory-safe`. No writes to memory occur in the assembly block.

### Stack underflow/overflow

The integrity check framework validates that at least 2 items are on the stack before `set` runs (2 inputs). Zero outputs means no stack growth. No underflow or overflow risk.

### State mutation

`run()` is marked `internal pure`, which is correct. The function only modifies in-memory state (`state.stateKV`). The actual persistence to the on-chain store happens after eval completes (in the caller), not within this opcode. No external calls, no reentrancy risk.

### Key/value ordering

The key is at `stackTop` (lower address, top of stack = first item pushed by preceding opcodes) and the value is at `stackTop + 0x20` (second item). This matches the Rainlang syntax `:set(key value)` where `key` is the first argument and `value` is the second. The `referenceFn` confirms: `inputs[0]` is key, `inputs[1]` is value. Consistent.

### Operand validation

The operand is unused by both `integrity()` and `run()`. The parser enforces that no operands are provided (tested by `testLibOpSetEvalOperandsDisallowed`). No validation needed here.

### referenceFn consistency

`referenceFn()` (lines 46-55) mirrors the `run()` logic using high-level Solidity: reads `inputs[0]` as key, `inputs[1]` as value, calls `stateKV.set()`, returns an empty array (0 outputs). The logic is identical to `run()`.

## Findings

No findings. The implementation is correct and secure.
