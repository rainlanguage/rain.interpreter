# Pass 2 -- Test Coverage Audit: Literal, Extern, Deploy Libraries

**Agent:** A05
**Date:** 2026-03-07
**Scope:** 14 source files covering literal parsing, extern encoding/dispatch, reference extern ops, deploy constants, and the DISPaiR registry interface.

## Source Files Reviewed

| # | File | Library / Interface | Functions |
|---|------|---------------------|-----------|
| 1 | `src/lib/parse/literal/LibParseLiteral.sol` | `LibParseLiteral` | `selectLiteralParserByIndex` (L43), `parseLiteral` (L65), `tryParseLiteral` (L87) |
| 2 | `src/lib/parse/literal/LibParseLiteralDecimal.sol` | `LibParseLiteralDecimal` | `parseDecimalFloatPacked` (L23) |
| 3 | `src/lib/parse/literal/LibParseLiteralHex.sol` | `LibParseLiteralHex` | `boundHex` (L36), `parseHex` (L68) |
| 4 | `src/lib/parse/literal/LibParseLiteralString.sol` | `LibParseLiteralString` | `boundString` (L26), `parseString` (L88) |
| 5 | `src/lib/parse/literal/LibParseLiteralSubParseable.sol` | `LibParseLiteralSubParseable` | `parseSubParseable` (L38) |
| 6 | `src/lib/extern/LibExtern.sol` | `LibExtern` | `encodeExternDispatch` (L27), `decodeExternDispatch` (L35), `encodeExternCall` (L56), `decodeExternCall` (L70) |
| 7 | `src/lib/extern/reference/op/LibExternOpContextCallingContract.sol` | `LibExternOpContextCallingContract` | `subParser` (L25) |
| 8 | `src/lib/extern/reference/op/LibExternOpContextRainlen.sol` | `LibExternOpContextRainlen` | `subParser` (L33) |
| 9 | `src/lib/extern/reference/op/LibExternOpContextSender.sol` | `LibExternOpContextSender` | `subParser` (L22) |
| 10 | `src/lib/extern/reference/op/LibExternOpIntInc.sol` | `LibExternOpIntInc` | `run` (L27), `integrity` (L44), `subParser` (L57) |
| 11 | `src/lib/extern/reference/op/LibExternOpStackOperand.sol` | `LibExternOpStackOperand` | `subParser` (L23) |
| 12 | `src/lib/extern/reference/literal/LibParseLiteralRepeat.sol` | `LibParseLiteralRepeat` | `parseRepeat` (L53) |
| 13 | `src/lib/deploy/LibInterpreterDeploy.sol` | `LibInterpreterDeploy` | Constants (10) + `etchDISPaiR` (L95) |
| 14 | `src/interface/IDISPaiRegistry.sol` | `IDISPaiRegistry` | `expressionDeployerAddress`, `interpreterAddress`, `storeAddress`, `parserAddress` |

## Test Files Reviewed

| Test File | Covers |
|-----------|--------|
| `test/src/lib/parse/literal/LibParseLiteral.selectByIndex.t.sol` | `selectLiteralParserByIndex` (indexes 0, 1, 2) |
| `test/src/lib/parse/literal/LibParseLiteral.dispatch.t.sol` | `parseLiteral`, `tryParseLiteral` (all dispatch branches, cursor advancement, UppercaseHexPrefix, OOB poison, UnsupportedLiteralType) |
| `test/src/lib/parse/literal/LibParseLiteralDecimal.parseDecimalFloat.t.sol` | `parseDecimalFloatPacked` (extensive happy path, multiple revert cases) |
| `test/src/lib/parse/literal/LibParseLiteralHex.boundHex.t.sol` | `boundHex` (concrete + fuzz) |
| `test/src/lib/parse/literal/LibParseLiteralHex.parseHex.t.sol` | `parseHex` (round-trip fuzz, overflow, zero-length, odd-length, mixed-case, upper, lower, alternating) |
| `test/src/lib/parse/literal/LibParseLiteralString.boundString.t.sol` | `boundString` (fuzz, too-long, invalid char, out-of-bounds, unclosed at end boundary) |
| `test/src/lib/parse/literal/LibParseLiteralString.parseString.t.sol` | `parseString` (empty, fuzz, memory restoration, corrupt) |
| `test/src/lib/parse/literal/LibParseLiteralSubParseable.parseSubParseable.t.sol` | `parseSubParseable` (unclosed, missing dispatch, body variants, fuzz, bracket-past-end, multi sub-parser fallthrough) |
| `test/src/lib/extern/LibExtern.codec.t.sol` | `encodeExternDispatch`, `decodeExternDispatch`, `encodeExternCall`, `decodeExternCall` (round-trip fuzz + standalone decode) |
| `test/src/lib/extern/reference/op/LibExternOpContextCallingContract.subParser.t.sol` | `LibExternOpContextCallingContract.subParser` (fuzz all inputs) |
| `test/src/lib/extern/reference/op/LibExternOpContextRainlen.subParser.t.sol` | `LibExternOpContextRainlen.subParser` (fuzz all inputs) |
| `test/src/lib/extern/reference/op/LibExternOpContextSender.subParser.t.sol` | `LibExternOpContextSender.subParser` (fuzz all inputs) |
| `test/src/lib/extern/reference/op/LibExternOpStackOperand.subParser.t.sol` | `LibExternOpStackOperand.subParser` (fuzz all inputs) |
| `test/src/lib/extern/reference/literal/LibParseLiteralRepeat.t.sol` | `parseRepeat` (output value fuzz, invalid dispatch, too-long revert) |
| `test/src/concrete/RainterpreterReferenceExtern.intInc.t.sol` | `LibExternOpIntInc.run` (fuzz), `integrity` (fuzz), `subParser` (via `subParseWord2` integration) |
| `test/src/lib/deploy/LibInterpreterDeploy.t.sol` | All 5 deploy address/codehash constants, creation code, runtime code, generated addresses, `etchDISPaiR` (basic + idempotent) |
| `test/src/concrete/RainterpreterDISPaiRegistry.ierc165.t.sol` | `IDISPaiRegistry` ERC165 support |

## Coverage Analysis

Every function in every source file has corresponding test coverage:

- **LibParseLiteral**: All three functions tested with dispatch for every literal type (hex, decimal, string, sub-parseable), unrecognized types, uppercase hex prefix revert, and the out-of-bounds second-byte poison edge case.
- **LibParseLiteralDecimal**: Single function tested with ~30 happy-path variants and ~15 revert cases (empty, non-decimal, malformed exponent, dot edge cases, precision loss).
- **LibParseLiteralHex**: Both functions tested. `boundHex` has concrete + fuzz. `parseHex` has round-trip fuzz over all `bytes32` values, plus error paths for overflow (>64 hex digits), zero-length, and odd-length.
- **LibParseLiteralString**: Both functions tested. `boundString` has fuzz + boundary tests. `parseString` has fuzz + memory restoration + corrupt char tests.
- **LibParseLiteralSubParseable**: Tested with extensive error cases (unclosed, missing dispatch, whitespace variants), body parsing, fuzz, bracket-past-end edge case, and multi sub-parser fallthrough/reject-all scenarios.
- **LibExtern**: All four codec functions tested with fuzz round-trips and standalone decode from manually constructed words (catches symmetric encode/decode bugs).
- **Reference extern ops**: All five libraries have dedicated fuzz tests. `LibExternOpIntInc` has direct tests for `run`, `integrity`, and integration tests for `subParser` through `subParseWord2`.
- **LibParseLiteralRepeat**: Fuzz output value, invalid dispatch revert, too-long revert.
- **LibInterpreterDeploy**: All constants verified against actual Zoltu deployment addresses and codehashes (fork tests). Creation and runtime code constants verified against compiler output. `etchDISPaiR` tested for correctness and idempotency.
- **IDISPaiRegistry**: Interface tested via ERC165 support check.

## Findings

No findings. All source functions have adequate direct test coverage.
