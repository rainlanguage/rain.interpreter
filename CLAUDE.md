# CLAUDE.md

Guidance for Claude Code in this repo. This file takes precedence over session
summaries — re-read it as written rather than trusting a summary's framing of
what a process means.

## Build Environment

Nix flakes only: run everything as `nix develop -c <cmd>`. Once per session, in
order, before any build or test:

```bash
nix develop -c rainix-sol-prelude
nix develop -c rainix-rs-prelude
nix develop -c rainlang-prelude   # generates meta/ needed by the sol build
```

Common tasks (all via `nix develop -c`): `rainix-sol-test`, `rainix-sol-static`,
`rainix-rs-test`, `rainix-rs-static`, `test-wasm-build`.

## Generated code

`script/Build.sol` writes ALL of it. Never hand-edit:

- `src/generated/<Name>Pointers.sol` — parse meta, function pointer tables, meta
  hashes. Committed because contract and pointers file depend on each other
  circularly.
- `src/generated/candidate/<Name>.sol` — each deployed contract's rolling deploy
  snapshot: hash, Zoltu address, creation/runtime code, dependencies.
- `src/generated/<x_y_z>/` — FROZEN release records. Append-only: never
  regenerate, move or delete a tag dir.
- `src/lib/Lib*Released.sol` and `src/lib/LibReleasedSuites.sol`.

After any source change affecting bytecode:

1. `nix develop -c rainlang-prelude`
2. `nix develop -c forge script --silent ./script/Build.sol`
3. `nix develop -c forge fmt`
4. Repeat until `src/generated/` stops changing — deploy constants cascade
   parser → expression deployer → Rainlang; interpreter also cascades to
   Rainlang.

Address all `forge build` warnings before pointer rebuild, tests, or the next
task.

## Deploy and release

`src/abstract/RainlangDeploySuites.sol` is the ONE declaration of what this repo
deploys. `script/Deploy.sol`, `script/Build.sol` and the deploy tests all read
it; a deployment declared anywhere else is invisible to all three.

`[external.package].version` in `foundry.toml` is the LAST Soldeer publish, not
a next-version slot: a normal PR never moves it. Releasing is deploy (Manual sol
artifacts) → verify (`RainlangDeployChainTest`) → a PR carrying `cutRelease()`'s
frozen dir and the version bump → merge → push `sol-v<x.y.z>`.

Three things look wrong and are load-bearing: `optimizer_runs = 1000000` (not
the org's 100000 — it is baked into every live CREATE2 address here); `/test`
absent from `.soldeerignore` (raindex imports `test/abstract/OpTest.sol` through
the published package); and `src/lib/deploy/LibInterpreterDeploy.sol` being
hand-written rather than a generated alias lib (its constant names and
`etchRainlang` are a published consumer API).

## Conventions

- Compiler, optimizer and fuzz settings: `foundry.toml` is the source of truth.
- NatSpec: if a doc block has any explicit tag, every entry must be tagged —
  untagged lines continue the previous tag, not implicit `@notice`.
- Tests: read `TESTING.md` before writing tests. Run test commands with
  `run_in_background: true` and continue independent work meanwhile.

## Process (Jidoka)

Process correctness (correct future) over ad hoc progress (present state). Each
fix is a complete cycle: understand → write test → run it (confirm it fails) →
fix → run it (confirm it passes) → full suite → verify. Never write the fix
before the failing test reproduces the bug. Do not move on with incomplete work;
new code meets the `/audit` skill's requirements.

"jidoka" from the user signals a process defect: identify it, propose a durable
fix (document edit, rule change), then STOP and wait for agreement — the process
fix is the deliverable of that moment. A "why" question asks for root cause
analysis of the process failure, not for the task to be done.

Do not claim motivations or internal states. Describe what you actually did ("I
skipped the test suite run"), not a story about why — you have no metrics, no
persistence, no self-observation; narratives about your own reasoning are
fabrications.
