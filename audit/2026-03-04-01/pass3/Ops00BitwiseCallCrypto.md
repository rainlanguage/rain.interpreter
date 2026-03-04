# Pass 3 -- Ops: 00, Bitwise, Call, Crypto

Audit of NatSpec documentation for files A30-A43.

## Evidence

### A30: `src/lib/op/00/LibOpConstant.sol`
- **Library**: `LibOpConstant` (L15), `@title` (L11), `@notice` (L12)
- **Functions**: `integrity` (L21), `run` (L37), `referenceFn` (L52)
- **Errors imported**: `OutOfBoundsConstantRead`
- All functions have `@notice`, `@param` for each named parameter, `@return` for each return value.
- NatSpec is accurate against implementation.
- **No findings.**

### A31: `src/lib/op/00/LibOpContext.sol`
- **Library**: `LibOpContext` (L12), `@title` (L10), `@notice` (L11)
- **Functions**: `integrity` (L16), `run` (L28), `referenceFn` (L47)
- All functions have `@notice`, appropriate `@param`/`@return` tags.
- Unnamed parameters in `integrity` correctly omit `@param`.
- NatSpec is accurate against implementation.
- **No findings.**

### A32: `src/lib/op/00/LibOpExtern.sol`
- **Library**: `LibOpExtern` (L23), `@title` (L21), `@notice` (L22)
- **Functions**: `integrity` (L29), `run` (L49), `referenceFn` (L102)
- **Errors imported**: `NotAnExternContract`, `BadOutputsLength`
- All functions have `@notice`, `@param`, `@return`.
- NatSpec is accurate against implementation.
- **No findings.**

### A33: `src/lib/op/00/LibOpStack.sol`
- **Library**: `LibOpStack` (L15), `@title` (L11), `@notice` (L12)
- **Functions**: `integrity` (L21), `run` (L41), `referenceFn` (L58)
- **Errors imported**: `OutOfBoundsStackRead`
- All functions have `@notice`, `@param`, `@return`.
- NatSpec is accurate against implementation.
- **No findings.**

### A34: `src/lib/op/LibAllStandardOps.sol`
- **Library**: `LibAllStandardOps` (L110), `@title` (L107), `@notice` (L108)
- **Constant**: `ALL_STANDARD_OPS_LENGTH` (L105) -- has `@dev` tag.
- **Functions**: `authoringMetaV2` (L120), `literalParserFunctionPointers` (L344), `operandHandlerFunctionPointers` (L377), `integrityFunctionPointers` (L549), `opcodeFunctionPointers` (L653)
- See findings A34-P3-1 and A34-P3-2 below.

### A35: `src/lib/op/bitwise/LibOpBitwiseAnd.sol`
- **Library**: `LibOpBitwiseAnd` (L12), `@title` (L10), `@notice` (L11)
- **Functions**: `integrity` (L16), `run` (L24), `referenceFn` (L36)
- All functions have `@notice`, `@param`, `@return`.
- NatSpec is accurate against implementation.
- **No findings.**

### A36: `src/lib/op/bitwise/LibOpBitwiseCountOnes.sol`
- **Library**: `LibOpBitwiseCountOnes` (L15), `@title` (L11), `@notice` (L12)
- **Functions**: `integrity` (L19), `run` (L27), `referenceFn` (L44)
- All functions have `@notice`, `@param`, `@return`.
- NatSpec is accurate against implementation.
- **No findings.**

### A37: `src/lib/op/bitwise/LibOpBitwiseDecode.sol`
- **Library**: `LibOpBitwiseDecode` (L14), `@title` (L11), `@notice` (L12)
- **Functions**: `integrity` (L20), `run` (L33), `referenceFn` (L65)
- All functions have `@notice`, `@param`, `@return`.
- NatSpec is accurate against implementation.
- **No findings.**

### A38: `src/lib/op/bitwise/LibOpBitwiseEncode.sol`
- **Library**: `LibOpBitwiseEncode` (L13), `@title` (L11), `@notice` (L12)
- **Functions**: `integrity` (L19), `run` (L36), `referenceFn` (L76)
- **Errors imported**: `ZeroLengthBitwiseEncoding`, `TruncatedBitwiseEncoding`
- All functions have `@notice`, `@param`, `@return`.
- NatSpec is accurate against implementation.
- **No findings.**

### A39: `src/lib/op/bitwise/LibOpBitwiseOr.sol`
- **Library**: `LibOpBitwiseOr` (L12), `@title` (L10), `@notice` (L11)
- **Functions**: `integrity` (L16), `run` (L24), `referenceFn` (L36)
- All functions have `@notice`, `@param`, `@return`.
- NatSpec is accurate against implementation.
- **No findings.**

### A40: `src/lib/op/bitwise/LibOpBitwiseShiftLeft.sol`
- **Library**: `LibOpBitwiseShiftLeft` (L14), `@title` (L11), `@notice` (L12)
- **Functions**: `integrity` (L19), `run` (L38), `referenceFn` (L49)
- **Errors imported**: `UnsupportedBitwiseShiftAmount`
- All functions have `@notice`, `@param`, `@return`.
- NatSpec is accurate against implementation.
- **No findings.**

### A41: `src/lib/op/bitwise/LibOpBitwiseShiftRight.sol`
- **Library**: `LibOpBitwiseShiftRight` (L14), `@title` (L11), `@notice` (L12)
- **Functions**: `integrity` (L19), `run` (L38), `referenceFn` (L49)
- **Errors imported**: `UnsupportedBitwiseShiftAmount`
- All functions have `@notice`, `@param`, `@return`.
- NatSpec is accurate against implementation.
- **No findings.**

### A42: `src/lib/op/call/LibOpCall.sol`
- **Library**: `LibOpCall` (L69), `@title` (L13), `@notice` (L14)
- **Functions**: `integrity` (L85), `run` (L122)
- **Errors imported**: `CallOutputsExceedSource`
- No `referenceFn` (call is not testable via standard reference pattern).
- See finding A42-P3-1 below.

### A43: `src/lib/op/crypto/LibOpHash.sol`
- **Library**: `LibOpHash` (L12), `@title` (L10), `@notice` (L11)
- **Functions**: `integrity` (L17), `run` (L28), `referenceFn` (L41)
- All functions have `@notice`, `@param`, `@return`.
- NatSpec is accurate against implementation.
- **No findings.**

---

## Findings

### A34-P3-1 (LOW): LibAllStandardOps functions missing `@notice` tag

All five functions in `LibAllStandardOps` use untagged `///` doc comments instead of explicit `@notice`. While the library-level doc block uses explicit tags (`@title`, `@notice`), the function-level doc blocks do not use any tags at all. Per NatSpec rules, untagged lines without any explicit tags are implicitly `@notice`, so there is no tag-mixing violation here. However, for consistency with every other library in this audit scope (which all use explicit `@notice` on functions), these should use explicit `@notice`.

**Affected functions (all in `src/lib/op/LibAllStandardOps.sol`):**
- `authoringMetaV2` (L111)
- `literalParserFunctionPointers` (L341)
- `operandHandlerFunctionPointers` (L373)
- `integrityFunctionPointers` (L545)
- `opcodeFunctionPointers` (L650)

### A34-P3-2 (LOW): LibAllStandardOps functions missing `@return` tag

All five functions return `bytes memory` but none document the return value with `@return`. Every other function in this audit scope that returns a value documents it.

**Affected functions (all in `src/lib/op/LibAllStandardOps.sol`):**
- `authoringMetaV2` (L120) -- returns ABI-encoded `AuthoringMetaV2[]`
- `literalParserFunctionPointers` (L344) -- returns 16-bit relative pointer bytes
- `operandHandlerFunctionPointers` (L377) -- returns 16-bit relative pointer bytes
- `integrityFunctionPointers` (L549) -- returns 16-bit relative pointer bytes
- `opcodeFunctionPointers` (L653) -- returns 16-bit relative pointer bytes

### A42-P3-1 (LOW): LibOpCall.integrity has single `@return` for two return values

`LibOpCall.integrity` (L85) returns `(uint256, uint256)` but has only a single `@return` tag (L84):
```
/// @return The number of inputs and outputs for stack tracking.
```

Every other `integrity` function across the audit scope uses two separate `@return` tags:
```
/// @return The number of inputs.
/// @return The number of outputs.
```
