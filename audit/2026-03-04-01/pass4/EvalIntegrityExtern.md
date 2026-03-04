# Pass 4 Findings: Eval, Integrity, and Extern Libraries (A21-A29)

## Files Reviewed

| Agent ID | File |
|----------|------|
| A21 | `src/lib/eval/LibEval.sol` |
| A22 | `src/lib/extern/LibExtern.sol` |
| A23 | `src/lib/extern/reference/literal/LibParseLiteralRepeat.sol` |
| A24 | `src/lib/extern/reference/op/LibExternOpContextCallingContract.sol` |
| A25 | `src/lib/extern/reference/op/LibExternOpContextRainlen.sol` |
| A26 | `src/lib/extern/reference/op/LibExternOpContextSender.sol` |
| A27 | `src/lib/extern/reference/op/LibExternOpIntInc.sol` |
| A28 | `src/lib/extern/reference/op/LibExternOpStackOperand.sol` |
| A29 | `src/lib/integrity/LibIntegrityCheck.sol` |

## Evidence

### A21: LibEval.sol

- **Library**: `LibEval`
- **Functions**:
  - `evalLoop(InterpreterState memory, uint256, Pointer, Pointer) returns (Pointer)` (line 41) -- internal view
  - `eval4(InterpreterState memory, StackItem[] memory, uint256) returns (StackItem[] memory, bytes32[] memory)` (line 191) -- internal view
- **Imports**: `LibInterpreterState`, `InterpreterState`, `LibMemCpy`, `LibMemoryKV`, `MemoryKV`, `LibBytecode`, `Pointer`, `OperandV2`, `StackItem`, `InputsLengthMismatch` -- all used
- **No dead code, no commented-out code, no unused imports**

### A22: LibExtern.sol

- **Library**: `LibExtern`
- **Functions**:
  - `encodeExternDispatch(uint256, OperandV2) returns (ExternDispatchV2)` (line 27) -- internal pure
  - `decodeExternDispatch(ExternDispatchV2) returns (uint256, OperandV2)` (line 35) -- internal pure
  - `encodeExternCall(IInterpreterExternV4, ExternDispatchV2) returns (EncodedExternDispatchV2)` (line 56) -- internal pure
  - `decodeExternCall(EncodedExternDispatchV2) returns (IInterpreterExternV4, ExternDispatchV2)` (line 70) -- internal pure
- **Imports**: `IInterpreterExternV4`, `ExternDispatchV2`, `EncodedExternDispatchV2`, `OperandV2`, `StackItem` -- all used (StackItem re-exported per documented convention)
- **No dead code, no commented-out code**

### A23: LibParseLiteralRepeat.sol

- **Library**: `LibParseLiteralRepeat`
- **Functions**:
  - `parseRepeat(uint256, uint256, uint256) returns (uint256)` (line 53) -- internal pure
- **Constants**: `MAX_REPEAT_LITERAL_LENGTH` (line 34)
- **Errors**: `RepeatLiteralTooLong(uint256)` (line 39), `RepeatDispatchNotDigit(uint256)` (line 43)
- **No dead code, no commented-out code, no unused imports**

### A24: LibExternOpContextCallingContract.sol

- **Library**: `LibExternOpContextCallingContract`
- **Functions**:
  - `subParser(uint256, uint256, OperandV2) returns (bool, bytes memory, bytes32[] memory)` (line 25) -- internal pure
- **No dead code, no commented-out code, no unused imports**

### A25: LibExternOpContextRainlen.sol

- **Library**: `LibExternOpContextRainlen`
- **Functions**:
  - `subParser(uint256, uint256, OperandV2) returns (bool, bytes memory, bytes32[] memory)` (line 33) -- internal pure
- **Constants**: `CONTEXT_CALLER_CONTEXT_COLUMN` (line 13), `CONTEXT_CALLER_CONTEXT_ROW_RAINLEN` (line 18)
- **No dead code, no commented-out code, no unused imports**

### A26: LibExternOpContextSender.sol

- **Library**: `LibExternOpContextSender`
- **Functions**:
  - `subParser(uint256, uint256, OperandV2) returns (bool, bytes memory, bytes32[] memory)` (line 23) -- internal pure
- **No dead code, no commented-out code, no unused imports**

### A27: LibExternOpIntInc.sol

- **Library**: `LibExternOpIntInc`
- **Functions**:
  - `run(OperandV2, StackItem[] memory) returns (StackItem[] memory)` (line 27) -- internal pure
  - `integrity(OperandV2, uint256, uint256) returns (uint256, uint256)` (line 44) -- internal pure
  - `subParser(uint256, uint256, OperandV2) returns (bool, bytes memory, bytes32[] memory)` (line 57) -- internal view
- **Constants**: `OP_INDEX_INCREMENT` (line 13)
- **No dead code, no commented-out code, no unused imports**

### A28: LibExternOpStackOperand.sol

- **Library**: `LibExternOpStackOperand`
- **Functions**:
  - `subParser(uint256, uint256, OperandV2) returns (bool, bytes memory, bytes32[] memory)` (line 23) -- internal pure
- **No dead code, no commented-out code, no unused imports**

### A29: LibIntegrityCheck.sol

- **Library**: `LibIntegrityCheck`
- **Struct**: `IntegrityCheckState` (line 35) with fields: `stackIndex`, `stackMaxIndex`, `readHighwater`, `constants`, `opIndex`, `bytecode`
- **Functions**:
  - `newState(bytes memory, uint256, bytes32[] memory) returns (IntegrityCheckState memory)` (line 56) -- internal pure
  - `integrityCheck2(bytes memory, bytes memory, bytes32[] memory) returns (bytes memory)` (line 91) -- internal view
- **Imports**: `Pointer`, `OpcodeOutOfRange`, `StackAllocationMismatch`, `StackOutputsMismatch`, `StackUnderflow`, `StackUnderflowHighwater`, `BadOpInputsLength`, `BadOpOutputsLength`, `LibBytecode`, `OperandV2` -- all used
- **No dead code, no commented-out code**

## Findings

### A22-P4-1 [INFO] Ambiguous parameter name `dispatch` used for two different types

**File**: `src/lib/extern/LibExtern.sol`
**Lines**: 35, 56, 70

The parameter name `dispatch` is used for both `ExternDispatchV2` (lines 35, 56) and `EncodedExternDispatchV2` (line 70) within the same library. These are semantically distinct types: `ExternDispatchV2` encodes an opcode+operand pair, while `EncodedExternDispatchV2` encodes an address+opcode+operand triple. Using the same parameter name for both obscures the difference.

```solidity
// Line 35: dispatch is ExternDispatchV2
function decodeExternDispatch(ExternDispatchV2 dispatch) ...

// Line 56: dispatch is ExternDispatchV2
function encodeExternCall(IInterpreterExternV4 extern, ExternDispatchV2 dispatch) ...

// Line 70: dispatch is EncodedExternDispatchV2
function decodeExternCall(EncodedExternDispatchV2 dispatch) ...
```

A name like `encodedCall` or `encodedExternDispatch` for line 70 would eliminate the ambiguity.

### A28-P4-1 [INFO] Inconsistent unused parameter handling across extern op subParsers

**File**: `src/lib/extern/reference/op/LibExternOpStackOperand.sol` (line 23)
**Compare**: `LibExternOpContextCallingContract.sol` (line 25), `LibExternOpContextRainlen.sol` (line 33), `LibExternOpContextSender.sol` (line 23)

`LibExternOpStackOperand.subParser` leaves its second parameter unnamed:
```solidity
function subParser(uint256 constantsHeight, uint256, OperandV2 operand)
```

While the three context op subParsers name the same parameter and use a tuple-discard statement:
```solidity
function subParser(uint256 constantsHeight, uint256 ioByte, OperandV2 operand)
    ...
{
    (constantsHeight, ioByte, operand);
    ...
}
```

Both approaches are valid Solidity, but using different patterns for the same role across sibling libraries in the same module family is a style inconsistency. The context ops also document the unused parameter with `@param ioByte The IO byte encoding inputs and outputs (unused).` while `LibExternOpStackOperand` has no corresponding documentation for the unnamed parameter.
