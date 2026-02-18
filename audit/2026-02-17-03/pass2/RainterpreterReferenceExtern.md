# A49 — RainterpreterReferenceExtern Test Coverage

## Evidence of Thorough Reading

### Source File: `src/concrete/extern/RainterpreterReferenceExtern.sol`

**Contract/Library names:**
- `LibRainterpreterReferenceExtern` (library, line 84)
- `RainterpreterReferenceExtern` (contract, line 157) — inherits `BaseRainterpreterSubParser`, `BaseRainterpreterExtern`

**Functions:**
- `LibRainterpreterReferenceExtern.authoringMetaV2()` — line 93 (internal pure)
- `describedByMetaV1()` — line 161 (external pure override)
- `subParserParseMeta()` — line 168 (internal pure virtual override)
- `subParserWordParsers()` — line 175 (internal pure override)
- `subParserOperandHandlers()` — line 182 (internal pure override)
- `subParserLiteralParsers()` — line 189 (internal pure override)
- `opcodeFunctionPointers()` — line 196 (internal pure override)
- `integrityFunctionPointers()` — line 203 (internal pure override)
- `buildLiteralParserFunctionPointers()` — line 209 (external pure)
- `matchSubParseLiteralDispatch(uint256, uint256)` — line 231 (internal pure virtual override)
- `buildOperandHandlerFunctionPointers()` — line 274 (external pure override)
- `buildSubParserWordParsers()` — line 317 (external pure)
- `buildOpcodeFunctionPointers()` — line 357 (external pure)
- `buildIntegrityFunctionPointers()` — line 389 (external pure)
- `supportsInterface(bytes4)` — line 417 (public view virtual override)

**Errors defined in this file:**
- `InvalidRepeatCount()` — line 74

**Errors imported/used:**
- `BadDynamicLength(uint256, uint256)` from `ErrOpList.sol` (used in `buildLiteralParserFunctionPointers`, `buildOperandHandlerFunctionPointers`, `buildSubParserWordParsers`, `buildOpcodeFunctionPointers`, `buildIntegrityFunctionPointers`)

**Constants:**
- `SUB_PARSER_WORD_PARSERS_LENGTH` = 5 (line 46)
- `SUB_PARSER_LITERAL_PARSERS_LENGTH` = 1 (line 49)
- `SUB_PARSER_LITERAL_REPEAT_KEYWORD` (line 53)
- `SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES32` (line 58)
- `SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH` = 18 (line 61)
- `SUB_PARSER_LITERAL_REPEAT_KEYWORD_MASK` (line 65)
- `SUB_PARSER_LITERAL_REPEAT_INDEX` = 0 (line 71)
- `OPCODE_FUNCTION_POINTERS_LENGTH` = 1 (line 77)

### Inherited from `BaseRainterpreterExtern` (`src/abstract/BaseRainterpreterExtern.sol`):
- `constructor()` — line 43 (validates opcode/integrity pointer lengths)
- `extern(ExternDispatchV2, StackItem[])` — line 55 (external view)
- `externIntegrity(ExternDispatchV2, uint256, uint256)` — line 92 (external pure)
- `supportsInterface(bytes4)` — line 121 (public view virtual override)
- `opcodeFunctionPointers()` — line 130 (internal view virtual, overridden)
- `integrityFunctionPointers()` — line 137 (internal pure virtual, overridden)

**Errors from BaseRainterpreterExtern:**
- `ExternOpcodeOutOfRange(uint256, uint256)` — in `externIntegrity`
- `ExternPointersMismatch(uint256, uint256)` — in constructor
- `ExternOpcodePointersEmpty()` — in constructor

### Inherited from `BaseRainterpreterSubParser` (`src/abstract/BaseRainterpreterSubParser.sol`):
- `subParseLiteral2(bytes)` — line 164 (external view virtual)
- `subParseWord2(bytes)` — line 193 (external pure virtual)
- `supportsInterface(bytes4)` — line 220 (public view virtual override)

**Errors from BaseRainterpreterSubParser:**
- `SubParserIndexOutOfBounds(uint256, uint256)` — in `subParseLiteral2` and `subParseWord2`

### Test Files Read:

1. `RainterpreterReferenceExtern.contextCallingContract.t.sol` — 1 test: `testRainterpreterReferenceExternContextContractHappy`
2. `RainterpreterReferenceExtern.contextRainlen.t.sol` — 1 test: `testRainterpreterReferenceExternContextRainlenHappy`
3. `RainterpreterReferenceExtern.contextSender.t.sol` — 1 test: `testRainterpreterReferenceExternContextSenderHappy`
4. `RainterpreterReferenceExtern.describedByMetaV1.t.sol` — 1 test: `testRainterpreterReferenceExternDescribedByMetaV1Happy`
5. `RainterpreterReferenceExtern.ierc165.t.sol` — 1 fuzz test: `testRainterpreterReferenceExternIERC165`
6. `RainterpreterReferenceExtern.intInc.t.sol` — 5 tests: unsugared happy, sugared happy, subparse known word, subparse unknown word, run direct, integrity direct
7. `RainterpreterReferenceExtern.pointers.t.sol` — 6 tests: opcode pointers, integrity pointers, sub parser parse meta, literal parsers, sub parser function pointers, operand parsers
8. `RainterpreterReferenceExtern.repeat.t.sol` — 4 tests: happy, negative, non-integer, too-large
9. `RainterpreterReferenceExtern.stackOperand.t.sol` — 1 fuzz test: `testRainterpreterReferenceExternStackOperandSingle`
10. `RainterpreterReferenceExtern.unknownWord.t.sol` — 1 test: `testRainterpreterReferenceExternUnknownWord`

---

## Findings

### A49-1 [LOW] — `InvalidRepeatCount` error not directly asserted in revert tests

The `repeat.t.sol` test file tests three unhappy paths (negative, non-integer, repeat > 9) that should trigger `InvalidRepeatCount`. However, all three tests use a generic `vm.expectRevert()` without specifying the expected selector:

```solidity
vm.expectRevert();
bytes memory bytecode = I_DEPLOYER.parse2(bytes(string.concat(baseStr, "_: [ref-extern-repeat--1 abc];")));
```

This means the tests would pass even if the revert came from a different error (e.g., a parsing error upstream). The test should assert `vm.expectRevert(abi.encodeWithSelector(InvalidRepeatCount.selector))` to confirm the correct code path is exercised. Note: the `InvalidRepeatCount` import is present in the test file but never used in an assertion.

### A49-2 [LOW] — `BadDynamicLength` error path never tested

The `BadDynamicLength` revert appears in five `build*` functions as a sanity check ("should be an unreachable error"). No test anywhere in the suite triggers this revert path. Grep for `BadDynamicLength` across `test/` returns zero results. While it is described as unreachable, documenting this coverage gap is appropriate since the error exists in deployed code.

### A49-3 [LOW] — `SubParserIndexOutOfBounds` error path never tested for `RainterpreterReferenceExtern`

The `SubParserIndexOutOfBounds` error in `BaseRainterpreterSubParser.subParseWord2` (line 208) and `subParseLiteral2` (line 173) has no test that exercises it through the `RainterpreterReferenceExtern` contract. Grep for `SubParserIndexOutOfBounds` in `test/` returns zero results. This is a bounds-check error path in inherited code that has no direct test coverage.

### A49-4 [LOW] — No test for `extern()` function called directly on `RainterpreterReferenceExtern`

The `extern(ExternDispatchV2, StackItem[])` function inherited from `BaseRainterpreterExtern` is tested indirectly via the full eval pipeline (the `intInc` unsugared test deploys an expression that uses `extern<0>(2 3)`). However, there is no test that calls `extern()` directly on a `RainterpreterReferenceExtern` instance. Direct testing would cover:
- The opcode mod wrapping behavior (out-of-range opcode dispatched to `extern()`)
- Zero-length inputs
- Large input arrays

Note: `BaseRainterpreterExtern` has its own test file for `ExternOpcodeOutOfRange` in `externIntegrity`, but the runtime `extern()` function uses a mod (not a revert) for out-of-range opcodes, and this mod behavior has no dedicated test.

### A49-5 [LOW] — No test for `externIntegrity()` called directly on `RainterpreterReferenceExtern`

Similar to A49-4, `externIntegrity()` is tested at the `BaseRainterpreterExtern` level (`test/src/abstract/BaseRainterpreterExtern.integrityOpcodeRange.t.sol`), but not directly on a `RainterpreterReferenceExtern` instance. This means the specific integrity function pointer table of the reference extern is only validated indirectly.

### A49-6 [INFO] — No test for `matchSubParseLiteralDispatch` with exact-length-equal-to-keyword input

The `matchSubParseLiteralDispatch` function (line 231) requires `length > SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH` (strictly greater than). There is no test that verifies the boundary case where `length == SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH` returns `(false, 0, 0)`. The existing `repeat` tests only exercise the happy path and error paths that pass the length check.

### A49-7 [INFO] — No test for repeat literal with digit 0

The `repeat.t.sol` happy path tests digits 8 and 9. The boundary digit 0 (`ref-extern-repeat-0`) is never tested. While the code should handle it correctly (0 repeated produces value 0), explicit boundary testing would strengthen coverage.

### A49-8 [INFO] — `authoringMetaV2()` only tested indirectly through parse meta construction

`LibRainterpreterReferenceExtern.authoringMetaV2()` is called in `RainterpreterReferenceExtern.pointers.t.sol` to build parse meta, but there is no test that directly validates the returned struct array contents (word names, descriptions). The existing test only checks that the parse meta built from the authoring meta matches the expected constant.
