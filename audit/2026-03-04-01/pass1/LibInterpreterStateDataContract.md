# A117 — LibInterpreterStateDataContract.sol — Pass 1 (Security)

## Evidence

**Library:** `LibInterpreterStateDataContract`

**Functions:**
- `serializeSize(bytes memory bytecode, bytes32[] memory constants) -> uint256` (line 26): Computes total byte size for serialization.
- `unsafeSerialize(Pointer cursor, bytes memory bytecode, bytes32[] memory constants)` (line 39): Writes constants + bytecode into a pre-allocated memory region.
- `unsafeDeserialize(bytes memory serialized, uint256 sourceIndex, FullyQualifiedNamespace namespace, IInterpreterStoreV3 store, bytes32[][] memory context, bytes memory fs) -> InterpreterState memory` (line 69): Reconstructs InterpreterState from serialized bytes.

**Custom errors:** None.
**Constants:** None.

## Security Review

### serializeSize (line 26-31)

Uses `unchecked` arithmetic: `bytecode.length + constants.length * 0x20 + 0x40`. For overflow to occur, `constants.length` would need to exceed `2^251`, which is impossible given EVM memory constraints. The NatSpec correctly documents the caller's responsibility for non-corrupt length fields. No issue.

### unsafeSerialize (line 39-54)

**Assembly block (line 42-50):** Copies constants array (length prefix + elements) from source to destination using a word-by-word loop. The loop iterates from `constants` to `constants + 0x20 * (constants.length + 1)`, copying `constants.length + 1` words total. `cursor` is updated in the assembly block and persists to Solidity scope, so the subsequent `unsafeCopyBytesTo` call receives the correct position past the constants data.

**Bytecode copy (line 52):** `unsafeCopyBytesTo(bytecode.startPointer(), cursor, bytecode.length + 0x20)` copies the length prefix + all bytecode data. `startPointer()` returns the pointer to the length word, and `bytecode.length + 0x20` is the total size including the length word. Correct.

**`memory-safe` annotation:** The assembly writes to caller-allocated memory (not past the free memory pointer from this function's perspective) and does not modify the free memory pointer or zero slot. Valid.

**Empty inputs:** When `constants.length == 0`, the loop copies just the length word (0). When `bytecode.length == 0`, `unsafeCopyBytesTo` copies just the length word (0). Both are correct.

No issues found.

### unsafeDeserialize (line 69-142)

This is the most complex function. It deserializes constants, bytecode, and stack allocations from a contiguous byte array.

**Constants aliasing (line 84-88):** `constants := cursor` aliases the constants array to the serialized data in-place. This avoids a copy. The pointer arithmetic `cursor := add(cursor, mul(0x20, add(mload(cursor), 1)))` correctly advances past the length word + all constant elements. Safe as long as the serialized data remains in memory (which it does for the duration of eval).

**Bytecode aliasing (line 91-94):** `bytecode := cursor` aliases bytecode in-place. Same safety reasoning as constants.

**Stack building (line 98-136):**

1. `cursor := add(cursor, 0x20)` — skips the bytecode length word.
2. `stacksLength := byte(0, mload(cursor))` — reads source count from first byte of bytecode data.
3. `cursor := add(cursor, 1)` — advances past source count byte.
4. `sourcesStart := add(cursor, mul(stacksLength, 2))` — start of source bodies (past all 2-byte relative pointers).

**stackBottoms allocation (line 106-108):** Allocates `(stacksLength + 1) * 0x20` bytes via the free memory pointer. Correctly stores the length and updates `0x40`. When `stacksLength == 0`, allocates just the length word (32 bytes) with length 0. Correct.

**Per-source stack allocation (line 112-135):** The Yul for-loop structure:
- Init: `i = 0`
- Condition: `i < stacksLength`
- Post: `i++`, `cursor += 2`, `stacksCursor += 0x20`
- Body: reads 2-byte relative source pointer, follows it to source prefix, reads stack size from second byte of prefix, allocates stack, stores bottom pointer.

The source pointer extraction `shr(0xf0, mload(cursor))` correctly reads the top 2 bytes of a 32-byte word as a uint16 offset. The stack size extraction `byte(1, mload(sourcePointer))` reads the second byte of the source prefix (the first byte is ops count, the second is stack allocation). The stack allocation `mstore(0x40, stackBottom)` correctly updates the free memory pointer.

**Write order in the loop:** `stacksCursor` starts at `stackBottoms + 0x20` (first slot) and the body writes to `stacksCursor` before the post-increment. So writes go to indices 0, 1, ..., stacksLength-1. Correct.

**`memory-safe` annotation (line 98):** All memory allocations go through the free memory pointer. All writes go to freshly allocated regions. The free memory pointer is correctly maintained. The zero slot is untouched. Valid.

**Trust boundary:** The function name starts with `unsafe`, and the NatSpec does not claim any validation of the serialized data. The caller (`eval4` in `Rainterpreter.sol`) receives data from the expression deployer, which runs integrity checks at deploy time. Malformed serialized data passed directly would lead to incorrect stack sizes or out-of-bounds reads, but this is a documented pre-condition, not a bug.

No issues found.

## Findings

No findings.
