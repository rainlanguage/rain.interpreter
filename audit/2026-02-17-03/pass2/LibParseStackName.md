# Pass 2 — Test Coverage: LibParseStackName

**Source:** `src/lib/parse/LibParseStackName.sol`
**Test:** `test/src/lib/parse/LibParseStackName.t.sol`

## Source Inventory

### Functions

| Function | Line | Visibility |
|---|---|---|
| `pushStackName(ParseState memory, bytes32)` | 31 | internal pure |
| `stackNameIndex(ParseState memory, bytes32)` | 62 | internal pure |

### Errors Used

None declared locally. No reverts in this library.

### Key Internals

- 224-bit fingerprint derived from `keccak256(word)` (line 40, 69)
- 256-position bloom filter via low 8 bits of fingerprint (line 71)
- Singly-linked list with 16-bit node pointers (line 75-84)
- Stack index derived from `state.topLevel1 & 0xFF` (line 47)

## Test Coverage Analysis

### Direct Tests (LibParseStackName.t.sol)

| Test | What It Covers |
|---|---|
| `testPushAndRetrieveStackNameSingle` | Push one name, retrieve it. Fuzz on state and word. |
| `testPushAndRetrieveStackNameDouble` | Push two distinct names, retrieve both by index. |
| `testPushAndRetrieveStackNameDoubleIdentical` | Push same name twice, verify dedup (exists=true). |
| `testPushAndRetrieveStackNameMany` | Push 1-100 names sequentially, retrieve all. |

### Indirect Coverage

- `stackNameIndex` and `pushStackName` are not referenced in any other test files.
- Integration coverage happens via `LibParse` tests (e.g., `LibParse.namedLHS.t.sol`, `LibParse.singleLHSNamed.gas.t.sol`, `LibParse.singleRHSNamed.gas.t.sol`) which exercise the parser end-to-end with named LHS items.

## Findings

### A41-1: No test for bloom filter false positive path (LOW)

The bloom filter can produce false positives (bloom bit is set but no matching fingerprint exists in the linked list). No test explicitly constructs a scenario where a bloom hit leads to a full linked-list traversal with no match. The fuzz tests may hit this probabilistically but it is not asserted.

**Evidence:** `stackNameIndex` lines 74-84 show the bloom-hit-then-miss path. No test asserts `exists == false` after the bloom filter has been populated with a different word that shares the same low 8 bits.

### A41-2: No test for fingerprint collision behavior (LOW)

Two different words could produce the same 224-bit fingerprint (keccak collision). This is astronomically unlikely but the code silently returns the wrong index in that case. No test documents this as accepted behavior.

**Evidence:** Line 79 compares only the fingerprint, not the original word.

### A41-3: No negative lookup test on populated list (LOW)

All tests that call `stackNameIndex` directly do so after pushing the same word. There is no test that pushes word A, then looks up word B (where B was never pushed) and asserts `exists == false, index == 0`. The `testPushAndRetrieveStackNameDouble` test only looks up words that were pushed.

**Evidence:** The `testPushAndRetrieveStackNameMany` test (line 79) pushes N words then retrieves all N, but never queries a word that was not pushed.

### A41-4: stackNameBloom update on miss not verified (INFO)

`stackNameIndex` updates `state.stackNameBloom` unconditionally (line 87), even on a miss. No test verifies that calling `stackNameIndex` for a word that does not exist still updates the bloom filter. This is benign behavior (optimistic bloom population) but untested.

**Evidence:** Line 87 merges the bloom bit regardless of `exists`.
