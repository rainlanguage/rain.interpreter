# Pass 5 (Correctness / Intent Verification) Summary — 2026-03-04-01

## Coverage

127 source files reviewed across 7 agent batches covering all non-generated Solidity (107 files) and all Rust source files (20 files).

## Findings

### LOW Findings (6)

| ID | File | Description |
|----|------|-------------|
| A18-P5-1 | `src/error/ErrSubParse.sol` | `ExternDispatchConstantsHeightOverflow` NatSpec says "single byte" but actual check uses `uint16` (16-bit limit) |
| A17-P5-1 | `src/error/ErrStore.sol` | `OddSetLength` NatSpec says "a `set` call" but error is also thrown in `eval4()` for `stateOverlay` |
| A108-P5-1 | `src/lib/parse/LibParseStackTracker.sol` | `ParseStackTracker` NatSpec claims 128/128-bit split; actual layout is 8/8/240-bit (current/inputs/max) |
| A102-P5-1 | `src/lib/parse/LibParse.sol` | `SUB_PARSER_BYTECODE_HEADER_SIZE` NatSpec describes fields that don't exist in the header |
| R12-P5-1 | `crates/eval/src/eval.rs` | `fork_parse` doc references non-existent `deployExpression2` call |
| R20-P5-1 | `crates/test_fixtures/src/lib.rs` | Doc says "to" field when it means "from" field |

### INFO Findings (8)

| ID | File | Description |
|----|------|-------------|
| A01-P5-1 | `src/abstract/BaseRainterpreterExtern.sol` | Undocumented `view`/`pure` asymmetry on function pointer getters |
| A10-P5-1 | `script/Deploy.sol` | NatSpec omits "dispair-registry" from supported deployment suites |
| A14-P5-1 | `src/error/ErrOpList.sol` | `BadDynamicLength` NatSpec reverses fixed/dynamic relationship |
| A31-P5-1 | `src/lib/op/00/LibOpContext.sol` | Swapped "row"/"column" labels in NatSpec |
| A73-P5-1 | `src/lib/op/math/LibOpDiv.sol` | `referenceFn` div-by-zero sentinel is dead code |
| A80-P5-1 | `src/lib/op/math/LibOpHeadroom.sol` | Comment says "1 - frac(x)" but code implements `ceil(x) - x` |
| R02-P5-1 | `crates/cli/src/commands/eval.rs` | Eval CLI help says "parse" instead of "evaluate" |
| R02-P5-2 | `crates/cli/src/commands/eval.rs` | Eval hardcodes `Binary` encoding but writes debug text |
| R19-P5-1 | `crates/parser/src/v2.rs` | Swapped "offset"/"length" comments in test |

## Files with No Findings

118 of 127 files had no findings. Key correctness properties verified:
- All 72 opcode `integrity` functions correctly declare input/output counts
- All `run` functions' assembly matches NatSpec descriptions
- All `referenceFn` implementations match their `run` counterparts
- All ERC interface calls use correct methods (ERC-20, ERC-721, ERC-5313)
- All bitmasks have correct widths and offsets match struct layouts
- `LibAllStandardOps` four parallel arrays are consistently ordered across all 72 entries
- Parse state struct offsets match field ordering
- Stack name fingerprint extraction is consistent between storage and lookup
- `LibExtern` encode/decode functions are symmetric and correct
- Eval loop opcode dispatch, integrity walk, and namespace qualification all verified correct
- Rust `qualify_namespace` matches Solidity `LibNamespace.qualifyNamespace` byte layout
