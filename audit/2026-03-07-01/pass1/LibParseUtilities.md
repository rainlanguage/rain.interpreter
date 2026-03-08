# Pass 1: Security Review of Parser Utility Files

**Agent:** A16
**Date:** 2026-03-07
**Branch:** 2026-03-07-audit

## Evidence of Thorough Reading

### 1. LibParseError.sol

- **Library:** `LibParseError` (line 7)
- **Functions:**
  - `parseErrorOffset(ParseState memory, uint256 cursor) -> uint256` (line 13)
  - `handleErrorSelector(ParseState memory, uint256 cursor, bytes4 errorSelector)` (line 26)
- **Types/Constants:** None
- **Imports:** `ParseState` from `LibParseState.sol`

### 2. LibParseInterstitial.sol

- **Library:** `LibParseInterstitial` (line 17)
- **Functions:**
  - `skipComment(ParseState memory, uint256 cursor, uint256 end) -> uint256` (line 28)
  - `skipWhitespace(ParseState memory, uint256 cursor, uint256 end) -> uint256` (line 96)
  - `parseInterstitial(ParseState memory, uint256 cursor, uint256 end) -> uint256` (line 111)
- **Types/Constants:** None (imports `FSM_YANG_MASK`, `CMASK_*` constants, error types)
- **Imports:** `FSM_YANG_MASK`, `ParseState`, `CMASK_COMMENT_HEAD`, `CMASK_WHITESPACE`, `COMMENT_END_SEQUENCE`, `COMMENT_START_SEQUENCE`, `CMASK_COMMENT_END_SEQUENCE_END`, `MalformedCommentStart`, `UnclosedComment`, `LibParseError`, `LibParseChar`

### 3. LibParseOperand.sol

- **Library:** `LibParseOperand` (line 24)
- **Functions:**
  - `parseOperand(ParseState memory, uint256 cursor, uint256 end) -> uint256` (line 38)
  - `handleOperand(ParseState memory, uint256 wordIndex) -> OperandV2` (line 139)
  - `handleOperandDisallowed(bytes32[] memory) -> OperandV2` (line 156)
  - `handleOperandDisallowedAlwaysOne(bytes32[] memory) -> OperandV2` (line 167)
  - `handleOperandSingleFull(bytes32[] memory) -> OperandV2` (line 180)
  - `handleOperandSingleFullNoDefault(bytes32[] memory) -> OperandV2` (line 204)
  - `handleOperandDoublePerByteNoDefault(bytes32[] memory) -> OperandV2` (line 228)
  - `handleOperand8M1M1(bytes32[] memory) -> OperandV2` (line 261)
  - `handleOperandM1M1(bytes32[] memory) -> OperandV2` (line 313)
- **Types/Constants:** None defined locally
- **Imports:** `ExpectedOperand`, `UnclosedOperand`, `OperandValuesOverflow`, `UnexpectedOperand`, `UnexpectedOperandValue`, `OperandOverflow`, `OperandV2`, `LibParseLiteral`, `CMASK_OPERAND_END`, `CMASK_WHITESPACE`, `CMASK_OPERAND_START`, `ParseState`, `OPERAND_VALUES_LENGTH`, `FSM_YANG_MASK`, `LibParseError`, `LibParseInterstitial`, `LibDecimalFloat`, `Float`

### 4. LibParsePragma.sol

- **Library:** `LibParsePragma` (line 28)
- **Functions:**
  - `parsePragma(ParseState memory, uint256 cursor, uint256 end) -> uint256` (line 41)
- **Types/Constants:**
  - `PRAGMA_KEYWORD_BYTES` (line 13): raw bytes of "using-words-from"
  - `PRAGMA_KEYWORD_BYTES32` (line 17): left-aligned bytes32 comparison value
  - `PRAGMA_KEYWORD_BYTES_LENGTH` (line 19): 16
  - `PRAGMA_KEYWORD_MASK` (line 23): isolates first 16 bytes of a bytes32
- **Imports:** `LibParseState`, `ParseState`, `CMASK_WHITESPACE`, `NoWhitespaceAfterUsingWordsFrom`, `LibParseError`, `LibParseInterstitial`, `LibParseLiteral`

### 5. LibParseStackName.sol

- **Library:** `LibParseStackName` (line 21)
- **Functions:**
  - `pushStackName(ParseState memory, bytes32 word) -> (bool exists, uint256 index)` (line 31)
  - `stackNameIndex(ParseState memory, bytes32 word) -> (bool exists, uint256 index)` (line 62)
- **Types/Constants:** None defined locally
- **Imports:** `ParseState` from `LibParseState.sol`

### 6. LibParseStackTracker.sol

- **Library:** `LibParseStackTracker` (line 15)
- **Functions:**
  - `pushInputs(ParseStackTracker, uint256 n) -> ParseStackTracker` (line 25)
  - `push(ParseStackTracker, uint256 n) -> ParseStackTracker` (line 47)
  - `pop(ParseStackTracker, uint256 n) -> ParseStackTracker` (line 74)
- **Types/Constants:**
  - `ParseStackTracker` user-defined value type wrapping `uint256` (line 10)
- **Imports:** `ParseStackUnderflow`, `ParseStackOverflow`

### 7. LibSubParse.sol

- **Library:** `LibSubParse` (line 37)
- **Functions:**
  - `subParserContext(uint256 column, uint256 row) -> (bool, bytes memory, bytes32[] memory)` (line 49)
  - `subParserConstant(uint256 constantsHeight, bytes32 value) -> (bool, bytes memory, bytes32[] memory)` (line 97)
  - `subParserExtern(IInterpreterExternV4, uint256, uint256, OperandV2, uint256) -> (bool, bytes memory, bytes32[] memory)` (line 162)
  - `subParseWordSlice(ParseState memory, uint256 cursor, uint256 end)` (line 216)
  - `subParseWords(ParseState memory, bytes memory bytecode) -> (bytes memory, bytes32[] memory)` (line 324)
  - `subParseLiteral(ParseState memory, uint256, uint256, uint256, uint256) -> bytes32` (line 350)
  - `consumeSubParseWordInputData(bytes memory, bytes memory, bytes memory) -> (uint256, uint256, ParseState memory)` (line 413)
  - `consumeSubParseLiteralInputData(bytes memory) -> (uint256, uint256, uint256)` (line 444)
- **Types/Constants:** None defined locally
- **Imports:** `LibParseState`, `ParseState`, `OPCODE_UNKNOWN`, `OPCODE_EXTERN`, `OPCODE_CONSTANT`, `OPCODE_CONTEXT`, `OperandV2`, `LibBytecode`, `Pointer`, `ISubParserV4`, `BadSubParserResult`, `UnknownWord`, `UnsupportedLiteralType`, `IInterpreterExternV4`, `LibExtern`, `EncodedExternDispatchV2`, `ExternDispatchConstantsHeightOverflow`, `ConstantOpcodeConstantsHeightOverflow`, `ContextGridOverflow`, `SubParseLiteralDispatchLengthOverflow`, `LibMemCpy`, `LibParseError`

---

## Previously Triaged Findings (Not Re-Flagged)

- **EXT-M02** (pragma OOB read): FIXED. Bounds check at LibParsePragma.sol lines 86-90 prevents `tryParseLiteral` from reading past `end`.
- **EXT-M03** (sub-parser dispatch truncation): FIXED. Explicit revert at LibSubParse.sol lines 363-365 prevents silent truncation of dispatch length > 0xFFFF.

---

## Security Review

### Memory Safety in Assembly

All assembly blocks across the seven files are marked `"memory-safe"`. Reviewed each block for:

1. **LibParseError.sol:** `parseErrorOffset` (line 15-17) computes pointer arithmetic, no writes. `handleErrorSelector` (line 29-32) writes to scratch space (0x00-0x24) then reverts -- safe, no memory corruption.

2. **LibParseInterstitial.sol:** `skipComment` reads individual bytes via `byte(0, mload(cursor))` and 2-byte sequences via `shr(0xf0, mload(...))`. All reads are bounded by `cursor < end` loop guards. `parseInterstitial` (line 114-117) reads single bytes.

3. **LibParseOperand.sol:** `parseOperand` (lines 40-103) reads bytes and writes to operandValues array at computed offsets bounded by `OPERAND_VALUES_LENGTH` (4) check. `handleOperand` (line 142-148) reads 2-byte function pointers from handlers array -- no bounds check but index is parser-internal.

4. **LibParsePragma.sol:** `parsePragma` (line 48-49) reads 32 bytes at cursor via `mload` for pragma comparison. The pragma comparison uses a mask so extra bytes beyond the keyword are irrelevant. Cursor bounds are checked at line 63.

5. **LibParseStackName.sol:** `pushStackName` (lines 38-44) allocates a new linked list node at the free memory pointer, correctly bumps `mload(0x40)`. Uses scratch space (0x00) for keccak. `stackNameIndex` (lines 67-86) traverses the linked list using 16-bit pointers, reads via `mload(ptr)`. The 16-bit pointer truncation is inherent to the linked list design and safe within EVM memory constraints during parsing (memory pointers during a single transaction's parsing phase stay well under 2^16).

6. **LibParseStackTracker.sol:** No assembly. Pure Solidity arithmetic with overflow/underflow checks on the packed 256-bit word.

7. **LibSubParse.sol:** Multiple assembly blocks for unaligned bytecode allocation and header construction. All allocations correctly update `mload(0x40)`. The `mstore(add(bytecode, 4), constantsHeight)` pattern (lines 122, 187) writes 32 bytes starting at the length slot area, but subsequent `mstore8` and final `mstore(bytecode, 4)` overwrite the relevant positions correctly. `subParseLiteral` (line 373) rounds up free memory pointer to 32-byte alignment.

### Input Validation

- **Operand handlers:** All enforce value count constraints and range checks (uint8, uint16, 1-bit flags). All use custom error types.
- **Pragma parsing:** Requires whitespace after keyword. Bounds-checks cursor before literal parsing.
- **Stack tracker:** Overflow check (`> 0xFF`) on push, underflow check on pop.
- **SubParse:** constantsHeight validated against `type(uint16).max`. Context grid values validated against `type(uint8).max`. Sub-bytecode length validated as exactly 4.

### Arithmetic Safety

- `skipComment` (line 39): `cursor + 4 > end` in unchecked. Comment notes overflow is irrelevant since cursor/end are memory pointers that can't approach uint256 max. Accepted.
- `push` (line 52): `current += n` in unchecked with `current` masked to 8 bits. NatSpec documents the safety invariant that `n` must be <= 0xFF. The `> 0xFF` check after addition would miss a wrapping sum, but since both operands are <= 0xFF, the max sum is 0x1FE which cannot wrap a uint256. Safe.
- `pop` (line 80): Direct subtraction from packed word in unchecked. Safe because `current >= n` is checked first, and since `n <= current <= 0xFF`, the subtraction cannot borrow into higher bytes.

### Error Handling

All error paths use custom error types. No string reverts found.

---

## Findings

No findings. All seven files demonstrate sound memory safety practices, proper input validation, correct arithmetic handling, and appropriate error types. The previously flagged issues (EXT-M02, EXT-M03) are confirmed fixed.
