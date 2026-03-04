# Pass 0: Process Review

**Audit:** 2026-03-01-01
**Date:** 2026-03-01

## Documents Reviewed

1. `CLAUDE.md` (132 lines) — Main process document
2. `TESTING.md` (46 lines) — Test conventions
3. `audit/known-false-positives.md` (31 lines) — Known false positives registry
4. Audit skill files: `audit/SKILL.md`, `audit-pass0/SKILL.md` through `audit-pass4/SKILL.md`, `audit-triage/SKILL.md`
5. Auto-memory: `MEMORY.md`

## Evidence of Thorough Reading

### CLAUDE.md
- Sections: Build Environment (lines 7-53), Architecture (lines 54-93), Solidity Conventions (lines 95-104), Test Conventions (lines 106-112), Process/Jidoka (lines 114-127), Audit Review (lines 129-132)
- Terms defined: Nix flakes, `i9r-prelude`, `BuildPointers.sol`, `BuildAuthoringMeta.sol`, four core components, opcode system, extern system, Rust crates, deployment
- Referenced external docs: `TESTING.md`, `/audit` skill

### TESTING.md
- Sections: Base Contracts (lines 3-11), Fuzz Testing (lines 13-17), Library Internals (lines 19-21), Revert Paths (lines 23-25), Bytecode Construction (lines 27-29), Bytecode Inspection (lines 31-33), Opcode Testing (lines 35-37), Boundary Tests (lines 39-41), One Test at a Time (lines 43-46)

### Audit skill files
- Master SKILL.md (122 lines): General rules, proposed fixes, severity levels, pass definitions (0-4), triage
- Per-pass SKILL.md files: Each duplicates the general rules section and adds pass-specific instructions

### known-false-positives.md
- Entries: LibOpGet read-only key persistence, ERC20 float opcodes `decimals()` optional

## Findings

### P0-1: (LOW) Proposed fix procedure in audit SKILL.md has no Bash tool for pass2

`audit-pass2/SKILL.md` line 5 lists `allowed-tools: Read, Grep, Glob, Task, Write` but does not include `Bash`. Agents running pass 2 that need to verify test compilation or run a specific test to confirm coverage cannot do so. Other passes that may not need Bash (pass 3) also lack it, but pass 2 is the most impacted because test coverage verification benefits from compilation checks. Compare with pass 1 and pass 4 which include Bash.

### P0-2: (LOW) CLAUDE.md Build Pipeline step 3 names `BuildPointers.sol` but the actual command is `forge script ./script/BuildPointers.sol`

CLAUDE.md line 47 says "BuildPointers.sol deploys contracts in local EVM..." but the actual invocation requires `nix develop -c forge script --silent ./script/BuildPointers.sol`. A future session reconstructing from a compressed summary might attempt `nix develop -c BuildPointers.sol` as a direct command. The MEMORY.md entry under "Pointer Regeneration" includes the correct full command, but CLAUDE.md itself does not provide the command syntax despite providing exact syntax for other commands.

### P0-3: (LOW) CLAUDE.md "Fuzz runs: 2048" is stated but the foundry.toml location is not referenced

CLAUDE.md line 99 states "Fuzz runs: 2048" as a convention but does not point to `foundry.toml` as the source of truth. If a future session needs to verify or change this value, it has no guidance on where the configuration lives. Other conventions (Solidity version, optimizer settings) are similarly stated without pointing to their source of truth in `foundry.toml`.

### P0-4: (LOW) TESTING.md references test base contracts without file paths

TESTING.md lines 5-11 list test base contracts (`RainterpreterExpressionDeployerDeploymentTest`, `OpTest`, `ParseTest`, `OperandTest`, `ParseLiteralTest`) with the directory `test/abstract/` but without full file paths. If files are renamed or reorganized, this list becomes stale. A future session would need to glob to find the actual files.

### P0-5: (LOW) Audit skill files duplicate general rules across 7 files

The general rules section (agent IDs, evidence requirements, finding format, severity definitions) is duplicated verbatim in `audit/SKILL.md` and each of the 6 per-pass/triage SKILL.md files. If any rule is updated in one file but not the others, the documents become inconsistent. The per-pass files should reference the master document rather than duplicating.

### P0-6: (LOW) `known-false-positives.md` is not referenced from CLAUDE.md or audit skill files

`audit/known-false-positives.md` exists but is not referenced from CLAUDE.md's audit section or from any audit skill SKILL.md file. An agent running a security audit has no instruction to consult this file, so the same false positives may be re-flagged in every audit cycle. The triage process cross-references prior triage.md files but not this document.

### P0-7: (LOW) CLAUDE.md does not document the RainterpreterDISPaiRegistry component

CLAUDE.md lines 57-66 describe "Four Core Components" but `src/concrete/RainterpreterDISPaiRegistry.sol` exists as a fifth concrete contract. The architecture section mentions only four components and the expression deployer as implementing `IParserV2`. The DISPaiRegistry is missing from the architecture description. The deploy constants cascade (parser -> expression deployer -> DISPaiRegistry) documented in MEMORY.md is not present in CLAUDE.md.

### P0-8: (LOW) Audit pass numbering inconsistency: "Proposed Fixes" section mentions writing fixes during passes but pass0 has no `.fixes` instruction

The master audit SKILL.md says "Each LOW+ finding must include a proposed fix written to `.fixes/`" and "Fix files are written alongside findings during each pass." However, pass 0 reviews process documents where fixes are textual edits to .md files — the `.fixes/` convention is designed for code changes. This ambiguity means pass 0 findings either need fix files (unusual for process docs) or the rule should explicitly exempt pass 0.
