# Audit Review

An audit consists of four separate passes, each run as independent agents. All four passes are mandatory. Do not combine them into a single pass.

Each pass will need multiple agents to cover the full codebase. When partitioning files across agents, assign one file per agent. This ensures each agent reads its file thoroughly rather than skimming across many files. For passes that require cross-file context (e.g., Pass 2 needs both source and test files), the agent receives the source file plus its corresponding test file(s) — this is still a single-file-per-agent partition from the source file perspective.

Every pass requires reading every assigned file in full. Do not rely on grepping as a substitute for reading — systematic line-by-line review catches issues that keyword searches miss. Grepping is appropriate for cross-referencing (e.g., checking if an error name appears in test files) but not for understanding code.

After reading each file, the agent must list evidence of thorough reading before reporting findings. For each file, list:
- The contract/library name
- Every function name and its line number
- Every error/event/struct defined (if any)

This evidence must appear in the agent's output before any findings for that file. If the evidence is missing or incomplete, the audit of that file is invalid and must be re-run.

Findings from all passes should be reported, not fixed. Fixes are a separate step after findings are reviewed.

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
- After ensuring documentation exists, review it against the implementation for accuracy

## Pass 4: Code Quality

Review for maintainability, consistency, and good abstractions, including but not limited to:

- Audit for style consistency across the repo — when similar code uses different patterns for the same thing, flag it
- Identify leaky abstractions: internal details exposed through public interfaces, implementation concerns bleeding across module boundaries, or tight coupling between components that should be independent
- Review all commented-out code — each instance should be either reinstated or deleted, not left commented
- Ensure no build warnings from `forge build` or `cargo check`
- Check that all submodules sharing the same dependency are pinned to the same git commit
