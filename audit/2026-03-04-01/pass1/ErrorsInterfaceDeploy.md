# Pass 1 -- Security: Error Files, IDISPaiRegistry, LibInterpreterDeploy (A09-A20)

## A09 -- `src/error/ErrBitwise.sol`

### Evidence

| Item | Kind | Line |
|------|------|------|
| `ErrBitwise` | workaround contract | 6 |
| `UnsupportedBitwiseShiftAmount(uint256)` | custom error | 13 |
| `TruncatedBitwiseEncoding(uint256, uint256)` | custom error | 19 |
| `ZeroLengthBitwiseEncoding()` | custom error | 23 |

### Analysis

All errors are custom error types. No string reverts. NatSpec uses `@notice` and
`@param` tags on all errors. The workaround contract has a `@dev` explaining the
Foundry issue link. No security concerns.

---

## A10 -- `src/error/ErrDeploy.sol`

### Evidence

| Item | Kind | Line |
|------|------|------|
| `ErrDeploy` | workaround contract | 6 |
| `UnknownDeploymentSuite(bytes32)` | custom error | 11 |

### Analysis

Single custom error type. No string reverts. NatSpec is complete with `@notice`
and `@param`. No security concerns.

---

## A11 -- `src/error/ErrEval.sol`

### Evidence

| Item | Kind | Line |
|------|------|------|
| `ErrEval` | workaround contract | 6 |
| `InputsLengthMismatch(uint256, uint256)` | custom error | 11 |
| `ZeroFunctionPointers()` | custom error | 15 |

### Analysis

All errors are custom error types. No string reverts. `InputsLengthMismatch`
provides expected vs actual counts for diagnostics. `ZeroFunctionPointers`
guards against mod-by-zero in the eval loop. NatSpec is complete. No security
concerns.

---

## A12 -- `src/error/ErrExtern.sol`

### Evidence

| Item | Kind | Line |
|------|------|------|
| `ErrExtern` | workaround contract | 8 |
| import `NotAnExternContract` | re-export from `rain.interpreter.interface` | 5 |
| `ExternOpcodeOutOfRange(uint256, uint256)` | custom error | 14 |
| `ExternPointersMismatch(uint256, uint256)` | custom error | 20 |
| `BadOutputsLength(uint256, uint256)` | custom error | 25 |
| `ExternOpcodePointersEmpty()` | custom error | 28 |

### Analysis

All locally-defined errors are custom error types. No string reverts.
`NotAnExternContract` is imported from the interface package and re-exported so
that downstream files (`LibOpExtern.sol`) can import from this single location.
NatSpec is complete on all local errors. No security concerns.

---

## A13 -- `src/error/ErrIntegrity.sol`

### Evidence

| Item | Kind | Line |
|------|------|------|
| `ErrIntegrity` | workaround contract | 6 |
| `StackUnderflow(uint256, uint256, uint256)` | custom error | 12 |
| `StackUnderflowHighwater(uint256, uint256, uint256)` | custom error | 18 |
| `StackAllocationMismatch(uint256, uint256)` | custom error | 24 |
| `StackOutputsMismatch(uint256, uint256)` | custom error | 29 |
| `OutOfBoundsConstantRead(uint256, uint256, uint256)` | custom error | 35 |
| `OutOfBoundsStackRead(uint256, uint256, uint256)` | custom error | 41 |
| `CallOutputsExceedSource(uint256, uint256)` | custom error | 47 |
| `OpcodeOutOfRange(uint256, uint256, uint256)` | custom error | 53 |

### Analysis

All eight errors are custom error types with meaningful parameters for
diagnostics. No string reverts. NatSpec tags are consistent (`@notice` +
`@param` on each). These guard the integrity check phase which is a critical
security boundary -- every error provides enough context (opIndex, stack
positions, bounds) for debugging. No security concerns.

---

## A14 -- `src/error/ErrOpList.sol`

### Evidence

| Item | Kind | Line |
|------|------|------|
| `ErrOpList` | workaround contract | 6 |
| `BadDynamicLength(uint256, uint256)` | custom error | 12 |

### Analysis

Single custom error type. No string reverts. NatSpec complete. The error guards
against inconsistent array lengths in the opcode registration system. No
security concerns.

---

## A15 -- `src/error/ErrParse.sol`

### Evidence

| Item | Kind | Line |
|------|------|------|
| `ErrParse` | workaround contract | 6 |
| `UnexpectedOperand()` | custom error | 10 |
| `UnexpectedOperandValue()` | custom error | 14 |
| `ExpectedOperand()` | custom error | 18 |
| `OperandValuesOverflow(uint256)` | custom error | 23 |
| `UnclosedOperand(uint256)` | custom error | 27 |
| `UnsupportedLiteralType(uint256)` | custom error | 31 |
| `StringTooLong(uint256)` | custom error | 35 |
| `UnclosedStringLiteral(uint256)` | custom error | 40 |
| `HexLiteralOverflow(uint256)` | custom error | 44 |
| `ZeroLengthHexLiteral(uint256)` | custom error | 48 |
| `OddLengthHexLiteral(uint256)` | custom error | 52 |
| `MalformedHexLiteral(uint256)` | custom error | 56 |
| `MissingFinalSemi(uint256)` | custom error | 60 |
| `UnexpectedLHSChar(uint256)` | custom error | 64 |
| `UnexpectedRHSChar(uint256)` | custom error | 68 |
| `ExpectedLeftParen(uint256)` | custom error | 73 |
| `UnexpectedRightParen(uint256)` | custom error | 77 |
| `UnclosedLeftParen(uint256)` | custom error | 81 |
| `UnexpectedComment(uint256)` | custom error | 85 |
| `UnclosedComment(uint256)` | custom error | 89 |
| `MalformedCommentStart(uint256)` | custom error | 93 |
| `DuplicateLHSItem(uint256)` | custom error | 98 |
| `ExcessLHSItems(uint256)` | custom error | 102 |
| `NotAcceptingInputs(uint256)` | custom error | 106 |
| `ExcessRHSItems(uint256)` | custom error | 110 |
| `WordSize(string)` | custom error | 114 |
| `UnknownWord(string)` | custom error | 118 |
| `MaxSources()` | custom error | 121 |
| `DanglingSource()` | custom error | 124 |
| `ParserOutOfBounds()` | custom error | 131 |
| `ParseStackOverflow()` | custom error | 135 |
| `ParseStackUnderflow()` | custom error | 138 |
| `ParenOverflow()` | custom error | 142 |
| `NoWhitespaceAfterUsingWordsFrom(uint256)` | custom error | 146 |
| `InvalidSubParser(uint256)` | custom error | 150 |
| `UnclosedSubParseableLiteral(uint256)` | custom error | 154 |
| `SubParseableMissingDispatch(uint256)` | custom error | 158 |
| `BadSubParserResult(bytes)` | custom error | 163 |
| `OpcodeIOOverflow(uint256)` | custom error | 167 |
| `OperandOverflow()` | custom error | 170 |
| `ParseMemoryOverflow(uint256)` | custom error | 175 |
| `SourceItemOpsOverflow()` | custom error | 179 |
| `SourceTotalOpsOverflow()` | custom error | 183 |
| `ParenInputOverflow()` | custom error | 187 |
| `LineRHSItemsOverflow()` | custom error | 191 |
| `UppercaseHexPrefix(uint256)` | custom error | 197 |
| `LHSItemCountOverflow(uint256)` | custom error | 203 |

### Analysis

All 44 errors are custom error types. No string reverts. NatSpec is complete on
every error -- each has `@notice` and `@param` where parameters exist. Offset
parameters consistently use `uint256` to report byte positions in the source
string. `WordSize` and `UnknownWord` use `string` parameters to report the
offending word. `BadSubParserResult` uses `bytes` to report the offending
bytecode.

`ParserOutOfBounds` (line 131) is documented as a defensive guard that is
unreachable under normal operation and cannot be tested without mocking. This is
an appropriate defensive check.

No security concerns.

---

## A16 -- `src/error/ErrRainType.sol`

### Evidence

| Item | Kind | Line |
|------|------|------|
| `ErrRainType` | workaround contract | 6 |
| `NotAnAddress(uint256)` | custom error | 12 |

### Analysis

Single custom error type. No string reverts. NatSpec explains the validation
rationale clearly -- the upper 96 bits being non-zero indicates the value is not
a valid Ethereum address. No security concerns.

---

## A17 -- `src/error/ErrStore.sol`

### Evidence

| Item | Kind | Line |
|------|------|------|
| `ErrStore` | workaround contract | 6 |
| `OddSetLength(uint256)` | custom error | 10 |

### Analysis

Single custom error type. No string reverts. NatSpec complete. Guards against
misaligned key/value pairs in store set operations. No security concerns.

---

## A18 -- `src/error/ErrSubParse.sol`

### Evidence

| Item | Kind | Line |
|------|------|------|
| `ErrSubParse` | workaround contract | 6 |
| `ExternDispatchConstantsHeightOverflow(uint256)` | custom error | 11 |
| `ConstantOpcodeConstantsHeightOverflow(uint256)` | custom error | 16 |
| `ContextGridOverflow(uint256, uint256)` | custom error | 21 |
| `SubParserIndexOutOfBounds(uint256, uint256)` | custom error | 27 |
| `SubParseLiteralDispatchLengthOverflow(uint256)` | custom error | 33 |

### Analysis

All five errors are custom error types. No string reverts. NatSpec is complete
with `@notice` and `@param` on each. These errors guard against overflow
conditions in sub-parser operations -- `ExternDispatchConstantsHeightOverflow`
and `ConstantOpcodeConstantsHeightOverflow` protect against single-byte and
16-bit encoding overflows respectively. `SubParseLiteralDispatchLengthOverflow`
prevents silent truncation of dispatch lengths above 0xFFFF. No security
concerns.

---

## A19 -- `src/interface/IDISPaiRegistry.sol`

### Evidence

| Item | Kind | Line |
|------|------|------|
| `IDISPaiRegistry` | interface | 9 |
| `expressionDeployerAddress()` | external pure function | 13 |
| `interpreterAddress()` | external pure function | 17 |
| `storeAddress()` | external pure function | 21 |
| `parserAddress()` | external pure function | 25 |

### Analysis

Minimal read-only interface with four `external pure` getters returning
`address`. No state mutations, no events, no errors, no access control needed.
NatSpec uses `@title`, `@notice`, and `@return` tags consistently. All functions
are `pure` which is correct since the implementation returns compile-time
constants.

The interface covers the four components (Deployer, Interpreter, Store, Parser).
The registry contract name includes "DISPaiR" (five components including the
Registry itself), but the interface only exposes the four non-self components,
which is correct -- the registry's own address is known by the caller.

No security concerns.

---

## A20 -- `src/lib/deploy/LibInterpreterDeploy.sol`

### Evidence

| Item | Kind | Line |
|------|------|------|
| `LibInterpreterDeploy` | library | 11 |
| `PARSER_DEPLOYED_ADDRESS` | address constant | 14 |
| `PARSER_DEPLOYED_CODEHASH` | bytes32 constant | 20-21 |
| `STORE_DEPLOYED_ADDRESS` | address constant | 25 |
| `STORE_DEPLOYED_CODEHASH` | bytes32 constant | 31-32 |
| `INTERPRETER_DEPLOYED_ADDRESS` | address constant | 36 |
| `INTERPRETER_DEPLOYED_CODEHASH` | bytes32 constant | 42-43 |
| `EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS` | address constant | 47 |
| `EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH` | bytes32 constant | 53-54 |
| `DISPAIR_REGISTRY_DEPLOYED_ADDRESS` | address constant | 58 |
| `DISPAIR_REGISTRY_DEPLOYED_CODEHASH` | bytes32 constant | 64-65 |

### Analysis

**Nature of constants:** These are deterministic deploy addresses and bytecode
hashes for contracts deployed via the Zoltu deployer pattern. They are public
deployment information, not secrets. The addresses are derived deterministically
from the deployer address and contract bytecode, and the code hashes are the
keccak256 of the deployed bytecode. Both are verifiable on-chain.

**Constant management:** These values are regenerated by the build pipeline
(`BuildPointers.sol`) and verified in tests (`LibInterpreterDeployTest`). The
cascade order (parser -> expression deployer -> DISPaiRegistry) ensures
consistency.

**NatSpec:** The library-level doc block uses `@title` and `@notice`. Each
constant's doc block uses untagged `///` lines (no explicit tags), which means
implicit `@notice`. Since no explicit tags appear within any individual
constant's doc block, the implicit `@notice` rule applies correctly. NatSpec is
well-formed.

**Visibility:** All constants have default `internal` visibility, which is
correct for library constants accessed via `LibInterpreterDeploy.CONSTANT_NAME`.

**Address/hash pairing:** Each component has both an address and a code hash
constant, allowing consumers to verify both the deployment address and the
bytecode integrity. This dual-verification pattern is a security strength.

No security concerns.

---

## Findings

No LOW+ findings across any of the twelve files reviewed.

All error definitions use custom error types with no string reverts. All NatSpec
is well-formed. The interface is a minimal read-only specification. The deploy
constants are public deterministic deployment information with appropriate
dual-verification (address + code hash) for each component.
