# A02 — Pass 1 (Security) — BaseRainterpreterSubParser.sol

**File:** `src/abstract/BaseRainterpreterSubParser.sol` (221 lines)

## Evidence inventory

### Contract

- `BaseRainterpreterSubParser` (abstract, line 78) — inherits `ERC165`, `ISubParserV4`, `IDescribedByMetaV1`, `IParserToolingV1`, `ISubParserToolingV1`

### File-level constants

| Name | Line | Description |
|------|------|-------------|
| `SUB_PARSER_WORD_PARSERS` | 26 | Placeholder 2-byte packed function pointer table for word parsers |
| `SUB_PARSER_PARSE_META` | 32 | Placeholder bloom/fingerprint meta for word lookup |
| `SUB_PARSER_OPERAND_HANDLERS` | 36 | Placeholder 2-byte packed operand handler pointers |
| `SUB_PARSER_LITERAL_PARSERS` | 40 | Placeholder 2-byte packed literal parser pointers |

### Functions

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `subParserParseMeta` | 93 | internal virtual | pure |
| `subParserWordParsers` | 100 | internal virtual | pure |
| `subParserOperandHandlers` | 107 | internal virtual | pure |
| `subParserLiteralParsers` | 114 | internal virtual | pure |
| `matchSubParseLiteralDispatch` | 139 | internal virtual | view |
| `subParseLiteral2` | 159 | external virtual | view |
| `subParseWord2` | 188 | external virtual | pure |
| `supportsInterface` | 215 | public virtual override | view |

### Custom errors (imported)

| Error | Source |
|-------|--------|
| `SubParserIndexOutOfBounds(uint256, uint256)` | `ErrSubParse.sol` |

### Using-for directives

- `LibBytes for bytes` (line 85)
- `LibParse for ParseState` (line 86)
- `LibParseMeta for ParseState` (line 87)
- `LibParseOperand for ParseState` (line 88)

## Security review

### Assembly blocks

**subParseLiteral2 (line 171-173):** Loads a 2-byte function pointer from a packed bytes array. Pattern: `and(mload(add(localSubParserLiteralParsers, mul(add(index, 1), 2))), 0xFFFF)`. Bounds check at line 168 ensures `index < parsersLength` where `parsersLength = length / 2`. Maximum read offset is within the bytes array data region. The `0xFFFF` mask correctly isolates the target 2-byte pointer. Marked `memory-safe` — the `mload` window extends up to 30 bytes past the target data, but all excess bytes are masked away. Standard pattern, consistent with `LibParseOperand.sol:147` and `LibParseLiteral.sol:53`.

**subParseWord2 (line 205-206):** Identical pattern to the literal variant above, reading from the word parser function pointer table. Same bounds check structure (line 202). Same analysis applies.

### Bounds checking

Both `subParseLiteral2` and `subParseWord2` perform explicit bounds checks (`index >= parsersLength`) before the assembly function pointer load, reverting with `SubParserIndexOutOfBounds`. This prevents out-of-bounds dispatch into arbitrary memory.

### Sub-parser dispatch

`subParseWord2` delegates to `LibSubParse.consumeSubParseWordInputData` for header extraction, then to `LibParse.parseWord` and `LibParseMeta.lookupWord` for word resolution. If the word does not exist in the meta, it returns `(false, "", new bytes32[](0))` — correct fallback behavior.

`subParseLiteral2` delegates to `LibSubParse.consumeSubParseLiteralInputData` for pointer extraction, then to `matchSubParseLiteralDispatch` (which defaults to returning `false`). If dispatch does not match, returns `(false, 0)` — correct fallback behavior.

### Operand parsing

`subParseWord2` calls `state.handleOperand(index)` at line 198 before the bounds check against `subParserWordParsers` at line 202. The `handleOperand` function in `LibParseOperand.sol:139` uses the same `index` to look up the operand handler from `state.operandHandlers`, which was constructed from `subParserOperandHandlers()`. If the operand handlers table and the word parsers table have different lengths, `handleOperand` could read from an out-of-bounds index before the word parser bounds check fires. However, `handleOperand` deliberately does not bounds-check because it trusts that the index came from the parser's own meta lookup. The risk is limited to a misconfigured child contract providing mismatched table sizes.

### Access control

Both `subParseLiteral2` and `subParseWord2` are `external` and callable by anyone. This is by design — sub-parsers are meant to be called by the main parser contract, and access control is unnecessary for pure/view parse-time functions that produce no state changes.

### ERC165

`supportsInterface` correctly enumerates `ISubParserV4`, `IDescribedByMetaV1`, `IParserToolingV1`, `ISubParserToolingV1`, and delegates to `super.supportsInterface` for `IERC165`.

## Findings

No CRITICAL, HIGH, MEDIUM, or LOW findings.

## INFO

- **A02-INFO-01:** No validation that function pointer table byte lengths are even. If a child contract returns an odd-length `bytes` from `subParserWordParsers()` or `subParserLiteralParsers()`, the trailing byte is silently ignored by integer division (`length / 2`). Not exploitable — the truncated byte cannot be reached through the dispatch path. Same pattern as noted in `BaseRainterpreterExtern` (A01-INFO-02).

- **A02-INFO-02:** The contract-level NatSpec on `BaseRainterpreterSubParser` (lines 42-77) uses no explicit tags, relying on the entire block being treated as an implicit `@notice`. While valid, this is a very long untagged doc block. The virtual function NatSpec for `subParserParseMeta`, `subParserWordParsers`, `subParserOperandHandlers`, and `subParserLiteralParsers` (lines 90-116) similarly use untagged comments which is correct since no tags are present in those blocks.

- **A02-INFO-03:** Typo in `SUB_PARSER_PARSE_META` NatSpec (line 30): "fingeprinting" should be "fingerprinting".
