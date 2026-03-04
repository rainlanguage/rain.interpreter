# Pass 1 (Security) -- LibExternOpIntInc.sol (A27)

**File:** `src/lib/extern/reference/op/LibExternOpIntInc.sol`

## Evidence

### Library
- `LibExternOpIntInc` (line 18)

### Constants (file-level)
- `OP_INDEX_INCREMENT = 0` (line 13) -- opcode index for extern increment

### Using directives
- `using LibDecimalFloat for Float` (line 19)

### Functions
- `run(OperandV2, StackItem[] memory inputs) returns (StackItem[] memory)` -- line 27, `internal pure`
- `integrity(OperandV2, uint256 inputs, uint256) returns (uint256, uint256)` -- line 44, `internal pure`
- `subParser(uint256 constantsHeight, uint256 ioByte, OperandV2 operand) returns (bool, bytes memory, bytes32[] memory)` -- line 57, `internal view`

## Security Review

### `run` function (line 27-36)
- Iterates over `inputs`, wrapping each `StackItem` as a `Float`, adding decimal float value `1`, and writing it back.
- The `packLossless(1e37, -37)` correctly encodes the value 1 in the decimal float representation.
- In-place mutation of the `inputs` array is safe -- the caller (BaseRainterpreterExtern) expects the returned array and does not reuse the input array after the call.
- `Float.add` can revert on overflow/underflow in the float library. This is acceptable behavior for extreme values.

### `integrity` function (line 44-46)
- Returns `(inputs, inputs)`, meaning inputs == outputs. This correctly matches `run`, which produces one output per input.

### `subParser` function (line 57-66)
- Delegates to `LibSubParse.subParserExtern` with `address(this)` as the extern contract, `OP_INDEX_INCREMENT` (0) as the opcode index, and the caller-provided `constantsHeight`, `ioByte`, and `operand`.
- `OP_INDEX_INCREMENT` is 0, which is within uint16 range.
- The `subParserExtern` function validates `constantsHeight <= uint16 max`.

### No assembly
No assembly blocks in this library.

## Findings

No security findings.
