---
subject: issue-75
role: implementation
---

# Proposal — align rulebook with `implementation.spec.json` (#75)

Phase 1 only. No execution in this PR. Survey:
`docs/issue-75/reports/implementation/survey.md`. Scout brief:
`docs/issue-75/reports/implementation/scout-brief.md`.

files:
- README.md
- docs/specs/handoff-protocol.md
- record-shape/hooks/directive.sh
- record-shape/README.md
- record-shape/hooks/record-shape-gate.sh
- record-shape/hooks/tests/record-shape-tests.sh
- coding/hooks/directive.sh

## Request

Layer the marketplace's realized `implementation.spec.json` onto this
rulebook: its four required deliverable fields (`commit_sha`, `type`,
`breaking`, `verdict`) and its five-state `loop_state` vocabulary
(`coding`, `commit-unreachable`, `committing`, `landed`,
`scope-undeclared`) should appear in the rulebook's docs/hooks/gates,
strengthening existing methodology rather than deleting any of it. Where
a spec field has no natural rulebook home, say so explicitly with
reasoning instead of skipping it.

## Constraints

- Never delete existing methodology (proposal-shape, record-shape's
  current `code_under_review:`/`loop_state:`/`## What did not work`/
  `## Rationale for deviations` requirements, the doctrine placement
  ladder) — only strengthen.
- No new dependency, env var, or migration (survey confirmed: pure docs +
  one gate script).
- The write set is frozen to the seven files above; `.env.example`/
  dependency manifest are not touched because nothing in this change
  needs them.
- Every spec field name must appear in `docs/` and `README.md` after
  phase 2 (acceptance check 1) and the loop_state vocabulary documented
  in the rulebook must match the spec's five states exactly, no stale or
  extra states left in the surfaces that document it (acceptance check
  2).

## Rationale

**Alternative considered: rename `code_under_review:` to `commit_sha:`
across the rulebook.** Rejected. `code_under_review:` is the frontmatter
key already checked by `record-shape-gate.sh:163-167` and used across
every existing phase-2 record (`docs/issue-70/reports/implementation.md`,
etc.); renaming it is a breaking change to a mechanically-enforced,
already-adopted convention for a naming preference only, with no
functional gain — the spec only requires the *field concept*
`commit_sha` to exist and be documented, not a specific key spelling.
Instead this proposal documents the equivalence (`code_under_review:` IS
this rulebook's `commit_sha`) in every surface that lists required
fields, satisfying the acceptance grep (`commit_sha` will appear in docs
as the spec-vocabulary label) without a breaking rename.

**Alternative considered: mechanically enforce the loop_state vocabulary
as a closed enum in `record-shape-gate.sh`.** Rejected for this proposal,
adopted only as documentation. The gate currently checks *presence* of
`loop_state:`, not its value. Adding value-enum enforcement is a second,
separable decision (it changes gate behavior for every future write, not
just the deliverable-field-mapping this issue asks for) and the survey
found no existing failure this would prevent — no denied write today
carries a stale/invalid `loop_state` value. Documenting the exact
five-state vocabulary in the same three surfaces that currently document
the stale `proposed/approved/landed` set satisfies acceptance check 2
(the *documented* vocabulary matches the spec set exactly) without
widening this change into a new enforcement rule nobody asked for; if a
future issue wants that enforcement, it can build on the now-correct
documented vocabulary.

**Alternative considered: leave `docs/specs/handoff-protocol.md`
untouched since it is not sourced by any hook.** Rejected. The issue asks
for alignment across "docs, hooks, and gates" and explicitly says
"methodology docs" — this file's section 5 is exactly a loop_state-vocab
methodology section, already independently stale (pre-canon-rollout
kind/path names per the survey), and it is one of the only two places in
the repo that documents the phase-2 loop_state vocabulary in a named
list (`README.md` is the other). Skipping a doc because no hook reads it
would let the acceptance check's grep pass on `README.md` alone while
leaving a second, contradictory copy of the vocabulary on disk — the
"no stale or extra states" bar reads across the repo, not one file.

## What will be done

1. **`README.md`** — replace the "Record vocabulary" section's
   `proposed, approved, landed (+ findings-resolved)` list with the
   spec's five states (`coding, commit-unreachable, committing, landed,
   scope-undeclared`; terminal: `landed`), and add the four required
   fields (`commit_sha` — realized as `code_under_review:`, `type`,
   `breaking`, `verdict`) with one line each naming their rulebook home.
2. **`docs/specs/handoff-protocol.md`** section 5 — same vocabulary and
   field-list correction, plus updating the section's stale
   `docs/proposals/<date>-build-<slug>.md` / `docs/reports/records/
   <subject>/coding.md` path examples to the `docs/issue-<n>/proposals|
   reports/` layout already in force elsewhere in this doc set (in-scope
   because the section is being edited anyway; not a separate ask).
3. **`record-shape/hooks/directive.sh`** — extend the required-frontmatter
   description to name all four fields (`code_under_review:`/`commit_sha`,
   `type:`, `breaking:`, `verdict:`) alongside the existing
   `loop_state:`.
4. **`record-shape/README.md`** — mirror the same four-field list.
5. **`record-shape/hooks/record-shape-gate.sh`** — extend the frontmatter
   check (the block at line ~163) to also require `type:`, `breaking:`,
   `verdict:` keys present (presence-only, no value/enum validation, per
   Rationale), added to the existing `missing.append(...)` pattern and
   the deny message.
6. **`record-shape/hooks/tests/record-shape-tests.sh`** — add fixtures:
   one record missing each new key (denied), one record carrying all
   four (allowed), following the file's existing fixture shape.
7. **`coding/hooks/directive.sh`** — extend the `HAND_OFF` text's
   record-requirement clause to name the four required fields and the
   five-state vocabulary inline, so a fresh session sees it at
   SessionStart without opening `record-shape/`.

## Out of scope

- Mechanically enforcing the loop_state vocabulary as a closed enum
  (Rationale, above) — documentation-only for this issue.
- Renaming `code_under_review:` to `commit_sha:` (Rationale, above).
- Reworking `proposal-shape/` (phase-1 proposal shape) — the spec's four
  fields and five states are phase-2 (deliverable-record) concepts per
  the issue body; phase-1 proposal shape (issue-52's ADR skeleton) is
  untouched.
- Adding `verdict:`/`type:`/`breaking:` semantics anywhere outside the
  implementation role's own record — qa/review/verify's own record
  formats are out of this role's write scope per the handoff contract.
- Backfilling `type:`/`breaking:`/`verdict:` onto already-landed records
  under `docs/issue-<n>/reports/implementation.md` for n < 75 — those are
  historical and the gate only applies going forward.

## Empty-state note (acceptance criterion)

No spec field lacks a home: `commit_sha` maps onto the existing
`code_under_review:` key (equivalence documented, not renamed); `type`
and `breaking` are net-new frontmatter keys with no prior rulebook
analog (scout brief: Conventional Commits is the external precedent,
adopted as free-text `type:` and boolean `breaking:`); `verdict` is a
net-new key that gives the no-mock directive's existing "run it once,
state the outcome honestly" confirmation step (already required in prose
via the `<no-mock-directive>` hook) a named field to land in, satisfying
the acceptance's "unverifiable: no test suite present" phrasing as one
valid `verdict:` value among others (e.g. `pass`, `fail`, `unverifiable`).

## How you'll know it worked

- `grep -ri "commit_sha\|type\|breaking\|verdict" docs/ README.md` (per
  the issue's own acceptance check) returns hits in `README.md`,
  `docs/specs/handoff-protocol.md`, and (indirectly, once phase 2 lands a
  record using them) `docs/issue-75/reports/implementation.md`.
- The loop_state vocabulary documented in `README.md` and
  `docs/specs/handoff-protocol.md` reads exactly `coding,
  commit-unreachable, committing, landed, scope-undeclared` — no
  `proposed`/`approved`/`findings-resolved` left in either.
- `record-shape/hooks/tests/record-shape-tests.sh` passes with the new
  fixtures, and `tests/run-gate-tests.sh` continues to pass unchanged.
- No `.env.example` or dependency-manifest diff appears in the phase-2
  PR (confirms the "no new dep/env var" constraint held).
