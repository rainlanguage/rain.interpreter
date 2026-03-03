# Pass 1 Audit: Parse Utility Libraries

Audited files:
- `src/lib/parse/LibParseOperand.sol` (A39)
- `src/lib/parse/LibParseInterstitial.sol` (A32)
- `src/lib/parse/LibParsePragma.sol` (A40)
- `src/lib/parse/LibParseStackName.sol` (A41)
- `src/lib/parse/LibParseStackTracker.sol` (A42)
- `src/lib/parse/LibSubParse.sol` (A44)
- `src/lib/parse/LibParseError.sol` (A31)

## Evidence of Thorough Reading

### LibParseOperand.sol (A39, 348 lines)
- `parseOperand`: reads char via `shl(byte(0, mload(cursor)), 1)` bitmask pattern; resets `operandValues` length to 0 via assembly; loops parsing literals between `<` and `>` delimiters; checks `OPERAND_VALUES_LENGTH` (4) bound on `i`; writes values via `mstore(add(operandValues, add(0x20, mul(i, 0x20))), value)` bypassing Solidity bounds checks against current length; toggles FSM_YANG_MASK for whitespace-separated literal sequences.
- `handleOperand`: reads 2-byte function pointer from `operandHandlers` at `add(handlers, add(2, mul(wordIndex, 2)))`, no bounds check (documented as intentional -- parser-internal index).
- `handleOperandDisallowed`, `handleOperandDisallowedAlwaysOne`: revert on non-empty values.
- `handleOperandSingleFull`, `handleOperandSingleFullNoDefault`: Float-to-integer conversion via `toFixedDecimalLossless`; uint16 range check.
- `handleOperandDoublePerByteNoDefault`: two uint8 values packed `a | (b << 8)`.
- `handleOperand8M1M1`: uint8 + two 1-bit flags packed `a | (b << 8) | (c << 9)`.
- `handleOperandM1M1`: two optional 1-bit flags packed `a | (b << 1)`.

### LibParseInterstitial.sol (A32, 128 lines)
- `skipComment`: checks `cursor + 4 > end`; validates `/*` start sequence via `shr(0xf0, mload(cursor))`; skips to cursor+3; scans for `*/` by checking `byte(0, mload(cursor)) == CMASK_COMMENT_END_SEQUENCE_END` (which is `/`, value 0x2F); on match, reads 2-byte sequence at `cursor-1` via `shr(0xf0, mload(sub(cursor, 1)))` and compares to `COMMENT_END_SEQUENCE`; sets FSM_YANG_MASK.
- `skipWhitespace`: clears FSM_YANG_MASK; delegates to `LibParseChar.skipMask`.
- `parseInterstitial`: loops skipping whitespace and comments until non-interstitial char.

### LibParsePragma.sol (A40, 92 lines)
- Constants: `PRAGMA_KEYWORD_BYTES = "using-words-from"` (16 bytes); mask zeroes low `(32-16)*8 = 128` bits.
- `parsePragma`: loads 32 bytes at cursor; masks and compares to keyword; requires at least one whitespace char after keyword; loops calling `parseInterstitial` then `tryParseLiteral`; calls `pushSubParser` for each address.

### LibParseStackName.sol (A41, 89 lines)
- Node packing: bits [255:32] = 224-bit fingerprint, bits [23:16] = stack index, bits [15:0] = next-node pointer.
- `pushStackName`: hashes word via `keccak256(0, 0x20)` after `mstore(0, word)`; computes `fingerprint := and(hash, not(0xFFFFFFFF))` (top 224 bits, bottom 32 zeroed); allocates node at free pointer; stores `fingerprint | (stackLHSIndex << 0x10) | ptr`.
- `stackNameIndex`: computes `fingerprint := shr(0x20, hash)` (top 224 bits shifted to [223:0]); bloom key = `and(fingerprint, 0xFF)` (bits [39:32] of original hash); bloom = `shl(bloomKey, 1)`; on bloom hit, walks linked list comparing `eq(fingerprint, shr(0x20, stackNames))`; extracts index as `and(shr(0x10, stackNames), 0xFFFF)`.
- Bloom filter always updated (line 87) even on miss, ensuring future lookups hit.
- Fingerprint comparison verified consistent between push and lookup (both derive same 224-bit value, just stored/compared differently).

### LibParseStackTracker.sol (A42, 77 lines)
- Type: `ParseStackTracker` is `uint256` with packing: bits [7:0] = current height, bits [15:8] = inputs, bits [255:16] = high watermark (max).
- `pushInputs`: calls `push(n)` then adds `n` to inputs byte; checks `inputs > 0xFF`.
- `push`: extracts current, inputs, max; `current += n` unchecked; checks `current > 0xFF`; updates max if exceeded; repacks.
- `pop`: extracts current; checks `current < n`; subtracts `n` directly from packed word (safe because `n <= current <= 0xFF` prevents borrow into higher bytes).

### LibSubParse.sol (A44, 450 lines)
- `subParserContext`: bounds-checks column/row to uint8; unaligned 4-byte bytecode allocation; individual `mstore8` for each byte; empty constants array.
- `subParserConstant`: bounds-checks `constantsHeight` to uint16; writes constants height via `mstore(add(bytecode, 4), constantsHeight)` (32-byte write that zeroes IO/opcode area, then individual `mstore8` for IO byte and opcode); single-element constants array.
- `subParserExtern`: bounds-checks `constantsHeight`; builds extern dispatch via `LibExtern.encodeExternCall`; same bytecode construction pattern.
- `subParseWordSlice`: iterates bytecode 4 bytes at a time; for `OPCODE_UNKNOWN` (0xFF), walks sub-parser linked list; extracts operand as data pointer (`and(shr(0xe0, memoryAtCursor), 0xFFFF)`); writes 3-byte header (constants height + IO byte) into data; calls `subParseWord2`; validates result length == 4; copies result over unknown op; pushes sub-constants. If no sub-parser succeeds, constructs error string from subparse data and reverts `UnknownWord`.
- `subParseWords`: iterates all sources via `LibBytecode`; calls `subParseWordSlice` for each.
- `subParseLiteral`: builds data with 2-byte dispatch length prefix; copies dispatch and body; walks sub-parser list calling `subParseLiteral2`; reverts `UnsupportedLiteralType` if none succeed.
- `consumeSubParseWordInputData`: extracts constants height (16-bit at data+2), IO byte (8-bit at data+3), string length (16-bit at data+5); advances data pointer past header; creates new `ParseState`.
- `consumeSubParseLiteralInputData`: extracts dispatch length and computes pointers.

### LibParseError.sol (A31, 36 lines)
- `parseErrorOffset`: computes `cursor - (data + 0x20)` via assembly.
- `handleErrorSelector`: if selector non-zero, packs selector + offset into scratch and reverts with 36 bytes.

## Findings

### A44-1: Unaligned Free Memory Pointer in `subParseLiteral` (LOW)

**File:** `src/lib/parse/LibSubParse.sol`, line 367

**Description:** The `subParseLiteral` function allocates a `bytes memory` region for the sub-parser payload with:
```solidity
mstore(0x40, add(data, add(dataLength, 0x20)))
```

`dataLength = 2 + dispatchLength + bodyLength`, which can be any value. The free memory pointer is advanced to `data + 0x20 + dataLength`, which is not guaranteed to be 32-byte aligned. Subsequent Solidity-generated code (including the ABI encoding for the `subParser.subParseLiteral2(data)` external call) expects the free memory pointer to be 32-byte aligned.

**Impact:** In practice, the Solidity ABI encoder tolerates unaligned free memory pointers in current compiler versions (0.8.25). However, this violates the Solidity memory model's alignment invariant. A future compiler version or optimizer pass that relies on this invariant could produce incorrect ABI encoding, causing malformed external calls to sub-parsers.

Additionally, the same pattern exists in `subParserContext`, `subParserConstant`, and `subParserExtern` (lines 65, 114, 185) where `add(bytecode, 0x24)` is not 32-byte aligned. These are documented as intentionally unaligned and the bytecode is only used via direct memory copy (not passed to Solidity ABI encoding), so they are less concerning. However, `subParseLiteral` does pass the unaligned allocation to an ABI-encoded external call.

**Severity:** LOW -- no known exploit path in solc 0.8.25; the risk is future compiler incompatibility. The `checkParseMemoryOverflow` modifier would catch gross memory corruption but not misalignment.

### A42-1: `pop` Does Not Validate `n` Upper Bound (INFORMATIONAL)

**File:** `src/lib/parse/LibParseStackTracker.sol`, line 68

**Description:** The `pop` function accepts `uint256 n` and checks `current < n` to prevent underflow. If `n > 0xFF`, the check correctly reverts (since `current <= 0xFF`). However, unlike `push` which documents "MUST be <= 0xFF" for `n`, `pop`'s NatSpec does not impose an upper bound on `n`. The NatSpec comment at lines 60-63 explains why the direct subtraction shortcut is safe ("n <= current <= 0xFF") but this is an invariant that follows from the underflow check, not a precondition on `n`.

No bug here -- the code is correct. The NatSpec could be clearer that `n` has no precondition requirement because the underflow check implicitly constrains it to `<= current <= 0xFF`.

**Severity:** INFORMATIONAL -- documentation clarity only.

### A41-1: Stack Name Fingerprint Collision Causes Silent Misresolution (INFORMATIONAL)

**File:** `src/lib/parse/LibParseStackName.sol`, lines 31-52

**Description:** Stack name identity is determined by a 224-bit fingerprint derived from `keccak256(word)`. If two distinct LHS names produce the same 224-bit fingerprint, `pushStackName` would find the first name via `stackNameIndex`, return `exists = true`, and skip allocating a new node. The second name would silently resolve to the first name's stack index.

A 224-bit collision requires ~2^112 attempts (birthday bound), which is computationally infeasible. The bloom filter adds no additional collision risk beyond what the fingerprint already has -- bloom false positives just trigger a linked-list traversal that still compares the full 224-bit fingerprint.

**Severity:** INFORMATIONAL -- astronomically unlikely; standard hash-based identity approach.

### A44-2: Sub-Parser Header Mutation Persists Across Iterations (INFORMATIONAL)

**File:** `src/lib/parse/LibSubParse.sol`, lines 243-259

**Description:** In `subParseWordSlice`, the header bytes (constants height + IO byte) are written into the `data` region pointed to by the unknown opcode's operand. This `data` region is shared across all sub-parser attempts in the while loop (line 224). The header is written before each `subParseWord2` call, but since `constantsBuilder` and `memoryAtCursor` do not change between iterations, the re-write is idempotent.

If a sub-parser implementation were to mutate the `data` bytes it receives (which is allowed since it's an external call that copies the data into its own memory), it would not affect the next sub-parser's view because external calls use calldata copies. But if a sub-parser were called via `delegatecall` instead, it could corrupt the shared data. Currently only `call` is used (via the interface's `external` function), so this is not an issue.

**Severity:** INFORMATIONAL -- no current exploit path; the external call boundary provides isolation.

### A32-1: Comment End Detection Scans Single Byte Before Checking Sequence (INFORMATIONAL)

**File:** `src/lib/parse/LibParseInterstitial.sol`, lines 63-76

**Description:** The comment end detection first checks if the current byte equals `CMASK_COMMENT_END_SEQUENCE_END` (which is `0x2F`, the `/` character -- the low byte of `*/`). On match, it then loads the 2-byte sequence at `cursor - 1` to verify the full `*/`. The `mload(sub(cursor, 1))` reads from `cursor - 1`, which is safe because `cursor` starts at `original_cursor + 3` and only increments, so `cursor - 1 >= original_cursor + 2 >= data_start`.

The single-byte pre-check (`/`) is correct as a fast path. A standalone `/` inside a comment triggers the 2-byte verification but does not falsely close the comment. The sequence `*/` is correctly detected. The cursor advancement (`++cursor` at line 73) moves past the final `/`, which is correct.

**Severity:** INFORMATIONAL -- no issue found; documenting the analysis for completeness.
