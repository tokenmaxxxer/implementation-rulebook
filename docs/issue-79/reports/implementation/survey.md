---
subject: issue-79
role: implementation
---

# Survey — adopting the test-env resolution convention (issue #551)

## Scout-skip note

Skipped. This is adoption of an already-landed, already-designed
external convention (`on-the-record` issue #551,
`docs/specs/test-env-resolution.md`), not a design task — the resolution
order, SKIP contract, exit code, and reference module are fixed by that
doc. The only open questions are mechanical (which of this repo's files
need the ad-hoc block replaced, and how the bash callers should invoke
the reference module), settled below by reading this repo's own test
scripts, not by scouting the field.

## The convention (read from `on-the-record`)

`docs/specs/test-env-resolution.md` (fetched via
`gh api repos/tokenmaxxxer/on-the-record/contents/docs/specs/test-env-resolution.md`,
this repo has no local up-to-date clone of `on-the-record`'s current
`main`) defines:

- Resolution order: `$CLAUDE_PLUGIN_ROOT_CORE` (if it contains a
  non-empty `hooks/lib/gate-lib.sh`) → first caller-supplied candidate
  path containing the same → **SKIP** (not a failure).
- SKIP contract: print `SKIP: core plugin unreachable — unverifiable
  outside spawn env` to stderr, exit `75` (`EX_TEMPFAIL`), distinct from
  a gate's own `0`/`1`/`2`.
- Reference implementation: `gates/test_env_resolve.py`, a
  `resolve_core(env, candidates)` function + CLI wrapper
  (`python3 -m gates.test_env_resolve <candidates...>`), verbatim in the
  convention doc. No network fetch — "a repo-local extension a consumer
  MAY layer on top", explicitly not part of the canonical contract.
- Adoption guidance for a bash test runner: invoke the module as a
  subprocess CLI and branch on exit code (`0` = resolved, print path;
  `75` = skip the whole run).
- Named exception: a test suite with no core dependency at all is out of
  scope — this repo's own test scripts all resolve core (below), so the
  exception does not apply to any of them.

## This repo's current resolution — the problem, confirmed

Eight scripts (`grep -rl "CLAUDE_PLUGIN_ROOT_CORE" --include='*.sh' .`
plus `tests/methodology-plugins-tests.sh`, which shares none of the
grep hits but calls three core-dependent gates unconditionally) all
either duplicate or omit resolution:

1. `tests/run-gate-tests.sh` — ad hoc `if [ -z "$CLAUDE_PLUGIN_ROOT_CORE" ]; then for _cand in ...`
   block (lines 23-27), two hardcoded candidates
   (`$HOME/tokenmaxxxer/tokenmaxxxer-core/core`, `$ROOT/../core`). If
   neither exists, the script does **not** skip — it proceeds and calls
   `coding-progress-gate.sh` as a subprocess, which sources
   `gate-lib.sh` and fails with whatever error that produces, indistinct
   from a real gate regression. This is exactly the issue's "many fail
   with a misleading error instead of a clear verdict" problem.
2. `survey-order/hooks/tests/survey-order-tests.sh` — same pattern
   (lines 11-15), candidates
   `$HOME/tokenmaxxxer/tokenmaxxxer-core/core`, `$HERE/../../../core`.
3. `coding/hooks/tests/coding-progress-gate-tests.sh` — same pattern
   (lines 12-16), same two candidates.
4. `coding/hooks/tests/hunt-guard-tests.sh` — same pattern (lines
   13-17), same two candidates. Also contains a deliberate
   `missing-core` **regression test** (lines 58-72) that forces
   `CLAUDE_PLUGIN_ROOT_CORE` to a nonexistent path to assert the gate
   itself fails closed with an explicit "core plugin not found" message
   — this is a different concern from environment resolution (it tests
   the *gate's* fail-closed behavior when core is truly absent at
   runtime) and must not be touched or reinterpreted as a SKIP case.
5. `coding/hooks/tests/hunt-state-tests.sh` — same ad hoc block (lines
   12-16) plus the same kind of deliberate missing-core assertions
   (lines 18-54) as #4, same non-goal.
6. `proposal-shape/hooks/tests/proposal-shape-tests.sh` — same pattern
   (lines 12-16).
7. `record-shape/hooks/tests/record-shape-tests.sh` — same pattern
   (lines 14-18).
8. `tests/methodology-plugins-tests.sh` — sets no `CLAUDE_PLUGIN_ROOT_CORE`
   resolution at all; calls `PS_GATE`/`RS_GATE`/`SO_GATE` (all three
   source `gate-lib.sh`) unconditionally. Outside spawn env with no
   sibling core checkout, every one of its `run`/`runenv` cases against
   those three gates fails with the gate's own sourcing error, not a
   SKIP. (Its `bash -n` syntax-check block has no core dependency and is
   unaffected either way.)

All eight scripts hardcode the same two candidate paths independently —
duplicated literals, not shared config — and none of them implements the
SKIP contract: none prints the convention's message, none exits `75`,
and outside spawn env with no sibling checkout they all fail rather than
skip. This confirms the issue body's description exactly.

## What already exists that must not be weakened

- `docs/handbooks/gate-tests.md` currently instructs a human to manually
  `export CLAUDE_PLUGIN_ROOT_CORE=...` before running any test script
  locally — still valid under the convention (resolution order step 1),
  needs updating only to describe the new SKIP behavior when that step
  is skipped and step 2's candidates also miss.
- `hunt-guard-tests.sh` and `hunt-state-tests.sh`'s deliberate
  missing-core fail-closed assertions (per #4/#5 above) are runtime gate
  behavior tests, not environment-resolution tests — they must keep
  working unchanged; they already run inside a scratch dir with
  `CLAUDE_PLUGIN_ROOT_CORE` force-set to a bogus path, which is
  orthogonal to how the *test script itself* resolves core for its own
  other (non-missing-core) cases.
- No script currently references `test-env-resolution` or issue #551 —
  confirmed via `grep -ri "test-env-resolution\|issue.*551" .` (no
  hits) — so the acceptance check "scripts reference the convention doc"
  currently fails everywhere.

## Write surfaces this touches (frozen in the proposal)

- New: `gates/test_env_resolve.py` — the convention's reference module,
  vendored verbatim (matches this repo's own reference-not-copy norm for
  *core's* gate-lib per `docs/handbooks/gate-tests.md`; this module is
  the convention's own reference implementation meant for exactly this
  kind of adoption, not core's internal lib, so vendoring it verbatim is
  the intended adoption path per the convention doc itself).
- New: `tests/lib/resolve-core-env.sh` — one shared bash helper, sourced
  by all eight scripts, that invokes `gates/test_env_resolve.py` with
  this repo's two existing candidate paths, exports
  `CLAUDE_PLUGIN_ROOT_CORE` on success, or prints the SKIP message and
  exits `75` on failure — replacing the eight duplicated ad hoc blocks
  with one call site.
- Modified (ad hoc block replaced by a call to the new helper; SKIP
  contract wired into each script's own exit path):
  `tests/run-gate-tests.sh`,
  `survey-order/hooks/tests/survey-order-tests.sh`,
  `coding/hooks/tests/coding-progress-gate-tests.sh`,
  `coding/hooks/tests/hunt-guard-tests.sh`,
  `coding/hooks/tests/hunt-state-tests.sh`,
  `proposal-shape/hooks/tests/proposal-shape-tests.sh`,
  `record-shape/hooks/tests/record-shape-tests.sh`,
  `tests/methodology-plugins-tests.sh` (gains resolution where it
  currently has none).
- `docs/handbooks/gate-tests.md` — document the SKIP contract and that
  the manual `export CLAUDE_PLUGIN_ROOT_CORE=...` step is now optional
  (resolution order step 1) rather than mandatory.

No new dependency (`gates/test_env_resolve.py` is stdlib-only, matching
its own verbatim source), no new env var beyond the already-existing
`CLAUDE_PLUGIN_ROOT_CORE`, no migration, no `.env.example` change.
