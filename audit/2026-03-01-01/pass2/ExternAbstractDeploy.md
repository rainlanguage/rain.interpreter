# Pass 2: Test Coverage — Extern, Abstract, Deploy, AllStandardOps

**Audit:** 2026-03-01-01
**Agent IDs:** A01, A02, A04, A06, A13, A49

## Findings

### P2-EAD-01 (LOW) `BaseRainterpreterSubParser.subParseWord2` missing happy-path and no-match tests (A02)

The test file `BaseRainterpreterSubParser.subParseWord2.t.sol` only tests the `SubParserIndexOutOfBounds` revert paths. There is no base-level test for:

1. **Happy path**: A word is found in meta and the corresponding parser function pointer is called, producing valid output. The happy path is only tested indirectly through `RainterpreterReferenceExtern.intInc.t.sol`. The base abstract contract should have its own isolated happy-path test.

2. **No-match path**: A word is not found in the parse meta, and the function returns `(false, "", new bytes32[](0))`. This path at line 210 is never directly tested at the base level.

### P2-EAD-02 (LOW) `authoringMetaV2` word names not verified beyond index 3 (A04)

The `testAuthoringMetaV2Content` test verifies that words[0..3] are "stack", "constant", "extern", "context" and that all words are non-empty. However, it does not verify the names or ordering of opcodes 4 through 71. A subtle typo in a word name or an ordering swap between two entries would not be caught by any test.

The four parallel arrays (authoring meta, operand handlers, integrity pointers, opcode pointers) must have consistent ordering. Length consistency is tested, but ordering is not.

**Mitigating factor**: The parse meta is built from the authoring meta at build time and baked into constants. Any ordering change changes the parse meta constant, which is validated by the pointer tests.

### P2-EAD-03 (INFO) `extern()` mod-wrap not tested at base level with multiple opcodes (A01)

The `extern()` function uses `mod(opcode, fsCount)` to wrap out-of-range opcodes. This is tested only through `RainterpreterReferenceExtern` which has exactly 1 opcode. No base-level test with multiple opcodes verifies that mod dispatches to the correct function for different opcode values.

### P2-EAD-04 (INFO) Repeat literal boundary digit 0 not tested through full stack (A49)

The repeat literal happy-path tests exercise digits 8 and 9. Digit 0 (lower boundary) is not tested through the full parse-and-eval stack, though it is covered at the library level by `LibParseLiteralRepeat.t.sol` fuzz tests.
