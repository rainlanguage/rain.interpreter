# Pass 3: Documentation — LibParseOperand.sol, LibParsePragma.sol, LibParseStackName.sol

Agent: A24

---

## Evidence of Thorough Reading

### File 1: `src/lib/parse/LibParseOperand.sol`

**Library:** `LibParseOperand` (line 21)

**Functions:**
| Function | Line |
|---|---|
| `parseOperand(ParseState memory, uint256, uint256) returns (uint256)` | 35 |
| `handleOperand(ParseState memory, uint256) returns (OperandV2)` | 136 |
| `handleOperandDisallowed(bytes32[] memory) returns (OperandV2)` | 153 |
| `handleOperandDisallowedAlwaysOne(bytes32[] memory) returns (OperandV2)` | 164 |
| `handleOperandSingleFull(bytes32[] memory) returns (OperandV2)` | 177 |
| `handleOperandSingleFullNoDefault(bytes32[] memory) returns (OperandV2)` | 199 |
| `handleOperandDoublePerByteNoDefault(bytes32[] memory) returns (OperandV2)` | 222 |
| `handleOperand8M1M1(bytes32[] memory) returns (OperandV2)` | 255 |
| `handleOperandM1M1(bytes32[] memory) returns (OperandV2)` | 306 |

**Errors referenced (from ErrParse.sol):**
- `ExpectedOperand()`
- `UnclosedOperand(uint256 offset)`
- `OperandValuesOverflow(uint256 offset)`
- `UnexpectedOperand()`
- `UnexpectedOperandValue()`
- `OperandOverflow()`

**No events, structs, or constants defined in this file.**

---

### File 2: `src/lib/parse/LibParsePragma.sol`

**Library:** `LibParsePragma` (line 20)

**Functions:**
| Function | Line |
|---|---|
| `parsePragma(ParseState memory, uint256, uint256) returns (uint256)` | 33 |

**File-level constants:**
| Constant | Line |
|---|---|
| `PRAGMA_KEYWORD_BYTES` | 12 |
| `PRAGMA_KEYWORD_BYTES32` | 15 |
| `PRAGMA_KEYWORD_BYTES_LENGTH` | 16 |
| `PRAGMA_KEYWORD_MASK` | 18 |

**Errors referenced (from ErrParse.sol):**
- `NoWhitespaceAfterUsingWordsFrom(uint256 offset)`

**No events or structs defined in this file.**

---

### File 3: `src/lib/parse/LibParseStackName.sol`

**Library:** `LibParseStackName` (line 21)

**Functions:**
| Function | Line |
|---|---|
| `pushStackName(ParseState memory, bytes32) returns (bool, uint256)` | 31 |
| `stackNameIndex(ParseState memory, bytes32) returns (bool, uint256)` | 62 |

**No errors, events, structs, or file-level constants defined in this file.**

Has a `@title` doc block on the library (lines 7-20).

---

## Findings

### A24-1 [INFO] `LibParseOperand.sol` — No `@title` NatSpec on library

**File:** `src/lib/parse/LibParseOperand.sol`, line 21

The `LibParseOperand` library has no `@title` or top-level description NatSpec. Compare with `LibParseStackName` which has a detailed `@title` block. A brief description of the library's purpose would aid navigation and documentation generation.

---

### A24-2 [INFO] `LibParsePragma.sol` — No `@title` NatSpec on library

**File:** `src/lib/parse/LibParsePragma.sol`, line 20

The `LibParsePragma` library has no `@title` or top-level description NatSpec. A brief description of what the pragma system does would improve documentation completeness.

---

### A24-3 [INFO] `LibParsePragma.sol` — File-level constants have no NatSpec

**File:** `src/lib/parse/LibParsePragma.sol`, lines 12-18

The four file-level constants (`PRAGMA_KEYWORD_BYTES`, `PRAGMA_KEYWORD_BYTES32`, `PRAGMA_KEYWORD_BYTES_LENGTH`, `PRAGMA_KEYWORD_MASK`) have no NatSpec documentation. While `PRAGMA_KEYWORD_BYTES` and `PRAGMA_KEYWORD_BYTES_LENGTH` are self-explanatory, `PRAGMA_KEYWORD_MASK` (line 18) involves a bitwise construction that would benefit from a brief `@dev` explanation of why the mask is shaped the way it is (masking out the trailing bytes of a bytes32 to compare only the keyword-length prefix).

---

### A24-4 [LOW] `LibParseOperand.handleOperandSingleFull` — NatSpec description is partially inaccurate

**File:** `src/lib/parse/LibParseOperand.sol`, lines 171-173

The NatSpec says "the provided value MUST fit in two bytes and is used as is." The "used as is" phrasing is inaccurate: the value is not used as-is from the operand values array. It is first unpacked from `Float` representation via `Float.wrap(...).unpack()`, then converted to a fixed-point decimal with `toFixedDecimalLossless`, and only then checked against `type(uint16).max`. The NatSpec should describe the float-to-integer conversion that occurs before the two-byte range check.

---

### A24-5 [LOW] `LibParseOperand.handleOperandSingleFullNoDefault` — NatSpec description is incomplete

**File:** `src/lib/parse/LibParseOperand.sol`, lines 196-198

The NatSpec says "There must be exactly one value. There is no default fallback." This describes the control flow but omits the data transformation. Like `handleOperandSingleFull`, the value undergoes float-to-integer conversion and a `uint16` range check. The NatSpec should document this.

---

### A24-6 [LOW] `LibParseOperand.handleOperandDoublePerByteNoDefault` — NatSpec description is partially inaccurate

**File:** `src/lib/parse/LibParseOperand.sol`, lines 218-219

The NatSpec says "Each value MUST fit in one byte and is used as is." The "used as is" is inaccurate: each value is unpacked from `Float` format and converted to a fixed-decimal integer before the `uint8` range check and bit-packing into `a | (b << 8)`. The NatSpec should describe the float conversion.

---

### A24-7 [LOW] `LibParseOperand.handleOperand8M1M1` — NatSpec incomplete for bit layout

**File:** `src/lib/parse/LibParseOperand.sol`, lines 249-253

The NatSpec says "8 bit value then maybe 1 bit flag then maybe 1 bit flag." This describes the conceptual layout but does not mention the float-to-integer conversion that each value undergoes before encoding. Additionally, it would benefit from documenting the output bit layout explicitly: `bits [7:0] = value a`, `bit [8] = flag b`, `bit [9] = flag c` (as seen on line 294: `aUint | (bUint << 8) | (cUint << 9)`).

---

### A24-8 [LOW] `LibParseOperand.handleOperandM1M1` — NatSpec incomplete for bit layout

**File:** `src/lib/parse/LibParseOperand.sol`, lines 302-304

The NatSpec says "2x maybe 1 bit flags. Fallback to 0 for both flags if not provided." This does not mention the float-to-integer conversion. Also, the output bit layout (`a | (b << 1)`, line 339) is not documented.

---

### A24-9 [INFO] `LibParseOperand.handleOperandDisallowed` — NatSpec could document the revert behavior

**File:** `src/lib/parse/LibParseOperand.sol`, lines 149-152

The NatSpec says "Reverts if any values are provided, otherwise returns a zero operand." This is accurate but does not name the specific error (`UnexpectedOperand`). Naming the error in the NatSpec aids discoverability.

---

### A24-10 [INFO] `LibParseOperand.handleOperandDisallowedAlwaysOne` — NatSpec could document the revert behavior

**File:** `src/lib/parse/LibParseOperand.sol`, lines 160-163

Same as A24-9. The NatSpec does not name the `UnexpectedOperand` error that is thrown.

---

### A24-11 [INFO] `LibParseStackName.pushStackName` — NatSpec `@return index` description could be more precise

**File:** `src/lib/parse/LibParseStackName.sol`, lines 29-30

The `@return index` says "The new index after the word was pushed. Will be unchanged if the word already existed." When the word already exists, `index` is the existing stack index found by `stackNameIndex`. When it does not exist, `index` is set to `stackLHSIndex + 1` (line 49). The description "new index" is slightly ambiguous since it could mean "newly assigned" or "updated value of the counter." The actual semantics are: the 1-based count of LHS items after this push. This could be stated more precisely.

---

### A24-12 [INFO] `LibParseStackName.stackNameIndex` — NatSpec says "Also updates the bloom filter" but does not document this as `@param` side effect

**File:** `src/lib/parse/LibParseStackName.sol`, lines 54-57

The NatSpec accurately states "Also updates the bloom filter so that future lookups for this word will hit." This is a side effect on the `state` parameter. The `@param state` tag says "The parser state containing the stack names" but does not mention that the function mutates the bloom filter within state. While NatSpec does not have a formal "mutates" tag, adding a note to the `@param state` description (e.g., "Modified: updates `stackNameBloom`") would be more precise, especially since this is a `pure` function with memory-only side effects.

---

### A24-13 [INFO] `LibParseOperand.parseOperand` — NatSpec could mention that `state.operandValues` is populated as a side effect

**File:** `src/lib/parse/LibParseOperand.sol`, lines 28-34

The NatSpec documents `@param state`, `@param cursor`, `@param end`, and `@return`. However, the primary purpose of this function is to populate `state.operandValues` (side effect on the state parameter). The NatSpec mentions "extracting literal values ... into the state's operandValues array" in the description but the `@param state` tag just says "The current parse state" without noting the mutation. Consider expanding the `@param state` to note that `operandValues` is modified.

---

## Summary

| Severity | Count |
|---|---|
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 5 |
| INFO | 8 |
| **Total** | **13** |

All three files have NatSpec on every function with `@param` and `@return` tags present. The findings are primarily about accuracy of descriptions (the "used as is" phrasing when float conversion occurs) and completeness (missing library-level `@title`, undocumented constants, side effects not noted in `@param` tags).
