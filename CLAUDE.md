# CLAUDE.md

This file takes precedence over session summaries. After a compaction, re-read
and follow this file as written — do not trust the summary's framing of these
processes.

## Build

All commands run inside the nix shell: `nix develop -c <cmd>`. Once per session,
in order: `nix develop -c rainix-sol-prelude`, `rainix-rs-prelude`,
`rainlang-prelude` (generates `meta/` files the Solidity build needs).

After `forge build`, address all warnings before pointer rebuild, tests, or the
next task.

After any source change affecting bytecode: `nix develop -c rainlang-prelude` →
`nix develop -c forge script --silent ./script/Build.sol` (rewrites
`src/generated/*.pointers.sol`) → `nix develop -c forge fmt`, then run
`LibInterpreterDeployTest` for new addresses/codehashes and update
`src/lib/deploy/LibInterpreterDeploy.sol`, repeating until stable — deploy
constants cascade parser → expression deployer → Rainlang, and interpreter →
Rainlang.

## Conventions

- NatSpec ruling: if a doc block has any explicit tag, every entry must be
  explicitly tagged — untagged lines continue the previous tag, not implicit
  `@notice`.
- Read `TESTING.md` before writing tests.
- Run builds/tests with `run_in_background: true` and continue non-dependent
  work while they run.

## Process (Jidoka)

Process correctness over ad hoc progress. Each fix is a complete cycle:
understand → failing test → fix → passing test → full suite → verify. TDD for
bugs: confirm the reproduction fails before writing the fix. Incomplete work
does not carry to the next item; new code meets the `/audit` bar.

When the user says "jidoka": identify the process defect, propose a durable fix,
then stop and wait for agreement — the process fix is the deliverable of that
moment. When the user asks "why" about a defect: root-cause the process failure
first; do not go do the thing.

Do not claim motivations or internal states. Describe what you did ("I skipped
the test suite run"), not a story about why — you have no self-observation and
such narratives are fabrications.
