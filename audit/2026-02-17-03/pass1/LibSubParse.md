# Pass 1 (Security) -- LibSubParse.sol

**File:** `src/lib/parse/LibSubParse.sol`

## Evidence of Thorough Reading

**Library name:** `LibSubParse`

**Functions:**

| Function | Line |
|---|---|
| `subParserContext(uint256 column, uint256 row)` | 37 |
| `subParserConstant(uint256 constantsHeight, bytes32 value)` | 85 |
| `subParserExtern(IInterpreterExternV4 extern, uint256 constantsHeight, uint256 ioByte, OperandV2 operand, uint256 opcodeIndex)` | 146 |
| `subParseWordSlice(ParseState memory state, uint256 cursor, uint256 end)` | 200 |
| `subParseWords(ParseState memory state, bytes memory bytecode)` | 308 |
| `subParseLiteral(ParseState memory state, uint256 dispatchStart, uint256 dispatchEnd, uint256 bodyStart, uint256 bodyEnd)` | 334 |
| `consumeSubParseWordInputData(bytes memory data, bytes memory meta, bytes memory operandHandlers)` | 392 |
| `consumeSubParseLiteralInputData(bytes memory data)` | 423 |

**Errors/Events/Structs defined in this file:** None (all errors are imported from `ErrParse.sol` and `ErrSubParse.sol`).

**Imported errors used:**
- `BadSubParserResult` (from `ErrParse.sol`) -- line 253
- `UnknownWord` (from `ErrParse.sol`) -- line 295
- `UnsupportedLiteralType` (from `ErrParse.sol`) -- line 377
- `ExternDispatchConstantsHeightOverflow` (from `ErrSubParse.sol`) -- line 157
- `ConstantOpcodeConstantsHeightOverflow` (from `ErrSubParse.sol`) -- line 91
- `ContextGridOverflow` (from `ErrSubParse.sol`) -- line 43

**Using directives:** `LibParseState for ParseState` (line 26), `LibParseError for ParseState` (line 27).

---

## Findings

### 1. INFO -- Misleading Error Doc for ExternDispatchConstantsHeightOverflow

**Location:** `src/error/ErrSubParse.sol`, line 8-10 (imported and used at `LibSubParse.sol` line 157)

**Description:** The NatSpec for `ExternDispatchConstantsHeightOverflow` says "outside the range a single byte can represent" but the actual check in `subParserExtern` at line 156 is `constantsHeight > 0xFFFF`, which is the 16-bit (2-byte) range. The check is correct -- the operand encoding uses 2 bytes for the constants height -- but the error documentation is misleading.

**Impact:** No runtime impact. The code correctly rejects values exceeding 16 bits. The documentation could cause confusion during code review or debugging.

### 2. LOW -- No Validation of ioByte Range in subParserExtern

**Location:** `src/lib/parse/LibSubParse.sol`, lines 149, 173

**Description:** The `subParserExtern` function accepts `ioByte` as a `uint256` but writes it to a single byte via `mstore8(add(bytecode, 0x21), ioByte)`. The `mstore8` EVM instruction stores only the least significant byte, silently truncating any value larger than 0xFF. While callers such as `consumeSubParseWordInputData` already mask `ioByte` to `0xFF` (line 401), the `subParserExtern` function itself does not validate this precondition.

**Mitigating factors:** All known call sites (`LibExternOpIntInc.subParser` and similar extern op libraries) receive `ioByte` from `consumeSubParseWordInputData`, which masks the value to a single byte. The function is `internal`, so it can only be called from within the same contract/library linkage.

**Impact:** If a future caller passes an `ioByte` greater than 0xFF, the upper bits would be silently dropped, resulting in an incorrect IO encoding. This is a defense-in-depth concern rather than a current vulnerability.

### 3. LOW -- No Validation of opcodeIndex Range in subParserExtern

**Location:** `src/lib/parse/LibSubParse.sol`, lines 151, 181

**Description:** The `opcodeIndex` parameter is passed to `LibExtern.encodeExternDispatch(opcodeIndex, operand)` which performs `bytes32(opcode) << 0x10 | operandV2`. The `LibExtern` documentation explicitly states: "The encoding process does not check that either the opcode or operand fit within 16 bits. This is the responsibility of the caller." However, `subParserExtern` does not validate that `opcodeIndex` fits in 16 bits before calling `encodeExternDispatch`.

**Mitigating factors:** The `opcodeIndex` comes from the extern's own opcode table (e.g., `OP_INDEX_INCREMENT` in `LibExternOpIntInc`), which are small constants defined by the extern implementer. The function is `internal`.

**Impact:** If `opcodeIndex >= 2^16`, the encoding would silently lose the high bits, potentially dispatching to the wrong extern opcode. This is a defense-in-depth concern.

### 4. INFO -- Unaligned Memory Allocations

**Location:** `src/lib/parse/LibSubParse.sol`, lines 47-66, 96-120, 163-178

**Description:** The bytecode allocations in `subParserContext`, `subParserConstant`, and `subParserExtern` advance the free memory pointer by 0x24 (36 bytes) rather than the 32-byte-aligned size. This leaves the free memory pointer 4 bytes past a 32-byte boundary. Subsequent allocations (the `constants` arrays at lines 69-73, 123-128, 185-190) will then start at misaligned addresses.

**Mitigating factors:** The code comments explicitly note these are unaligned allocations and explain that the 4-byte bytecode "never reaches Solidity code that expects 32-byte aligned memory." The EVM does not require memory alignment for `mload`/`mstore` operations, so all reads and writes are functionally correct. The constants arrays are only iterated in assembly or via simple Solidity array indexing, which works regardless of alignment.

**Impact:** No functional impact. This is an observation about an unconventional memory layout pattern that is intentional and documented.

### 5. INFO -- unchecked Block in subParseWordSlice and subParseWords

**Location:** `src/lib/parse/LibSubParse.sol`, lines 201, 313

**Description:** Both `subParseWordSlice` (line 201) and `subParseWords` (line 313) wrap their bodies in `unchecked` blocks.

- In `subParseWordSlice`, `cursor += 4` iterates through 4-byte opcodes. This is safe because `cursor` starts at a pointer within valid bytecode and is bounded by `end`.
- In `subParseWords`, `sourceOpsCount(bytecode, sourceIndex) * 4` is safe because `sourceOpsCount` returns a single byte (0-255), so the maximum product is 1020, which cannot overflow.
- The `sourceIndex` loop increment `++sourceIndex` is bounded by `sourceCount`, also a byte value.
- The `++i` in the constants loop (line 267) is bounded by `subConstants.length`.

**Impact:** No overflow risk. The `unchecked` arithmetic is correctly bounded by the constraints of the data structures.

### 6. INFO -- subParseWordSlice Operates on Raw Memory Pointers from Operand

**Location:** `src/lib/parse/LibSubParse.sol`, lines 224-226, 286-288

**Description:** In `subParseWordSlice`, the operand of an unknown opcode is extracted via `and(shr(0xe0, memoryAtCursor), 0xFFFF)` and used directly as a memory pointer (`data` at line 225, `word` at line 287). This pointer is then dereferenced and written to. There is no explicit bounds check on this pointer value.

**Mitigating factors:** These pointers are set by the main parser during the parsing phase. The main parser allocates the sub-parse data structures in memory and writes the pointers into the operand slots of unknown opcodes. By the time `subParseWordSlice` executes, the parser has already validated the overall structure. The pointers are internal to the parse process and not user-controlled -- they are derived from the parser's own memory allocations.

**Impact:** No practical risk. The pointer values are produced by trusted internal parser logic, not directly from untrusted input.

### 7. INFO -- Header Write in subParseWordSlice Uses Masked OR

**Location:** `src/lib/parse/LibSubParse.sol`, lines 230-244

**Description:** The header write at line 243 uses a masked OR pattern:
```
mstore(headerPtr, or(header, and(mload(headerPtr), not(shl(0xe8, 0xFFFFFF)))))
```
This preserves the existing data at `headerPtr` except for the top 3 bytes (24 bits at positions 0xe8-0xff), where the header (constantsHeight and ioByte) is written. The mask `shl(0xe8, 0xFFFFFF)` = `0xFFFFFF << 232` correctly targets the top 3 bytes of the 32-byte word. This is correct and preserves the string length and string data that follow the header.

**Impact:** No issue. The masking logic is correct.

### 8. INFO -- All Reverts Use Custom Errors

All revert paths in `LibSubParse.sol` use custom errors imported from `src/error/ErrParse.sol` and `src/error/ErrSubParse.sol`:
- `ContextGridOverflow` (line 43)
- `ConstantOpcodeConstantsHeightOverflow` (line 91)
- `ExternDispatchConstantsHeightOverflow` (line 157)
- `BadSubParserResult` (line 253)
- `UnknownWord` (line 295)
- `UnsupportedLiteralType` (line 377)

No string-based reverts are used. This satisfies the project convention.

---

## Summary

No CRITICAL or HIGH severity findings. The library is well-structured with correct bounds checks on all major parameters (`column`, `row`, `constantsHeight`). Assembly blocks use the `"memory-safe"` annotation and the memory operations are consistent with the documented allocation patterns. The `unchecked` arithmetic is correctly bounded by data structure constraints.

The two LOW findings relate to missing input validation on `ioByte` and `opcodeIndex` in `subParserExtern`. These are defense-in-depth concerns because all current callers provide correctly bounded values, but the function itself does not enforce its own preconditions.
