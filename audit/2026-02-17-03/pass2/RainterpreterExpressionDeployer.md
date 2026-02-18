# Pass 2: Test Coverage -- RainterpreterExpressionDeployer (A47)

## Evidence of Thorough Reading

### Source: `src/concrete/RainterpreterExpressionDeployer.sol`

- **Contract**: `RainterpreterExpressionDeployer` (line 24), inherits `IDescribedByMetaV1`, `IParserV2`, `IParserPragmaV1`, `IIntegrityToolingV1`, `ERC165`
- **Functions**:
  - `supportsInterface(bytes4)` -- public view virtual override, line 32
  - `parse2(bytes memory data)` -- external view virtual override, line 39
  - `parsePragma1(bytes calldata data)` -- external view virtual override, line 64
  - `buildIntegrityFunctionPointers()` -- external view virtual, line 82
  - `describedByMetaV1()` -- external pure override, line 87
- **Errors/Events/Structs**: None defined directly (errors come from called libraries: `LibIntegrityCheck`, `LibParse`, etc.)
- **Imports**: `ERC165`, `IParserV2`, `IParserPragmaV1`, `IDescribedByMetaV1`, `IIntegrityToolingV1`, `LibIntegrityCheck`, `LibInterpreterStateDataContract`, `LibAllStandardOps`, `RainterpreterParser`, `LibInterpreterDeploy`, `INTEGRITY_FUNCTION_POINTERS`, `DESCRIBED_BY_META_HASH`

### Test files:

#### `test/src/concrete/RainterpreterExpressionDeployer.deployCheck.t.sol`
- **Contract**: `RainterpreterExpressionDeployerDeployCheckTest` (line 15)
- **Test functions**:
  - `testRainterpreterExpressionDeployerDeployNoEIP1820()` -- line 17: deploys a new deployer, no assertions beyond successful construction

#### `test/src/concrete/RainterpreterExpressionDeployer.describedByMetaV1.t.sol`
- **Contract**: `RainterpreterExpressionDeployerDescribedByMetaV1Test` (line 12)
- **Test functions**:
  - `testRainterpreterExpressionDeployerDescribedByMetaV1Happy()` -- line 13: reads meta file, asserts hash matches `describedByMetaV1()` return

#### `test/src/concrete/RainterpreterExpressionDeployer.ierc165.t.sol`
- **Contract**: `RainterpreterExpressionDeployerIERC165Test` (line 14)
- **Test functions**:
  - `testRainterpreterExpressionDeployerIERC165(bytes4 badInterfaceId)` -- line 16: fuzz test verifying `supportsInterface` returns `true` for all five interfaces (`IERC165`, `IDescribedByMetaV1`, `IParserV2`, `IParserPragmaV1`, `IIntegrityToolingV1`) and `false` for random IDs

#### `test/src/concrete/RainterpreterExpressionDeployer.meta.t.sol`
- **Contract**: `RainterpreterExpressionDeployerMetaTest` (line 14), inherits `RainterpreterExpressionDeployerDeploymentTest`
- **Test functions**:
  - `testRainterpreterExpressionDeployerExpectedConstructionMetaHash()` -- line 17: asserts `describedByMetaV1()` matches `DESCRIBED_BY_META_HASH` constant

### Indirect coverage via `test/abstract/OpTest.sol`

The `OpTest` base contract calls `I_DEPLOYER.parse2(...)` extensively (line 206, 286, 304). This exercises `parse2` with valid Rainlang input as part of every opcode test. The `RainterpreterExpressionDeployerDeploymentTest` abstract also exercises `buildIntegrityFunctionPointers` (line 115-120).

## Findings

### A47-1: No direct test for `parse2` with invalid input [MEDIUM]

The `parse2` function is called indirectly through `OpTest` and individual opcode tests, but always with valid Rainlang. There is no test file directly exercising `parse2` with:
- Empty input (`bytes("")`)
- Malformed Rainlang (to trigger parse errors bubbling through `unsafeParse`)
- Input that parses successfully but fails integrity check (to trigger `integrityCheck2` errors)

These error paths are exercised at the library level (e.g., `LibParse` tests, `LibIntegrityCheck` tests), but there is no test confirming the errors propagate correctly through the `RainterpreterExpressionDeployer.parse2` entry point. If the deployer were to accidentally swallow or transform errors, no test would catch it.

### A47-2: No direct test for `parsePragma1` on the expression deployer [MEDIUM]

The `parsePragma1` function on the expression deployer (line 64) is a convenience proxy that delegates to `RainterpreterParser.parsePragma1`. While `RainterpreterParser.parsePragma1` is tested in `RainterpreterParser.parserPragma.t.sol`, there is no test calling `deployer.parsePragma1(...)` to verify the proxy works correctly. A grep for `deployer.*parsePragma1|I_DEPLOYER.*parsePragma1` across the test directory returned zero matches.

### A47-3: No test for `buildIntegrityFunctionPointers` return value consistency [LOW]

The `buildIntegrityFunctionPointers` function (line 82) is exercised in the `RainterpreterExpressionDeployerDeploymentTest` abstract constructor (line 115-120), which asserts its return matches the `INTEGRITY_FUNCTION_POINTERS` constant. However, there is no standalone test file for this function (unlike the parser which has `RainterpreterParser.pointers.t.sol`). The existing coverage is adequate but indirect.

### A47-4: `parse2` assembly block has no isolated test for memory allocation [LOW]

The `parse2` function contains an inline assembly block (lines 46-51) that manually allocates memory for the serialized output. There is no test specifically targeting this allocation logic -- for example, verifying that the returned `bytes memory` has the correct length, or that the free memory pointer is correctly updated. The assembly is simple (allocate `size + 0x20` bytes, store length), but a dedicated test would guard against regressions if this code changes.
