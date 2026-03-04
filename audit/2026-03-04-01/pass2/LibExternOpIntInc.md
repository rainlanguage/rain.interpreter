# Pass 2 — LibExternOpIntInc.sol

**Source**: `src/lib/extern/reference/op/LibExternOpIntInc.sol`
**Test**: `test/src/concrete/RainterpreterReferenceExtern.intInc.t.sol`

## Functions

| Function | Line | Tested |
|---|---|---|
| `run(OperandV2, StackItem[])` | 27 | Yes — `testRainterpreterReferenceExternIntIncRun` (fuzz, direct call) |
| `integrity(OperandV2, uint256, uint256)` | 44 | Yes — `testRainterpreterReferenceExternIntIncIntegrity` (fuzz, direct call) |
| `subParser(uint256, uint256, OperandV2)` | 57 | Indirect only — via `subParseWord2` integration test |

## Findings

### A27-1 (LOW): Missing direct unit test for `subParser`

Every other extern op library (`LibExternOpContextCallingContract`, `LibExternOpContextRainlen`, `LibExternOpContextSender`, `LibExternOpStackOperand`) has a dedicated `*.subParser.t.sol` test file that calls the library function directly and verifies the returned bytecode structure, constants, and success flag.

`LibExternOpIntInc.subParser` has no equivalent direct test. It is only tested indirectly through `testRainterpreterReferenceExternIntIncSubParseKnownWord`, which calls `subParseWord2` on the full `RainterpreterReferenceExtern` contract. That integration test exercises the function pointer dispatch path and verifies the end-to-end result, but does not isolate the library function.

A direct unit test would:
- Call `LibExternOpIntInc.subParser` directly with fuzzed `constantsHeight`, `ioByte`, and `operand`
- Verify the returned bytecode contains `OPCODE_EXTERN` with the correct IO byte and constants index
- Verify the constants array contains a single entry encoding `address(this)` as the extern contract and `OP_INDEX_INCREMENT` as the opcode
- Confirm the success flag is true

This is consistent with how all other extern op sub parsers are tested in this codebase.
