# Audit Review

An audit consists of the passes defined below. All passes are mandatory. Do not combine them into a single pass. Each pass must be run as its own separate conversation to avoid hitting context limits.

Each pass will need multiple agents to cover the full codebase. When partitioning files across agents, assign one file per agent. This ensures each agent reads its file thoroughly rather than skimming across many files. For passes that require cross-file context (e.g., Pass 2 needs both source and test files), the agent receives the source file plus its corresponding test file(s) — this is still a single-file-per-agent partition from the source file perspective.

Agents are assigned sequential IDs (A01, A02, ...) based on alphabetical order of their source file paths. Each agent prefixes its findings with its ID (e.g., A03-1, A03-2). This produces a stable global ordering: sort by agent ID, then by finding number within each agent. The ordering is deterministic because it derives from the file list, which is fixed for a given codebase snapshot.

Every pass requires reading every assigned file in full. Do not rely on grepping as a substitute for reading — systematic line-by-line review catches issues that keyword searches miss. Grepping is appropriate for cross-referencing (e.g., checking if an error name appears in test files) but not for understanding code.

After reading each file, the agent must list evidence of thorough reading before reporting findings. For each file, list:
- The contract/library name
- Every function name and its line number
- Every error/event/struct defined (if any)

This evidence must appear in the agent's output before any findings for that file. If the evidence is missing or incomplete, the audit of that file is invalid and must be re-run.

Findings from all passes should be reported, not fixed. Fixes are a separate step after findings are reviewed. Each finding must be classified as one of: **CRITICAL** (exploitable now with direct impact), **HIGH** (significant risk requiring specific conditions), **MEDIUM** (real concern with mitigating factors), **LOW** (minor issue or theoretical risk), **INFO** (observation with no direct risk).

Each agent must write its findings to `audit/<YYYY-MM-DD>-<NN>/pass<M>/<FileName>.md` where `<NN>` is a zero-padded incrementing integer starting at 01, `<M>` is the pass number, and `<FileName>` matches the source file name (e.g. `LibEval.md` for `LibEval.sol`). To determine `<NN>`, glob for `audit/<YYYY-MM-DD>-*` and use one higher than the highest existing number, or 01 if none exist. All passes of the same audit share the same `<NN>`. Each audit run uses this namespace so previous runs are preserved as history. Findings that only exist in agent task output are lost when context compacts — the file is the record of truth.

## Triage

During triage, maintain `audit/<YYYY-MM-DD>-<NN>/triage.md` recording the disposition of every LOW+ finding, keyed by finding ID (e.g., A03-1). Each entry has a status: **FIXED** (code changed), **DOCUMENTED** (NatSpec/comments added), **DISMISSED** (no action needed), **UPSTREAM** (fix belongs in a dependency/submodule, not this repo), or **PENDING** (not yet triaged). This file is the durable record of triage progress — conversation context is lost on compaction, but the file persists. Before presenting the next finding, check the triage file for the first PENDING ID in sort order. Present findings neutrally and let the user decide the disposition.

When triaging a finding as already FIXED (test already exists), apply the same rigor as writing a new fix: read the actual test code, verify it covers the finding, check for missing edge cases and boundary conditions, and add tests if gaps exist. "Test exists" is not the same as "properly tested." One finding at a time — no batch-marking.

## Pass 0: Process Review

Review CLAUDE.md and AUDIT.md for issues that would cause future sessions to misinterpret instructions. This pass reviews process documents, not source code. No subagents needed — the documents are small enough to review in the main conversation. Record findings to `audit/<YYYY-MM-DD>-<NN>/pass0/process.md`.

Check for:
- Ambiguous instructions a future session could misinterpret (e.g. reused placeholder names, unclear defaults)
- Instructions that are fragile under context compression (e.g. relying on subtle distinctions)
- Missing defaults or undefined terms
- Inconsistencies between CLAUDE.md and AUDIT.md

## Pass 1: Security

Review for all security issues. The following are known areas of concern for this codebase, not an exhaustive list:

- Check assembly blocks for memory safety: out-of-bounds reads/writes, incorrect pointer arithmetic, missing bounds checks
- Verify stack underflow/overflow protection in opcode `run` functions
- Check that integrity functions correctly declare inputs/outputs matching what `run` actually consumes/produces
- Look for reentrancy risks in opcodes that make external calls (ERC20, ERC721, extern)
- Verify namespace isolation in the store — `msg.sender` + `StateNamespace` must always scope storage access
- Check that bytecode hash verification in the expression deployer cannot be bypassed
- Verify function pointer tables cannot index out of bounds or be manipulated
- Look for unchecked arithmetic that could silently wrap
- Check that operand parsing rejects invalid operand values rather than silently misinterpreting them
- Verify that the eval loop cannot be made to jump to arbitrary code via crafted bytecode
- Check that context array access is bounds-checked
- Review extern dispatch for correct encoding/decoding of `ExternDispatchV2`
- Ensure all reverts use custom errors, not string messages (`revert("...")` is not allowed). Custom errors should be defined in `src/error/`

## Pass 2: Test Coverage

For each source file, read both the source file and its corresponding test file(s). Test files are in `test/` mirroring `src/` structure, suffixed `.t.sol`. Some source files (especially error definitions in `src/error/`) are tested indirectly by test files elsewhere — grep for the error/function name across `test/` to find where coverage exists. Report all coverage gaps, including but not limited to:

- Source files with no corresponding test file
- Functions with no test exercising them
- Error/revert paths with no test triggering them (check every `revert` in source, every `error` in `src/error/`)
- Missing edge case coverage: zero-length inputs, max-length inputs, off-by-one boundaries, odd/even parity

## Pass 3: Documentation

Review all documentation for completeness and accuracy, including but not limited to:

- Systematically enumerate every function in every contract and library, and verify each has NatSpec documentation
- Explicitly list undocumented functions as findings
- All NatSpec must include `@param` and `@return` tags as relevant for functions, structs, errors, etc.
- When a doc block contains any explicit tag (e.g. `@title`), all entries must be explicitly tagged. Untagged lines after a tag are parsed as continuation of the previous tag, not as implicit `@notice`. Every contract/library-level doc block with `@title` must also have an explicit `@notice`.
- After ensuring documentation exists, review it against the implementation for accuracy

## Pass 4: Code Quality

Review for maintainability, consistency, and good abstractions, including but not limited to:

- Audit for style consistency across the repo — when similar code uses different patterns for the same thing, flag it
- Identify leaky abstractions: internal details exposed through public interfaces, implementation concerns bleeding across module boundaries, or tight coupling between components that should be independent
- Review all commented-out code — each instance should be either reinstated or deleted, not left commented
- Ensure no build warnings from `forge build` or `cargo check`
- Check that all submodules sharing the same dependency are pinned to the same git commit
