---
subject: issue-75
role: implementation
---

# Survey — aligning rulebook with `implementation.spec.json`

`roles/specs/implementation.spec.json` (the on-the-record marketplace spec)
is not vendored into this repo — this is the rulebook repo, not the
consuming repo. The issue body states the spec facts directly:

- required fields: `commit_sha`, `type`, `breaking`, `verdict`
- `loop_state` vocabulary: `coding`, `commit-unreachable`, `committing`,
  `landed`, `scope-undeclared`

## Current state — required fields

- `code_under_review:` and `loop_state:` are the only two frontmatter keys
  mechanically required on `docs/issue-<n>/reports/implementation.md`, by
  `record-shape/hooks/record-shape-gate.sh:163-167`. `code_under_review:`
  is a commit sha in current practice (e.g.
  `docs/issue-70/reports/implementation.md`), i.e. it already plays the
  role the spec calls `commit_sha` — different name, same field.
- Nothing in this repo enforces or documents `type`, `breaking`, or
  `verdict`. `record-shape/README.md`, `record-shape/hooks/directive.sh`,
  and `coding/hooks/directive.sh`'s `HAND_OFF` text do not mention these
  three names at all (`grep -n "type:\|breaking:\|verdict:\|commit_sha"`
  across those files returns nothing).
- `verdict` already exists as a concept elsewhere on the board — a QA/
  verify record's own `loop_state` (`reproduced`/`cleared`) functions as a
  verdict for a finding (`coding/hooks/coding-progress-gate.sh:147-148`) —
  but the implementation role's own record carries no verdict field for
  its own honest-claims confirmation run (the no-mock directive's "build
  it, run it, run the tests you wrote, once" step currently has no
  written home).

## Current state — loop_state vocabulary

- `README.md:60` documents `loop_state: proposed, approved, landed (+
  findings-resolved per s15; terminal: landed)` under "Record vocabulary".
  This describes the phase-1→phase-2 *lifecycle* of a proposal/record pair
  (drafted → human-approved → shipped), not the spec's five states, which
  read as *execution* states inside phase 2 itself (`coding` = mid-build,
  `committing`/`commit-unreachable` = around the commit step,
  `scope-undeclared` = write-set not frozen, `landed` = terminal).
- `docs/specs/handoff-protocol.md` section 5 ("Blackboard record spec")
  independently documents `loop_state` vocabulary `proposed, approved,
  landed` for a `build-proposal`/`coding-record` kind pair, using path
  conventions (`docs/proposals/<date>-build-<slug>.md`,
  `docs/reports/records/<subject>/coding.md`) that predate the
  `docs/issue-<n>/proposals|reports/` layout used everywhere else in this
  repo (issue-53's canon rollout already moved live practice off these
  paths without updating this file). This file is not sourced by any hook
  (`grep -rl "handoff-protocol"` over `*.sh`/`*.json` is empty) — it is a
  standalone methodology doc, already stale independent of issue-75, and
  in scope here because it is exactly a "methodology doc" carrying
  `loop_state` vocabulary per the issue's instruction.
- No hook or doc in this repo currently states the five-state execution
  vocabulary (`coding, commit-unreachable, committing, landed,
  scope-undeclared`) anywhere. `record-shape-gate.sh` checks only that
  *some* `loop_state:` key exists — it does not validate the value against
  any enumerated set, so adding the vocabulary to a doc does not by itself
  require a gate change to stay consistent (the gate would need a new
  regex/enum check only if we want it *mechanically* enforced — see
  proposal Constraints/Out-of-scope).

## Write surfaces this touches (frozen in the proposal)

- `README.md` — "Record vocabulary" section (loop_state vocab + field
  list)
- `docs/specs/handoff-protocol.md` — section 5 (loop_state vocab + field
  list, stale kind/path names corrected to current canon in the same
  edit since the section is being touched anyway)
- `record-shape/hooks/directive.sh` — required-field list in the directive
  text
- `record-shape/README.md` — required-field list
- `record-shape/hooks/record-shape-gate.sh` — mechanical checks extended
  to require `type:`, `breaking:`, `verdict:` frontmatter keys (in
  addition to already-required `code_under_review:`/`loop_state:`);
  `record-shape/hooks/tests/record-shape-tests.sh` gains fixtures for the
  new required keys
- `coding/hooks/directive.sh` — `HAND_OFF` text, one clause naming the
  four required fields and the five-state vocabulary

No new dependency, no new env var, no migration. Pure-docs+one-gate-script
change; no `.env.example`/manifest touch needed.

## Scout-skip note

Not applicable — scouting ran (see
`docs/issue-75/reports/implementation/scout-brief.md`); this is not a
skip.
