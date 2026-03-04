# Pass 4 Findings: ERC, EVM, and Logic Ops (A44-A68)

## Evidence Summary

### A44: `src/lib/op/erc20/LibOpERC20Allowance.sol`
- **Library**: `LibOpERC20Allowance`
- **Functions**: `integrity` (L21), `run` (L30), `referenceFn` (L83)
- **Imports**: `IERC20`, `Pointer`, `IntegrityCheckState`, `OperandV2` (L8), `InterpreterState`, `LibDecimalFloat`/`Float`, `LibTOFUTokenDecimals`, `StackItem` (L12), `NotAnAddress`
- **Note**: `OperandV2` and `StackItem` imported on separate lines from the same module

### A45: `src/lib/op/erc20/LibOpERC20BalanceOf.sol`
- **Library**: `LibOpERC20BalanceOf`
- **Functions**: `integrity` (L21), `run` (L30), `referenceFn` (L67)
- **Imports**: Same split-import pattern as A44

### A46: `src/lib/op/erc20/LibOpERC20TotalSupply.sol`
- **Library**: `LibOpERC20TotalSupply`
- **Functions**: `integrity` (L21), `run` (L30), `referenceFn` (L61)
- **Imports**: Same split-import pattern as A44

### A47: `src/lib/op/erc20/uint256/LibOpUint256ERC20Allowance.sol`
- **Library**: `LibOpUint256ERC20Allowance`
- **Functions**: `integrity` (L19), `run` (L28), `referenceFn` (L63)
- **Imports**: Combined `OperandV2, StackItem` import

### A48: `src/lib/op/erc20/uint256/LibOpUint256ERC20BalanceOf.sol`
- **Library**: `LibOpUint256ERC20BalanceOf`
- **Functions**: `integrity` (L19), `run` (L28), `referenceFn` (L57)

### A49: `src/lib/op/erc20/uint256/LibOpUint256ERC20TotalSupply.sol`
- **Library**: `LibOpUint256ERC20TotalSupply`
- **Functions**: `integrity` (L19), `run` (L28), `referenceFn` (L51)

### A50: `src/lib/op/erc5313/LibOpERC5313Owner.sol`
- **Library**: `LibOpERC5313Owner`
- **Functions**: `integrity` (L18), `run` (L27), `referenceFn` (L50)

### A51: `src/lib/op/erc721/LibOpERC721BalanceOf.sol`
- **Library**: `LibOpERC721BalanceOf`
- **Functions**: `integrity` (L19), `run` (L28), `referenceFn` (L60)

### A52: `src/lib/op/erc721/LibOpERC721OwnerOf.sol`
- **Library**: `LibOpERC721OwnerOf`
- **Functions**: `integrity` (L18), `run` (L27), `referenceFn` (L53)

### A53: `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol`
- **Library**: `LibOpUint256ERC721BalanceOf`
- **Functions**: `integrity` (L19), `run` (L28), `referenceFn` (L55)

### A54: `src/lib/op/evm/LibOpBlockNumber.sol`
- **Library**: `LibOpBlockNumber`
- **Functions**: `integrity` (L19), `run` (L26), `referenceFn` (L39)
- **Using**: `LibDecimalFloat for Float`

### A55: `src/lib/op/evm/LibOpBlockTimestamp.sol`
- **Library**: `LibOpBlockTimestamp`
- **Functions**: `integrity` (L19), `run` (L26), `referenceFn` (L39)
- **Using**: `LibDecimalFloat for Float`

### A56: `src/lib/op/evm/LibOpChainId.sol`
- **Library**: `LibOpChainId`
- **Functions**: `integrity` (L19), `run` (L26), `referenceFn` (L39)
- **Using**: `LibDecimalFloat for Float`

### A57: `src/lib/op/logic/LibOpAny.sol`
- **Library**: `LibOpAny`
- **Functions**: `integrity` (L21), `run` (L33), `referenceFn` (L60)
- **Using**: `LibDecimalFloat for Float`

### A58: `src/lib/op/logic/LibOpBinaryEqualTo.sol`
- **Library**: `LibOpBinaryEqualTo`
- **Functions**: `integrity` (L17), `run` (L26), `referenceFn` (L38)

### A59: `src/lib/op/logic/LibOpConditions.sol`
- **Library**: `LibOpConditions`
- **Functions**: `integrity` (L23), `run` (L40), `referenceFn` (L82)
- **Using**: `LibIntOrAString for IntOrAString`, `LibDecimalFloat for Float`

### A60: `src/lib/op/logic/LibOpEnsure.sol`
- **Library**: `LibOpEnsure`
- **Functions**: `integrity` (L22), `run` (L32), `referenceFn` (L50)
- **Using**: `LibDecimalFloat for Float`, `LibIntOrAString for IntOrAString`

### A61: `src/lib/op/logic/LibOpEqualTo.sol`
- **Library**: `LibOpEqualTo`
- **Functions**: `integrity` (L21), `run` (L30), `referenceFn` (L52)
- **Using**: `LibDecimalFloat for Float`

### A62: `src/lib/op/logic/LibOpEvery.sol`
- **Library**: `LibOpEvery`
- **Functions**: `integrity` (L21), `run` (L32), `referenceFn` (L58)
- **Using**: `LibDecimalFloat for Float`

### A63: `src/lib/op/logic/LibOpGreaterThan.sol`
- **Library**: `LibOpGreaterThan`
- **Functions**: `integrity` (L20), `run` (L28), `referenceFn` (L46)
- **Using**: `LibDecimalFloat for Float`

### A64: `src/lib/op/logic/LibOpGreaterThanOrEqualTo.sol`
- **Library**: `LibOpGreaterThanOrEqualTo`
- **Functions**: `integrity` (L20), `run` (L29), `referenceFn` (L47)
- **Using**: `LibDecimalFloat for Float`

### A65: `src/lib/op/logic/LibOpIf.sol`
- **Library**: `LibOpIf`
- **Functions**: `integrity` (L20), `run` (L29), `referenceFn` (L47)
- **Using**: `LibDecimalFloat for Float`

### A66: `src/lib/op/logic/LibOpIsZero.sol`
- **Library**: `LibOpIsZero`
- **Functions**: `integrity` (L19), `run` (L27), `referenceFn` (L42)
- **Using**: `LibDecimalFloat for Float`

### A67: `src/lib/op/logic/LibOpLessThan.sol`
- **Library**: `LibOpLessThan`
- **Functions**: `integrity` (L20), `run` (L28), `referenceFn` (L46)
- **Using**: `LibDecimalFloat for Float`

### A68: `src/lib/op/logic/LibOpLessThanOrEqualTo.sol`
- **Library**: `LibOpLessThanOrEqualTo`
- **Functions**: `integrity` (L20), `run` (L29), `referenceFn` (L47)
- **Using**: `LibDecimalFloat for Float`

---

## Findings

### A53-P4-1: Missing safe-cast explanatory comment in LibOpUint256ERC721BalanceOf referenceFn [INFO]

**File**: `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol`, line 72

In `referenceFn`, the `account` variable's safe cast is missing the standard explanatory comment that all other files in this batch consistently include before forge-lint suppressions for post-validation casts. The `token` cast on line 70 has the full comment, but `account` on line 72 only has the `forge-lint` suppression:

```solidity
        // Casting to `uint160` is safe because `NotAnAddress` above
        // ensures the value fits in 160 bits.
        //forge-lint: disable-next-line(unsafe-typecast)
        address token = address(uint160(tokenValue));
        //forge-lint: disable-next-line(unsafe-typecast)   // <-- missing explanatory comment
        address account = address(uint160(accountValue));
```

Every other file in this batch (A44-A52, A47-A49) includes the "Casting to `uint160` is safe because `NotAnAddress` above ensures the value fits in 160 bits." comment before each post-validation forge-lint suppression.

### A44-P4-1: Split imports from same module in float-variant ERC20 files [INFO]

**Files**: `src/lib/op/erc20/LibOpERC20Allowance.sol` (lines 8, 12), `src/lib/op/erc20/LibOpERC20BalanceOf.sol` (lines 8, 12), `src/lib/op/erc20/LibOpERC20TotalSupply.sol` (lines 8, 12)

These three files import `OperandV2` and `StackItem` from `rain.interpreter.interface/interface/IInterpreterV4.sol` on two separate import lines:

```solidity
import {OperandV2} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
// ... other imports ...
import {StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
```

All other files in this batch (A47-A68) that need both symbols combine them into a single import:

```solidity
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
```

This is a style inconsistency across the ERC20 op files. The three float-variant files are the only ones in this 25-file batch that split the import.
