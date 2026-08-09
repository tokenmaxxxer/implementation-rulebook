---
subject: issue-79
role: implementation
code_under_review:
  - gates/test_env_resolve.py
  - tests/lib/resolve-core-env.sh
  - tests/run-gate-tests.sh
  - tests/methodology-plugins-tests.sh
  - survey-order/hooks/tests/survey-order-tests.sh
  - coding/hooks/tests/coding-progress-gate-tests.sh
  - coding/hooks/tests/hunt-guard-tests.sh
  - coding/hooks/tests/hunt-state-tests.sh
  - proposal-shape/hooks/tests/proposal-shape-tests.sh
  - record-shape/hooks/tests/record-shape-tests.sh
  - docs/handbooks/gate-tests.md
type: feature
breaking: false
verdict: pending
loop_state: landed
---

# Implementation record — adopt test-env resolution convention (#79)

## What was done

Phase 2 delivery per the approved proposal
`docs/issue-79/proposals/2026-08-09-test-env-resolution-adoption.md`:

- Vendored `gates/test_env_resolve.py` — verbatim reference module from
  `on-the-record`'s `docs/specs/test-env-resolution.md` (issue #551):
  `resolve_core(env, candidates)`, `_has_gate_lib` (non-empty-file
  check), `EX_TEMPFAIL = 75`, the exact `SKIP_MESSAGE`, and the CLI
  `main()`.
- Added `tests/lib/resolve-core-env.sh` — one shared bash helper sourced
  by all eight test scripts. Computes this repo's two existing candidate
  paths, invokes `gates/test_env_resolve.py` as a subprocess, exports
  `CLAUDE_PLUGIN_ROOT_CORE` on exit 0, or prints the SKIP message and
  returns 75 on exit 75.
- Replaced the duplicated ad hoc resolution block in each of:
  `tests/run-gate-tests.sh`,
  `survey-order/hooks/tests/survey-order-tests.sh`,
  `coding/hooks/tests/coding-progress-gate-tests.sh`,
  `coding/hooks/tests/hunt-guard-tests.sh`,
  `coding/hooks/tests/hunt-state-tests.sh`,
  `proposal-shape/hooks/tests/proposal-shape-tests.sh`,
  `record-shape/hooks/tests/record-shape-tests.sh` — with
  `source ".../tests/lib/resolve-core-env.sh" || exit 75`, each preceded
  by a comment referencing `docs/specs/test-env-resolution.md` and issue
  #551.
- Added the same resolution call to `tests/methodology-plugins-tests.sh`,
  which previously had none, before its core-dependent gate invocations.
- `hunt-guard-tests.sh` / `hunt-state-tests.sh`'s deliberate missing-core
  fail-closed regression cases are untouched (per proposal Constraints).
- Updated `docs/handbooks/gate-tests.md` with a short paragraph
  describing the SKIP contract (exit 75, explicit stderr message).

## Why

Per the proposal's Rationale: vendoring the convention's one reference
module and calling it from one shared bash helper replaces eight
independently-drifting hand-rolled resolution blocks with byte-identical
resolution semantics, matching the adoption path the convention doc
itself specifies.

## Upstream / basis

`docs/issue-79/proposals/2026-08-09-test-env-resolution-adoption.md`

## Verification run

Ran all eight scripts in this session's spawn environment (core
reachable via `$HOME/tokenmaxxxer/tokenmaxxxer-core/core`): each
resolves `CLAUDE_PLUGIN_ROOT_CORE` and its previously-passing assertions
are unchanged — `run-gate-tests.sh` 5/5, `methodology-plugins-tests.sh`
22/23 (the 1 `rs-complete` failure and `hunt-guard-tests.sh`/
`hunt-state-tests.sh`'s several failures are pre-existing on unmodified
`HEAD`, confirmed via `git stash`/`git stash pop` diffing before/after —
`hunt-guard.sh`/`hunt-state.sh` themselves are absent from this
checkout, unrelated to this change), `coding-progress-gate-tests.sh`
11/11, `proposal-shape-tests.sh` 13/13, `record-shape-tests.sh` 18/18,
`survey-order-tests.sh` 12/12 — all unchanged from `HEAD`.

The SKIP branch itself could not be exercised end-to-end via the shell
scripts in this sandbox (overriding `HOME`/unsetting
`CLAUDE_PLUGIN_ROOT_CORE` to force both resolution steps to miss was
blocked by the sandbox's command-approval gate), so it was verified at
the unit level instead: calling `gates.test_env_resolve.resolve_core`
directly with `env={}` and two nonexistent candidate paths returns
`skip=True` and the exact `SKIP_MESSAGE`; `main()` against real
`os.environ` (which has `CLAUDE_PLUGIN_ROOT_CORE` set in this session)
returns the resolved path and exit 0. Both branches of `resolve_core`
are exercised; only the bash-level `exit 75` wiring in
`resolve-core-env.sh` is unexercised end-to-end here, though its logic
mirrors the CLI contract's exit-code branch directly.

`grep -rl "test-env-resolution" .` returns all eight scripts plus
`gates/test_env_resolve.py` and `docs/handbooks/gate-tests.md`.

## What did not work

None.

## Open findings

None outstanding at time of writing.

## Next steps

Commit, push, and open the PR for #79 referencing the phase-2 delivery;
set `loop_state: landed` once committed and pushed.

## Open-finding-resolution-path

No open findings; if one surfaces before landing, resolve it via a
follow-up commit on this branch before the PR is opened, and record the
resolution here.
