# Pass 4: Style Consistency -- Extern Reference Ops & All Opcodes

**Agent:** A03
**Scope:** `src/lib/extern/reference/` (6 files), `src/lib/op/` (~69 files + LibAllStandardOps.sol)

## Checklist Results

### Bare `src/` import paths
**Result:** None found. Grepped `"src/` across all files in both directories. Zero matches.

### Commented-out code
**Result:** None found. Grepped for patterns like `// function`, `// import`, `// return`, etc. All matches were legitimate inline comments (opcode name labels in `LibAllStandardOps.sol`), SPDX headers, slither/forge-lint directives, or explanatory prose.

### Unused imports
**Result:** One pattern found (LOW).

### Inconsistent naming conventions
**Result:** None found. All opcode libraries follow the `LibOp<Name>` pattern consistently. Extern ops follow `LibExternOp<Name>`. The literal parser follows `LibParseLiteral<Name>`.

### Inconsistent operand handling patterns
**Result:** None found. All opcodes that read the input count from the operand use the same bit extraction: `uint256(OperandV2.unwrap(operand) >> 0x10) & 0x0F`. All opcodes that read low-16-bit indices use `uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)))`. Bitwise ops that read two bytes use the same pattern for both bytes.

### Style consistency
**Result:** Two informational items found.

---

## Findings

### P4-ALLOP-01 (LOW): Duplicate import of same source file in three ERC20 opcodes

**Files:**
- `src/lib/op/erc20/LibOpERC20Allowance.sol` (lines 8, 12)
- `src/lib/op/erc20/LibOpERC20BalanceOf.sol` (lines 8, 12)
- `src/lib/op/erc20/LibOpERC20TotalSupply.sol` (lines 8, 12)

**Description:** These three files import `OperandV2` from `rain.interpreter.interface/interface/IInterpreterV4.sol` on one line, then import `StackItem` from the exact same file on a separate line. Every other opcode in the codebase imports both symbols in a single import statement: `import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";`

**Evidence (LibOpERC20BalanceOf.sol):**
```solidity
import {OperandV2} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
// ... other imports ...
import {StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
```

Compare with standard pattern (e.g. LibOpBitwiseAnd.sol):
```solidity
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
```

This is functionally harmless but inconsistent with the rest of the codebase.

### P4-ALLOP-02 (INFO): Unused `using LibDecimalFloat for Float` in constant/EVM opcodes

**Files (8 total):**
- `src/lib/op/evm/LibOpBlockNumber.sol`
- `src/lib/op/evm/LibOpBlockTimestamp.sol`
- `src/lib/op/evm/LibOpChainId.sol`
- `src/lib/op/math/LibOpE.sol`
- `src/lib/op/math/LibOpMaxPositiveValue.sol`
- `src/lib/op/math/LibOpMaxNegativeValue.sol`
- `src/lib/op/math/LibOpMinPositiveValue.sol`
- `src/lib/op/math/LibOpMinNegativeValue.sol`

**Description:** These files declare `using LibDecimalFloat for Float;` but never call any method on a `Float` instance via dot-syntax. They only use `LibDecimalFloat.*` as static function calls (e.g. `LibDecimalFloat.fromFixedDecimalLosslessPacked(...)`, `LibDecimalFloat.FLOAT_E`, `LibDecimalFloat.packLossless(...)`). The `using` directive is dead weight. Solidity does not warn on unused `using` directives.

This is purely cosmetic and does not affect compilation, gas costs, or behaviour.

### P4-ALLOP-03 (INFO): LibOpCall is the only opcode without `StackItem` in its type surface

**File:** `src/lib/op/call/LibOpCall.sol`

**Description:** `LibOpCall` does not import `StackItem` and its `referenceFn` is absent (it has no `referenceFn`). This is intentional because `call` delegates to `LibEval.evalLoop` and cannot be meaningfully tested via the standard reference-function harness. Noted for completeness; not a defect.

---

## Summary

| ID | Severity | Category | Description |
|----|----------|----------|-------------|
| P4-ALLOP-01 | LOW | Duplicate imports | 3 ERC20 ops import same file twice with different symbols |
| P4-ALLOP-02 | INFO | Unused using | 8 files declare `using LibDecimalFloat for Float` but only use static calls |
| P4-ALLOP-03 | INFO | Pattern deviation | LibOpCall intentionally lacks referenceFn and StackItem import |
