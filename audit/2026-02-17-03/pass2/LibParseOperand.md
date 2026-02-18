# Pass 2: Test Coverage -- LibParseOperand

## Evidence of Thorough Reading

### Source: `src/lib/parse/LibParseOperand.sol`

- **Library**: `LibParseOperand`
- **Functions**:
  - `parseOperand(ParseState memory, uint256 cursor, uint256 end) returns (uint256)` -- line 35
  - `handleOperand(ParseState memory, uint256 wordIndex) returns (OperandV2)` -- line 136
  - `handleOperandDisallowed(bytes32[] memory) returns (OperandV2)` -- line 153
  - `handleOperandDisallowedAlwaysOne(bytes32[] memory) returns (OperandV2)` -- line 164
  - `handleOperandSingleFull(bytes32[] memory) returns (OperandV2)` -- line 177
  - `handleOperandSingleFullNoDefault(bytes32[] memory) returns (OperandV2)` -- line 199
  - `handleOperandDoublePerByteNoDefault(bytes32[] memory) returns (OperandV2)` -- line 222
  - `handleOperand8M1M1(bytes32[] memory) returns (OperandV2)` -- line 255
  - `handleOperandM1M1(bytes32[] memory) returns (OperandV2)` -- line 306
- **Errors used** (imported from `ErrParse.sol`):
  - `ExpectedOperand()` -- lines 212, 242, 296
  - `UnclosedOperand(uint256)` -- lines 111, 115
  - `OperandValuesOverflow(uint256)` -- line 88
  - `UnexpectedOperand()` -- lines 155, 165
  - `UnexpectedOperandValue()` -- lines 192, 214, 245, 298, 341
  - `OperandOverflow()` -- lines 186, 207, 238, 291, 336

### Test Files

1. **`test/src/lib/parse/LibParseOperand.parseOperand.t.sol`**
   - Contract: `LibParseOperandParseOperandTest`
   - Functions:
     - `checkParsingOperandFromData(string, bytes32[], uint256)` -- line 21 (helper)
     - `testParseOperandNoOpeningCharacter(string)` -- line 46
     - `testParseOperandEmptyOperand(string)` -- line 57
     - `testParseOperandSingleDecimalLiteral(bool, int256, string, string, string)` -- line 67
     - `testParseOperandTwoDecimalLiterals(...)` -- line 99
     - `testParseOperandThreeDecimalLiterals(...)` -- line 147
     - `testParseOperandFourDecimalLiterals(...)` -- line 213
     - `testParseOperandTooManyValues()` -- line 274
     - `testParseOperandUnclosed()` -- line 280
     - `testParseOperandUnexpectedChars()` -- line 286

2. **`test/src/lib/parse/LibParseOperand.handleOperandDisallowed.t.sol`**
   - Contract: `LibParseOperandHandleOperandDisallowedTest`
   - Functions:
     - `handleOperandDisallowedExternal(bytes32[])` -- line 10 (helper)
     - `testHandleOperandDisallowedNoValues()` -- line 14
     - `testHandleOperandDisallowedAnyValues(bytes32[])` -- line 18

3. **`test/src/lib/parse/LibParseOperand.handleOperandSingleFull.t.sol`**
   - Contract: `LibParseOperandHandleOperandSingleFullTest`
   - Functions:
     - `handleOperandSingleFullExternal(bytes32[])` -- line 11 (helper)
     - `testHandleOperandSingleFullNoValues()` -- line 16
     - `testHandleOperandSingleFullSingleValue(uint256)` -- line 21
     - `testHandleOperandSingleFullSingleValueDisallowed(uint256)` -- line 29
     - `testHandleOperandSingleFullManyValues(bytes32[])` -- line 38

4. **`test/src/lib/parse/LibParseOperand.handleOperandSingleFullNoDefault.t.sol`**
   - Contract: `LibParseOperandHandleOperandSingleFullTest`
   - Functions:
     - `handleOperandSingleFullNoDefaultExternal(bytes32[])` -- line 11 (helper)
     - `testHandleOperandSingleFullNoDefaultNoValues()` -- line 16
     - `testHandleOperandSingleFullNoDefaultSingleValue(uint256)` -- line 22
     - `testHandleOperandSingleFullSingleValueNoDefaultDisallowed(uint256)` -- line 30
     - `testHandleOperandSingleFullNoDefaultManyValues(bytes32[])` -- line 40

5. **`test/src/lib/parse/LibParseOperand.handleOperandDoublePerByteNoDefault.t.sol`**
   - Contract: `LibParseOperandHandleOperandDoublePerByteNoDefaultTest`
   - Functions:
     - `handleOperandDoublePerByteNoDefaultExternal(bytes32[])` -- line 11 (helper)
     - `testHandleOperandDoublePerByteNoDefaultNoValues()` -- line 16
     - `testHandleOperandDoublePerByteNoDefaultOneValue(uint256)` -- line 22
     - `testHandleOperandDoublePerByteNoDefaultManyValues(bytes32[])` -- line 31
     - `testHandleOperandDoublePerByteNoDefaultFirstValueTooLarge(uint256, uint256)` -- line 38
     - `testHandleOperandDoublePerByteNoDefaultSecondValueTooLarge(uint256, uint256)` -- line 51
     - `testHandleOperandDoublePerByteNoDefaultBothValuesWithinOneByte(uint256, uint256)` -- line 65

6. **`test/src/lib/parse/LibParseOperand.handleOperand8M1M1.t.sol`**
   - Contract: `LibParseOperandHandleOperand8M1M1Test`
   - Functions:
     - `handleOperand8M1M1External(bytes32[])` -- line 12 (helper)
     - `testHandleOperand8M1M1NoValues()` -- line 17
     - `testHandleOperand8M1M1FirstValueOnly(uint256)` -- line 23
     - `testHandleOperand8M1M1FirstValueTooLarge(int256)` -- line 31
     - `testHandleOperand8M1M1FirstAndSecondValue(uint256, uint256)` -- line 44
     - `testHandleOperand8M1M1FirstAndSecondValueSecondValueTooLarge(uint256, uint256)` -- line 55
     - `testHandleOperand8M1M1AllValues(uint256, uint256, uint256)` -- line 68
     - `testHandleOperand8M1M1AllValuesThirdValueTooLarge(uint256, uint256, uint256)` -- line 81
     - `testHandleOperand8M1M1ManyValues(bytes32[])` -- line 95

7. **`test/src/lib/parse/LibParseOperand.handleOperandM1M1.t.sol`**
   - Contract: `LibParseOperandHandleOperandM1M1Test`
   - Functions:
     - `handleOperandM1M1External(bytes32[])` -- line 12 (helper)
     - `testHandleOperandM1M1NoValues()` -- line 18
     - `testHandleOperandM1M1OneValue(uint256)` -- line 23
     - `testHandleOperandM1M1OneValueTooLarge(uint256)` -- line 31
     - `testHandleOperandM1M1TwoValues(uint256, uint256)` -- line 41
     - `testHandleOperandM1M1TwoValuesSecondValueTooLarge(uint256, uint256)` -- line 52
     - `testHandleOperandM1M1ManyValues(bytes32[])` -- line 64

## Findings

### A39-1: `handleOperandDisallowedAlwaysOne` has no test file or any test coverage [MEDIUM]

The function `handleOperandDisallowedAlwaysOne` (line 164) has no dedicated test file and no test references anywhere in the test suite. A grep for `DisallowedAlwaysOne` across the entire repository returns only the source definition. Furthermore, this function is not referenced anywhere in the `src/` tree either -- it appears to be dead code. It has two code paths:
1. Happy path: `values.length == 0` returns `OperandV2.wrap(bytes32(uint256(1)))` -- untested.
2. Revert path: `values.length != 0` reverts with `UnexpectedOperand()` -- untested.

Neither path is exercised by any test.

### A39-2: `handleOperand` (dispatch function) has no direct unit test [LOW]

The function `handleOperand(ParseState memory, uint256 wordIndex)` (line 136) has no direct test file. It is called from `LibParse.sol` (line 228) and `BaseRainterpreterSubParser.sol` (line 203), so it receives indirect coverage through integration/parse tests. However, there are no unit tests exercising the function pointer dispatch logic directly, such as verifying behavior with specific `wordIndex` values or checking the assembly-level pointer extraction.

### A39-3: `parseOperand` -- no test for `UnclosedOperand` revert from yang state (line 111 vs line 115) [LOW]

The `parseOperand` function has two distinct paths that revert with `UnclosedOperand`:
- Line 111: Inside the `else` block when `FSM_YANG_MASK` is set (two consecutive literals without whitespace between them).
- Line 115: After the `while` loop when `success` is false (the source string ended without a closing `>`).

The test `testParseOperandUnclosed` (line 280) tests the "reached end without closing" path (line 115). The test `testParseOperandUnexpectedChars` (line 286) tests the "unexpected character" path (line 111, via a `;` character while in yang state). However, the yang-state path is only tested with a non-literal character (`';'`). There is no test that explicitly exercises line 111 through the actual intended scenario: two literals placed back-to-back without whitespace (e.g., `<1 2 34>`), which would set yang, attempt to parse the next char as a literal, fail, and hit the else branch.

### A39-4: `parseOperand` -- no test for exactly `OPERAND_VALUES_LENGTH` values (boundary) [INFO]

The test `testParseOperandFourDecimalLiterals` tests parsing exactly 4 values (the maximum `OPERAND_VALUES_LENGTH`), and `testParseOperandTooManyValues` tests 5 values triggering `OperandValuesOverflow`. The boundary is adequately covered. This is informational only.

### A39-5: `handleOperandM1M1` -- no test for first value overflow with two values provided [LOW]

The `handleOperandM1M1` tests cover:
- No values (line 18)
- One valid value (line 23)
- One value too large (line 31)
- Two valid values (line 41)
- Second value too large (line 52)
- More than two values (line 64)

Missing: a test where `values.length == 2` and the **first** value exceeds 1 (i.e., `aUint > 1`). The overflow check at line 335 (`if (aUint > 1 || bUint > 1)`) is only tested with the second value overflowing. While the `||` short-circuit means the first-value overflow code path is implicitly exercised by the single-value-too-large test (since the same bounds check fires), there is no explicit two-value test where only `a` overflows.

### A39-6: `handleOperand8M1M1` -- no test for first value overflow with all three values provided [LOW]

Similar to A39-5, there is no test where all three values are provided but the first value (`a`) exceeds `type(uint8).max`. The test `testHandleOperand8M1M1FirstValueTooLarge` only provides one value (length 1). There is no test with `values.length == 3` where only `a` overflows.

### A39-7: `handleOperandDoublePerByteNoDefault` -- no test for both values simultaneously overflowing [INFO]

Tests exist for the first value too large (line 38) and the second value too large (line 51), but there is no test where both values exceed `type(uint8).max` simultaneously. This is a minor gap since either overflow alone triggers the revert.
