# Pass 1 — Security: LibParseStackName (A107)

**File:** `src/lib/parse/LibParseStackName.sol`

## Evidence

### Library
- `LibParseStackName` (line 21)

### Functions
| Function | Line | Visibility |
|---|---|---|
| `pushStackName(ParseState memory, bytes32)` | 31 | internal pure |
| `stackNameIndex(ParseState memory, bytes32)` | 62 | internal pure |

### Types / Errors / Constants
- None defined in this file
- Imports: `ParseState` from `LibParseState.sol`

## Assembly Review

### `pushStackName` — fingerprint and allocation (lines 38-44)
```solidity
assembly ("memory-safe") {
    mstore(0, word)
    fingerprint := and(keccak256(0, 0x20), not(0xFFFFFFFF))
    ptr := mload(0x40)
    mstore(ptr, oldStackNames)
    mstore(0x40, add(ptr, 0x20))
}
```

**Breakdown:**
1. `mstore(0, word)` — writes to scratch space (0x00). Allowed under `memory-safe`.
2. `keccak256(0, 0x20)` — hashes the 32-byte word from scratch space.
3. `and(..., not(0xFFFFFFFF))` — zeroes the bottom 32 bits, keeping the top 224 bits as the fingerprint.
4. `mload(0x40)` — reads the free memory pointer. Standard allocation pattern.
5. `mstore(ptr, oldStackNames)` — writes the previous linked list head to the newly allocated slot.
6. `mstore(0x40, add(ptr, 0x20))` — bumps the free memory pointer by 32 bytes.

This is a standard memory allocation pattern. The `memory-safe` annotation is accurate: scratch space is used for hashing, and new memory is allocated via the free memory pointer.

**16-bit pointer safety:** The `ptr` value is stored in the low 16 bits of `state.stackNames` (line 48: `fingerprint | (stackLHSIndex << 0x10) | ptr`). If `ptr >= 0x10000`, the high bits would be silently truncated, corrupting the linked list. This is prevented by the `checkParseMemoryOverflow` post-condition enforced at the entry points (`RainterpreterParser.parse2` and `parsePragma1`), which reverts if the free memory pointer reaches or exceeds `0x10000`.

### `stackNameIndex` — bloom filter and linked list traversal (lines 67-86)
```solidity
assembly ("memory-safe") {
    mstore(0, word)
    fingerprint := shr(0x20, keccak256(0, 0x20))
    bloom := shl(and(fingerprint, 0xFF), 1)

    if and(bloom, stackNameBloom) {
        for { let ptr := and(stackNames, 0xFFFF) } iszero(iszero(ptr)) {
            stackNames := mload(ptr)
            ptr := and(stackNames, 0xFFFF)
        } {
            if eq(fingerprint, shr(0x20, stackNames)) {
                exists := true
                index := and(shr(0x10, stackNames), 0xFFFF)
                break
            }
        }
    }
}
```

**Breakdown:**
1. `mstore(0, word)` — scratch space write. Fine.
2. `keccak256(0, 0x20)` — hashes the word. `shr(0x20, ...)` right-shifts by 32 bits to get the upper 224 bits into bits [223:0]. Note: this produces a different 224-bit value than `pushStackName` which uses `and(keccak256(...), not(0xFFFFFFFF))` to keep bits [255:32].

**Wait — fingerprint mismatch analysis:**

In `pushStackName` (line 40):
```
fingerprint := and(keccak256(0, 0x20), not(0xFFFFFFFF))
```
This keeps bits [255:32] and zeroes bits [31:0]. The result is stored in the top bits of the node word.

In `stackNameIndex` (line 69):
```
fingerprint := shr(0x20, keccak256(0, 0x20))
```
This right-shifts by 32 bits, moving bits [255:32] to [223:0].

The comparison at line 79:
```
if eq(fingerprint, shr(0x20, stackNames))
```
`shr(0x20, stackNames)` right-shifts the stored node by 32 bits. The stored node has structure: `fingerprint_bits[255:32] | stackIndex[31:16] | ptr[15:0]`. After `shr(0x20, ...)`, this becomes `fingerprint_bits[223:0] | stackIndex_partial`.

Actually, let me re-analyze more carefully:

- **Stored node** (from `pushStackName` line 48): `fingerprint | (stackLHSIndex << 0x10) | ptr`
  - `fingerprint` = `keccak256 & ~0xFFFFFFFF` = bits [255:32] of hash, bits [31:0] are zero
  - `stackLHSIndex << 0x10` occupies bits [23:16] (since stackLHSIndex <= 0xFF)
  - `ptr` occupies bits [15:0]
  - Combined: hash_bits[255:32] in [255:32], stackIndex in [23:16], ptr in [15:0]

- **Lookup fingerprint** (from `stackNameIndex` line 69): `shr(0x20, keccak256(0, 0x20))`
  - = hash_bits[255:32] shifted to [223:0]

- **Comparison** (line 79): `eq(fingerprint, shr(0x20, stackNames))`
  - `shr(0x20, stackNames)` = hash_bits[255:32] shifted to [223:0] | stackIndex in bits [7:0] (approximately)
  - Wait: `shr(0x20, node)` shifts the entire 256-bit node right by 32 bits. The top 224 bits of the node (the fingerprint) move to bits [223:0]. The former bits [31:0] (stackIndex | ptr) are lost (shifted out). But the bits that were at [31:16] (stackIndex) and [15:0] (ptr) shift into the lowest 32 bits? No — `shr(0x20, ...)` shifts right by 32 *bits* (0x20 = 32 decimal).

Wait. In EVM, `shr` takes a *bit* shift count. `shr(0x20, x)` shifts `x` right by 32 *bits*.

So `shr(0x20, stackNames)`:
- Original stackNames bits [255:32] → new bits [223:0]
- Original stackNames bits [31:0] are discarded (shifted out)

The lookup `fingerprint` = `shr(0x20, keccak256(...))`:
- Hash bits [255:32] → bits [223:0]

So the comparison `eq(fingerprint, shr(0x20, stackNames))` is:
- `hash[255:32] >> 32` == `(hash[255:32] | index_bits | ptr_bits) >> 32`
- = `hash[223:0]` == `hash[223:0]` (since bits [31:0] of the stored node are shifted out)

This is correct. The fingerprint comparison discards the low 32 bits (stackIndex and ptr) by right-shifting, and compares only the hash portion.

3. **Bloom filter**: `bloom := shl(and(fingerprint, 0xFF), 1)` — uses the low 8 bits of the shifted fingerprint (which are hash bits [39:32]) as the bloom key. A single bit is set. The bloom is checked with `and(bloom, stackNameBloom)`.

4. **Linked list traversal**: `ptr := and(stackNames, 0xFFFF)` extracts the 16-bit pointer. `mload(ptr)` dereferences it to load the next node. The loop terminates when `ptr == 0` (end of list). All pointers were allocated via the free memory pointer in `pushStackName`, so they point to valid allocated memory (as long as `checkParseMemoryOverflow` holds).

**`memory-safe` annotation:** This block writes to scratch space (0x00) and reads from allocated memory via computed pointers. No new allocations. The annotation is accurate.

## Security Assessment

### Fingerprint collision risk (INFO — by design)
The 224-bit fingerprint from keccak256 has a negligible collision probability (~2^-112 for birthday bound). This is a standard space-time tradeoff for parser-time name lookups and is not a security concern.

### 16-bit pointer truncation
The linked list uses 16-bit memory pointers. If the free memory pointer exceeds 0x10000, pointers would silently truncate, corrupting the linked list. This is mitigated by the `checkParseMemoryOverflow` post-condition at the parser entry points. The mitigation is sound — it reverts the entire parse transaction if memory usage exceeds the limit.

No findings.
