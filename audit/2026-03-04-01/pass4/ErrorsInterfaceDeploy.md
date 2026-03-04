# Pass 4 Findings: Error Files, IDISPaiRegistry, LibInterpreterDeploy

## Evidence Inventory

### A09: `src/error/ErrBitwise.sol`
- Contract: `ErrBitwise` (Foundry workaround, L6)
- Errors: `UnsupportedBitwiseShiftAmount(uint256)` (L13), `TruncatedBitwiseEncoding(uint256, uint256)` (L19), `ZeroLengthBitwiseEncoding()` (L23)
- No imports

### A10: `src/error/ErrDeploy.sol`
- Contract: `ErrDeploy` (Foundry workaround, L6)
- Errors: `UnknownDeploymentSuite(bytes32)` (L11)
- No imports

### A11: `src/error/ErrEval.sol`
- Contract: `ErrEval` (Foundry workaround, L6)
- Errors: `InputsLengthMismatch(uint256, uint256)` (L11), `ZeroFunctionPointers()` (L15)
- No imports

### A12: `src/error/ErrExtern.sol`
- Contract: `ErrExtern` (Foundry workaround, L8)
- Import: `NotAnExternContract` from `rain.interpreter.interface/error/ErrExtern.sol` (L5, re-export)
- Errors: `ExternOpcodeOutOfRange(uint256, uint256)` (L14), `ExternPointersMismatch(uint256, uint256)` (L20), `BadOutputsLength(uint256, uint256)` (L25), `ExternOpcodePointersEmpty()` (L28)

### A13: `src/error/ErrIntegrity.sol`
- Contract: `ErrIntegrity` (Foundry workaround, L6)
- Errors: `StackUnderflow(uint256, uint256, uint256)` (L12), `StackUnderflowHighwater(uint256, uint256, uint256)` (L18), `StackAllocationMismatch(uint256, uint256)` (L24), `StackOutputsMismatch(uint256, uint256)` (L29), `OutOfBoundsConstantRead(uint256, uint256, uint256)` (L35), `OutOfBoundsStackRead(uint256, uint256, uint256)` (L41), `CallOutputsExceedSource(uint256, uint256)` (L47), `OpcodeOutOfRange(uint256, uint256, uint256)` (L53)
- No imports

### A14: `src/error/ErrOpList.sol`
- Contract: `ErrOpList` (Foundry workaround, L6)
- Errors: `BadDynamicLength(uint256, uint256)` (L12)
- No imports

### A15: `src/error/ErrParse.sol`
- Contract: `ErrParse` (Foundry workaround, L6)
- Errors (44 total): `UnexpectedOperand()` (L10), `UnexpectedOperandValue()` (L14), `ExpectedOperand()` (L18), `OperandValuesOverflow(uint256)` (L23), `UnclosedOperand(uint256)` (L27), `UnsupportedLiteralType(uint256)` (L31), `StringTooLong(uint256)` (L35), `UnclosedStringLiteral(uint256)` (L40), `HexLiteralOverflow(uint256)` (L44), `ZeroLengthHexLiteral(uint256)` (L48), `OddLengthHexLiteral(uint256)` (L52), `MalformedHexLiteral(uint256)` (L56), `MissingFinalSemi(uint256)` (L60), `UnexpectedLHSChar(uint256)` (L64), `UnexpectedRHSChar(uint256)` (L68), `ExpectedLeftParen(uint256)` (L73), `UnexpectedRightParen(uint256)` (L77), `UnclosedLeftParen(uint256)` (L81), `UnexpectedComment(uint256)` (L85), `UnclosedComment(uint256)` (L89), `MalformedCommentStart(uint256)` (L93), `DuplicateLHSItem(uint256)` (L98), `ExcessLHSItems(uint256)` (L102), `NotAcceptingInputs(uint256)` (L106), `ExcessRHSItems(uint256)` (L110), `WordSize(string)` (L114), `UnknownWord(string)` (L118), `MaxSources()` (L121), `DanglingSource()` (L124), `ParserOutOfBounds()` (L131), `ParseStackOverflow()` (L135), `ParseStackUnderflow()` (L138), `ParenOverflow()` (L142), `NoWhitespaceAfterUsingWordsFrom(uint256)` (L146), `InvalidSubParser(uint256)` (L150), `UnclosedSubParseableLiteral(uint256)` (L154), `SubParseableMissingDispatch(uint256)` (L158), `BadSubParserResult(bytes)` (L163), `OpcodeIOOverflow(uint256)` (L167), `OperandOverflow()` (L170), `ParseMemoryOverflow(uint256)` (L175), `SourceItemOpsOverflow()` (L179), `SourceTotalOpsOverflow()` (L183), `ParenInputOverflow()` (L187), `LineRHSItemsOverflow()` (L191), `UppercaseHexPrefix(uint256)` (L197), `LHSItemCountOverflow(uint256)` (L203)
- No imports

### A16: `src/error/ErrRainType.sol`
- Contract: `ErrRainType` (Foundry workaround, L6)
- Errors: `NotAnAddress(uint256)` (L12)
- No imports

### A17: `src/error/ErrStore.sol`
- Contract: `ErrStore` (Foundry workaround, L6)
- Errors: `OddSetLength(uint256)` (L10)
- No imports

### A18: `src/error/ErrSubParse.sol`
- Contract: `ErrSubParse` (Foundry workaround, L6)
- Errors: `ExternDispatchConstantsHeightOverflow(uint256)` (L11), `ConstantOpcodeConstantsHeightOverflow(uint256)` (L16), `ContextGridOverflow(uint256, uint256)` (L21), `SubParserIndexOutOfBounds(uint256, uint256)` (L27), `SubParseLiteralDispatchLengthOverflow(uint256)` (L33)
- No imports

### A19: `src/interface/IDISPaiRegistry.sol`
- Interface: `IDISPaiRegistry` (L9)
- Functions: `expressionDeployerAddress()` (L13), `interpreterAddress()` (L17), `storeAddress()` (L21), `parserAddress()` (L25)
- All `external pure returns (address)`
- No imports

### A20: `src/lib/deploy/LibInterpreterDeploy.sol`
- Library: `LibInterpreterDeploy` (L11)
- Constants (all `internal`): `PARSER_DEPLOYED_ADDRESS` (L14), `PARSER_DEPLOYED_CODEHASH` (L20), `STORE_DEPLOYED_ADDRESS` (L25), `STORE_DEPLOYED_CODEHASH` (L31), `INTERPRETER_DEPLOYED_ADDRESS` (L36), `INTERPRETER_DEPLOYED_CODEHASH` (L42), `EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS` (L47), `EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH` (L53), `DISPAIR_REGISTRY_DEPLOYED_ADDRESS` (L58), `DISPAIR_REGISTRY_DEPLOYED_CODEHASH` (L64)
- No imports

---

## Findings

### A09-P4-1 (INFO) -- Ambiguous NatSpec wording on `UnsupportedBitwiseShiftAmount`

**File:** `src/error/ErrBitwise.sol`, lines 8-12

**Description:** The NatSpec reads "with a shift amount greater than 255 or 0." This
is ambiguous -- it can be parsed as "greater than (255 or 0)" rather than the
intended "greater than 255, or equal to 0." The actual validation logic
(`shiftAmount > type(uint8).max || shiftAmount == 0`) rejects shifts above 255
and shifts of exactly 0.

**Suggested wording:** "with a shift amount of 0 or greater than 255."

### A15-P4-1 (INFO) -- Inconsistent `@param offset` descriptions in `ErrParse.sol`

**File:** `src/error/ErrParse.sol`, lines 22, 26

**Description:** The `@param offset` on `OperandValuesOverflow` (L22) and
`UnclosedOperand` (L26) reads "The offset in the source string where the error
occurred." All other offset-bearing errors in the file (27 occurrences) read
"The byte offset in the source where the error occurred." The word "byte" is
missing from the first two, and they say "source string" instead of "source."

### A13-P4-1 (INFO) -- Mixed NatSpec voice in `ErrIntegrity.sol`

**File:** `src/error/ErrIntegrity.sol`

**Description:** The first four errors (L8, L14, L20, L26) use a descriptive
voice ("The stack underflowed...", "The bytecode stack allocation does not
match...") while the last four errors (L31, L37, L43, L49) use "Thrown when..."
voice. Within the same file, these two styles are inconsistent.

---

## Summary

No CRITICAL, HIGH, MEDIUM, or LOW findings. Three INFO-level NatSpec
consistency findings were identified. All error files use custom error types
with no string reverts. No dead code, no unused imports (the `NotAnExternContract`
re-export in `ErrExtern.sol` is consumed by `LibOpExtern.sol`). No commented-out
code. No leaky abstractions. The `IDISPaiRegistry` interface is a clean
read-only contract. `LibInterpreterDeploy` constants are generated and properly
paired (address + code hash for each component).
