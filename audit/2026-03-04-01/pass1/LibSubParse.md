# A110 -- Pass 1 (Security) -- LibSubParse.sol

## Evidence of Thorough Reading

**Library name:** `LibSubParse`

**Functions and line numbers:**

| Line | Name | Kind | Visibility | Mutability |
|------|------|------|------------|------------|
| 49 | `subParserContext(uint256, uint256)` | function | internal | pure |
| 97 | `subParserConstant(uint256, bytes32)` | function | internal | pure |
| 162 | `subParserExtern(IInterpreterExternV4, uint256, uint256, OperandV2, uint256)` | function | internal | pure |
| 216 | `subParseWordSlice(ParseState memory, uint256, uint256)` | function | internal | view |
| 324 | `subParseWords(ParseState memory, bytes memory)` | function | internal | view |
| 350 | `subParseLiteral(ParseState memory, uint256, uint256, uint256, uint256)` | function | internal | view |
| 413 | `consumeSubParseWordInputData(bytes memory, bytes memory, bytes memory)` | function | internal | pure |
| 444 | `consumeSubParseLiteralInputData(bytes memory)` | function | internal | pure |

**Errors used (imported):**
- `BadSubParserResult(bytes)` from `ErrParse.sol`
- `UnknownWord(string)` from `ErrParse.sol`
- `UnsupportedLiteralType(uint256)` from `ErrParse.sol`
- `ExternDispatchConstantsHeightOverflow(uint256)` from `ErrSubParse.sol`
- `ConstantOpcodeConstantsHeightOverflow(uint256)` from `ErrSubParse.sol`
- `ContextGridOverflow(uint256, uint256)` from `ErrSubParse.sol`
- `SubParseLiteralDispatchLengthOverflow(uint256)` from `ErrSubParse.sol`

**Constants used (imported):**
- `OPCODE_UNKNOWN` (0xFF), `OPCODE_EXTERN`, `OPCODE_CONSTANT`, `OPCODE_CONTEXT` from `IInterpreterV4.sol`

**Using-for declarations:**
- `LibParseState for ParseState`
- `LibParseError for ParseState`

---

## Security Review

### EXT-M03 verification (silent truncation in sub parser linked list)

The prior finding EXT-M03 concerned silent truncation of the 16-bit linked-list pointer in `pushSubParser`. The fix is in `LibParseState.sol` lines 308-333: `pushSubParser` stores the tail pointer in the high 16 bits of the `bytes32` sub-parser entry, and `checkParseMemoryOverflow` (enforced on all external parse entry points) ensures the free memory pointer never reaches `0x10000`. The NatSpec at line 311-314 explicitly documents this invariant. The traversal in `subParseWordSlice` (line 228: `deref := mload(shr(0xf0, deref))`) and `subParseLiteral` (line 389) correctly reads the high 16 bits as a pointer. Fix is in place.

### Assembly memory safety

All assembly blocks are tagged `("memory-safe")`.

**`subParserContext` (lines 59-78, 81-85):**
- Allocates 36 bytes (0x24) from free memory for unaligned 4-byte bytecode. Bump is correct.
- Writes exactly 4 bytes of data at bytecode+0x20 through bytecode+0x23 via mstore8.
- Second allocation for empty constants array: 32 bytes (0x20), stores length 0. Correct.

**`subParserConstant` (lines 108-132, 135-140):**
- Same 36-byte unaligned allocation pattern. Correct.
- `mstore(add(bytecode, 4), constantsHeight)` writes 32 bytes starting at bytecode+4. This overlaps the length field (bytecode+0 to bytecode+31) and the data region (bytecode+0x20 to bytecode+0x23). Since constantsHeight <= 0xFFFF (checked at line 102), the 32-byte big-endian write places the value in the operand bytes (bytecode+0x22, bytecode+0x23) and zeros everything else. Then mstore8 writes IO byte and opcode, and mstore writes the length last. Correct.
- Constants array: 64 bytes (0x40), length 1, one value. Correct.

**`subParserExtern` (lines 179-194, 201-206):**
- Same patterns as above. `constantsHeight` checked at line 172. Correct.

**`subParseWordSlice` (lines 220-222, 227-228, 240-260, 275-279, 295-309):**
- Line 220-222: `mload(cursor)` reads 32 bytes from bytecode pointer. The cursor iterates in 4-byte steps from `cursor` to `end`, both provided by `subParseWords` which derives them from `LibBytecode.sourcePointer` and `sourceOpsCount`. Safe within the bytecode allocation.
- Line 240-242: `data := and(shr(0xe0, memoryAtCursor), 0xFFFF)` extracts the operand (bytes 2-3 of the 4-byte opcode) as a memory pointer. This is a 16-bit pointer to the sub-parse data region allocated during the main parse. Safe under the `checkParseMemoryOverflow` invariant.
- Line 247-259: Header construction overwrites the first 3 bytes of the data region at `add(data, 0x20)` with the IO byte and constants height, preserving the rest with a mask. Correctly scoped.
- Line 275-279: Copies 4 bytes from sub-bytecode result over the cursor using mask `0xFFFFFFFF << 0xe0`. Correct -- only the top 4 bytes of the 32-byte word at cursor are modified.
- Line 295-309: Error path extracts the unknown word from the operand pointer. Manipulates the sub-parse data to extract a string for the `UnknownWord` error. This is a revert path only -- no memory corruption risk.

**`subParseLiteral` (lines 369-376):**
- Allocates `data` with proper 32-byte aligned rounding: `and(add(add(data, add(dataLength, 0x20)), 0x1f), not(0x1f))`. Correct alignment formula.
- Writes dispatch length as 2 bytes at `add(data, 2)`, then total length at `data`. The dispatch length is checked <= `type(uint16).max` at line 363. Correct.

**`consumeSubParseWordInputData` (lines 419-429):**
- Extracts `constantsHeight` (2 bytes), `ioByte` (1 byte), then mutates `data` pointer forward by 5 bytes. The new length is read from bytes 4-5 of the original data. This is an in-place pointer shift, no allocation. The `operandValues` pointer is computed from `data + newLength + 0x20`. Correct, assuming the data layout matches the sub-parse wire format.

**`consumeSubParseLiteralInputData` (lines 449-454):**
- Pure pointer arithmetic. Reads dispatch length from 2 bytes, computes start/end pointers. No allocation. Correct.

### Bounds checks and input validation

- `subParserContext`: column and row checked against `type(uint8).max` at line 54.
- `subParserConstant`: constantsHeight checked against `type(uint16).max` at line 102.
- `subParserExtern`: constantsHeight checked against `type(uint16).max` at line 172.
- `subParserExtern`: `ioByte` and `opcodeIndex` NOT bounds-checked. Documented in NatSpec (lines 153-158) as caller responsibility. These are internal functions called by sub-parser implementations (e.g., `LibExternOpIntInc` passes a compile-time constant for `opcodeIndex` and a parser-derived `ioByte`). The trust boundary is reasonable for internal library use.
- `subParseWordSlice`: No explicit bounds check on cursor/end -- these are derived from `LibBytecode` functions in `subParseWords`. Correct delegation.
- `subParseLiteral`: dispatchLength checked against `type(uint16).max` at line 363. bodyLength is derived from pointer arithmetic with no independent check, but this is safe because bodyEnd >= bodyStart is guaranteed by the caller (parser cursor can only advance forward).
- `subParseWordSlice` line 268: sub-bytecode length must be exactly 4. Explicit check.

### Custom errors

No string reverts. All error paths use custom error types.

### External calls

- Line 264: `subParser.subParseWord2(data)` -- external call to sub parser contracts. These are user-opted-in via `using-words-from`. A malicious sub parser can return arbitrary bytecode (documented in library NatSpec lines 30-36), but the integrity check runs afterward on the complete bytecode.
- Line 392: `subParser.subParseLiteral2(data)` -- same trust model.

---

## Findings

No LOW+ findings.

The library is well-structured with appropriate bounds checks on all size-constrained fields. The documented trust model for sub-parsers (lines 30-36) correctly identifies that sub-parsers are fully trusted, and the integrity check provides the safety net. Assembly is carefully written with correct allocation bumps and mask operations. The prior finding EXT-M03 is addressed by the `checkParseMemoryOverflow` invariant enforced at the parser entry points.
