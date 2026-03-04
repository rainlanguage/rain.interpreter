# Pass 3 Findings: Growth, Uint256, and Store Ops

## A96-P3-1 (LOW): Incorrect Rainlang word name in `run` NatSpec

**File:** `src/lib/op/math/uint256/LibOpUint256MaxValue.sol`
**Line:** 20

The `run` function NatSpec says `` `max-uint256` `` but the actual Rainlang word name registered in `LibAllStandardOps.sol` is `uint256-max-value`. The `integrity` and `referenceFn` NatSpec in the same file both correctly use `uint256-max-value`.

```solidity
/// @notice `max-uint256` opcode. Pushes type(uint256).max onto the stack.
```

Should be:

```solidity
/// @notice `uint256-max-value` opcode. Pushes type(uint256).max onto the stack.
```

## A98-P3-1 (LOW): Incorrect Rainlang word name in `integrity` NatSpec

**File:** `src/lib/op/math/uint256/LibOpUint256Power.sol`
**Line:** 14

The `integrity` function NatSpec says `` `uint256-pow` `` but the actual Rainlang word name registered in `LibAllStandardOps.sol` is `uint256-power`. The `run` NatSpec in the same file correctly uses `uint256-power`.

```solidity
/// @notice `uint256-pow` integrity check. Requires at least 2 inputs and produces 1 output.
```

Should be:

```solidity
/// @notice `uint256-power` integrity check. Requires at least 2 inputs and produces 1 output.
```
