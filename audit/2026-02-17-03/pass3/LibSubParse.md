# Pass 3 (Documentation): LibSubParse.sol

**Agent:** A26
**File:** `src/lib/parse/LibSubParse.sol`

## Evidence of Thorough Reading

### Contract/Library

- `LibSubParse` (library, line 36)

### Functions (with line numbers)

| # | Function | Line |
|---|----------|------|
| 1 | `subParserContext(uint256 column, uint256 row)` | 48 |
| 2 | `subParserConstant(uint256 constantsHeight, bytes32 value)` | 96 |
| 3 | `subParserExtern(IInterpreterExternV4 extern, uint256 constantsHeight, uint256 ioByte, OperandV2 operand, uint256 opcodeIndex)` | 161 |
| 4 | `subParseWordSlice(ParseState memory state, uint256 cursor, uint256 end)` | 215 |
| 5 | `subParseWords(ParseState memory state, bytes memory bytecode)` | 323 |
| 6 | `subParseLiteral(ParseState memory state, uint256 dispatchStart, uint256 dispatchEnd, uint256 bodyStart, uint256 bodyEnd)` | 349 |
| 7 | `consumeSubParseWordInputData(bytes memory data, bytes memory meta, bytes memory operandHandlers)` | 407 |
| 8 | `consumeSubParseLiteralInputData(bytes memory data)` | 438 |

### Errors/Events/Structs Defined in File

None defined in this file. Errors imported from `ErrSubParse.sol` and `ErrParse.sol`:
- `ExternDispatchConstantsHeightOverflow` (from ErrSubParse.sol)
- `ConstantOpcodeConstantsHeightOverflow` (from ErrSubParse.sol)
- `ContextGridOverflow` (from ErrSubParse.sol)
- `BadSubParserResult` (from ErrParse.sol)
- `UnknownWord` (from ErrParse.sol)
- `UnsupportedLiteralType` (from ErrParse.sol)

### Library-level NatSpec

- `@title LibSubParse` present at line 25 with a description spanning lines 26-35.

## Findings

### A26-1 [INFO] `ExternDispatchConstantsHeightOverflow` error description says "single byte" but check is 0xFFFF (2 bytes)

**Location:** `src/error/ErrSubParse.sol`, line 8-10

The `@dev` comment on `ExternDispatchConstantsHeightOverflow` says "constants height is outside the range a single byte can represent" but the actual check in `subParserExtern` (line 171) is `constantsHeight > 0xFFFF`, which is a 16-bit (two-byte) range. The error message is inaccurate.

```solidity
/// @dev Thrown when a subparser is asked to build an extern dispatch when the
/// constants height is outside the range a single byte can represent.
error ExternDispatchConstantsHeightOverflow(uint256 constantsHeight);
```

The check at line 171:
```solidity
if (constantsHeight > 0xFFFF) {
    revert ExternDispatchConstantsHeightOverflow(constantsHeight);
}
```

`0xFFFF` is a two-byte limit, not a single-byte limit.

---

### A26-2 [INFO] `subParseWordSlice` return values are undocumented

**Location:** `src/lib/parse/LibSubParse.sol`, lines 210-215

The NatSpec for `subParseWordSlice` documents `@param` for all three parameters but the function has no return value, so no `@return` is needed. However, the function mutates `state` in place (via `state.pushConstantValue` at line 283) and mutates memory at `cursor` (line 275-278). The NatSpec mentions "attempts to resolve any unknown opcodes" but does not describe that it modifies bytecode in-place and pushes constants to the state's constants builder. This is a side-effect documentation gap.

```solidity
/// Iterates over a slice of bytecode ops and attempts to resolve any
/// unknown opcodes by delegating to the registered sub parsers.
/// @param state The current parse state containing sub parser references.
/// @param cursor The memory pointer to the start of the bytecode slice.
/// @param end The memory pointer to the end of the bytecode slice.
function subParseWordSlice(ParseState memory state, uint256 cursor, uint256 end) internal view {
```

The NatSpec could be improved by explicitly stating that unknown ops are overwritten in-place in the bytecode and that resolved constants are pushed onto `state.constantsBuilder`.

---

No other documentation gaps were found. All eight functions have NatSpec with appropriate `@param` and `@return` tags. The descriptions accurately reflect the implementations. The library-level `@title` and description are thorough and informative.
