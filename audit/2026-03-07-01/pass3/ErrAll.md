# Pass 3 - Documentation Audit: Error Files and IDISPaiRegistry

Agent: A02
Date: 2026-03-07

## Files Reviewed

1. `src/error/ErrBitwise.sol`
2. `src/error/ErrDeploy.sol`
3. `src/error/ErrEval.sol`
4. `src/error/ErrExtern.sol`
5. `src/error/ErrIntegrity.sol`
6. `src/error/ErrOpList.sol`
7. `src/error/ErrParse.sol`
8. `src/error/ErrRainType.sol`
9. `src/error/ErrStore.sol`
10. `src/error/ErrSubParse.sol`
11. `src/interface/IDISPaiRegistry.sol`

## Evidence

### ErrBitwise.sol

| Line | Item | NatSpec | Tags Correct | Docs Match Impl |
|------|------|---------|--------------|-----------------|
| 5-6 | `contract ErrBitwise` (workaround) | `@dev` only | Yes (single tag) | Yes |
| 8-13 | `UnsupportedBitwiseShiftAmount(uint256)` | `@notice`, `@param` | Yes | Yes -- checked against `LibOpBitwiseShiftLeft.sol:25` and `LibOpBitwiseShiftRight.sol:25`: `shiftAmount > type(uint8).max || shiftAmount == 0` matches "greater than 255 or 0" |
| 15-19 | `TruncatedBitwiseEncoding(uint256, uint256)` | `@notice`, `@param` x2 | Yes | Yes -- used in encode integrity; decode delegates to encode integrity |
| 21-23 | `ZeroLengthBitwiseEncoding()` | `@notice` | Yes | Yes -- used in `LibOpBitwiseEncode.sol:24` |

### ErrDeploy.sol

| Line | Item | NatSpec | Tags Correct | Docs Match Impl |
|------|------|---------|--------------|-----------------|
| 5-6 | `contract ErrDeploy` (workaround) | `@dev` only | Yes | Yes |
| 8-11 | `UnknownDeploymentSuite(bytes32)` | `@notice`, `@param` | Yes | Yes -- used in `script/Deploy.sol:135` |

### ErrEval.sol

| Line | Item | NatSpec | Tags Correct | Docs Match Impl |
|------|------|---------|--------------|-----------------|
| 5-6 | `contract ErrEval` (workaround) | `@dev` only | Yes | Yes |
| 8-11 | `InputsLengthMismatch(uint256, uint256)` | `@notice`, `@param` x2 | Yes | Yes -- used in `LibEval.sol:213` |
| 13-15 | `ZeroFunctionPointers()` | `@notice` | Yes | Yes -- used in `Rainterpreter.sol:39` |

### ErrExtern.sol

| Line | Item | NatSpec | Tags Correct | Docs Match Impl |
|------|------|---------|--------------|-----------------|
| 5 | `import {NotAnExternContract}` | N/A (import) | N/A | Re-exported for internal use |
| 7-8 | `contract ErrExtern` (workaround) | `@dev` only | Yes | Yes |
| 10-14 | `ExternOpcodeOutOfRange(uint256, uint256)` | `@notice`, `@param` x2 | Yes | Yes -- used in `BaseRainterpreterExtern.sol:99` |
| 16-20 | `ExternPointersMismatch(uint256, uint256)` | `@notice`, `@param` x2 | Yes | Yes -- used in `BaseRainterpreterExtern.sol:41` |
| 22-25 | `BadOutputsLength(uint256, uint256)` | `@notice`, `@param` x2 | Yes | Yes -- used in `LibOpExtern.sol:73,115` |
| 27-28 | `ExternOpcodePointersEmpty()` | `@notice` | Yes | Yes -- used in `BaseRainterpreterExtern.sol:37` |

### ErrIntegrity.sol

| Line | Item | NatSpec | Tags Correct | Docs Match Impl |
|------|------|---------|--------------|-----------------|
| 5-6 | `contract ErrIntegrity` (workaround) | `@dev` only | Yes | Yes |
| 8-12 | `StackUnderflow(uint256, uint256, uint256)` | `@notice`, `@param` x3 | Yes | Yes |
| 14-18 | `StackUnderflowHighwater(uint256, uint256, uint256)` | `@notice`, `@param` x3 | Yes | Yes |
| 20-24 | `StackAllocationMismatch(uint256, uint256)` | `@notice`, `@param` x2 | Yes | Yes |
| 26-29 | `StackOutputsMismatch(uint256, uint256)` | `@notice`, `@param` x2 | Yes | Yes |
| 31-35 | `OutOfBoundsConstantRead(uint256, uint256, uint256)` | `@notice`, `@param` x3 | Yes | Yes |
| 37-41 | `OutOfBoundsStackRead(uint256, uint256, uint256)` | `@notice`, `@param` x3 | Yes | Yes |
| 43-47 | `CallOutputsExceedSource(uint256, uint256)` | `@notice`, `@param` x2 | Yes | Yes |
| 49-53 | `OpcodeOutOfRange(uint256, uint256, uint256)` | `@notice`, `@param` x3 | Yes | Yes |

### ErrOpList.sol

| Line | Item | NatSpec | Tags Correct | Docs Match Impl |
|------|------|---------|--------------|-----------------|
| 5-6 | `contract ErrOpList` (workaround) | `@dev` only | Yes | Yes |
| 8-12 | `BadDynamicLength(uint256, uint256)` | `@notice`, `@param` x2 | Yes | Yes -- used in `LibAllStandardOps.sol` and `RainterpreterReferenceExtern.sol` |

### ErrParse.sol

| Line | Item | NatSpec | Tags Correct | Docs Match Impl |
|------|------|---------|--------------|-----------------|
| 5-6 | `contract ErrParse` (workaround) | `@dev` only | Yes | Yes |
| 8-10 | `UnexpectedOperand()` | `@notice` | Yes | Yes |
| 12-14 | `UnexpectedOperandValue()` | `@notice` | Yes | Yes |
| 16-18 | `ExpectedOperand()` | `@notice` | Yes | Yes |
| 20-23 | `OperandValuesOverflow(uint256)` | `@notice`, `@param` | Yes | Yes |
| 25-27 | `UnclosedOperand(uint256)` | `@notice`, `@param` | Yes | Yes |
| 29-31 | `UnsupportedLiteralType(uint256)` | `@notice`, `@param` | Yes | Yes |
| 33-35 | `StringTooLong(uint256)` | `@notice`, `@param` | Yes | Yes |
| 37-40 | `UnclosedStringLiteral(uint256)` | `@notice`, `@param` | Yes | Yes |
| 42-44 | `HexLiteralOverflow(uint256)` | `@notice`, `@param` | Yes | Yes |
| 46-48 | `ZeroLengthHexLiteral(uint256)` | `@notice`, `@param` | Yes | Yes |
| 50-52 | `OddLengthHexLiteral(uint256)` | `@notice`, `@param` | Yes | Yes |
| 54-56 | `MalformedHexLiteral(uint256)` | `@notice`, `@param` | Yes | Yes |
| 58-60 | `MissingFinalSemi(uint256)` | `@notice`, `@param` | Yes | Yes |
| 62-64 | `UnexpectedLHSChar(uint256)` | `@notice`, `@param` | Yes | Yes |
| 66-68 | `UnexpectedRHSChar(uint256)` | `@notice`, `@param` | Yes | Yes |
| 70-73 | `ExpectedLeftParen(uint256)` | `@notice`, `@param` | Yes | Yes |
| 75-77 | `UnexpectedRightParen(uint256)` | `@notice`, `@param` | Yes | Yes |
| 79-81 | `UnclosedLeftParen(uint256)` | `@notice`, `@param` | Yes | Yes |
| 83-85 | `UnexpectedComment(uint256)` | `@notice`, `@param` | Yes | Yes |
| 87-89 | `UnclosedComment(uint256)` | `@notice`, `@param` | Yes | Yes |
| 91-93 | `MalformedCommentStart(uint256)` | `@notice`, `@param` | Yes | Yes |
| 95-98 | `DuplicateLHSItem(uint256)` | `@notice`, `@param` | Yes | Yes |
| 100-102 | `ExcessLHSItems(uint256)` | `@notice`, `@param` | Yes | Yes |
| 104-106 | `NotAcceptingInputs(uint256)` | `@notice`, `@param` | Yes | Yes |
| 108-110 | `ExcessRHSItems(uint256)` | `@notice`, `@param` | Yes | Yes |
| 112-114 | `WordSize(string)` | `@notice`, `@param` | Yes | Yes |
| 116-118 | `UnknownWord(string)` | `@notice`, `@param` | Yes | Yes |
| 120-121 | `MaxSources()` | `@notice` | Yes | Yes |
| 123-124 | `DanglingSource()` | `@notice` | Yes | Yes |
| 126-131 | `ParserOutOfBounds()` | `@notice` | Yes | Yes |
| 133-135 | `ParseStackOverflow()` | `@notice` | Yes | Yes |
| 137-138 | `ParseStackUnderflow()` | `@notice` | Yes | Yes |
| 140-142 | `ParenOverflow()` | `@notice` | Yes | Yes |
| 144-146 | `NoWhitespaceAfterUsingWordsFrom(uint256)` | `@notice`, `@param` | Yes | Yes |
| 148-150 | `InvalidSubParser(uint256)` | `@notice`, `@param` | Yes | Yes |
| 152-154 | `UnclosedSubParseableLiteral(uint256)` | `@notice`, `@param` | Yes | Yes |
| 156-158 | `SubParseableMissingDispatch(uint256)` | `@notice`, `@param` | Yes | Yes |
| 160-163 | `BadSubParserResult(bytes)` | `@notice`, `@param` | Yes | Yes |
| 165-167 | `OpcodeIOOverflow(uint256)` | `@notice`, `@param` | Yes | Yes |
| 169-170 | `OperandOverflow()` | `@notice` | Yes | Yes |
| 172-175 | `ParseMemoryOverflow(uint256)` | `@notice`, `@param` | Yes | Yes |
| 177-179 | `SourceItemOpsOverflow()` | `@notice` | Yes | Yes |
| 181-183 | `SourceTotalOpsOverflow()` | `@notice` | Yes | Yes |
| 185-187 | `ParenInputOverflow()` | `@notice` | Yes | Yes |
| 189-191 | `LineRHSItemsOverflow()` | `@notice` | Yes | Yes |
| 193-197 | `UppercaseHexPrefix(uint256)` | `@notice`, `@param` | Yes | Yes |
| 199-203 | `LHSItemCountOverflow(uint256)` | `@notice`, `@param` | Yes | Yes |

### ErrRainType.sol

| Line | Item | NatSpec | Tags Correct | Docs Match Impl |
|------|------|---------|--------------|-----------------|
| 5-6 | `contract ErrRainType` (workaround) | `@dev` only | Yes | Yes |
| 8-12 | `NotAnAddress(uint256)` | `@notice`, `@param` | Yes | Yes -- checked against multiple ERC20/ERC721 op libraries |

### ErrStore.sol

| Line | Item | NatSpec | Tags Correct | Docs Match Impl |
|------|------|---------|--------------|-----------------|
| 5-6 | `contract ErrStore` (workaround) | `@dev` only | Yes | Yes |
| 8-10 | `OddSetLength(uint256)` | `@notice`, `@param` | Yes | Yes -- used in `Rainterpreter.sol:64` and `RainterpreterStore.sol:52` |

### ErrSubParse.sol

| Line | Item | NatSpec | Tags Correct | Docs Match Impl |
|------|------|---------|--------------|-----------------|
| 5-6 | `contract ErrSubParse` (workaround) | `@dev` only | Yes | Yes |
| 8-11 | `ExternDispatchConstantsHeightOverflow(uint256)` | `@notice`, `@param` | Yes | Yes -- used in `LibSubParse.sol:173` |
| 13-16 | `ConstantOpcodeConstantsHeightOverflow(uint256)` | `@notice`, `@param` | Yes | Yes -- used in `LibSubParse.sol:103` |
| 18-21 | `ContextGridOverflow(uint256, uint256)` | `@notice`, `@param` x2 | Yes | Yes -- used in `LibSubParse.sol:55` |
| 23-27 | `SubParserIndexOutOfBounds(uint256, uint256)` | `@notice`, `@param` x2 | Yes | Yes -- used in `BaseRainterpreterSubParser.sol:169,203` |
| 29-33 | `SubParseLiteralDispatchLengthOverflow(uint256)` | `@notice`, `@param` | Yes | Yes -- used in `LibSubParse.sol:364` |

### IDISPaiRegistry.sol

| Line | Item | NatSpec | Tags Correct | Docs Match Impl |
|------|------|---------|--------------|-----------------|
| 5-8 | `interface IDISPaiRegistry` | `@title`, `@notice` | Yes (explicit `@notice` with `@title`) | Yes |
| 10-13 | `expressionDeployerAddress()` | `@notice`, `@return` | Yes | Yes -- returns deployer address |
| 15-17 | `interpreterAddress()` | `@notice`, `@return` | Yes | Yes -- returns interpreter address |
| 19-21 | `storeAddress()` | `@notice`, `@return` | Yes | Yes -- returns store address |
| 23-25 | `parserAddress()` | `@notice`, `@return` | Yes | Yes -- returns parser address |

## NatSpec Convention Compliance

All files were checked for the convention: "When a doc block contains any explicit tag (e.g. `@title`), all entries must be explicitly tagged."

- The workaround contracts use only `@dev` (single tag, no mixed-tag issue).
- All error definitions use explicit `@notice` and `@param` tags consistently.
- `IDISPaiRegistry.sol` uses `@title` + explicit `@notice` at the interface level, and explicit `@notice` + `@return` on each function. Compliant.

## Findings

No findings. All 11 files have complete, accurate NatSpec documentation:
- Every error has `@notice` documentation.
- Every error parameter has a `@param` tag with an accurate description.
- NatSpec descriptions match actual implementation behavior (verified against usage sites).
- The `@notice` tag is used explicitly wherever other tags are present.
- The `IDISPaiRegistry` interface functions are fully documented with `@notice` and `@return` tags.
