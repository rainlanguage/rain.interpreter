# LibExtern and Reference Extern Ops — Pass 3 (Documentation)

Agent: A09

## Evidence of Reading

### File 1: src/lib/extern/LibExtern.sol
- **Library:** `LibExtern` (line 17)
- **Functions:** `encodeExternDispatch` (24), `decodeExternDispatch` (29), `encodeExternCall` (47), `decodeExternCall` (58)

### File 2: src/lib/extern/reference/op/LibExternOpContextCallingContract.sol
- **Library:** `LibExternOpContextCallingContract` (line 15)
- **Functions:** `subParser` (19)

### File 3: src/lib/extern/reference/op/LibExternOpContextRainlen.sol
- **Library:** `LibExternOpContextRainlen` (line 14)
- **Constants:** `CONTEXT_CALLER_CONTEXT_COLUMN` (8), `CONTEXT_CALLER_CONTEXT_ROW_RAINLEN` (9)
- **Functions:** `subParser` (18)

### File 4: src/lib/extern/reference/op/LibExternOpContextSender.sol
- **Library:** `LibExternOpContextSender` (line 13)
- **Functions:** `subParser` (17)

### File 5: src/lib/extern/reference/op/LibExternOpIntInc.sol
- **Library:** `LibExternOpIntInc` (line 18)
- **Constants:** `OP_INDEX_INCREMENT` (13)
- **Functions:** `run` (25), `integrity` (37), `subParser` (44)

### File 6: src/lib/extern/reference/op/LibExternOpStackOperand.sol
- **Library:** `LibExternOpStackOperand` (line 14)
- **Functions:** `subParser` (16)

## Findings

### A09-1: `encodeExternDispatch` missing `@param` and `@return` tags
**Severity:** LOW

### A09-2: `decodeExternDispatch` missing `@param` and `@return` tags
**Severity:** LOW

### A09-3: `encodeExternCall` missing `@param` and `@return` tags
**Severity:** LOW

### A09-4: `decodeExternCall` missing `@param` and `@return` tags
**Severity:** LOW

### A09-5: `LibExternOpContextCallingContract.subParser` missing `@param` and `@return` tags
**Severity:** LOW

### A09-6: `LibExternOpContextRainlen.subParser` missing `@param` and `@return` tags
**Severity:** LOW

### A09-7: `CONTEXT_CALLER_CONTEXT_COLUMN` and `CONTEXT_CALLER_CONTEXT_ROW_RAINLEN` missing NatSpec
**Severity:** INFO

No `///` NatSpec describing what column 1 and row 0 represent in the context matrix.

### A09-8: `LibExternOpContextSender.subParser` missing `@param` and `@return` tags
**Severity:** LOW

### A09-9: `LibExternOpIntInc.run` missing `@param` and `@return` tags
**Severity:** LOW

### A09-10: `LibExternOpIntInc.integrity` missing `@param` and `@return` tags
**Severity:** LOW

### A09-11: `LibExternOpIntInc.subParser` missing `@param` and `@return` tags
**Severity:** LOW

### A09-12: `LibExternOpStackOperand.subParser` missing NatSpec entirely
**Severity:** LOW

Only function in the batch with zero function-level NatSpec.

### A09-13: `decodeExternDispatch` and `decodeExternCall` NatSpec descriptions are terse
**Severity:** INFO

Only say "Inverse of encode..." without documenting the bit layout.

### A09-14: `LibExternOpIntInc.run` NatSpec doesn't mention decimal float encoding
**Severity:** INFO

Says "increments every input by 1" but implementation operates in decimal float space, not raw uint256.
