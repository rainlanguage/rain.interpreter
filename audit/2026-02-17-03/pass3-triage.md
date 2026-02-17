# Pass 3 (Documentation) Triage

## MEDIUM

| ID | Status | Description |
|----|--------|-------------|
| A04-2 | PENDING | `parse2` has no meaningful NatSpec — `@inheritdoc` inherits nothing from undocumented interface |
| A06-9 | PENDING | `matchSubParseLiteralDispatch()` entirely undocumented (non-trivial function) |
| A20-3 | PENDING | LibOpMul `integrity` missing `@param`/`@return` tags |
| A20-4 | PENDING | LibOpMul `run` missing `@param`/`@return` tags |
| A20-5 | PENDING | LibOpMul `referenceFn` missing `@param`/`@return` tags |
| A20-6 | PENDING | LibOpPow `integrity` missing `@param`/`@return` tags |
| A20-7 | PENDING | LibOpPow `run` missing `@param`/`@return` tags |
| A20-8 | PENDING | LibOpPow `referenceFn` missing `@param`/`@return` tags |
| A20-9 | PENDING | LibOpSqrt `integrity` missing `@param`/`@return` tags |
| A20-10 | PENDING | LibOpSqrt `run` missing `@param`/`@return` tags |
| A20-11 | PENDING | LibOpSqrt `referenceFn` missing `@param`/`@return` tags |
| A20-12 | PENDING | LibOpSub `integrity` missing `@param`/`@return` tags |
| A20-13 | PENDING | LibOpSub `run` missing `@param`/`@return` tags |
| A20-14 | PENDING | LibOpSub `referenceFn` missing `@param`/`@return` tags |
| A25-2 | PENDING | `ParseState` struct has stale `@param literalBloom` referencing non-existent field |
| A25-3 | PENDING | `ParseState` struct missing `@param` for 8 fields |
| A28-1 | PENDING | `InterpreterState` struct has no NatSpec documentation (9 fields undocumented) |

## LOW — Struct/Type Documentation

| ID | Status | Description |
|----|--------|-------------|
| A10-1 | PENDING | `IntegrityCheckState` struct has no NatSpec |
| A25-1 | PENDING | `ParseStackTracker` user-defined type has no NatSpec |

## LOW — Documentation Inaccuracies

| ID | Status | Description |
|----|--------|-------------|
| A17-21 | PENDING | LibOpExp2 `referenceFn` NatSpec says "exp" not "exp2" |
| A18-7 | PENDING | LibOpHeadroom `run` NatSpec inaccurate (missing "point", undocumented special-case) |
| A25-5 | PENDING | `ParseState.fsm` NatSpec bit layout doesn't match actual constants |
| A28-3 | PENDING | `stackTrace` NatSpec inaccurately describes 4-byte prefix (2 fields, not 1) |
| A24-4 | PENDING | `handleOperandSingleFull` NatSpec says "used as is" but float conversion occurs |
| A24-6 | PENDING | `handleOperandDoublePerByteNoDefault` NatSpec says "used as is" but float conversion occurs |

## LOW — Missing NatSpec on Non-Opcode Functions

| ID | Status | Description |
|----|--------|-------------|
| A01-1 | PENDING | `opcodeFunctionPointers` missing `@return` tag |
| A01-2 | PENDING | `integrityFunctionPointers` missing `@return` tag |
| A02-1 | PENDING | `subParserParseMeta` missing `@return` tag |
| A02-2 | PENDING | `subParserWordParsers` missing `@return` tag |
| A02-3 | PENDING | `subParserOperandHandlers` missing `@return` tag |
| A02-4 | PENDING | `subParserLiteralParsers` missing `@return` tag |
| A02-5 | PENDING | `subParseLiteral2` `@inheritdoc` lacks implementation-specific docs |
| A02-6 | PENDING | `subParseWord2` `@inheritdoc` lacks implementation-specific docs |
| A02-7 | PENDING | `supportsInterface` override undocumented interfaces |
| A03-1 | PENDING | Constructor has no NatSpec |
| A03-2 | PENDING | `opcodeFunctionPointers()` NatSpec lacks function description |
| A03-6 | PENDING | Contract-level NatSpec uses `@notice` |
| A04-1 | PENDING | Contract-level NatSpec is title-only, no description |
| A04-3 | PENDING | `parsePragma1` missing `@param` and `@return` tags |
| A05-1 | PENDING | `unsafeParse` missing `@param` and `@return` tags |
| A05-2 | PENDING | `parsePragma1` missing `@param` and `@return` tags |
| A05-3 | PENDING | `parseMeta` missing `@return` tag |
| A05-4 | PENDING | `operandHandlerFunctionPointers` missing `@return` tag |
| A05-5 | PENDING | `literalParserFunctionPointers` missing `@return` tag |
| A05-6 | PENDING | `buildOperandHandlerFunctionPointers` missing `@return` tag |
| A05-7 | PENDING | `buildLiteralParserFunctionPointers` missing `@return` tag |
| A06-1 | PENDING | `authoringMetaV2()` lacks `@return` tag |
| A06-2 | PENDING | `describedByMetaV1()` relies solely on `@inheritdoc` |
| A06-3 | PENDING | `subParserParseMeta()` lacks `@return` tag |
| A06-4 | PENDING | `subParserWordParsers()` lacks `@return` tag |
| A06-5 | PENDING | `subParserOperandHandlers()` lacks `@return` tag |
| A06-6 | PENDING | `subParserLiteralParsers()` lacks `@return` tag |
| A06-7 | PENDING | `opcodeFunctionPointers()` lacks `@return` tag |
| A06-8 | PENDING | `integrityFunctionPointers()` lacks `@return` tag |
| A06-10 | PENDING | `buildLiteralParserFunctionPointers()` lacks `@return` tag |
| A06-11 | PENDING | `buildOperandHandlerFunctionPointers()` lacks `@return` tag |
| A06-12 | PENDING | `buildSubParserWordParsers()` lacks `@return` tag |
| A06-13 | PENDING | `buildOpcodeFunctionPointers()` lacks `@return` and `@inheritdoc` |
| A06-14 | PENDING | `buildIntegrityFunctionPointers()` lacks `@return` and `@inheritdoc` |
| A06-15 | PENDING | `supportsInterface()` lacks `@param` tag |
| A08-2 | PENDING | `eval2` NatSpec "parallel arrays of keys and values" ambiguous |
| A09-1 | PENDING | `encodeExternDispatch` missing `@param` and `@return` |
| A09-2 | PENDING | `decodeExternDispatch` missing `@param` and `@return` |
| A09-3 | PENDING | `encodeExternCall` missing `@param` and `@return` |
| A09-4 | PENDING | `decodeExternCall` missing `@param` and `@return` |
| A09-5 | PENDING | `LibExternOpContextCallingContract.subParser` missing tags |
| A09-6 | PENDING | `LibExternOpContextRainlen.subParser` missing tags |
| A09-8 | PENDING | `LibExternOpContextSender.subParser` missing tags |
| A09-9 | PENDING | `LibExternOpIntInc.run` missing tags |
| A09-10 | PENDING | `LibExternOpIntInc.integrity` missing tags |
| A09-11 | PENDING | `LibExternOpIntInc.subParser` missing tags |
| A09-12 | PENDING | `LibExternOpStackOperand.subParser` missing NatSpec entirely |
| A11-1 | PENDING | `authoringMetaV2()` missing `@return` tag |
| A11-2 | PENDING | `literalParserFunctionPointers()` missing `@return` tag |
| A11-3 | PENDING | `operandHandlerFunctionPointers()` missing `@return` tag |
| A11-4 | PENDING | `integrityFunctionPointers()` missing `@return` tag |
| A11-5 | PENDING | `opcodeFunctionPointers()` missing `@return` tag |
| A11-9 | PENDING | `LibOpContext` library-level NatSpec lacks description |
| A20-15 | PENDING | LibOpMul/LibOpSub `run` NatSpec is single word with no description |
| A23-1 | PENDING | LibParse file-level constants lack NatSpec |
| A23-3 | PENDING | `parseWord` return values unnamed in NatSpec |
| A23-4 | PENDING | `parseLHS` NatSpec omits FSM transition details |
| A23-5 | PENDING | `parseRHS` NatSpec omits significant implementation details |
| A24-5 | PENDING | `handleOperandSingleFullNoDefault` NatSpec incomplete |
| A24-7 | PENDING | `handleOperand8M1M1` NatSpec incomplete for bit layout |
| A24-8 | PENDING | `handleOperandM1M1` NatSpec incomplete for bit layout |
| A25-4 | PENDING | FSM constants `FSM_YANG_MASK`/`FSM_WORD_END_MASK` have no NatSpec |
| A25-6 | PENDING | `endLine` function NatSpec minimal |
| A25-8 | PENDING | Offset constants don't document derivation |
| A28-2 | PENDING | `STACK_TRACER` constant has no NatSpec |
| A28-5 | PENDING | `unsafeSerialize` cursor side-effect not documented |

## LOW — Error `@param` Tags (ErrParse.sol batch)

| ID | Status | Description |
|----|--------|-------------|
| A07-1 | PENDING | `BadOutputsLength` in ErrExtern.sol missing `@param` tags |
| A07-2 | PENDING | `UnsupportedLiteralType` missing `@param` |
| A07-3 | PENDING | `StringTooLong` missing `@param` |
| A07-4 | PENDING | `UnclosedStringLiteral` missing `@param` |
| A07-5 | PENDING | `HexLiteralOverflow` missing `@param` |
| A07-6 | PENDING | `ZeroLengthHexLiteral` missing `@param` |
| A07-7 | PENDING | `OddLengthHexLiteral` missing `@param` |
| A07-8 | PENDING | `MalformedHexLiteral` missing `@param` |
| A07-9 | PENDING | `MalformedExponentDigits` missing `@param` |
| A07-10 | PENDING | `MalformedDecimalPoint` missing `@param` |
| A07-11 | PENDING | `MissingFinalSemi` missing `@param` |
| A07-12 | PENDING | `UnexpectedLHSChar` missing `@param` |
| A07-13 | PENDING | `UnexpectedRHSChar` missing `@param` |
| A07-14 | PENDING | `ExpectedLeftParen` missing `@param` |
| A07-15 | PENDING | `UnexpectedRightParen` missing `@param` |
| A07-16 | PENDING | `UnclosedLeftParen` missing `@param` |
| A07-17 | PENDING | `UnexpectedComment` missing `@param` |
| A07-18 | PENDING | `UnclosedComment` missing `@param` |
| A07-19 | PENDING | `MalformedCommentStart` missing `@param` |
| A07-20 | PENDING | `ExcessLHSItems` missing `@param` |
| A07-21 | PENDING | `NotAcceptingInputs` missing `@param` |
| A07-22 | PENDING | `ExcessRHSItems` missing `@param` |
| A07-23 | PENDING | `WordSize` missing `@param word` |
| A07-24 | PENDING | `UnknownWord` missing `@param word` |
| A07-25 | PENDING | `NoWhitespaceAfterUsingWordsFrom` missing `@param` |
| A07-26 | PENDING | `InvalidSubParser` missing `@param` |
| A07-27 | PENDING | `UnclosedSubParseableLiteral` missing `@param` |
| A07-28 | PENDING | `SubParseableMissingDispatch` missing `@param` |
| A07-29 | PENDING | `BadSubParserResult` missing `@param bytecode` |
| A07-30 | PENDING | `OpcodeIOOverflow` missing `@param` |

## LOW — Opcode Library `@param`/`@return` Tags (Systematic)

All opcode libraries follow the same pattern: `integrity`, `run`, `referenceFn` have descriptions but no `@param`/`@return` tags.

| ID | Status | Description |
|----|--------|-------------|
| A11-6 | PENDING | LibOpConstant.integrity missing tags |
| A11-7 | PENDING | LibOpConstant.run missing tags |
| A11-8 | PENDING | LibOpConstant.referenceFn missing tags |
| A11-10 | PENDING | LibOpContext.integrity missing tags |
| A11-11 | PENDING | LibOpContext.run missing tags |
| A11-12 | PENDING | LibOpContext.referenceFn missing tags |
| A11-13 | PENDING | LibOpExtern.integrity missing tags |
| A11-14 | PENDING | LibOpExtern.run missing tags |
| A11-15 | PENDING | LibOpExtern.referenceFn missing tags |
| A11-16 | PENDING | LibOpStack.integrity missing tags |
| A11-17 | PENDING | LibOpStack.run missing tags |
| A11-18 | PENDING | LibOpStack.referenceFn missing tags |
| A12-1 | PENDING | LibOpBitwiseAnd integrity missing tags |
| A12-2 | PENDING | LibOpBitwiseAnd run missing tags |
| A12-3 | PENDING | LibOpBitwiseAnd referenceFn missing tags |
| A12-4 | PENDING | LibOpBitwiseOr integrity missing tags |
| A12-5 | PENDING | LibOpBitwiseOr run missing tags |
| A12-6 | PENDING | LibOpBitwiseOr referenceFn missing tags |
| A12-7 | PENDING | LibOpCtPop integrity missing tags |
| A12-8 | PENDING | LibOpCtPop run missing tags |
| A12-9 | PENDING | LibOpCtPop referenceFn missing tags |
| A12-10 | PENDING | LibOpDecodeBits integrity missing tags |
| A12-11 | PENDING | LibOpDecodeBits run missing tags |
| A12-12 | PENDING | LibOpDecodeBits referenceFn missing tags |
| A12-13 | PENDING | LibOpEncodeBits integrity missing tags |
| A12-14 | PENDING | LibOpEncodeBits run missing tags |
| A12-15 | PENDING | LibOpEncodeBits referenceFn missing tags |
| A12-16 | PENDING | LibOpShiftBitsLeft integrity missing tags |
| A12-17 | PENDING | LibOpShiftBitsLeft run missing tags |
| A12-18 | PENDING | LibOpShiftBitsLeft referenceFn missing tags |
| A12-19 | PENDING | LibOpShiftBitsRight integrity missing tags |
| A12-20 | PENDING | LibOpShiftBitsRight run missing tags |
| A12-21 | PENDING | LibOpShiftBitsRight referenceFn missing tags |
| A13-1 | PENDING | LibOpHash integrity missing tags |
| A13-2 | PENDING | LibOpHash run missing tags |
| A13-3 | PENDING | LibOpHash referenceFn missing tags |
| A13-4 | PENDING | LibOpERC20Allowance integrity missing tags |
| A13-5 | PENDING | LibOpERC20Allowance run missing tags |
| A13-6 | PENDING | LibOpERC20Allowance referenceFn missing tags |
| A13-7 | PENDING | LibOpERC20BalanceOf integrity missing tags |
| A13-8 | PENDING | LibOpERC20BalanceOf run missing tags |
| A13-9 | PENDING | LibOpERC20BalanceOf referenceFn missing tags |
| A13-10 | PENDING | LibOpERC20TotalSupply integrity missing tags |
| A13-11 | PENDING | LibOpERC20TotalSupply run missing tags |
| A13-12 | PENDING | LibOpERC20TotalSupply referenceFn missing tags |
| A13-13 | PENDING | LibOpUint256ERC20Allowance integrity missing tags |
| A13-14 | PENDING | LibOpUint256ERC20Allowance run missing tags |
| A13-15 | PENDING | LibOpUint256ERC20Allowance referenceFn missing tags |
| A13-16 | PENDING | LibOpUint256ERC20BalanceOf `@title` missing `Lib` prefix |
| A13-17 | PENDING | LibOpUint256ERC20BalanceOf integrity missing tags |
| A13-18 | PENDING | LibOpUint256ERC20BalanceOf run missing tags |
| A13-19 | PENDING | LibOpUint256ERC20BalanceOf referenceFn missing tags |
| A13-20 | PENDING | LibOpUint256ERC20TotalSupply integrity missing tags |
| A13-21 | PENDING | LibOpUint256ERC20TotalSupply run missing tags |
| A13-22 | PENDING | LibOpUint256ERC20TotalSupply referenceFn missing tags |
| A14-1 | PENDING | All 7 `integrity` functions missing tags |
| A14-2 | PENDING | All 7 `run` functions missing tags |
| A14-3 | PENDING | All 7 `referenceFn` functions missing tags |
| A14-7 | PENDING | Unnamed function parameters prevent formal tags |
| A15-1 | PENDING | LibOpAny.integrity missing tags |
| A15-2 | PENDING | LibOpAny.run missing tags |
| A15-3 | PENDING | LibOpAny.referenceFn missing tags |
| A15-4 | PENDING | LibOpBinaryEqualTo.integrity missing NatSpec entirely |
| A15-5 | PENDING | LibOpBinaryEqualTo.run missing tags |
| A15-6 | PENDING | LibOpBinaryEqualTo.referenceFn missing tags |
| A15-8 | PENDING | LibOpConditions.integrity missing NatSpec entirely |
| A15-9 | PENDING | LibOpConditions.run missing tags |
| A15-10 | PENDING | LibOpConditions.referenceFn missing tags |
| A15-11 | PENDING | LibOpEnsure.integrity missing NatSpec entirely |
| A15-12 | PENDING | LibOpEnsure.run missing tags |
| A15-13 | PENDING | LibOpEnsure.referenceFn missing tags |
| A15-14 | PENDING | LibOpEqualTo.integrity missing tags |
| A15-15 | PENDING | LibOpEqualTo.run missing tags |
| A15-16 | PENDING | LibOpEqualTo.referenceFn missing tags |
| A15-17 | PENDING | LibOpEvery.integrity missing tags |
| A15-18 | PENDING | LibOpEvery.run missing tags |
| A15-19 | PENDING | LibOpEvery.referenceFn missing tags |
| A16-1 | PENDING | LibOpGreaterThan integrity missing tags |
| A16-2 | PENDING | LibOpGreaterThan run missing tags |
| A16-3 | PENDING | LibOpGreaterThan referenceFn missing tags |
| A16-4 | PENDING | LibOpGreaterThanOrEqualTo integrity missing tags |
| A16-5 | PENDING | LibOpGreaterThanOrEqualTo run missing tags |
| A16-6 | PENDING | LibOpGreaterThanOrEqualTo referenceFn missing tags |
| A16-7 | PENDING | LibOpIf integrity completely missing NatSpec |
| A16-8 | PENDING | LibOpIf run missing tags |
| A16-9 | PENDING | LibOpIf referenceFn missing tags |
| A16-10 | PENDING | LibOpIsZero integrity missing tags |
| A16-11 | PENDING | LibOpIsZero run missing tags |
| A16-12 | PENDING | LibOpIsZero referenceFn missing tags |
| A16-13 | PENDING | LibOpLessThan integrity missing tags |
| A16-14 | PENDING | LibOpLessThan run missing tags |
| A16-15 | PENDING | LibOpLessThan referenceFn missing tags |
| A16-16 | PENDING | LibOpLessThanOrEqualTo integrity missing tags |
| A16-17 | PENDING | LibOpLessThanOrEqualTo run missing tags |
| A16-18 | PENDING | LibOpLessThanOrEqualTo referenceFn missing tags |
| A17-1 | PENDING | LibOpAbs integrity missing tags |
| A17-2 | PENDING | LibOpAbs run missing tags |
| A17-3 | PENDING | LibOpAbs referenceFn missing tags |
| A17-4 | PENDING | LibOpAdd integrity missing tags |
| A17-5 | PENDING | LibOpAdd run missing tags |
| A17-6 | PENDING | LibOpAdd referenceFn missing tags |
| A17-7 | PENDING | LibOpAvg integrity missing tags |
| A17-8 | PENDING | LibOpAvg run missing tags |
| A17-9 | PENDING | LibOpAvg referenceFn missing tags |
| A17-10 | PENDING | LibOpCeil integrity missing tags |
| A17-11 | PENDING | LibOpCeil run missing tags |
| A17-12 | PENDING | LibOpCeil referenceFn missing tags |
| A17-13 | PENDING | LibOpDiv integrity missing tags |
| A17-14 | PENDING | LibOpDiv run missing tags |
| A17-15 | PENDING | LibOpDiv referenceFn missing tags |
| A17-16 | PENDING | LibOpE integrity missing tags |
| A17-17 | PENDING | LibOpE run missing tags |
| A17-18 | PENDING | LibOpE referenceFn missing tags |
| A17-22 | PENDING | LibOpExp2 integrity missing tags |
| A17-23 | PENDING | LibOpExp2 run missing tags |
| A17-24 | PENDING | LibOpExp2 referenceFn missing tags |
| A17-25 | PENDING | LibOpExp integrity missing tags |
| A17-26 | PENDING | LibOpExp run missing tags |
| A17-27 | PENDING | LibOpExp referenceFn missing tags |
| A18-1 | PENDING | LibOpFrac `@notice` usage |
| A18-2 | PENDING | LibOpGm `@notice` usage |
| A18-3 | PENDING | LibOpInv `@notice` usage |
| A19-1 | PENDING | LibOpMax integrity missing tags |
| A19-2 | PENDING | LibOpMax run missing tags |
| A19-3 | PENDING | LibOpMax referenceFn missing tags |
| A19-4 | PENDING | LibOpMaxNegativeValue integrity missing tags |
| A19-5 | PENDING | LibOpMaxNegativeValue run missing tags |
| A19-6 | PENDING | LibOpMaxNegativeValue referenceFn missing tags |
| A19-7 | PENDING | LibOpMaxPositiveValue integrity missing tags |
| A19-8 | PENDING | LibOpMaxPositiveValue run missing tags |
| A19-9 | PENDING | LibOpMaxPositiveValue referenceFn missing tags |
| A19-10 | PENDING | LibOpMin integrity missing tags |
| A19-11 | PENDING | LibOpMin run missing tags |
| A19-12 | PENDING | LibOpMin referenceFn missing tags |
| A19-13 | PENDING | LibOpMinNegativeValue integrity missing tags |
| A19-14 | PENDING | LibOpMinNegativeValue run missing tags |
| A19-15 | PENDING | LibOpMinNegativeValue referenceFn missing tags |
| A19-16 | PENDING | LibOpMinPositiveValue integrity missing tags |
| A19-17 | PENDING | LibOpMinPositiveValue run missing tags |
| A19-18 | PENDING | LibOpMinPositiveValue referenceFn missing tags |
| A20-1 | PENDING | LibOpPow `@notice` usage |
| A20-2 | PENDING | LibOpSqrt `@notice` usage |
| A21-1 | PENDING | LibOpExponentialGrowth integrity missing tags |
| A21-2 | PENDING | LibOpExponentialGrowth run missing tags |
| A21-3 | PENDING | LibOpExponentialGrowth referenceFn missing tags |
| A21-4 | PENDING | LibOpLinearGrowth integrity missing tags |
| A21-5 | PENDING | LibOpLinearGrowth run missing tags |
| A21-6 | PENDING | LibOpLinearGrowth referenceFn missing tags |
| A21-8 | PENDING | LibOpMaxUint256 integrity missing tags |
| A21-9 | PENDING | LibOpMaxUint256 run missing tags |
| A21-10 | PENDING | LibOpMaxUint256 referenceFn missing tags |
| A21-11 | PENDING | LibOpUint256Add integrity missing tags |
| A21-12 | PENDING | LibOpUint256Add run missing tags |
| A21-13 | PENDING | LibOpUint256Add referenceFn missing tags |
| A21-14 | PENDING | LibOpUint256Div integrity missing tags |
| A21-15 | PENDING | LibOpUint256Div run missing tags |
| A21-16 | PENDING | LibOpUint256Div referenceFn missing tags |
| A21-17 | PENDING | LibOpUint256Mul integrity missing tags |
| A21-18 | PENDING | LibOpUint256Mul run missing tags |
| A21-19 | PENDING | LibOpUint256Mul referenceFn missing tags |
| A21-20 | PENDING | LibOpUint256Pow integrity missing tags |
| A21-21 | PENDING | LibOpUint256Pow run missing tags |
| A21-22 | PENDING | LibOpUint256Pow referenceFn missing tags |
| A21-23 | PENDING | LibOpUint256Sub integrity missing tags |
| A21-24 | PENDING | LibOpUint256Sub run missing tags |
| A21-25 | PENDING | LibOpUint256Sub referenceFn missing tags |
| A22-1 | PENDING | LibOpGet integrity missing tags |
| A22-2 | PENDING | LibOpGet run missing tags |
| A22-3 | PENDING | LibOpGet referenceFn missing tags |
| A22-4 | PENDING | LibOpSet integrity missing tags |
| A22-5 | PENDING | LibOpSet run missing tags |
| A22-6 | PENDING | LibOpSet referenceFn missing tags |

## LOW — Literal Parse Lib `@param`/`@return` Tags

| ID | Status | Description |
|----|--------|-------------|
| A27-1 | PENDING | `selectLiteralParserByIndex` missing tags |
| A27-2 | PENDING | `parseLiteral` missing tags |
| A27-3 | PENDING | `tryParseLiteral` missing tags |
| A27-4 | PENDING | `parseDecimalFloatPacked` missing tags |
| A27-5 | PENDING | `boundHex` missing tags |
| A27-6 | PENDING | `parseHex` missing tags |
| A27-7 | PENDING | `boundString` missing tags |
| A27-9 | PENDING | `parseString` missing tags |
| A27-10 | PENDING | `parseSubParseable` missing tags |
