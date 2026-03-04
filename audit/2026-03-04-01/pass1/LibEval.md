# A21 — Pass 1 (Security) — LibEval.sol

## A21-1 (LOW): sourceIndex not bounds-checked in evalLoop

Same as prior A05-1. `state.sourceIndex` masked to 16 bits and used without bounds check against source count. Documented trust assumption — callers validate. Previously DISMISSED.

## A21-2 (LOW): Division-by-zero risk if state.fs is empty

Same as prior A05-2. `fsCount = state.fs.length / 2` — if empty, EVM MOD with 0 returns 0. Rainterpreter constructor guards with `ZeroFunctionPointers()`. Previously DISMISSED.

No new findings. Modulo dispatch, unchecked arithmetic, in-place output aliasing, stackTrace transient mutation, and remainder loop cursor all verified correct.
