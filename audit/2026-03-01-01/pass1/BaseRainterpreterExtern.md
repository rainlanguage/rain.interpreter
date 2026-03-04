# Pass 1 (Security) -- BaseRainterpreterExtern.sol & BaseRainterpreterSubParser.sol

**Auditor**: A01 / A02
**Date**: 2026-03-01
**Files**:
- `src/abstract/BaseRainterpreterExtern.sol` (131 lines)
- `src/abstract/BaseRainterpreterSubParser.sol` (220 lines)

## Evidence of Thorough Reading

### BaseRainterpreterExtern.sol

**Contract**: `BaseRainterpreterExtern` (line 29), abstract, inherits `IInterpreterExternV4`, `IIntegrityToolingV1`, `IOpcodeToolingV1`, `ERC165`

#### Imports

| Import | Source | Line |
|---|---|---|
| `ERC165` | `openzeppelin-contracts/contracts/utils/introspection/ERC165.sol` | 5 |
| `OperandV2` | `rain.interpreter.interface/interface/IInterpreterV4.sol` | 7 |
| `IInterpreterExternV4`, `ExternDispatchV2`, `StackItem` | `rain.interpreter.interface/interface/IInterpreterExternV4.sol` | 8-12 |
| `IIntegrityToolingV1` | `rain.sol.codegen/interface/IIntegrityToolingV1.sol` | 13 |
| `IOpcodeToolingV1` | `rain.sol.codegen/interface/IOpcodeToolingV1.sol` | 14 |
| `ExternOpcodeOutOfRange`, `ExternPointersMismatch`, `ExternOpcodePointersEmpty` | `../error/ErrExtern.sol` | 15 |

#### File-level Constants

| Constant | Type | Value | Line |
|---|---|---|---|
| `OPCODE_FUNCTION_POINTERS` | `bytes` | `hex""` | 20 |
| `INTEGRITY_FUNCTION_POINTERS` | `bytes` | `hex""` | 24 |

#### Functions

| Function | Signature | Visibility | Modifiers | Line |
|---|---|---|---|---|
| `constructor` | `()` | -- | -- | 34 |
| `extern` | `(ExternDispatchV2, StackItem[] memory) -> (StackItem[] memory)` | external view virtual override | -- | 46 |
| `externIntegrity` | `(ExternDispatchV2, uint256, uint256) -> (uint256, uint256)` | external pure virtual override | -- | 83 |
| `supportsInterface` | `(bytes4) -> (bool)` | public view virtual override | -- | 112 |
| `opcodeFunctionPointers` | `() -> (bytes memory)` | internal view virtual | -- | 121 |
| `integrityFunctionPointers` | `() -> (bytes memory)` | internal pure virtual | -- | 128 |

#### Errors (imported)

| Error | Parameters | Source |
|---|---|---|
| `ExternOpcodeOutOfRange` | `uint256 opcode, uint256 fsCount` | `src/error/ErrExtern.sol` |
| `ExternPointersMismatch` | `uint256 opcodeCount, uint256 integrityCount` | `src/error/ErrExtern.sol` |
| `ExternOpcodePointersEmpty` | -- | `src/error/ErrExtern.sol` |

---

### BaseRainterpreterSubParser.sol

**Contract**: `BaseRainterpreterSubParser` (line 78), abstract, inherits `ERC165`, `ISubParserV4`, `IDescribedByMetaV1`, `IParserToolingV1`, `ISubParserToolingV1`

#### Imports

| Import | Source | Line |
|---|---|---|
| `ERC165` | `openzeppelin-contracts/contracts/utils/introspection/ERC165.sol` | 5 |
| `LibBytes`, `Pointer` | `rain.solmem/lib/LibBytes.sol` | 6 |
| `ISubParserV4`, `AuthoringMetaV2` | `rain.interpreter.interface/interface/ISubParserV4.sol` | 10 |
| `LibSubParse`, `ParseState` | `../lib/parse/LibSubParse.sol` | 11 |
| `CMASK_RHS_WORD_TAIL` | `rain.string/lib/parse/LibParseCMask.sol` | 12 |
| `LibParse`, `OperandV2` | `../lib/parse/LibParse.sol` | 13 |
| `LibParseMeta` | `rain.interpreter.interface/lib/parse/LibParseMeta.sol` | 14 |
| `LibParseOperand` | `../lib/parse/LibParseOperand.sol` | 15 |
| `IDescribedByMetaV1` | `rain.metadata/interface/IDescribedByMetaV1.sol` | 16 |
| `IParserToolingV1` | `rain.sol.codegen/interface/IParserToolingV1.sol` | 17 |
| `ISubParserToolingV1` | `rain.sol.codegen/interface/ISubParserToolingV1.sol` | 18 |
| `SubParserIndexOutOfBounds` | `../error/ErrSubParse.sol` | 19 |

#### Using Directives

| Using | For | Line |
|---|---|---|
| `LibBytes` | `bytes` | 85 |
| `LibParse` | `ParseState` | 86 |
| `LibParseMeta` | `ParseState` | 87 |
| `LibParseOperand` | `ParseState` | 88 |

#### File-level Constants

| Constant | Type | Value | Line |
|---|---|---|---|
| `SUB_PARSER_WORD_PARSERS` | `bytes` | `hex""` | 26 |
| `SUB_PARSER_PARSE_META` | `bytes` | `hex""` | 32 |
| `SUB_PARSER_OPERAND_HANDLERS` | `bytes` | `hex""` | 36 |
| `SUB_PARSER_LITERAL_PARSERS` | `bytes` | `hex""` | 40 |

#### Functions

| Function | Signature | Visibility | Modifiers | Line |
|---|---|---|---|---|
| `subParserParseMeta` | `() -> (bytes memory)` | internal pure virtual | -- | 93 |
| `subParserWordParsers` | `() -> (bytes memory)` | internal pure virtual | -- | 100 |
| `subParserOperandHandlers` | `() -> (bytes memory)` | internal pure virtual | -- | 107 |
| `subParserLiteralParsers` | `() -> (bytes memory)` | internal pure virtual | -- | 114 |
| `matchSubParseLiteralDispatch` | `(uint256, uint256) -> (bool, uint256, bytes32)` | internal view virtual | -- | 139 |
| `subParseLiteral2` | `(bytes memory) -> (bool, bytes32)` | external view virtual | -- | 159 |
| `subParseWord2` | `(bytes memory) -> (bool, bytes memory, bytes32[] memory)` | external pure virtual | -- | 188 |
| `supportsInterface` | `(bytes4) -> (bool)` | public view virtual override | -- | 215 |

#### Errors (imported)

| Error | Parameters | Source |
|---|---|---|
| `SubParserIndexOutOfBounds` | `uint256 index, uint256 length` | `src/error/ErrSubParse.sol` |

---

## Security Analysis

### A01: Extern Dispatch Safety

#### Mod-wrapping in `extern()` (line 76)

The `extern()` function uses `mod(opcode, fsCount)` to bound the opcode index before using it to load a function pointer. This is deliberate and well-documented in the code comments (lines 55-65): it mirrors how the main eval loop handles opcode dispatch, and is cheaper than a bounds check. The integrity check (`externIntegrity`) separately enforces that opcodes are in range at parse time, reverting with `ExternOpcodeOutOfRange` (line 98-100).

The tradeoff is that a direct external call to `extern()` with an out-of-range opcode silently wraps to a different valid opcode rather than reverting. The comments correctly document this design choice and its rationale.

**Conclusion**: The mod-wrapping is intentional and correctly implemented. The integrity check provides the parse-time safety net. No finding.

#### Bounds check in `externIntegrity()` (lines 98-100)

The integrity function uses an explicit `if (opcode >= fsCount) revert` check rather than mod-wrapping. This is correct for the integrity path, which runs at parse time and should reject invalid opcodes rather than silently wrapping them.

**Conclusion**: Correct design. No finding.

### A01: Constructor Validation

The constructor (lines 34-43) enforces:
1. `opcodeFunctionPointers().length != 0` -- prevents zero-length table
2. `opcodeFunctionPointers().length == integrityFunctionPointers().length` -- ensures 1:1 correspondence

Both checks use raw byte lengths. See finding A01-1 for an edge case.

### A01: Assembly Memory Safety

#### `extern()` assembly blocks (lines 68-70, 75-77)

Block 1 computes `fPointersStart` by adding 0x20 to skip the bytes length prefix. No allocation, no writes. Safe.

Block 2 reads a function pointer from the computed offset within the `fPointers` array. The `mod(opcode, fsCount)` ensures the index is within `[0, fsCount)`, so the read starts within the array bounds. The `mload` reads 32 bytes, extending past the array boundary for small tables, but `shr(0xf0, ...)` isolates only the first 2 bytes (the actual function pointer). No memory corruption.

**Conclusion**: Both blocks are correctly marked `memory-safe`.

#### `externIntegrity()` assembly blocks (lines 94-96, 104-106)

Same pattern as `extern()`. The explicit bounds check at line 98-100 ensures `opcode < fsCount` before the assembly access, so the read is within the array.

**Conclusion**: Correctly marked `memory-safe`.

### A02: Sub Parser Bounds Checking

#### `subParseLiteral2()` (lines 159-178)

After `matchSubParseLiteralDispatch` returns `(true, index, ...)`, the code checks `index >= parsersLength` at line 168-170 and reverts with `SubParserIndexOutOfBounds`. Only then does the assembly block at lines 171-173 load the function pointer.

**Conclusion**: Bounds checking is correct and precedes the unsafe memory access.

#### `subParseWord2()` (lines 188-212)

After `lookupWord` returns `(true, index)`, the code checks `index >= parsersLength` at lines 202-204. Only then does the assembly block at lines 205-207 load the function pointer.

**Conclusion**: Bounds checking is correct and precedes the unsafe memory access.

### A02: Assembly Memory Safety

#### `subParseLiteral2()` assembly (lines 171-173)

```solidity
assembly ("memory-safe") {
    subParser := and(mload(add(localSubParserLiteralParsers, mul(add(index, 1), 2))), 0xFFFF)
}
```

The offset `(index + 1) * 2` from the base of the bytes array implicitly skips the 32-byte length prefix and then indexes to the correct 2-byte pointer. With the bounds check `index < parsersLength`, the maximum offset is `parsersLength * 2 = localSubParserLiteralParsers.length`, which is within the array. The `mload` reads 32 bytes, but `and(..., 0xFFFF)` masks to the lowest 16 bits, which contain exactly the target function pointer. Bytes read beyond the array are discarded.

**Conclusion**: Correctly marked `memory-safe`.

#### `subParseWord2()` assembly (lines 205-207)

Identical pattern to `subParseLiteral2()`. Same analysis applies.

**Conclusion**: Correctly marked `memory-safe`.

### A01/A02: ERC165 Support

Both contracts correctly override `supportsInterface` and chain to `super.supportsInterface(interfaceId)`. The reference extern (`RainterpreterReferenceExtern`) correctly resolves the diamond inheritance ambiguity by overriding both with a single `super.supportsInterface()` call that traverses the C3 linearization.

**Conclusion**: No finding.

---

## Findings

### A01-1 -- LOW: Constructor allows odd-length function pointer tables

**Location**: `BaseRainterpreterExtern.sol`, lines 34-43

**Description**: The constructor validates that `opcodeFunctionPointers().length` is non-zero and equals `integrityFunctionPointers().length`. However, it does not validate that these lengths are even. Since each function pointer is 2 bytes, an odd byte length means the last byte is orphaned and `fsCount` (computed as `length / 2` using integer division) is one less than expected.

Critically, a 1-byte pointer table (e.g., `hex"00"`) passes the non-zero check but produces `fsCount = 0`. At runtime, `mod(opcode, 0)` in `extern()` causes an EVM panic (division by zero), and `externIntegrity()` always reverts with `ExternOpcodeOutOfRange` (since any opcode >= 0). The contract becomes permanently non-functional despite successful deployment.

While this requires a misconfiguration by the inheriting contract, the constructor's purpose is to catch exactly such misconfigurations. Adding an even-length check would make the validation complete.

**Severity**: LOW -- requires inheritor misconfiguration; the contract is non-functional rather than exploitable.

### A02-1 -- INFO: No constructor validation in BaseRainterpreterSubParser

**Location**: `BaseRainterpreterSubParser.sol`, entire contract

**Description**: Unlike `BaseRainterpreterExtern` which validates pointer table consistency at construction time, `BaseRainterpreterSubParser` performs no constructor validation. The bounds checks in `subParseLiteral2` and `subParseWord2` provide runtime safety, but misconfigurations (e.g., a word parsers table shorter than the parse meta index space) are only caught when specific words are looked up. A constructor could validate that `subParserWordParsers().length / 2` is consistent with the parse meta, and that `subParserLiteralParsers()` is non-empty if `matchSubParseLiteralDispatch` can return `true`.

However, the sub parser design is inherently more flexible than the extern: the parse meta is a bloom filter that may map to indices handled by different code paths, and the `matchSubParseLiteralDispatch` is a virtual function whose behavior cannot be predicted at construction time. The runtime bounds checks are the correct safety net for this architecture.

**Severity**: INFO -- architectural observation, runtime checks are appropriate here.

### A01-2 -- INFO: Inconsistent assembly idioms for function pointer extraction

**Location**: `BaseRainterpreterExtern.sol` lines 75-77; `BaseRainterpreterSubParser.sol` lines 171-173, 205-207

**Description**: Two different assembly idioms extract 16-bit function pointers from packed `bytes` arrays:

- **Extern**: `shr(0xf0, mload(add(fPointersStart, mul(opcode, 2))))` -- pre-computes base past the length prefix, then right-shifts to isolate the top 16 bits of the loaded word.
- **SubParser**: `and(mload(add(base, mul(add(index, 1), 2))), 0xFFFF)` -- offsets from the array base using `(index + 1) * 2` to implicitly skip the length prefix, then masks the bottom 16 bits.

Both are correct. The difference arises from whether the 0x20 skip is factored into the base address or the index calculation. This is a stylistic inconsistency, not a bug.

**Severity**: INFO

### A01-3 -- INFO: `extern()` mod-wrapping is by design

**Location**: `BaseRainterpreterExtern.sol`, lines 53-79

**Description**: A direct external call to `extern()` with an out-of-range opcode silently wraps via `mod(opcode, fsCount)` to a different valid opcode. This is by design: the code comments (lines 55-65) explain the rationale (cheaper than bounds check, mirrors main eval loop, integrity check provides parse-time safety). Without the mod, out-of-range opcodes would read arbitrary memory and jump to arbitrary code, which is worse.

The security model relies on the integrity check running during parsing. Any path that invokes `extern()` without a prior integrity check (e.g., hand-crafted bytecode or direct external calls) will get mod-wrapped behavior rather than a revert.

**Severity**: INFO -- documented design decision with correct rationale.

---

## Summary

No CRITICAL, HIGH, or MEDIUM findings. One LOW finding (A01-1) identifies a missing even-length validation in the extern constructor that could cause a deployment to be permanently non-functional. Three INFO findings document architectural observations and design decisions. Both contracts use assembly correctly, with proper `memory-safe` annotations. Bounds checking is consistently applied before unsafe memory access. The extern's mod-wrapping dispatch and the sub parser's explicit bounds checks are both appropriate for their respective threat models.
