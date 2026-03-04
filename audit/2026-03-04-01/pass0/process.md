# Pass 0: Process Review — 2026-03-04-01

## P0-1: (LOW) GENERAL_RULES.md has rules not propagated to main audit SKILL.md

**File:** `~/.claude/skills/audit/GENERAL_RULES.md` lines 22-26, `~/.claude/skills/audit/SKILL.md`

GENERAL_RULES.md contains 3 rules that do not appear in the main audit SKILL.md:
1. "Before reporting findings, read `audit/known-false-positives.md`" (line 22)
2. "Before proposing a test for an audit finding, answer: 'How does this test cover the gap?'" (line 24)
3. "Per-test `forge-config: default.fuzz.runs` overrides exist intentionally..." (line 26)

When running `/audit` (full audit), the main SKILL.md is loaded but GENERAL_RULES.md is not referenced. Individual pass skills reference GENERAL_RULES.md. This means these 3 rules only apply to individual pass runs, not full `/audit` runs.

## P0-2: (LOW) CLAUDE.md omits full command for LibInterpreterDeployTest

**File:** `CLAUDE.md` line 54

The build pipeline says "run `LibInterpreterDeployTest` to get new deploy addresses/codehashes" but does not specify the full command. Under context compression, a session may not know the command is `nix develop -c forge test --match-contract LibInterpreterDeployTest`.

## P0-3: (LOW) TESTING.md only covers Solidity but is referenced as general

**File:** `CLAUDE.md` line 113, `TESTING.md`

CLAUDE.md says "Testing patterns and conventions are in `TESTING.md`. Read that file before writing tests." This appears under the general "Test Conventions" section which also mentions Rust test fixtures (line 116). However, TESTING.md only contains Solidity test conventions (OpTest, ParseTest, forge fuzz, vm.expectRevert, etc.) with no Rust testing guidance. A future session writing Rust tests would find no relevant conventions.

## P0-4: (LOW) Proposed fixes instructions missing from GENERAL_RULES.md

**File:** `~/.claude/skills/audit/SKILL.md` lines 26-42, `~/.claude/skills/audit/GENERAL_RULES.md`

The `.fixes/` proposed fix convention is documented only in the main audit SKILL.md. GENERAL_RULES.md does not include it, and individual pass skills only reference GENERAL_RULES.md. When running `/audit-pass1` individually, the fix-writing requirement is not communicated.
