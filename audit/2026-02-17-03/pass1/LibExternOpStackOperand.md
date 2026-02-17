# Pass 1 (Security) — LibExternOpStackOperand.sol

**File:** `src/lib/extern/reference/op/LibExternOpStackOperand.sol`

## Evidence of Thorough Reading

### Contract/Library Name

- `LibExternOpStackOperand` (library, line 14)

### Functions

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `subParser(uint256 constantsHeight, uint256, OperandV2 operand)` | 16 | `internal` | `pure` |

### Errors / Events / Structs Defined

None defined in this file.

### Imports

- `OperandV2` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 5)
- `LibSubParse` from `../../../parse/LibSubParse.sol` (line 6)

## Findings

### No findings

This is a minimal wrapper library consisting of a single 7-line function. It delegates entirely to `LibSubParse.subParserConstant(constantsHeight, OperandV2.unwrap(operand))`.

Security analysis:

1. **No assembly blocks** — The library contains no inline assembly. All assembly is in the callee (`LibSubParse.subParserConstant`), which is outside the scope of this file's audit.

2. **No unchecked arithmetic** — No arithmetic operations are performed in this library.

3. **No custom errors needed** — The function does not revert directly. Any revert (e.g., `ConstantOpcodeConstantsHeightOverflow`) is raised by `LibSubParse.subParserConstant` when `constantsHeight > 0xFFFF`.

4. **Type safety of the delegation** — `OperandV2` is defined as `type OperandV2 is bytes32` (in `IInterpreterV4.sol`). `OperandV2.unwrap(operand)` returns `bytes32`, which matches the `value` parameter type of `subParserConstant(uint256, bytes32)`. The type conversion is correct.

5. **Unused second parameter** — The second `uint256` parameter is unnamed and unused. This is intentional: the function signature must match the function pointer type used in `RainterpreterReferenceExtern`'s sub-parser dispatch table (line 325-327 of `RainterpreterReferenceExtern.sol`), where all sub-parser functions share the signature `function(uint256, uint256, OperandV2) internal view returns (bool, bytes memory, bytes32[] memory)`. The unused parameter carries no security risk.

6. **Slither annotations** — Two slither-disable annotations are present: `dead-code` (line 15) for the function itself (referenced only via function pointer), and `unused-return` (line 21) for the returned tuple (which is passed through as the return value). Both are appropriate.

7. **Operand passed as constant value** — The entire `bytes32` operand is used as the constant value pushed to the stack. This is by design: the NatSpec (lines 9-13) explains this op copies its operand value to the constants array at parse time, so it becomes a regular constant opcode at eval time. There is no truncation or misinterpretation risk because both types are `bytes32`.

No CRITICAL, HIGH, MEDIUM, LOW, or INFO issues identified in this file.
