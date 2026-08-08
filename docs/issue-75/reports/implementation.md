---
code_under_review:
  - README.md
  - docs/specs/handoff-protocol.md
  - record-shape/hooks/directive.sh
  - record-shape/README.md
  - record-shape/hooks/record-shape-gate.sh
  - record-shape/hooks/tests/record-shape-tests.sh
  - coding/hooks/directive.sh
type: docs
breaking: false
verdict: pass
loop_state: landed
---

# Implementation record — issue-75

## Summary of work

Applied the approved phase-1 proposal
(`docs/issue-75/proposals/2026-08-09-spec-field-loop-state-alignment.md`)
layering `implementation.spec.json`'s four deliverable fields
(`commit_sha`, `type`, `breaking`, `verdict`) and its five-state
`loop_state` vocabulary (`coding`, `commit-unreachable`, `committing`,
`landed`, `scope-undeclared`) onto the rulebook's docs, hooks, and gates,
across exactly the seven frozen write-set files:

- `README.md` — Record vocabulary section updated to the spec's five
  `loop_state` values (terminal: `landed`) and the four required fields,
  each with its rulebook home named (`commit_sha` = `code_under_review:`).
- `docs/specs/handoff-protocol.md` §5 — same vocabulary/field
  correction, plus the stale `docs/proposals/<date>-build-<slug>.md` /
  `docs/reports/records/<subject>/coding.md` path examples updated to
  the `docs/issue-<n>/proposals|reports/` layout used elsewhere.
- `record-shape/hooks/directive.sh` — required-frontmatter description
  now names all four fields alongside `loop_state:`.
- `record-shape/README.md` — mirrors the same four-field list.
- `record-shape/hooks/record-shape-gate.sh` — frontmatter check extended
  to also require `type:`, `breaking:`, `verdict:` keys present
  (presence-only, no enum/value validation), added to the existing
  `missing.append(...)` pattern and deny message.
- `record-shape/hooks/tests/record-shape-tests.sh` — new fixtures: one
  record missing each new key (denied), one record carrying all four
  (allowed).
- `coding/hooks/directive.sh` — `HAND_OFF` record-requirement clause now
  names the four fields and five-state vocabulary inline.

## Why

Basis: `docs/issue-75/proposals/2026-08-09-spec-field-loop-state-alignment.md`
(approved via issue comment `APPROVE issue-75/implementation`). The
proposal's Rationale section is authoritative for the three alternatives
considered and rejected (renaming `code_under_review:`, mechanically
enforcing the loop_state enum, skipping `handoff-protocol.md`) — not
repeated here.

## What did not work

None.

## Open findings

resolved_findings: docs/reports/2026-08-09-hunt-spec-field-loop-state-alignment.md
(before-landing hunt, stance 0). Finding: the gate's no-leading-`---`
branch fell back to scanning the entire document body as "frontmatter"
(contradicting its own comment, which already claimed an empty
frontmatter block for this case), so any prose with loose `key: value`
lines satisfied all five presence checks with no real YAML frontmatter
present — pre-existing hole, widened by this diff's three new keys.
Fixed in the same commit: `record-shape/hooks/record-shape-gate.sh`'s
else-branch now sets `frontmatter = ""` instead of `new_text`, matching
the comment's stated intent. Re-verified via
`record-shape/hooks/tests/record-shape-tests.sh` (18/18 pass, including
the pre-existing `missing-frontmatter-key` deny case) and
`tests/run-gate-tests.sh` (5/5 pass).

## Rationale for deviations

`tests/run-gate-tests.sh` (not in the frozen write set) required a
one-line fixture update: its own `GOOD` record-shape fixture predates the
`type:`/`breaking:`/`verdict:` frontmatter requirement added to
`record-shape/hooks/record-shape-gate.sh` in this same change, and would
otherwise deny where it previously allowed, failing the suite for a
reason unrelated to any real regression. Per the scope-exceeded rule this
is reported rather than silently absorbed: the edit adds the same three
frontmatter keys to that one fixture string, no behavior or assertion
logic changed.

## Next steps

None — `loop_state: landed` is terminal for this record. Ran
`record-shape/hooks/tests/record-shape-tests.sh` (18/18 pass) and
`tests/run-gate-tests.sh` (5/5 pass) before this commit.

## Open-finding resolution path

No open findings. Should one surface after merge, its resolution path is:
fix on a follow-up branch, append a `resolved_findings:` entry naming the
finder path and finder-record sha, then re-request the finder's
clearance before the next commit.
