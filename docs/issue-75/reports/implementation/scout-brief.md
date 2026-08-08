---
subject: issue-75
role: implementation
---

# Scout brief — issue-75

Mode: batched-sequential (single-session WebSearch calls; no parallel
subagent fan-out — one narrow naming question, not a multi-angle field).
1 sweep stage, 1 judge point, no deepening needed (saturated on the first
pass: the two field names in question map onto one well-established
external convention each).

## Must-bes found

- `type` and `breaking` (as change-classification fields) map directly
  onto Conventional Commits' `type` prefix (`feat`, `fix`, ...) and its
  `!`/`BREAKING CHANGE:` breaking-change marker — the dominant external
  convention for exactly this pair of concepts. Conventional Commits
  requires only the header type; breaking-change marking is optional but
  structurally always a boolean-shaped signal (marker present or absent),
  which is what `breaking:` as a frontmatter key should be — a boolean,
  not free text.
- `verdict` is not a Conventional Commits concept; it belongs to the
  review/CI-status family (a PR review state, a CI job's pass/fail/
  unverifiable result). No single external doc-convention was found that
  names a `verdict` field on a *build* record specifically — this repo's
  own no-mock "honest claims" step (run it once, state the outcome) is
  the closest existing internal must-be, already load-bearing via the
  `<no-mock-directive>` hook text, just not yet written to a named field.

## Adopt / skip

- Adopt: treat `breaking` as boolean (`true`/`false`), matching
  Conventional Commits' binary marker, not a free-text field.
- Adopt: treat `type` as a short enumerated-ish string (free text
  acceptable, mirroring Conventional Commits' open type list rather than
  inventing a closed enum this repo would have to maintain).
- Skip: importing Conventional Commits' full type enum (`feat`, `fix`,
  `chore`, `refactor`, ...) as a mechanically-enforced closed list — this
  repo's records span docs-only and mixed-kind commits (see
  `docs/issue-70`, `docs/issue-52`) that don't cleanly bucket into that
  vocabulary; enforcing presence, not enumerated value, per proposal's
  Rationale.

## Gap line

The rulebook already meets the `commit_sha` must-be (via
`code_under_review:`) and has an unwritten analog for `verdict` (the
no-mock confirmation-run step). It has no existing analog at all for
`type` or `breaking` — those are net-new fields with no prior partial
implementation to strengthen.

## Segment fit

One line: this is a methodology-doc/gate change, not a product surface —
scout depth is intentionally shallow (naming-convention lookup only), per
the scout directive's category-appropriate-depth guidance for non-product
roles.

Sources:
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
