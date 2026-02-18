# Pass 4: Code Quality -- Error Files (Agent A05)

## Evidence of Thorough Reading

### ErrBitwise.sol
- Contract: `ErrBitwise` (line 6, Foundry workaround)
- `error UnsupportedBitwiseShiftAmount(uint256 shiftAmount)` (line 13)
- `error TruncatedBitwiseEncoding(uint256 startBit, uint256 length)` (line 19)
- `error ZeroLengthBitwiseEncoding()` (line 23)

### ErrDeploy.sol
- Contract: `ErrDeploy` (line 6, Foundry workaround)
- `error UnknownDeploymentSuite(bytes32 suite)` (line 11)

### ErrEval.sol
- Contract: `ErrEval` (line 6, Foundry workaround)
- `error InputsLengthMismatch(uint256 expected, uint256 actual)` (line 11)
- `error ZeroFunctionPointers()` (line 15)

### ErrExtern.sol
- Contract: `ErrExtern` (line 8, Foundry workaround)
- Import: `NotAnExternContract` from `rain.interpreter.interface/error/ErrExtern.sol` (line 5, re-export)
- `error ExternOpcodeOutOfRange(uint256 opcode, uint256 fsCount)` (line 14)
- `error ExternPointersMismatch(uint256 opcodeCount, uint256 integrityCount)` (line 20)
- `error BadOutputsLength(uint256 expectedLength, uint256 actualLength)` (line 23)
- `error ExternOpcodePointersEmpty()` (line 26)

### ErrIntegrity.sol
- Contract: `ErrIntegrity` (line 6, Foundry workaround)
- `error StackUnderflow(uint256 opIndex, uint256 stackIndex, uint256 calculatedInputs)` (line 12)
- `error StackUnderflowHighwater(uint256 opIndex, uint256 stackIndex, uint256 stackHighwater)` (line 18)
- `error StackAllocationMismatch(uint256 stackMaxIndex, uint256 bytecodeAllocation)` (line 24)
- `error StackOutputsMismatch(uint256 stackIndex, uint256 bytecodeOutputs)` (line 29)
- `error OutOfBoundsConstantRead(uint256 opIndex, uint256 constantsLength, uint256 constantRead)` (line 35)
- `error OutOfBoundsStackRead(uint256 opIndex, uint256 stackTopIndex, uint256 stackRead)` (line 41)
- `error CallOutputsExceedSource(uint256 sourceOutputs, uint256 outputs)` (line 47)
- `error OpcodeOutOfRange(uint256 opIndex, uint256 opcodeIndex, uint256 fsCount)` (line 53)

### ErrOpList.sol
- Contract: `ErrOpList` (line 6, Foundry workaround)
- `error BadDynamicLength(uint256 dynamicLength, uint256 standardOpsLength)` (line 12)

### ErrParse.sol
- Contract: `ErrParse` (line 6, Foundry workaround)
- 41 errors defined (lines 10-163), full list:
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

### ErrStore.sol
- Contract: `ErrStore` (line 6, Foundry workaround)
- `error OddSetLength(uint256 length)` (line 10)

### ErrSubParse.sol
- Contract: `ErrSubParse` (line 7, Foundry workaround)
- `error ExternDispatchConstantsHeightOverflow(uint256 constantsHeight)` (line 10)
- `error ConstantOpcodeConstantsHeightOverflow(uint256 constantsHeight)` (line 14)
- `error ContextGridOverflow(uint256 column, uint256 row)` (line 17)

---

## Findings

### A05-1: `MalformedExponentDigits` and `MalformedDecimalPoint` are unused in this repo [LOW]

**File:** `src/error/ErrParse.sol`, lines 53 and 56

These two errors are defined in this repo's `ErrParse.sol` but are never imported or referenced anywhere in `src/`. The only usages of identically named errors exist in the submodule `lib/rain.interpreter.interface/lib/rain.math.float/src/error/ErrParse.sol` and `lib/rain.interpreter.interface/lib/rain.math.float/src/lib/parse/LibParseDecimalFloat.sol`, which is a separate error definition in a separate file. The submodule does not import from this repo's `src/error/ErrParse.sol`.

This makes these two errors dead code. They either should be removed from this file, or if they were intended to be used by `LibParseLiteralDecimal.sol`, the decimal parsing code should import them from here rather than relying on the submodule's own error definitions.

---

### A05-2: Inconsistent NatSpec `@dev` usage across error files [LOW]

**Files:** All 9 error files

Error NatSpec comments are inconsistent in their use of the `@dev` tag:

- **ErrSubParse.sol**: All 3 errors use `/// @dev` prefix (lines 8, 12, 16)
- **ErrParse.sol**: 1 of 41 errors uses `/// @dev` (`DuplicateLHSItem`, line 86); the other 40 use plain `///`
- **All other files** (ErrBitwise, ErrDeploy, ErrEval, ErrExtern, ErrIntegrity, ErrOpList, ErrStore): Use plain `///` consistently

Per the user preferences in MEMORY.md, `@notice` should not be used -- just use `///` directly. While `@dev` is not `@notice`, the same principle of consistency applies. The codebase should pick one convention and apply it uniformly. The dominant pattern (used in 7 of 9 files) is plain `///` without `@dev`.

---

### A05-3: Missing `@param` tags on 28 parameterized errors in ErrParse.sol [LOW]

**File:** `src/error/ErrParse.sol`

Of the 30 errors in `ErrParse.sol` that have parameters, only 3 include `@param` tags (`OperandValuesOverflow`, `UnclosedOperand`, `DuplicateLHSItem`, `ParseMemoryOverflow`). The remaining 26 parameterized errors are missing `@param` documentation:

`UnsupportedLiteralType`, `StringTooLong`, `UnclosedStringLiteral`, `HexLiteralOverflow`, `ZeroLengthHexLiteral`, `OddLengthHexLiteral`, `MalformedHexLiteral`, `MalformedExponentDigits`, `MalformedDecimalPoint`, `MissingFinalSemi`, `UnexpectedLHSChar`, `UnexpectedRHSChar`, `ExpectedLeftParen`, `UnexpectedRightParen`, `UnclosedLeftParen`, `UnexpectedComment`, `UnclosedComment`, `MalformedCommentStart`, `ExcessLHSItems`, `NotAcceptingInputs`, `ExcessRHSItems`, `WordSize`, `UnknownWord`, `NoWhitespaceAfterUsingWordsFrom`, `InvalidSubParser`, `UnclosedSubParseableLiteral`, `SubParseableMissingDispatch`, `BadSubParserResult`, `OpcodeIOOverflow`

Many of these share the common `offset` parameter pattern. While the parameter name is self-explanatory, consistency with the rest of the codebase (ErrBitwise, ErrDeploy, ErrEval, ErrIntegrity, ErrOpList, ErrStore all have `@param` on every parameterized error) requires adding them.

---

### A05-4: Missing `@param` tags on `BadOutputsLength` in ErrExtern.sol [LOW]

**File:** `src/error/ErrExtern.sol`, line 23

`BadOutputsLength(uint256 expectedLength, uint256 actualLength)` is the only parameterized error in `ErrExtern.sol` that lacks `@param` tags. The other two parameterized errors (`ExternOpcodeOutOfRange`, `ExternPointersMismatch`) both include `@param` documentation.

---

### A05-5: Missing `@param` tags on all 3 errors in ErrSubParse.sol [LOW]

**File:** `src/error/ErrSubParse.sol`, lines 10, 14, 17

All three errors have parameters but none include `@param` tags:
- `ExternDispatchConstantsHeightOverflow(uint256 constantsHeight)` -- missing `@param constantsHeight`
- `ConstantOpcodeConstantsHeightOverflow(uint256 constantsHeight)` -- missing `@param constantsHeight`
- `ContextGridOverflow(uint256 column, uint256 row)` -- missing `@param column` and `@param row`

---

### A05-6: Pragma uses `^0.8.25` but CLAUDE.md specifies "exactly 0.8.25" [INFO]

**Files:** All 9 error files

All files use `pragma solidity ^0.8.25;` (caret range), which allows any 0.8.x version >= 0.8.25. CLAUDE.md states the Solidity version should be "exactly `0.8.25`". This is an observation about consistency between the process document and the code. The caret pragma is the standard Solidity convention for library code and may be intentional, but it conflicts with the documented convention. This affects the entire codebase, not just error files.

---

### A05-7: `DuplicateLHSItem` uses `@dev` while adjacent errors in ErrParse.sol do not [LOW]

**File:** `src/error/ErrParse.sol`, line 86

`DuplicateLHSItem` is the only error in `ErrParse.sol` that uses `/// @dev` prefix. Every other error in the file uses plain `///`. This is a subset of A05-2 but worth calling out specifically because it is a single outlier within a single file, suggesting it was written at a different time or by a different convention and was not normalized.

---

### A05-8: No commented-out code found [INFO]

**Files:** All 9 error files

No commented-out code was found in any of the 9 error files. All comments are documentation comments.

---

### A05-9: No magic numbers found [INFO]

**Files:** All 9 error files

No numeric literals appear in any of the 9 error files. All files contain only error definitions and documentation.

---

### A05-10: Error organization is appropriate [INFO]

**Files:** All 9 error files

Errors are logically grouped by subsystem:
- `ErrBitwise.sol` -- bitwise opcode integrity errors
- `ErrDeploy.sol` -- deployment script errors
- `ErrEval.sol` -- evaluation runtime errors
- `ErrExtern.sol` -- extern system errors (plus re-export of interface error)
- `ErrIntegrity.sol` -- integrity check errors
- `ErrOpList.sol` -- opcode list registration errors
- `ErrParse.sol` -- parser errors (largest file, 41 errors)
- `ErrStore.sol` -- store operation errors
- `ErrSubParse.sol` -- sub-parser errors

No misplaced errors were found. The separation between `ErrParse.sol` and `ErrSubParse.sol` is reasonable given the sub-parser is a distinct subsystem.

---

### A05-11: File header/license consistency is good [INFO]

**Files:** All 9 error files

All 9 files use identical headers:
```
// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;
```

All include the Foundry workaround contract (`/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572`).

---

### A05-12: Error naming conventions are mostly consistent [INFO]

**Files:** All 9 error files

Error names follow consistent patterns:
- Overflow conditions: `*Overflow` (e.g., `OperandValuesOverflow`, `ParseStackOverflow`, `HexLiteralOverflow`)
- Mismatches: `*Mismatch` (e.g., `InputsLengthMismatch`, `StackAllocationMismatch`)
- Out-of-bounds: `OutOfBounds*` (e.g., `OutOfBoundsConstantRead`, `OutOfBoundsStackRead`)
- Unexpected tokens: `Unexpected*` (e.g., `UnexpectedOperand`, `UnexpectedRHSChar`)
- Unclosed delimiters: `Unclosed*` (e.g., `UnclosedOperand`, `UnclosedLeftParen`)
- Malformed input: `Malformed*` (e.g., `MalformedHexLiteral`, `MalformedCommentStart`)

One minor inconsistency: `ExternOpcodeOutOfRange` (in ErrExtern.sol) vs `OpcodeOutOfRange` (in ErrIntegrity.sol). Both describe an opcode index being out of bounds, but the extern version has the `Extern` prefix to disambiguate. This is acceptable given the different contexts.
