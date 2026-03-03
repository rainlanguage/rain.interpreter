# Pass 1 (Security) -- RainterpreterStore.sol

**Auditor**: A50
**Date**: 2026-03-01
**File**: `src/concrete/RainterpreterStore.sol` (69 lines)

## Evidence of Thorough Reading

**Contract**: `RainterpreterStore` (line 25), inherits `IInterpreterStoreV3`, `ERC165`

**Using directive**: `LibNamespace` for `StateNamespace` (line 26)

### Imports

| Import | Source | Line |
|---|---|---|
| `ERC165` | `openzeppelin-contracts/contracts/utils/introspection/ERC165.sol` | 5 |
| `IInterpreterStoreV3` | `rain.interpreter.interface/interface/IInterpreterStoreV3.sol` | 7 |
| `LibNamespace`, `FullyQualifiedNamespace`, `StateNamespace` | `rain.interpreter.interface/lib/ns/LibNamespace.sol` | 8-12 |
| `BYTECODE_HASH` (as `STORE_BYTECODE_HASH`) | `../generated/RainterpreterStore.pointers.sol` | 16 |
| `OddSetLength` | `../error/ErrStore.sol` | 17 |

### State Variables

| Variable | Type | Visibility | Line |
|---|---|---|---|
| `sStore` | `mapping(FullyQualifiedNamespace => mapping(bytes32 => bytes32))` | internal | 40 |

### Functions

| Function | Signature | Visibility | Modifiers | Line |
|---|---|---|---|---|
| `supportsInterface` | `(bytes4) -> (bool)` | public view virtual override | -- | 43 |
| `set` | `(StateNamespace, bytes32[] calldata) -> ()` | external virtual | -- | 48 |
| `get` | `(FullyQualifiedNamespace, bytes32) -> (bytes32)` | external view virtual | -- | 66 |

### Errors (imported)

| Error | Parameters | Source | Line |
|---|---|---|---|
| `OddSetLength` | `uint256 length` | `src/error/ErrStore.sol` | 17 |

### Events (from interface)

| Event | Parameters |
|---|---|
| `Set` | `FullyQualifiedNamespace namespace, bytes32 key, bytes32 value` |

### Types (from interface)

| Type | Underlying | Definition |
|---|---|---|
| `StateNamespace` | `uint256` | User-defined value type |
| `FullyQualifiedNamespace` | `uint256` | User-defined value type |

---

## Security Analysis

### Namespace Isolation

The `set` function qualifies the caller-provided `StateNamespace` with `msg.sender` at line 55:

```solidity
FullyQualifiedNamespace fullyQualifiedNamespace = namespace.qualifyNamespace(msg.sender);
```

`qualifyNamespace` (in `LibNamespace`) computes `keccak256(stateNamespace, sender)`, producing a 256-bit hash. This makes it computationally infeasible for one `msg.sender` to produce a `FullyQualifiedNamespace` that collides with another sender's namespace.

**Conclusion**: Write isolation is correctly enforced. One user cannot write to another user's storage.

### Can One User Read Another User's Storage?

The `get` function at line 66 accepts a `FullyQualifiedNamespace` directly:

```solidity
function get(FullyQualifiedNamespace namespace, bytes32 key) external view virtual returns (bytes32) {
    return sStore[namespace][key];
}
```

Any address can read any other address's stored values by computing the appropriate `FullyQualifiedNamespace`. This is by design per the `IInterpreterStoreV3` interface spec, which documents: "Technically also allows onchain reads of any set value from any contract." All on-chain storage is publicly readable via `eth_getStorageAt` regardless, so no confidentiality expectation exists.

**Conclusion**: Read access is intentionally unrestricted. Not a vulnerability.

### Assembly Memory Safety

`RainterpreterStore.sol` contains no inline assembly. The `LibNamespace.qualifyNamespace` function called at line 55 uses assembly to write to scratch space (`0x00`-`0x3f`) and compute `keccak256`:

```solidity
assembly ("memory-safe") {
    mstore(0, stateNamespace)
    mstore(0x20, sender)
    qualifiedNamespace := keccak256(0, 0x40)
}
```

This is marked `memory-safe` and correctly uses only the EVM scratch space (bytes 0-63), which Solidity reserves for hashing. It does not allocate or corrupt memory.

**Conclusion**: No memory safety issues.

### Storage Collision Risks

The `sStore` mapping uses `FullyQualifiedNamespace` (a keccak256 hash) as its first key. Solidity storage layout for nested mappings computes the slot as `keccak256(key, keccak256(innerKey, slot))`. Since `FullyQualifiedNamespace` is itself a keccak256 output, the probability of storage slot collision is negligible (2^-256).

There is only one state variable (`sStore`), so there are no slot overlap concerns with other storage variables.

**Conclusion**: No storage collision risk.

### Unchecked Arithmetic

The `set` function wraps its loop in `unchecked` (lines 54-62):

- `i += 2`: Bounded by `i < kvs.length`, and `kvs.length` is bounded by calldata size (max ~16M bytes on mainnet, well below `type(uint256).max`). Cannot overflow.
- `i + 1`: Safe because `kvs.length` is verified even at line 51, so when `i` is a valid even index, `i + 1` is always in bounds.
- Calldata array indexing (`kvs[i]`, `kvs[i + 1]`) is bounds-checked by the Solidity compiler regardless of `unchecked`.

**Conclusion**: Unchecked arithmetic is provably safe.

### Reentrancy

`set` performs only storage writes and event emissions -- no external calls. `get` is a pure view function. Neither function has reentrancy risk.

### Access Control

`set` is `external virtual` with no access restriction beyond namespace qualification. Any address can call `set` and will write to their own namespace. This is the intended design -- the store is a shared utility contract.

`get` is `external view virtual` with no access restriction. Read access is unrestricted by design.

`supportsInterface` is `public view virtual override` and is a standard ERC-165 implementation.

---

## Findings

### A50-1 -- INFO: `get()` accepts pre-qualified namespace without sender verification

**Location**: Line 66-68

**Description**: The `get` function accepts a `FullyQualifiedNamespace` directly, allowing any caller to read any namespace's data. This is intentional per the interface specification and does not constitute a vulnerability since on-chain storage is publicly observable regardless.

**Severity**: INFO

### A50-2 -- INFO: `set()` event emission for duplicate keys

**Location**: Lines 56-61

**Description**: When the same key appears multiple times in the `kvs` array, `Set` is emitted for each occurrence. Only the last value persists in storage, but all events are logged. Event consumers (indexers, off-chain systems) must be aware that for a given key within a single `set` call, only the last emitted `Set` event reflects the final state. The NatSpec at lines 23-24 documents this: "doesn't attempt to do any deduping etc. if the same key appears twice it will be set twice."

**Severity**: INFO

### A50-3 -- INFO: Unchecked arithmetic in `set()` is provably safe

**Location**: Lines 54-62

**Description**: The `unchecked` block wraps loop arithmetic (`i += 2`, `i + 1`). The odd-length check at line 51 guarantees `kvs.length` is even, so `i + 1` is always in bounds when `i < kvs.length`. The loop increment `i += 2` cannot overflow because `kvs.length` is bounded by calldata size.

**Severity**: INFO

### A50-4 -- INFO: No constructor or initializer

**Description**: The contract has no constructor or initializer. The `sStore` mapping defaults to zero for all keys, and `ERC165` has no constructor side effects. This is correct -- no initialization is needed.

**Severity**: INFO

---

## Summary

No CRITICAL, HIGH, MEDIUM, or LOW findings. `RainterpreterStore` is a 69-line contract with a single state variable, three functions, no assembly, no external calls, and correct namespace isolation via `keccak256(stateNamespace, msg.sender)`. The write path enforces sender isolation; the read path is intentionally unrestricted. The unchecked arithmetic is bounded by the prior parity check. The contract is straightforward and secure.
