# Pass 1 (Security) -- LibExtern.sol & LibOpExtern.sol

Agents: A06 (LibExtern), A21 (LibOpExtern)

## Files

- `src/lib/extern/LibExtern.sol`
- `src/lib/op/00/LibOpExtern.sol`

## Evidence of Thorough Reading

### LibExtern.sol

**Library:** `library LibExtern` (line 17)

**Functions:**

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `encodeExternDispatch(uint256 opcode, OperandV2 operand)` | 27 | `internal` | `pure` |
| `decodeExternDispatch(ExternDispatchV2 dispatch)` | 35 | `internal` | `pure` |
| `encodeExternCall(IInterpreterExternV4 extern, ExternDispatchV2 dispatch)` | 56 | `internal` | `pure` |
| `decodeExternCall(EncodedExternDispatchV2 dispatch)` | 70 | `internal` | `pure` |

**Errors/Events/Structs/Constants:** None defined in this file.

**Imports:**
- `IInterpreterExternV4`, `ExternDispatchV2`, `EncodedExternDispatchV2` from `rain.interpreter.interface/interface/IInterpreterExternV4.sol` (lines 5-9)
- `OperandV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 12)

**User-defined types (from interface):**
- `ExternDispatchV2 is bytes32`
- `EncodedExternDispatchV2 is bytes32`
- `OperandV2 is bytes32`

### LibOpExtern.sol

**Library:** `library LibOpExtern` (line 23)

**Functions:**

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `integrity(IntegrityCheckState memory, OperandV2)` | 29 | `internal` | `view` |
| `run(InterpreterState memory, OperandV2, Pointer)` | 49 | `internal` | `view` |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` | 102 | `internal` | `view` |

**Errors/Events/Structs/Constants:** None defined. Errors imported:
- `NotAnExternContract` from `../../../error/ErrExtern.sol` (line 5, originally from `rain.interpreter.interface/error/ErrExtern.sol`)
- `BadOutputsLength` from `../../../error/ErrExtern.sol` (line 19)

**Imports:**
- `NotAnExternContract` from `../../../error/ErrExtern.sol` (line 5)
- `IntegrityCheckState` from `../../integrity/LibIntegrityCheck.sol` (line 6)
- `OperandV2` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 7)
- `InterpreterState` from `../../state/LibInterpreterState.sol` (line 8)
- `Pointer` from `rain.solmem/lib/LibPointer.sol` (line 9)
- `IInterpreterExternV4`, `ExternDispatchV2`, `EncodedExternDispatchV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterExternV4.sol` (lines 10-15)
- `LibExtern` from `../../extern/LibExtern.sol` (line 16)
- `LibBytes32Array` from `rain.solmem/lib/LibBytes32Array.sol` (line 17)
- `ERC165Checker` from `openzeppelin-contracts/contracts/utils/introspection/ERC165Checker.sol` (line 18)
- `BadOutputsLength` from `../../../error/ErrExtern.sol` (line 19)

## Security Analysis

### Encoding/Decoding Safety (LibExtern.sol)

**ExternDispatchV2 encoding** (line 28): `bytes32(opcode) << 0x10 | OperandV2.unwrap(operand)`
- Bits [0,16): operand low 16 bits
- Bits [16,32): opcode low 16 bits
- Bits above 32: any overflow from opcode > 16 bits or operand bits above 15
- No masking or validation. Documented as caller responsibility (lines 22-23).

**ExternDispatchV2 decoding** (lines 36-40):
- Opcode: `uint256(dispatch >> 0x10)` -- returns full 240 bits above bit 16, no mask to 16 bits.
- Operand: `dispatch & bytes32(uint256(0xFFFF))` -- properly masked to 16 bits.
- The unmasked opcode decode is not a vulnerability because: (a) the actual consumer in `BaseRainterpreterExtern.extern()` applies its own `& bytes32(uint256(type(uint16).max))` mask (line 71 of BaseRainterpreterExtern.sol), and (b) `decodeExternDispatch` is only used in tests.

**EncodedExternDispatchV2 encoding** (lines 61-63): `bytes32(uint256(uint160(address))) | dispatch << 160`
- Bits [0,160): extern address (safe, `uint160` truncation enforced by Solidity)
- Bits [160,256): dispatch (when correctly encoded, only bits [160,192) used)
- Roundtrip correct when dispatch uses only low 32 bits.

**EncodedExternDispatchV2 decoding** (lines 75-78):
- Address: `uint160(uint256(unwrap(dispatch)))` -- extracts low 160 bits cleanly.
- Dispatch: `unwrap(dispatch) >> 160` -- recovers bits [160,256).
- Roundtrip correct.

### Malformed Dispatch / Out-of-Bounds Access

If a malformed `EncodedExternDispatchV2` is stored in the constants array, `decodeExternCall` will extract whatever address and dispatch bits are present. The extern address could be an EOA or non-contract address. In `run()`, the call to `extern.extern()` on an EOA would revert (no code). In `integrity()`, the ERC165 check would fail and revert with `NotAnExternContract`. No out-of-bounds memory access is possible from malformed dispatch values.

The `encodedExternDispatchIndex` (low 16 bits of operand) is used to index `state.constants[]`. Solidity's built-in bounds checking applies. An index beyond the constants array causes a panic revert.

### ERC165 Check: Integrity vs Run

`integrity()` (line 35) checks `ERC165Checker.supportsInterface(address(extern), type(IInterpreterExternV4).interfaceId)`. `run()` does not repeat this check. This is by design: integrity runs at deploy time through the expression deployer, and the constants (including the extern address) are immutable after deployment. Re-checking at runtime would waste gas with no security benefit under the invariant that constants are immutable. If a proxy-based extern changed implementation post-deploy, the `extern.extern()` call would revert naturally if the interface is no longer supported.

### External Call Safety

Both `extern.extern()` calls (in `run` at line 71, `referenceFn` at line 113) occur within `internal view` functions. The top-level `eval4()` is `external view`, so all external calls are `staticcall`. State modifications are impossible, eliminating reentrancy concerns. The extern cannot call back into the interpreter to modify state.

### Return Data Validation

`run()` (line 72) checks `outputsLength != outputs.length` and reverts with `BadOutputsLength`. `referenceFn()` (line 114) does the same check. The Solidity ABI decoder handles malformed return data -- if the extern returns data that cannot be decoded as `StackItem[] memory`, the decoder reverts.

### Stack Manipulation Safety (LibOpExtern.run)

The assembly in `run()` (lines 59-93):
1. **Input array construction** (lines 59-70): Temporarily overwrites `sub(stackTop, 0x20)` to build an array length field. Original value saved in `head` and restored at line 79. The mutation window spans only the `extern.extern()` staticcall, which cannot observe or modify the caller's memory.
2. **Stack pointer adjustment** (line 80): `stackTop := add(stackTop, mul(inputsLength, 0x20))` pops inputs. Safe because integrity guarantees sufficient stack depth.
3. **Output reverse copy** (lines 82-92): Iterates outputs forward, writes to stack backward. Each iteration decrements stackTop by 0x20 and writes one output. The loop is bounded by `outputsLength` which was validated against `outputs.length`. Final stackTop = original + inputsLength*32 - outputsLength*32. Stack allocation was pre-computed during integrity to accommodate this.

All three assembly blocks are correctly annotated `"memory-safe"`:
- Block 1 (lines 59-70): Writes to stack memory within allocated region, saves/restores the overwritten word.
- Block 2 (lines 76-92): Restores saved word, reads from ABI-decoded array (allocated at free pointer), writes within pre-allocated stack.
- Block 3 in `referenceFn` (lines 119-121): Type-punning cast only, no memory access.

### Operand Bit Layout Consistency

Both `integrity()` and `run()` extract the same three fields identically:
- `encodedExternDispatchIndex`: `OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF))` -- 16 bits [0,16)
- `inputsLength` (integrity line 38, run line 51): `(operand >> 0x10) & 0x0F` -- 4 bits [16,20)
- `outputsLength` (integrity line 39, run line 52): `(operand >> 0x14) & 0x0F` -- 4 bits [20,24)

`referenceFn()` extracts the same `encodedExternDispatchIndex` and `outputsLength` but not `inputsLength` (receives inputs as an array parameter). Consistent.

## Findings

No new security findings above INFO severity.

Both files are unchanged since the previous audit (commit `31a6799f`). The previous audit's findings (A06-1 through A06-3 for LibExtern, A21-LOW-1 and A21-LOW-2 for LibOpExtern) were triaged and either fixed or dismissed. No new code has been introduced.

### A06-INFO-1: No assembly blocks in LibExtern.sol

All operations are pure Solidity bitwise operations on `bytes32` user-defined value types. No memory safety concerns, no pointer arithmetic, no unchecked blocks.

### A06-INFO-2: Encoding functions document lack of input validation

`encodeExternDispatch` (line 22-23) and `encodeExternCall` (lines 49-52) explicitly document that they do not validate input widths. This is appropriate for internal pure functions where the caller is responsible for providing correctly-sized values. The only production caller is the sub-parser path which provides compile-time constants.

### A21-INFO-1: Reentrancy impossible due to view/staticcall context

The `extern.extern()` calls in `run()` (line 71) and `referenceFn()` (line 113) execute as `staticcall` because the entire eval chain is `view`. State modification and reentrancy are structurally impossible.

### A21-INFO-2: Constants array access is bounds-checked by Solidity

`state.constants[encodedExternDispatchIndex]` at lines 33, 54, and 110 uses standard Solidity array indexing with automatic bounds checking. The maximum possible index is 65535 (16-bit operand field). An out-of-bounds index causes a Solidity panic revert.

### A21-INFO-3: Assembly memory-safe annotations are correct

All three assembly blocks in LibOpExtern are annotated `"memory-safe"` and verified to only read/write within previously allocated memory regions. The temporary mutation of the word before `stackTop` is saved/restored within the same function, and the mutation window spans only a `staticcall` which cannot observe the caller's memory.

### A21-INFO-4: Custom errors used correctly

All error paths use custom errors (`NotAnExternContract`, `BadOutputsLength`). No string revert messages. Consistent with project conventions.
