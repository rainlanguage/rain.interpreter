# Pass 5 -- Correctness / Intent Verification: Errors, Eval, Integrity, Extern

Files audited: A09-A29

## Findings

### A18-P5-1 (LOW) -- `ExternDispatchConstantsHeightOverflow` NatSpec says "single byte" but check uses 16-bit limit

**File:** `src/error/ErrSubParse.sol` (line 8-11)

**NatSpec (line 8-9):**
> Thrown when a subparser is asked to build an extern dispatch when the constants height is outside the range a single byte can represent.

**Actual check in `src/lib/parse/LibSubParse.sol` (line 172):**
```solidity
if (constantsHeight > type(uint16).max) {
    revert ExternDispatchConstantsHeightOverflow(constantsHeight);
}
```

`type(uint16).max` is 65535 (a 2-byte / 16-bit limit), not 255 (a 1-byte / 8-bit limit). The NatSpec claims the error triggers when the value exceeds a single byte, but the implementation allows values up to 65535. The sibling error `ConstantOpcodeConstantsHeightOverflow` correctly describes its threshold as "the 16-bit operand encoding."

---

### A17-P5-1 (LOW) -- `OddSetLength` NatSpec says "a `set` call" but error is also thrown in `eval4`

**File:** `src/error/ErrStore.sol` (line 8-10)

**NatSpec (line 8):**
> Thrown when a `set` call is made with an odd number of arguments.

**Actual usage:**
1. `src/concrete/RainterpreterStore.sol` line 51-52 -- inside `set()` function for `kvs.length % 2 != 0`. Matches NatSpec.
2. `src/concrete/Rainterpreter.sol` line 63-64 -- inside `eval4()` for `eval.stateOverlay.length % 2 != 0`. This is NOT a `set` call; it validates the `stateOverlay` array during evaluation.

The NatSpec ties the error exclusively to the `set` function, but the error is also used to validate `stateOverlay` in `eval4`. The NatSpec should describe the general condition (odd-length key/value array) rather than a specific call site.

---

### A14-P5-1 (INFO) -- `BadDynamicLength` NatSpec describes the relationship backwards and parameter name is misleading

**File:** `src/error/ErrOpList.sol` (line 8-12)

**NatSpec (line 8):**
> Thrown when a dynamic length array is NOT 1 more than a fixed length array.

**Actual relationship:** The fixed-length array has `N + 1` elements (one extra slot for the length prefix). The dynamic array's `.length` should equal `N`. So the fixed array is 1 more than the dynamic array, not the other way around. The NatSpec says "dynamic is NOT 1 more than fixed" which reverses the relationship.

**Parameter name:** The second parameter is named `standardOpsLength`, but the error is also used for literal parser, operand handler, and integrity function pointer arrays (in `LibAllStandardOps.sol` lines 366-367, and `RainterpreterReferenceExtern.sol`). In those contexts the value is `LITERAL_PARSERS_LENGTH` or similar, not a standard ops length.

---

### A10-P5-1 (INFO) -- `Deploy.sol` NatSpec omits "dispair-registry" from supported suite list

**File:** `script/Deploy.sol` (line 28-32)

**NatSpec (line 31):**
> The `DEPLOYMENT_SUITE` env var selects which component to deploy: "parser", "store", "interpreter", or "expression-deployer".

**Actual code:** The script also handles `DEPLOYMENT_SUITE_DISPAIR_REGISTRY` (line 101) for the value `"dispair-registry"`. The NatSpec lists only four suite options but the code supports five.
