# Pass 1 (Security) -- Error Definition Files

Auditor: Claude Opus 4.6
Date: 2026-02-17

## Files Reviewed

### 1. `src/error/ErrBitwise.sol`

**Contract/Library name:** `ErrBitwise` (empty workaround contract)

**Errors defined:**
- `UnsupportedBitwiseShiftAmount(uint256 shiftAmount)` (line 13) -- shift amount > 255 or 0
- `TruncatedBitwiseEncoding(uint256 startBit, uint256 length)` (line 19) -- end bit position beyond 256
- `ZeroLengthBitwiseEncoding()` (line 23) -- zero-length encoding

All three errors are used in `src/lib/op/bitwise/` files.

---

### 2. `src/error/ErrDeploy.sol`

**Contract/Library name:** `ErrDeploy` (empty workaround contract)

**Errors defined:**
- `UnknownDeploymentSuite(bytes32 suite)` (line 11) -- unrecognised `DEPLOYMENT_SUITE` env var

Used in `script/Deploy.sol`.

---

### 3. `src/error/ErrEval.sol`

**Contract/Library name:** `ErrEval` (empty workaround contract)

**Errors defined:**
- `InputsLengthMismatch(uint256 expected, uint256 actual)` (line 11) -- inputs length mismatch during eval
- `ZeroFunctionPointers()` (line 15) -- empty function pointer table (prevents mod-by-zero)

Used in `src/lib/eval/LibEval.sol` and `src/concrete/Rainterpreter.sol`.

---

### 4. `src/error/ErrExtern.sol`

**Contract/Library name:** `ErrExtern` (empty workaround contract)

**Import:** Re-exports `NotAnExternContract` from `rain.interpreter.interface/error/ErrExtern.sol`.

**Errors defined (locally):**
- `ExternOpcodeOutOfRange(uint256 opcode, uint256 fsCount)` (line 14)
- `ExternPointersMismatch(uint256 opcodeCount, uint256 integrityCount)` (line 20)
- `BadOutputsLength(uint256 expectedLength, uint256 actualLength)` (line 23)
- `ExternOpcodePointersEmpty()` (line 26)

All errors are used in `src/abstract/BaseRainterpreterExtern.sol` or `src/lib/op/00/LibOpExtern.sol`.

---

### 5. `src/error/ErrIntegrity.sol`

**Contract/Library name:** `ErrIntegrity` (empty workaround contract)

**Errors defined:**
- `StackUnderflow(uint256 opIndex, uint256 stackIndex, uint256 calculatedInputs)` (line 12)
- `StackUnderflowHighwater(uint256 opIndex, uint256 stackIndex, uint256 stackHighwater)` (line 18)
- `StackAllocationMismatch(uint256 stackMaxIndex, uint256 bytecodeAllocation)` (line 24)
- `StackOutputsMismatch(uint256 stackIndex, uint256 bytecodeOutputs)` (line 29)
- `OutOfBoundsConstantRead(uint256 opIndex, uint256 constantsLength, uint256 constantRead)` (line 35)
- `OutOfBoundsStackRead(uint256 opIndex, uint256 stackTopIndex, uint256 stackRead)` (line 41)
- `CallOutputsExceedSource(uint256 sourceOutputs, uint256 outputs)` (line 47)
- `OpcodeOutOfRange(uint256 opIndex, uint256 opcodeIndex, uint256 fsCount)` (line 53)

All errors are used in `src/lib/integrity/LibIntegrityCheck.sol`.

---

### 6. `src/error/ErrOpList.sol`

**Contract/Library name:** `ErrOpList` (empty workaround contract)

**Errors defined:**
- `BadDynamicLength(uint256 dynamicLength, uint256 standardOpsLength)` (line 12)

Used in `src/lib/op/LibAllStandardOps.sol` and `src/concrete/extern/RainterpreterReferenceExtern.sol`.

---

### 7. `src/error/ErrParse.sol`

**Contract/Library name:** `ErrParse` (empty workaround contract)

**Errors defined:**
- `UnexpectedOperand()` (line 10)
- `UnexpectedOperandValue()` (line 14)
- `ExpectedOperand()` (line 18)
- `OperandValuesOverflow(uint256 offset)` (line 23)
- `UnclosedOperand(uint256 offset)` (line 27)
- `UnsupportedLiteralType(uint256 offset)` (line 30)
- `StringTooLong(uint256 offset)` (line 33)
- `UnclosedStringLiteral(uint256 offset)` (line 37)
- `HexLiteralOverflow(uint256 offset)` (line 40)
- `ZeroLengthHexLiteral(uint256 offset)` (line 43)
- `OddLengthHexLiteral(uint256 offset)` (line 46)
- `MalformedHexLiteral(uint256 offset)` (line 49)
- `MalformedExponentDigits(uint256 offset)` (line 53)
- `MalformedDecimalPoint(uint256 offset)` (line 56)
- `MissingFinalSemi(uint256 offset)` (line 59)
- `UnexpectedLHSChar(uint256 offset)` (line 62)
- `UnexpectedRHSChar(uint256 offset)` (line 65)
- `ExpectedLeftParen(uint256 offset)` (line 69)
- `UnexpectedRightParen(uint256 offset)` (line 72)
- `UnclosedLeftParen(uint256 offset)` (line 75)
- `UnexpectedComment(uint256 offset)` (line 78)
- `UnclosedComment(uint256 offset)` (line 81)
- `MalformedCommentStart(uint256 offset)` (line 84)
- `DuplicateLHSItem(uint256 offset)` (line 89)
- `ExcessLHSItems(uint256 offset)` (line 92)
- `NotAcceptingInputs(uint256 offset)` (line 95)
- `ExcessRHSItems(uint256 offset)` (line 98)
- `WordSize(string word)` (line 101)
- `UnknownWord(string word)` (line 104)
- `MaxSources()` (line 107)
- `DanglingSource()` (line 110)
- `ParserOutOfBounds()` (line 113)
- `ParseStackOverflow()` (line 117)
- `ParseStackUnderflow()` (line 120)
- `ParenOverflow()` (line 124)
- `NoWhitespaceAfterUsingWordsFrom(uint256 offset)` (line 127)
- `InvalidSubParser(uint256 offset)` (line 130)
- `UnclosedSubParseableLiteral(uint256 offset)` (line 133)
- `SubParseableMissingDispatch(uint256 offset)` (line 136)
- `BadSubParserResult(bytes bytecode)` (line 140)
- `OpcodeIOOverflow(uint256 offset)` (line 143)
- `OperandOverflow()` (line 146)
- `ParseMemoryOverflow(uint256 freeMemoryPointer)` (line 151)
- `SourceItemOpsOverflow()` (line 155)
- `ParenInputOverflow()` (line 158)
- `LineRHSItemsOverflow()` (line 163)

---

### 8. `src/error/ErrStore.sol`

**Contract/Library name:** `ErrStore` (empty workaround contract)

**Errors defined:**
- `OddSetLength(uint256 length)` (line 10)

Used in `src/concrete/RainterpreterStore.sol` and `src/concrete/Rainterpreter.sol`.

---

### 9. `src/error/ErrSubParse.sol`

**Contract/Library name:** `ErrSubParse` (empty workaround contract)

**Errors defined:**
- `ExternDispatchConstantsHeightOverflow(uint256 constantsHeight)` (line 10)
- `ConstantOpcodeConstantsHeightOverflow(uint256 constantsHeight)` (line 14)
- `ContextGridOverflow(uint256 column, uint256 row)` (line 17)

All three errors are used in `src/lib/parse/LibSubParse.sol`.

---

## Security Findings

### No CRITICAL, HIGH, or MEDIUM findings.

All error definition files are purely declarative -- they define custom error types and contain no executable logic, storage access, or external calls. The security surface of these files is minimal.

---

### INFO-01: Missing `@param` tags on `BadOutputsLength`

**Severity:** INFO
**File:** `src/error/ErrExtern.sol`, line 23
**Description:** The `BadOutputsLength` error has two parameters (`expectedLength`, `actualLength`) but its NatSpec documentation does not include `@param` tags. All other parameterized errors in the same file have `@param` tags. This is a documentation completeness gap, not a security issue.

```solidity
/// Thrown when the outputs length is not equal to the expected length.
error BadOutputsLength(uint256 expectedLength, uint256 actualLength);
```

---

### INFO-02: Inconsistent use of `@dev` tag on NatSpec comments

**Severity:** INFO
**File:** Multiple error files
**Description:** NatSpec style is inconsistent across error files. In `ErrSubParse.sol`, all three error comments use `/// @dev` prefix. In `ErrParse.sol`, `DuplicateLHSItem` uses `/// @dev` while all other errors use plain `///`. In `ErrExtern.sol`, the workaround contract uses `/// @dev` but error comments do not. This inconsistency has no security impact but affects documentation tooling consistency. Per user preference, `@dev` should not be used -- plain `///` is preferred.

---

### INFO-03: Re-export pattern in `ErrExtern.sol` for `NotAnExternContract`

**Severity:** INFO
**File:** `src/error/ErrExtern.sol`, line 5
**Description:** `ErrExtern.sol` imports `NotAnExternContract` from `rain.interpreter.interface/error/ErrExtern.sol`. This import serves as a re-export point so that internal source files (e.g., `LibOpExtern.sol`) can import it from the local error file rather than reaching into the interface dependency directly. This is a reasonable centralization pattern. No security concern, noted for completeness.

---

### INFO-04: All errors use custom error types (no string reverts)

**Severity:** INFO (positive finding)
**Description:** Verified that none of the nine error files contain `revert("...")` or `require(..., "...")` patterns. All errors are defined as custom error types as required by the project conventions. The only `require(false, ...)` usage in the broader `src/` directory is in `LibOpConditions.sol` (line 93-95), which is an intentional design choice for the `conditions` opcode to propagate user-defined error messages -- this is outside the scope of these error definition files.

---

### INFO-05: Empty workaround contracts

**Severity:** INFO
**File:** All nine error files
**Description:** Each error file contains an empty contract (e.g., `contract ErrBitwise {}`) as a workaround for [foundry-rs/foundry#6572](https://github.com/foundry-rs/foundry/issues/6572). These contracts have no functionality and exist solely so that Foundry recognizes the files as compilable units. No security impact.

---

## Summary

All nine error definition files are clean from a security perspective. They are purely declarative, define only custom error types (no string reverts), and all defined errors are actively used in the codebase. The only findings are documentation-level observations (missing `@param` tags, inconsistent `@dev` usage). No executable logic, no state manipulation, and no attack surface.
