# Pass 1 (Security) -- LibExternOpStackOperand.sol (A28)

**File:** `src/lib/extern/reference/op/LibExternOpStackOperand.sol`

## Evidence

### Library
- `LibExternOpStackOperand` (line 14)

### Functions
- `subParser(uint256 constantsHeight, uint256, OperandV2 operand) returns (bool, bytes memory, bytes32[] memory)` -- line 23, `internal pure`

## Security Review

### Delegation to LibSubParse.subParserConstant
The function delegates entirely to `LibSubParse.subParserConstant(constantsHeight, OperandV2.unwrap(operand))`.

- `subParserConstant` validates `constantsHeight <= type(uint16).max` (line 102 of LibSubParse.sol), reverting with `ConstantOpcodeConstantsHeightOverflow` if exceeded.
- `OperandV2.unwrap(operand)` produces a `bytes32` which is stored as-is in the constants array. No truncation or validation needed -- any bytes32 is a valid constant.

### No `run` or `integrity` functions
As documented in the NatSpec, this opcode does not dispatch to an extern at eval time. The sub parser emits an `OPCODE_CONSTANT`, so the interpreter handles it directly. No extern run/integrity functions are needed.

### Unused `ioByte` parameter
The second parameter (unnamed) is the `ioByte`, which is unused. The `subParserConstant` function hardcodes the IO byte to `0x10` (0 inputs, 1 output), which is correct for a constant push.

### No assembly
No assembly blocks in this library.

## Findings

No security findings.
