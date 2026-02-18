# Pass 2: Test Coverage — Misc Operations (ERC5313, ERC721, EVM)

**Audit:** 2026-02-17-03
**Agent:** A26
**Pass:** 2 (Test Coverage)

## Evidence of Thorough Reading

### Source File: `src/lib/op/erc5313/LibOpERC5313Owner.sol`
- **Library:** `LibOpERC5313Owner`
- **Functions:**
  - `integrity` (line 15) — returns (1, 1)
  - `run` (line 22) — reads account from stack, calls `IERC5313.owner()`, writes owner to stack
  - `referenceFn` (line 38) — reference implementation for testing
- **Errors/Events/Structs:** None defined locally

### Source File: `src/lib/op/erc721/LibOpERC721BalanceOf.sol`
- **Library:** `LibOpERC721BalanceOf`
- **Functions:**
  - `integrity` (line 16) — returns (2, 1)
  - `run` (line 23) — reads token and account, calls `IERC721.balanceOf()`, converts result via `LibDecimalFloat.fromFixedDecimalLosslessPacked`, writes to stack
  - `referenceFn` (line 45) — reference implementation for testing
- **Errors/Events/Structs:** None defined locally

### Source File: `src/lib/op/erc721/LibOpERC721OwnerOf.sol`
- **Library:** `LibOpERC721OwnerOf`
- **Functions:**
  - `integrity` (line 15) — returns (2, 1)
  - `run` (line 22) — reads token and tokenId, calls `IERC721.ownerOf()`, writes owner to stack
  - `referenceFn` (line 41) — reference implementation for testing
- **Errors/Events/Structs:** None defined locally

### Source File: `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol`
- **Library:** `LibOpUint256ERC721BalanceOf`
- **Functions:**
  - `integrity` (line 15) — returns (2, 1)
  - `run` (line 22) — reads token and account, calls `IERC721.balanceOf()`, writes raw uint256 to stack (no float conversion)
  - `referenceFn` (line 42) — reference implementation for testing
- **Errors/Events/Structs:** None defined locally

### Source File: `src/lib/op/evm/LibOpBlockNumber.sol`
- **Library:** `LibOpBlockNumber`
- **Functions:**
  - `integrity` (line 17) — returns (0, 1)
  - `run` (line 22) — pushes `number()` onto stack (subtracts 0x20 from stackTop, writes)
  - `referenceFn` (line 34) — reference implementation using `LibDecimalFloat.fromFixedDecimalLosslessPacked(block.number, 0)`
- **Errors/Events/Structs:** None defined locally

### Source File: `src/lib/op/evm/LibOpChainId.sol`
- **Library:** `LibOpChainId`
- **Functions:**
  - `integrity` (line 17) — returns (0, 1)
  - `run` (line 22) — pushes `chainid()` onto stack
  - `referenceFn` (line 34) — reference implementation using `LibDecimalFloat.fromFixedDecimalLosslessPacked(block.chainid, 0)`
- **Errors/Events/Structs:** None defined locally

### Source File: `src/lib/op/evm/LibOpTimestamp.sol`
- **Library:** `LibOpTimestamp`
- **Functions:**
  - `integrity` (line 17) — returns (0, 1)
  - `run` (line 22) — pushes `timestamp()` onto stack
  - `referenceFn` (line 34) — reference implementation using `LibDecimalFloat.fromFixedDecimalLosslessPacked(block.timestamp, 0)`
- **Errors/Events/Structs:** None defined locally

### Test File: `test/src/lib/op/erc5313/LibOpERC5313Owner.t.sol`
- **Contract:** `LibOpERC5313OwnerTest` (extends `OpTest`)
- **Functions:**
  - `testOpERC5313OwnerOfIntegrity` (line 16) — fuzz test on integrity
  - `testOpERC5313OwnerOfRun` (line 23) — fuzz test on run via `opReferenceCheck`
  - `testOpERC5313OwnerEvalHappy` (line 46) — eval from parsed string
  - `testOpERC5313OwnerEvalZeroInputs` (line 54) — bad inputs: 0
  - `testOpERC5313OwnerEvalTwoInputs` (line 58) — bad inputs: 2
  - `testOpERC5313OwnerEvalZeroOutputs` (line 62) — bad outputs: 0
  - `testOpERC5313OwnerEvalTwoOutputs` (line 66) — bad outputs: 2
  - `testOpERC5313OwnerEvalOperandDisallowed` (line 71) — operand disallowed

### Test File: `test/src/lib/op/erc721/LibOpERC721BalanceOf.t.sol`
- **Contract:** `LibOpERC721BalanceOfTest` (extends `OpTest`)
- **Functions:**
  - `testOpERC721BalanceOfIntegrity` (line 26) — fuzz test on integrity
  - `testOpERC721BalanceOfRun` (line 41) — fuzz test on run via `opReferenceCheck`
  - `testOpERC721BalanceOfEvalHappy` (line 68) — eval from parsed string (fuzz)
  - `testOpERC721BalanceOfIntegrityFail0` (line 102) — 0 inputs revert
  - `testOpERC721BalanceOfIntegrityFail1` (line 109) — 1 input revert
  - `testOpERC721BalanceOfIntegrityFail3` (line 116) — 3 inputs revert
  - `testOpERC721BalanceOfIntegrityFailOperand` (line 123) — operand revert
  - `testOpERC721BalanceOfZeroInputs` (line 129) — checkBadInputs 0
  - `testOpERC721BalanceOfOneInput` (line 133) — checkBadInputs 1
  - `testOpERC721BalanceOfThreeInputs` (line 137) — checkBadInputs 3
  - `testOpERC721BalanceOfZeroOutputs` (line 141) — checkBadOutputs 0
  - `testOpERC721BalanceOfTwoOutputs` (line 145) — checkBadOutputs 2

### Test File: `test/src/lib/op/erc721/LibOpERC721OwnerOf.t.sol`
- **Contract:** `LibOpERC721OwnerOfTest` (extends `OpTest`)
- **Functions:**
  - `testOpERC721OwnerOfIntegrity` (line 26) — fuzz test on integrity
  - `testOpERC721OwnerOfRun` (line 34) — fuzz test on run via `opReferenceCheck`
  - `testOpERC721OwnerOfEvalHappy` (line 56) — eval from parsed string (fuzz)
  - `testOpERC721OwnerOfEvalFail0` (line 87) — 0 inputs revert
  - `testOpERC721OwnerOfEvalFail1` (line 94) — 1 input revert
  - `testOpERC721OwnerOfEvalFail3` (line 101) — 3 inputs revert
  - `testOpERC721OwnerOfEvalFailOperand` (line 108) — operand revert
  - `testOpERC721OwnerOfEvalZeroInputs` (line 114) — checkBadInputs 0
  - `testOpERC721OwnerOfEvalOneInput` (line 118) — checkBadInputs 1
  - `testOpERC721OwnerOfEvalThreeInputs` (line 122) — checkBadInputs 3
  - `testOpERC721OwnerOfEvalZeroOutputs` (line 126) — checkBadOutputs 0
  - `testOpERC721OwnerOfTwoOutputs` (line 130) — checkBadOutputs 2

### Test File: `test/src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.t.sol`
- **Contract:** `LibOpUint256ERC721BalanceOfTest` (extends `OpTest`)
- **Functions:**
  - `testOpERC721BalanceOfIntegrity` (line 25) — fuzz test on integrity
  - `testOpERC721BalanceOfRun` (line 40) — fuzz test on run via `opReferenceCheck`
  - `testOpERC721BalanceOfEvalHappy` (line 64) — eval from parsed string (fuzz)
  - `testOpERC721BalanceOfIntegrityFail0` (line 95) — 0 inputs revert
  - `testOpERC721BalanceOfIntegrityFail1` (line 102) — 1 input revert
  - `testOpERC721BalanceOfIntegrityFail3` (line 109) — 3 inputs revert
  - `testOpERC721BalanceOfIntegrityFailOperand` (line 116) — operand revert
  - `testOpERC721BalanceOfZeroInputs` (line 122) — checkBadInputs 0
  - `testOpERC721BalanceOfOneInput` (line 126) — checkBadInputs 1
  - `testOpERC721BalanceOfThreeInputs` (line 130) — checkBadInputs 3
  - `testOpERC721BalanceOfZeroOutputs` (line 134) — checkBadOutputs 0
  - `testOpERC721BalanceOfTwoOutputs` (line 138) — checkBadOutputs 2

### Test File: `test/src/lib/op/evm/LibOpBlockNumber.t.sol`
- **Contract:** `LibOpBlockNumberTest` (extends `OpTest`)
- **Functions:**
  - `testOpBlockNumberIntegrity` (line 23) — fuzz test on integrity
  - `testOpBlockNumberRun` (line 40) — fuzz test on run via `opReferenceCheck`
  - `testOpBlockNumberEval` (line 52) — eval from parsed string (fuzz)
  - `testOpBlockNumberEvalOneInput` (line 58) — checkBadInputs 1
  - `testOpBlockNumberEvalZeroOutputs` (line 62) — checkBadOutputs 0
  - `testOpBlockNumberEvalTwoOutputs` (line 66) — checkBadOutputs 2

### Test File: `test/src/lib/op/evm/LibOpChainId.t.sol`
- **Contract:** `LibOpChainIdTest` (extends `OpTest`)
- **Functions:**
  - `testOpChainIDIntegrity` (line 20) — fuzz test on integrity
  - `testOpChainIdRun` (line 35) — fuzz test on run via `opReferenceCheck`
  - `testOpChainIDEval` (line 44) — eval from parsed string (fuzz)
  - `testOpChainIdEvalFail` (line 50) — 1 input revert
  - `testOpChainIdZeroOutputs` (line 56) — checkBadOutputs 0
  - `testOpChainIdTwoOutputs` (line 60) — checkBadOutputs 2

### Test File: `test/src/lib/op/evm/LibOpTimestamp.t.sol`
- **Contract:** `LibOpTimestampTest` (extends `OpTest`)
- **Functions:**
  - `timestampWords` (line 26) — helper returning `["block-timestamp", "now"]`
  - `testOpTimestampIntegrity` (line 34) — fuzz test on integrity
  - `testOpTimestampRun` (line 49) — fuzz test on run via `opReferenceCheck`
  - `testOpTimestampEval` (line 61) — eval from parsed string (fuzz), tests both words
  - `testOpBlockTimestampEvalFail` (line 86) — 1 input revert, tests both words
  - `testOpBlockTimestampZeroOutputs` (line 96) — checkBadOutputs 0, tests both words
  - `testOpBlockTimestampTwoOutputs` (line 104) — checkBadOutputs 2, tests both words

---

## Coverage Analysis

### LibOpERC5313Owner
| Function | Tested? | Notes |
|----------|---------|-------|
| `integrity` | Yes | Fuzz test verifies returns (1,1) |
| `run` | Yes | Fuzz test via `opReferenceCheck` with mock |
| `referenceFn` | Yes | Used as reference in `opReferenceCheck` |
| Operand handler | Yes | `testOpERC5313OwnerEvalOperandDisallowed` |
| Bad inputs (0) | Yes | `testOpERC5313OwnerEvalZeroInputs` |
| Bad inputs (2) | Yes | `testOpERC5313OwnerEvalTwoInputs` |
| Bad outputs (0) | Yes | `testOpERC5313OwnerEvalZeroOutputs` |
| Bad outputs (2) | Yes | `testOpERC5313OwnerEvalTwoOutputs` |
| Full eval | Yes | `testOpERC5313OwnerEvalHappy` |

### LibOpERC721BalanceOf
| Function | Tested? | Notes |
|----------|---------|-------|
| `integrity` | Yes | Fuzz test verifies returns (2,1) |
| `run` | Yes | Fuzz test via `opReferenceCheck` with mock; assumes lossless float conversion |
| `referenceFn` | Yes | Used as reference in `opReferenceCheck` |
| Operand handler | Yes | `testOpERC721BalanceOfIntegrityFailOperand` |
| Bad inputs (0,1,3) | Yes | Both via `expectRevert` and `checkBadInputs` |
| Bad outputs (0,2) | Yes | Via `checkBadOutputs` |
| Full eval | Yes | `testOpERC721BalanceOfEvalHappy` (fuzz) |

### LibOpERC721OwnerOf
| Function | Tested? | Notes |
|----------|---------|-------|
| `integrity` | Yes | Fuzz test verifies returns (2,1) |
| `run` | Yes | Fuzz test via `opReferenceCheck` with mock |
| `referenceFn` | Yes | Used as reference in `opReferenceCheck` |
| Operand handler | Yes | `testOpERC721OwnerOfEvalFailOperand` |
| Bad inputs (0,1,3) | Yes | Both via `expectRevert` and `checkBadInputs` |
| Bad outputs (0,2) | Yes | Via `checkBadOutputs` |
| Full eval | Yes | `testOpERC721OwnerOfEvalHappy` (fuzz) |

### LibOpUint256ERC721BalanceOf
| Function | Tested? | Notes |
|----------|---------|-------|
| `integrity` | Yes | Fuzz test verifies returns (2,1) |
| `run` | Yes | Fuzz test via `opReferenceCheck` with mock |
| `referenceFn` | Yes | Used as reference in `opReferenceCheck` |
| Operand handler | Yes | `testOpERC721BalanceOfIntegrityFailOperand` |
| Bad inputs (0,1,3) | Yes | Both via `expectRevert` and `checkBadInputs` |
| Bad outputs (0,2) | Yes | Via `checkBadOutputs` |
| Full eval | Yes | `testOpERC721BalanceOfEvalHappy` (fuzz) |

### LibOpBlockNumber
| Function | Tested? | Notes |
|----------|---------|-------|
| `integrity` | Yes | Fuzz test verifies returns (0,1) |
| `run` | Yes | Fuzz test via `opReferenceCheck` with `vm.roll` |
| `referenceFn` | Yes | Used as reference in `opReferenceCheck` |
| Bad inputs (1) | Yes | `testOpBlockNumberEvalOneInput` |
| Bad outputs (0,2) | Yes | `testOpBlockNumberEvalZeroOutputs`, `testOpBlockNumberEvalTwoOutputs` |
| Full eval | Yes | `testOpBlockNumberEval` (fuzz) |

### LibOpChainId
| Function | Tested? | Notes |
|----------|---------|-------|
| `integrity` | Yes | Fuzz test verifies returns (0,1) |
| `run` | Yes | Fuzz test via `opReferenceCheck` with `vm.chainId` |
| `referenceFn` | Yes | Used as reference in `opReferenceCheck` |
| Bad inputs (1) | Yes | `testOpChainIdEvalFail` |
| Bad outputs (0,2) | Yes | `testOpChainIdZeroOutputs`, `testOpChainIdTwoOutputs` |
| Full eval | Yes | `testOpChainIDEval` (fuzz) |

### LibOpTimestamp
| Function | Tested? | Notes |
|----------|---------|-------|
| `integrity` | Yes | Fuzz test verifies returns (0,1) |
| `run` | Yes | Fuzz test via `opReferenceCheck` with `vm.warp` |
| `referenceFn` | Yes | Used as reference in `opReferenceCheck` |
| Bad inputs (1) | Yes | `testOpBlockTimestampEvalFail` (both aliases) |
| Bad outputs (0,2) | Yes | Both aliases tested |
| Full eval | Yes | `testOpTimestampEval` (both `block-timestamp` and `now` aliases, fuzz) |

---

## Findings

### A26-1: Missing operand disallowed test for LibOpBlockNumber

**Severity:** LOW

**File:** `test/src/lib/op/evm/LibOpBlockNumber.t.sol`

The test file does not include a test verifying that an operand is rejected (e.g., `_: block-number<0>();`). All other opcodes in this group that disallow operands have explicit tests for this (e.g., `testOpERC5313OwnerEvalOperandDisallowed`, `testOpERC721BalanceOfIntegrityFailOperand`). While the operand handler may still be tested implicitly through the parser, there is no explicit `UnexpectedOperand` assertion in the block-number test file.

### A26-2: Missing operand disallowed test for LibOpChainId

**Severity:** LOW

**File:** `test/src/lib/op/evm/LibOpChainId.t.sol`

Same as A26-1 but for the `chain-id` opcode. No test verifies that `_: chain-id<0>();` is rejected with `UnexpectedOperand`.

### A26-3: Missing operand disallowed test for LibOpTimestamp

**Severity:** LOW

**File:** `test/src/lib/op/evm/LibOpTimestamp.t.sol`

Same as A26-1 but for the `block-timestamp` / `now` opcode. No test verifies that `_: block-timestamp<0>();` or `_: now<0>();` is rejected with `UnexpectedOperand`.

### A26-4: LibOpTimestamp `testOpTimestampRun` does not fuzz operandData

**Severity:** INFO

**File:** `test/src/lib/op/evm/LibOpTimestamp.t.sol` (line 49)

The `testOpTimestampRun` function hardcodes operandData to `0` via `LibOperand.build(0, 1, 0)`, whereas the analogous tests for `LibOpBlockNumber` and `LibOpChainId` accept `uint16 operandData` as a fuzz parameter. This means the test does not verify that arbitrary operand values are safely ignored at runtime. The risk is low since the `run` function does not read the operand, but it is an inconsistency in test coverage relative to the other EVM opcodes.

### A26-5: LibOpERC721BalanceOf `testOpERC721BalanceOfEvalHappy` assertion compares raw balance, not float

**Severity:** INFO

**File:** `test/src/lib/op/erc721/LibOpERC721BalanceOf.t.sol` (line 97)

The eval happy-path test at line 97 asserts `StackItem.unwrap(stack[0]) == bytes32(balance)`. The `run` function converts balance via `LibDecimalFloat.fromFixedDecimalLosslessPacked(tokenBalance, 0)` to a float representation. The assertion succeeds because `vm.assume(lossless)` is used and `fromFixedDecimalLosslessPacked(x, 0)` for small-enough values produces the identity (the raw bytes equal the input). However, the test could be more explicit about verifying the float conversion output rather than relying on the identity property. This is purely informational since the `opReferenceCheck` fuzz test in `testOpERC721BalanceOfRun` already validates the float conversion path against the reference function.

### A26-6: Duplicate test coverage in ERC721 test files

**Severity:** INFO

**File:** `test/src/lib/op/erc721/LibOpERC721BalanceOf.t.sol`, `test/src/lib/op/erc721/LibOpERC721OwnerOf.t.sol`, `test/src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.t.sol`

All three ERC721 test files contain duplicate bad-input/output tests: they test the same error paths twice using both direct `vm.expectRevert` + `parse2` patterns (e.g., `testOpERC721BalanceOfIntegrityFail0`) and via the `checkBadInputs` / `checkBadOutputs` helpers (e.g., `testOpERC721BalanceOfZeroInputs`). While redundancy is not harmful, it indicates test cruft that could be consolidated. No coverage gap exists — this is a code-quality observation.

---

## Summary

All 7 source files have corresponding test files. All three standard functions (`integrity`, `run`, `referenceFn`) are tested for each opcode. The `opReferenceCheck` harness provides strong assurance by comparing `run` output against `referenceFn` output with fuzz inputs. Integration-level eval tests parse Rainlang strings and evaluate through the full interpreter stack.

The main gaps are the missing `UnexpectedOperand` tests for the three EVM opcodes (A26-1, A26-2, A26-3). These are LOW severity because the operand rejection is still enforced by the parser's operand handler, but it lacks explicit test coverage in these files. The remaining findings (A26-4, A26-5, A26-6) are INFO-level observations about minor inconsistencies and redundancies.
