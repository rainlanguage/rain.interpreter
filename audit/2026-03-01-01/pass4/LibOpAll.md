# Pass 4: Opcode Libraries Maintainability, Consistency & Abstractions

Audit date: 2026-03-01
Auditor: Claude Opus 4.6
Scope: All files under `src/lib/op/` (72 opcodes across 68 files)

## File Inventory

### LibAllStandardOps.sol
- `authoringMetaV2()` (line 121)
- `literalParserFunctionPointers()` (line 330)
- `operandHandlerFunctionPointers()` (line 363)
- `integrityFunctionPointers()` (line 535)
- `opcodeFunctionPointers()` (line 639)

### src/lib/op/00/
| File | Library | Functions (line) |
|------|---------|-----------------|
| LibOpConstant.sol | LibOpConstant | `integrity` (21), `run` (37), `referenceFn` (52) |
| LibOpContext.sol | LibOpContext | `integrity` (16), `run` (28), `referenceFn` (47) |
| LibOpExtern.sol | LibOpExtern | `integrity` (29), `run` (49), `referenceFn` (102) |
| LibOpStack.sol | LibOpStack | `integrity` (21), `run` (41), `referenceFn` (58) |

### src/lib/op/bitwise/
| File | Library | Functions (line) |
|------|---------|-----------------|
| LibOpBitwiseAnd.sol | LibOpBitwiseAnd | `integrity` (16), `run` (24), `referenceFn` (36) |
| LibOpBitwiseOr.sol | LibOpBitwiseOr | `integrity` (16), `run` (24), `referenceFn` (36) |
| LibOpCtPop.sol | LibOpCtPop | `integrity` (22), `run` (30), `referenceFn` (47) |
| LibOpDecodeBits.sol | LibOpDecodeBits | `integrity` (20), `run` (33), `referenceFn` (65) |
| LibOpEncodeBits.sol | LibOpEncodeBits | `integrity` (19), `run` (36), `referenceFn` (76) |
| LibOpShiftBitsLeft.sol | LibOpShiftBitsLeft | `integrity` (19), `run` (38), `referenceFn` (49) |
| LibOpShiftBitsRight.sol | LibOpShiftBitsRight | `integrity` (19), `run` (38), `referenceFn` (49) |

### src/lib/op/call/
| File | Library | Functions (line) |
|------|---------|-----------------|
| LibOpCall.sol | LibOpCall | `integrity` (85), `run` (122) |

### src/lib/op/crypto/
| File | Library | Functions (line) |
|------|---------|-----------------|
| LibOpHash.sol | LibOpHash | `integrity` (17), `run` (28), `referenceFn` (41) |

### src/lib/op/erc20/
| File | Library | Functions (line) |
|------|---------|-----------------|
| LibOpERC20Allowance.sol | LibOpERC20Allowance | `integrity` (21), `run` (30), `referenceFn` (83) |
| LibOpERC20BalanceOf.sol | LibOpERC20BalanceOf | `integrity` (21), `run` (30), `referenceFn` (67) |
| LibOpERC20TotalSupply.sol | LibOpERC20TotalSupply | `integrity` (21), `run` (30), `referenceFn` (61) |

### src/lib/op/erc20/uint256/
| File | Library | Functions (line) |
|------|---------|-----------------|
| LibOpUint256ERC20Allowance.sol | LibOpUint256ERC20Allowance | `integrity` (16), `run` (25), `referenceFn` (60) |
| LibOpUint256ERC20BalanceOf.sol | LibOpUint256ERC20BalanceOf | `integrity` (16), `run` (25), `referenceFn` (54) |
| LibOpUint256ERC20TotalSupply.sol | LibOpUint256ERC20TotalSupply | `integrity` (16), `run` (25), `referenceFn` (48) |

### src/lib/op/erc721/
| File | Library | Functions (line) |
|------|---------|-----------------|
| LibOpERC721BalanceOf.sol | LibOpERC721BalanceOf | `integrity` (19), `run` (28), `referenceFn` (60) |
| LibOpERC721OwnerOf.sol | LibOpERC721OwnerOf | `integrity` (18), `run` (27), `referenceFn` (53) |

### src/lib/op/erc721/uint256/
| File | Library | Functions (line) |
|------|---------|-----------------|
| LibOpUint256ERC721BalanceOf.sol | LibOpUint256ERC721BalanceOf | `integrity` (16), `run` (25), `referenceFn` (52) |

### src/lib/op/erc5313/
| File | Library | Functions (line) |
|------|---------|-----------------|
| LibOpERC5313Owner.sol | LibOpERC5313Owner | `integrity` (18), `run` (27), `referenceFn` (50) |

### src/lib/op/evm/
| File | Library | Functions (line) |
|------|---------|-----------------|
| LibOpBlockNumber.sol | LibOpBlockNumber | `integrity` (19), `run` (26), `referenceFn` (39) |
| LibOpChainId.sol | LibOpChainId | `integrity` (19), `run` (26), `referenceFn` (39) |
| LibOpTimestamp.sol | LibOpTimestamp | `integrity` (19), `run` (26), `referenceFn` (39) |

### src/lib/op/logic/
| File | Library | Functions (line) |
|------|---------|-----------------|
| LibOpAny.sol | LibOpAny | `integrity` (21), `run` (33), `referenceFn` (60) |
| LibOpBinaryEqualTo.sol | LibOpBinaryEqualTo | `integrity` (17), `run` (26), `referenceFn` (38) |
| LibOpConditions.sol | LibOpConditions | `integrity` (23), `run` (40), `referenceFn` (82) |
| LibOpEnsure.sol | LibOpEnsure | `integrity` (20), `run` (31), `referenceFn` (49) |
| LibOpEqualTo.sol | LibOpEqualTo | `integrity` (21), `run` (30), `referenceFn` (52) |
| LibOpEvery.sol | LibOpEvery | `integrity` (21), `run` (32), `referenceFn` (58) |
| LibOpGreaterThan.sol | LibOpGreaterThan | `integrity` (20), `run` (28), `referenceFn` (46) |
| LibOpGreaterThanOrEqualTo.sol | LibOpGreaterThanOrEqualTo | `integrity` (20), `run` (29), `referenceFn` (47) |
| LibOpIf.sol | LibOpIf | `integrity` (20), `run` (29), `referenceFn` (47) |
| LibOpIsZero.sol | LibOpIsZero | `integrity` (19), `run` (27), `referenceFn` (42) |
| LibOpLessThan.sol | LibOpLessThan | `integrity` (20), `run` (28), `referenceFn` (46) |
| LibOpLessThanOrEqualTo.sol | LibOpLessThanOrEqualTo | `integrity` (20), `run` (29), `referenceFn` (47) |

### src/lib/op/math/
| File | Library | Functions (line) |
|------|---------|-----------------|
| LibOpAbs.sol | LibOpAbs | `integrity` (19), `run` (28), `referenceFn` (44) |
| LibOpAdd.sol | LibOpAdd | `integrity` (22), `run` (33), `referenceFn` (76) |
| LibOpAvg.sol | LibOpAvg | `integrity` (19), `run` (28), `referenceFn` (47) |
| LibOpCeil.sol | LibOpCeil | `integrity` (19), `run` (28), `referenceFn` (44) |
| LibOpDiv.sol | LibOpDiv | `integrity` (21), `run` (33), `referenceFn` (74) |
| LibOpE.sol | LibOpE | `integrity` (17), `run` (24), `referenceFn` (35) |
| LibOpExp.sol | LibOpExp | `integrity` (19), `run` (28), `referenceFn` (44) |
| LibOpExp2.sol | LibOpExp2 | `integrity` (19), `run` (28), `referenceFn` (45) |
| LibOpFloor.sol | LibOpFloor | `integrity` (19), `run` (28), `referenceFn` (44) |
| LibOpFrac.sol | LibOpFrac | `integrity` (19), `run` (28), `referenceFn` (44) |
| LibOpGm.sol | LibOpGm | `integrity` (21), `run` (31), `referenceFn` (55) |
| LibOpHeadroom.sol | LibOpHeadroom | `integrity` (20), `run` (30), `referenceFn` (49) |
| LibOpInv.sol | LibOpInv | `integrity` (19), `run` (28), `referenceFn` (44) |
| LibOpMax.sol | LibOpMax | `integrity` (20), `run` (32), `referenceFn` (67) |
| LibOpMaxNegativeValue.sol | LibOpMaxNegativeValue | `integrity` (19), `run` (26), `referenceFn` (37) |
| LibOpMaxPositiveValue.sol | LibOpMaxPositiveValue | `integrity` (19), `run` (26), `referenceFn` (37) |
| LibOpMin.sol | LibOpMin | `integrity` (20), `run` (32), `referenceFn` (68) |
| LibOpMinNegativeValue.sol | LibOpMinNegativeValue | `integrity` (19), `run` (26), `referenceFn` (37) |
| LibOpMinPositiveValue.sol | LibOpMinPositiveValue | `integrity` (19), `run` (26), `referenceFn` (37) |
| LibOpMul.sol | LibOpMul | `integrity` (21), `run` (32), `referenceFn` (74) |
| LibOpPow.sol | LibOpPow | `integrity` (19), `run` (28), `referenceFn` (47) |
| LibOpSqrt.sol | LibOpSqrt | `integrity` (19), `run` (28), `referenceFn` (44) |
| LibOpSub.sol | LibOpSub | `integrity` (21), `run` (33), `referenceFn` (75) |

### src/lib/op/math/growth/
| File | Library | Functions (line) |
|------|---------|-----------------|
| LibOpExponentialGrowth.sol | LibOpExponentialGrowth | `integrity` (18), `run` (26), `referenceFn` (47) |
| LibOpLinearGrowth.sol | LibOpLinearGrowth | `integrity` (18), `run` (26), `referenceFn` (48) |

### src/lib/op/math/uint256/
| File | Library | Functions (line) |
|------|---------|-----------------|
| LibOpMaxUint256.sol | LibOpMaxUint256 | `integrity` (14), `run` (21), `referenceFn` (31) |
| LibOpUint256Add.sol | LibOpUint256Add | `integrity` (17), `run` (30), `referenceFn` (64) |
| LibOpUint256Div.sol | LibOpUint256Div | `integrity` (18), `run` (30), `referenceFn` (65) |
| LibOpUint256Mul.sol | LibOpUint256Mul | `integrity` (17), `run` (30), `referenceFn` (64) |
| LibOpUint256Pow.sol | LibOpUint256Pow | `integrity` (17), `run` (30), `referenceFn` (64) |
| LibOpUint256Sub.sol | LibOpUint256Sub | `integrity` (17), `run` (30), `referenceFn` (64) |

### src/lib/op/store/
| File | Library | Functions (line) |
|------|---------|-----------------|
| LibOpGet.sol | LibOpGet | `integrity` (19), `run` (32), `referenceFn` (68) |
| LibOpSet.sol | LibOpSet | `integrity` (19), `run` (29), `referenceFn` (46) |

---

## Findings

### PASS4-LIBOP-1: Missing `@notice` tag on `integrity` NatSpec in several uint256/growth libraries [LOW]

**Files affected:**
- `src/lib/op/erc20/uint256/LibOpUint256ERC20Allowance.sol` line 15
- `src/lib/op/erc20/uint256/LibOpUint256ERC20BalanceOf.sol` line 15
- `src/lib/op/erc20/uint256/LibOpUint256ERC20TotalSupply.sol` line 15
- `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol` line 15
- `src/lib/op/math/growth/LibOpExponentialGrowth.sol` line 17
- `src/lib/op/math/growth/LibOpLinearGrowth.sol` line 17
- `src/lib/op/math/uint256/LibOpMaxUint256.sol` line 13, 30

**Evidence:**
The majority of opcode libraries tag the `integrity` function with `/// @notice`. For example, `LibOpERC20Allowance.integrity` (line 18) uses `/// @notice \`erc20-allowance\` integrity check.` However, the uint256 ERC variants, the growth opcodes, and the max-uint256 opcode use bare `///` (untagged NatSpec) for `integrity`. Since these doc blocks have no other explicit tags, the untagged line becomes implicit `@notice` and the compiler treats it the same. But the `CLAUDE.md` convention states: "when a doc block contains any explicit tag (e.g. `@title`), all entries must be explicitly tagged." While these particular doc blocks have no explicit tags so the implicit rule technically applies, this creates an inconsistency with the dominant pattern across the codebase.

`LibOpMaxUint256.referenceFn` at line 30 also lacks `@notice` while every other `referenceFn` in the codebase has one.

**Impact:** Readability/consistency only. No functional impact.

---

### PASS4-LIBOP-2: Missing `referenceFn` in `LibOpCall` [LOW]

**File:** `src/lib/op/call/LibOpCall.sol`

**Evidence:**
Every other opcode library provides a `referenceFn` function for testing purposes. `LibOpCall` has only `integrity` (line 85) and `run` (line 122) -- no `referenceFn`. This is the only standard opcode library without one. The `call` opcode's cross-source semantics make a pure reference implementation more complex, but the deviation from the universal pattern is notable from a consistency standpoint.

**Impact:** Reduces testability of the call opcode via the standard reference-comparison test harness.

---

### PASS4-LIBOP-3: Magic number `0x0F` used without named constant for operand input-count mask [INFO]

**Files affected:** Every opcode that reads input count from operand, including:
- `LibOpHash.sol` line 20: `uint256(OperandV2.unwrap(operand) >> 0x10) & 0x0F`
- `LibOpAdd.sol` line 24, 47
- `LibOpDiv.sol` line 23, 47
- `LibOpMul.sol` line 23, 46
- `LibOpSub.sol` line 23, 47
- `LibOpMax.sol` line 22, 43
- `LibOpMin.sol` line 22, 43
- `LibOpAny.sol` line 23, 35
- `LibOpEvery.sol` line 23, 34
- `LibOpConditions.sol` line 25
- `LibOpCall.sol` line 125, 126
- `LibOpExtern.sol` lines 38-39
- All uint256 math opcodes

**Evidence:**
The magic numbers `0x0F`, `0x10`, and `0x14` are repeated many dozens of times across the opcode libraries. They refer to the operand field layout (input count is 4 bits starting at bit 16, output count is 4 bits at bit 20). A named constant like `OPERAND_INPUTS_MASK` or similar would make the convention self-documenting.

**Impact:** Not a bug. These values are consistent across all files. But a future change to the operand layout would require changes in dozens of files. A named constant would reduce that risk.

---

### PASS4-LIBOP-4: Inconsistent `using ... for` declaration patterns [INFO]

**Files affected:** Several opcode libraries import `LibDecimalFloat` but declare `using LibDecimalFloat for Float` while others do not use the `using` directive and call `LibDecimalFloat.functionName(...)` directly.

**Examples using the directive:**
- `LibOpAbs.sol` line 14: `using LibDecimalFloat for Float;`
- `LibOpGreaterThan.sol` line 15: `using LibDecimalFloat for Float;`
- All logic ops with float comparisons

**Examples without the directive (calling library functions directly):**
- `LibOpE.sol` line 25: `Float e = LibDecimalFloat.FLOAT_E;` (no `using` needed since it only accesses constants)
- `LibOpMaxNegativeValue.sol` line 14: `using LibDecimalFloat for Float;` but only accesses a constant in `run` -- the `using` is unnecessary since `run` only uses `LibDecimalFloat.FLOAT_MAX_NEGATIVE_VALUE`.

**Impact:** Purely stylistic. The `using` declarations are harmless but unnecessary when only constants are used. Not a bug.

---

### PASS4-LIBOP-5: `LibOpSub` operand handler is `handleOperandSingleFull` while all other multi-input opcodes use `handleOperandDisallowed` [INFO]

**File:** `src/lib/op/LibAllStandardOps.sol` line 512

**Evidence:**
In `operandHandlerFunctionPointers()`, the `sub` opcode (line 512) uses `LibParseOperand.handleOperandSingleFull`, while all other N-input arithmetic opcodes (add, mul, div, max, min, uint256-add, uint256-sub, etc.) use `LibParseOperand.handleOperandDisallowed`. This is a deliberate difference -- the `sub` operand presumably enables explicit negation semantics via operand. But it is the only multi-input float math op with an explicit operand, which is worth documenting for maintainers.

**Impact:** This appears intentional based on the code structure, but the asymmetry could confuse maintainers. Consider a comment in `LibAllStandardOps.sol` explaining why `sub` has operand handling while other N-input math ops do not.

---

### PASS4-LIBOP-6: Inconsistent `referenceFn` return patterns -- some mutate inputs array, others allocate new outputs [INFO]

**Files affected:**
- `LibOpCtPop.sol` line 52: mutates `inputs[0]` and returns `inputs`
- `LibOpDecodeBits.sol` line 80: mutates `inputs[0]` and returns `inputs`
- `LibOpShiftBitsLeft.sol` line 55: mutates `inputs[0]` and returns `inputs`
- `LibOpShiftBitsRight.sol` line 55: mutates `inputs[0]` and returns `inputs`

vs.

- `LibOpAbs.sol` line 49: `outputs = new StackItem[](1);` allocates new array
- `LibOpIsZero.sol` line 47: `outputs = new StackItem[](1);` allocates new array
- All comparison ops allocate new arrays

**Evidence:**
For 1-input/1-output opcodes, there are two patterns:
1. Allocate a new `outputs` array and return it.
2. Mutate `inputs[0]` in-place and `return inputs`.

Both produce correct results for the test harness, but they are inconsistent. The pattern (2) is slightly more gas efficient for tests but could be surprising when reading the code, as it violates the implied contract that `inputs` remains unchanged.

**Impact:** Test-only code. No production impact. Minor readability issue.

---

### PASS4-LIBOP-7: `LibOpEnsure.integrity` missing `@notice` tag on the function NatSpec [INFO]

**File:** `src/lib/op/logic/LibOpEnsure.sol` line 18-20

**Evidence:**
```solidity
/// @return The number of inputs.
/// @return The number of outputs.
function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
```

The doc block jumps directly to `@return` tags without a `@notice` line. Since `@return` is an explicit tag, any untagged description would need `@notice` per the project convention. In this case there is no description at all -- only `@return` tags. Most other `integrity` functions include a `@notice` line like `/// @notice \`ensure\` integrity check. ...`.

**Impact:** Consistency issue. No functional impact.

---

### PASS4-LIBOP-8: No commented-out code or dead code found [N/A]

A complete scan of all 68 opcode library files found:
- Zero commented-out code blocks
- Zero unused imports (all imports are used by the functions in each file)
- Zero dead functions

---

## Summary

| ID | Severity | Description |
|----|----------|-------------|
| PASS4-LIBOP-1 | LOW | Missing `@notice` tag on integrity/referenceFn NatSpec in 8 files |
| PASS4-LIBOP-2 | LOW | Missing `referenceFn` in `LibOpCall` -- only standard opcode without one |
| PASS4-LIBOP-3 | INFO | Magic number `0x0F` / `0x10` / `0x14` repeated dozens of times for operand masks |
| PASS4-LIBOP-4 | INFO | Inconsistent `using ... for` declarations (some unnecessary) |
| PASS4-LIBOP-5 | INFO | `sub` is the only multi-input float math op with `handleOperandSingleFull` |
| PASS4-LIBOP-6 | INFO | Inconsistent `referenceFn` return pattern (mutate inputs vs. allocate outputs) |
| PASS4-LIBOP-7 | INFO | `LibOpEnsure.integrity` missing `@notice` while having `@return` tags |

Overall assessment: The opcode libraries are highly consistent. All 72 opcodes follow the `integrity`/`run`/`referenceFn` pattern (with the single exception of `LibOpCall`). Assembly patterns are consistent within each category (fixed-input ops, N-input ops, zero-input constant ops). There is no commented-out code, no dead code, and no unused imports. The findings above are all LOW or INFO severity, reflecting a well-maintained codebase.
