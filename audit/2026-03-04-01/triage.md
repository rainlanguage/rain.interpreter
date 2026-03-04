# Audit 2026-03-04-01 Triage

## Pass 0: Process

- [FIXED] P0-1: (LOW) GENERAL_RULES.md has rules not propagated to main audit SKILL.md — added reference to GENERAL_RULES.md from SKILL.md
- [FIXED] P0-2: (LOW) CLAUDE.md omits full command for LibInterpreterDeployTest — expanded to full nix develop -c forge test command
- [FIXED] P0-3: (LOW) TESTING.md only covers Solidity but referenced as general — added Rust testing conventions section
- [FIXED] P0-4: (LOW) Proposed fixes instructions missing from GENERAL_RULES.md — moved .fixes/ convention to GENERAL_RULES.md

## Pass 1: Security

- [FIXED] R11-RUST-01: (LOW) LocalForkId tracking assumes sequential IDs; create_select_fork return discarded — use actual return values from backend
- [DISMISSED] A05-1: (LOW) serializeSize overflow — carried forward; practically unreachable (prior A47-1)
- [DISMISSED] A21-1: (LOW) sourceIndex unchecked in eval — carried forward; documented trust assumption (prior A05-1)
- [DISMISSED] A21-2: (LOW) Empty fs div-by-zero — carried forward; constructor guard prevents (prior A05-2)

## Pass 2: Test Coverage

- [DISMISSED] P2-A02-01: (LOW) subParseWord2 missing happy-path tests — carried forward; tested indirectly (prior P2-EAD-01)
- [FIXED] P2-A08-01: (LOW) matchSubParseLiteralDispatch boundary digit 0 not tested through full stack — added testRainterpreterReferenceExternRepeatZero
- [FIXED] A27-1: (LOW) LibExternOpIntInc subParser lacks direct unit test — added fuzz test in LibExternOpIntInc.subParser.t.sol
- [FIXED] P2-A30-1: (LOW) Missing bad-inputs test for constant opcode — added testOpConstantOneInput and testOpConstantTwoInputs
- [FIXED] P2-A33-1: (LOW) Missing bad-inputs test for stack opcode — added testOpStackOneInput and testOpStackTwoInputs
- [FIXED] A38-1: (LOW) Missing explicit eval boundary test for bitwise-encode<1 0xFF> — added deterministic eval case
- [FIXED] A43-1: (LOW) No explicit eval test for hash with maximum inputs (15) — added testOpHashEval15Inputs
- [FIXED] A53-1: (LOW) Missing NotAnAddress revert tests for erc721 balance-of — added fuzz tests for token and account
- [FIXED] A71-1: (LOW) No negative-value deterministic eval examples for avg — added testOpAvgEvalNegativeExamples
- [FIXED] A73-1: (LOW) No negative-value deterministic eval examples for div — added testOpDivEvalNegativeExamples
- [FIXED] A88-1: (LOW) No negative-value deterministic eval examples for mul — added testOpMulEvalNegativeExamples
- [FIXED] A91-1: (LOW) No negative-value deterministic eval examples for sub; no overflow test — added testOpSubEvalNegativeExamples and testOpSubEvalOverflow
- [FIXED] A28-1: (LOW) Hex encoding and file-write paths in output.rs completely untested — added 4 tests in output.rs (hex/binary to file, empty bytes)
- [FIXED] A28-2: (LOW) flattened_trace_path_names unresolved-parent fallback untested — added test_flattened_trace_path_names_unresolved_parent
- [FIXED] A28-3: (LOW) into_flattened_table empty-results early-return untested — added test_into_flattened_table_empty_results
- [FIXED] A28-4: (LOW) search_trace_by_path stack index OOB error path untested — added test_search_trace_by_path_stack_index_out_of_bounds

## Pass 3: Documentation

- [FIXED] A21-P3-1: (LOW) Missing @title on LibEval library — added @title and @notice
- [FIXED] A29-P3-1: (LOW) IntegrityCheckState struct has untagged first line before @param tags — added explicit @notice
- [FIXED] A29-P3-2: (LOW) Missing @title on LibIntegrityCheck library — added @title and @notice
- [FIXED] A34-P3-1: (LOW) LibAllStandardOps all 5 functions use implicit @notice — added explicit @notice to all 5
- [FIXED] A34-P3-2: (LOW) LibAllStandardOps all 5 functions missing @return tags — added @return to all 5
- [FIXED] A42-P3-1: (LOW) LibOpCall integrity has single @return for two return values — split into two @return tags
- [FIXED] A59-P3-1: (LOW) referenceFn NatSpec says "condition" but word is "conditions" — fixed to "conditions"
- [FIXED] A96-P3-1: (LOW) run NatSpec says max-uint256 but Rainlang word is uint256-max-value — fixed to uint256-max-value
- [FIXED] A98-P3-1: (LOW) integrity NatSpec says uint256-pow but Rainlang word is uint256-power — fixed to uint256-power
- [FIXED] A103-P3-1: (LOW) Missing @title on LibParseError library — added @title and @notice
- [FIXED] A104-P3-1: (LOW) Missing @title on LibParseInterstitial library — added @title and @notice
- [FIXED] A116-P3-1: (LOW) Missing @title on LibInterpreterState library — added @title and @notice
- [FIXED] A117-P3-1: (LOW) Missing @title on LibInterpreterStateDataContract library — added @title and @notice
- [FIXED] R16-P3-1: (LOW) 7 public items missing doc comments in trace.rs — added doc comments to all public items

## Pass 4: Code Quality

- [FIXED] BUILD-P4-1: (LOW) Build warning: inputsLengthMismatch test can be restricted to pure — changed buildState to pure
- [FIXED] BUILD-P4-2: (LOW) Build warning: lhsOverflow test can be restricted to view — changed testLHSItemCountOverflow256 to view
- [FIXED] BUILD-P4-3: (LOW) Build warning: dispatch test can be restricted to view — changed testTryParseLiteralOOBSecondBytePoison to view
- [FIXED] A02-P4-1: (LOW) Two unused using directives (LibParse, LibParseMeta) in BaseRainterpreterSubParser — removed both
- [DISMISSED] A42-P4-1: (LOW) Missing &0x0F mask on outputs extraction in LibOpCall — intentional for gas; upper bits guaranteed zero by parser
- [FIXED] A115-P4-1: (LOW) Unused import and using directive for LibParse in LibParseLiteralSubParseable — removed both
- [FIXED] R12-P4-1: (LOW) Misleading CLI --context help text (says key=value but parses comma-separated U256s) — fixed help text
- [DISMISSED] R13-P4-1: (LOW) revm version mismatch: workspace 24.0.1 vs eval crate wasm 25.0.0 — intentional; wasm target needs different version from foundry-evm

## Pass 5: Correctness

- [FIXED] A18-P5-1: (LOW) ExternDispatchConstantsHeightOverflow NatSpec says "single byte" but check uses uint16 — fixed to "16-bit encoding limit (uint16)"
- [FIXED] A17-P5-1: (LOW) OddSetLength NatSpec says "a set call" but error also thrown in eval4 stateOverlay — broadened to "key-value array"
- [FIXED] A108-P5-1: (LOW) ParseStackTracker NatSpec claims 128/128-bit split but actual layout is 8/8/240 — fixed to describe actual bit layout
- [FIXED] A102-P5-1: (LOW) SUB_PARSER_BYTECODE_HEADER_SIZE NatSpec describes non-existent header fields — fixed to constants height, IO byte, word length
- [FIXED] R12-P5-1: (LOW) fork_parse doc references non-existent deployExpression2 call — fixed to "parse2 call"
- [FIXED] R20-P5-1: (LOW) Doc says "to" field when it means "from" field — fixed to "from"
