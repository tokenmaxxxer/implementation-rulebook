---
subject: issue-79
role: implementation
---

# Proposal — adopt the test-env resolution convention (#79)

Phase 1 only. No execution in this PR. Survey:
`docs/issue-79/reports/implementation/survey.md`. Scouting skipped (see
survey's Scout-skip note — adoption of an already-designed external
convention, no open design decision).

files:
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

## Request

Adopt the canonical test-env resolution convention landed at
`on-the-record`'s `docs/specs/test-env-resolution.md` (issue #551)
across this rulebook's gate-test scripts, so that outside the spawn
session environment (no `CLAUDE_PLUGIN_ROOT_CORE`, no reachable sibling
core checkout) every script SKIPs with the convention's explicit message
and distinct exit code instead of failing misleadingly. No assertion
that runs when core IS reachable changes.

## Constraints

- Never weaken an assertion that fires when core is reachable — SKIP
  applies only to the "core unreachable" branch.
- `hunt-guard-tests.sh` and `hunt-state-tests.sh`'s deliberate
  missing-core fail-closed regression cases (survey: these force
  `CLAUDE_PLUGIN_ROOT_CORE` to a bogus path to assert the *gate itself*
  fails closed) are a different concern from this issue's environment
  resolution and are untouched.
- No network fetch — the convention doc explicitly scopes that out of
  the canonical contract; this repo's existing scripts already don't do
  one, so nothing to remove there.
- No new dependency (the vendored resolver is stdlib-only Python,
  matching its verbatim upstream source) and no new env var beyond the
  already-used `CLAUDE_PLUGIN_ROOT_CORE`.

## Rationale

**Alternative considered: paste the convention's ad hoc resolution logic
into each of the eight scripts individually (bash-native, no Python
subprocess), instead of vendoring the reference module.** Rejected. The
eight scripts already each hand-roll their own near-identical bash
resolution block (survey: same two hardcoded candidate paths, duplicated
eight times) — that duplication is the existing defect this issue is
also implicitly about ("hand-rolling their own" is the exact phrase the
convention doc uses to describe what it's meant to replace). Re-deriving
the SKIP contract's message and exit-75 behavior in bash eight more times
would keep the duplication and risk each copy drifting independently
(the convention doc's own worked example is why issue #551 was opened in
the first place: divergent ad hoc copies producing inconsistent
diagnostics). Vendoring the one reference module and calling it from one
shared bash helper gives every script byte-identical resolution
semantics and puts the convention doc's exact stderr message and exit
code in exactly one place.

**Alternative considered: depend on `on-the-record`'s checkout at runtime
(shell out to a path under `$HOME/tokenmaxxxer/on-the-record` if
present) rather than vendoring `gates/test_env_resolve.py`.** Rejected.
That would make this repo's own test resolution depend on the
*consumer's* local filesystem layout happening to have another specific
repo cloned at a specific path — exactly the kind of spawn-environment
assumption issue #79 exists to remove. The convention doc supplies a
verbatim, stdlib-only reference module precisely so consumers vendor it
instead of depending on `on-the-record` being present; vendoring is the
adoption path the convention itself specifies ("Reference implementation
... Verbatim source ... this repo").

**Alternative considered: leave `tests/methodology-plugins-tests.sh`
unchanged, since it currently has no resolution block to replace (only
the other seven files have the duplicated ad hoc pattern the issue
names).** Rejected. The issue's acceptance criteria say "every test
script" and "zero misleading failures" — `methodology-plugins-tests.sh`
calls three core-dependent gates (`PS_GATE`/`RS_GATE`/`SO_GATE`)
unconditionally today and fails exactly as misleadingly outside spawn
env as the other seven (survey: confirmed, it has zero resolution logic
at all, not even the ad hoc kind). Skipping it because its current
failure mode is "no resolution" rather than "resolution present but
lacking SKIP" would leave one of the repo's eight test scripts still
failing the acceptance check.

## What will be done

1. **`gates/test_env_resolve.py`** (new) — vendor the convention doc's
   reference module verbatim: `resolve_core(env, candidates)` (env-var
   check → candidate loop → SKIP), the `_has_gate_lib` non-empty-file
   check, `EX_TEMPFAIL = 75`, the exact `SKIP_MESSAGE` string, and the
   CLI `main()` wrapper.
2. **`tests/lib/resolve-core-env.sh`** (new) — one shared helper, sourced
   by each of the eight test scripts in place of their own ad hoc block.
   It computes this repo's two existing candidate paths (unchanged from
   what each script already hardcodes:
   `$HOME/tokenmaxxxer/tokenmaxxxer-core/core` and a sibling `../core`
   relative to the sourcing script), invokes
   `python3 "$REPO_ROOT/gates/test_env_resolve.py" <candidates>`, and on
   exit `0` exports `CLAUDE_PLUGIN_ROOT_CORE` to the printed path; on
   exit `75` prints the SKIP message and returns `75` to the caller so
   the sourcing script can `exit 75` itself (distinct from that script's
   own pass-count `[ "$fail" -eq 0 ]` exit and from a gate's `0`/`1`/`2`).
3. **Each of the eight test scripts** — replace the duplicated
   `if [ -z "${CLAUDE_PLUGIN_ROOT_CORE:-}" ]; then for _cand in ...`
   block (or, for `methodology-plugins-tests.sh`, add resolution where
   none exists) with `source "$ROOT/tests/lib/resolve-core-env.sh" ||
   exit 75` near the top, before any core-dependent gate is invoked.
   Comment above the source line references
   `docs/specs/test-env-resolution.md` and issue #551 by name (satisfies
   the acceptance check's grep). `hunt-guard-tests.sh`/
   `hunt-state-tests.sh`'s separate missing-core *gate-behavior*
   assertions are left exactly as they are (per Constraints) — only the
   scripts' own top-of-file resolution block is replaced.
4. **`docs/handbooks/gate-tests.md`** — add a short paragraph describing
   the SKIP contract (exit `75`, explicit stderr message) so a human
   running a script outside spawn env with no core checkout sees a clear
   "this run is unverifiable, not failed" signal instead of reading the
   existing manual-export instruction as the only path; existing
   `export CLAUDE_PLUGIN_ROOT_CORE=...` guidance stays (resolution order
   step 1 still checks the env var first).

## Out of scope

- Changing `hunt-guard-tests.sh`/`hunt-state-tests.sh`'s missing-core
  fail-closed regression assertions — different concern (Constraints).
- Vendoring the convention's own unit test suite
  (`gates/test_test_env_resolve.py`) — the convention doc's own "Out of
  scope" section scopes per-repo adoption to using the module, not
  re-testing it; this repo can trust the upstream module's own tests.
- Any change to core's `gate-lib.sh`/`gate-lib.py` or to
  `docs/handbooks/gate-tests.md`'s reference-not-copy rule for *those*
  files — unrelated to this convention.
- A network-fetch fallback layered on top of candidate resolution — the
  convention doc explicitly marks this as an opt-in extension, and this
  repo's existing scripts never had one; not adding one now keeps the
  SKIP contract unambiguous per the convention's own stated reasoning.

## How you'll know it worked

- On a plain checkout with `CLAUDE_PLUGIN_ROOT_CORE` unset and no
  sibling core checkout at either candidate path, running any of the
  eight scripts prints the convention's exact SKIP message to stderr and
  exits `75` — verified by running each script in that environment
  (`env -u CLAUDE_PLUGIN_ROOT_CORE bash <script>`, checked from a
  directory with no sibling `core/`).
- With `CLAUDE_PLUGIN_ROOT_CORE` pointed at a real core checkout (or a
  sibling checkout present), all eight scripts' existing pass counts are
  unchanged — run each and diff `ok`/`FAIL` counts against current
  `main` before/after.
- `grep -rl "test-env-resolution" .` returns all eight test scripts plus
  `gates/test_env_resolve.py` and `docs/handbooks/gate-tests.md`.
- `hunt-guard-tests.sh`'s and `hunt-state-tests.sh`'s missing-core
  fail-closed cases still assert `deny`/`allow` and the "core plugin not
  found" message exactly as before (their content is untouched by this
  change; regression check is a straight diff of those assertion
  blocks).
